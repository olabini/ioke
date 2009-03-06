use("iopt")

ISpec do(
  Options = Origin mimic do(
    create = method(err, out,
      self with(errorStream: err, outStream: out, formatters: [], files: [], directories: []))
      
    runExamples = method(
      files each(f, use(f))
      directories each(d,
        FileSystem["#{d}/**/*_spec.ik"] each(f, use(f)))

      reporter = ISpec Reporter create(self)

      reporter start(0)
      success = true
      ISpec specifications each(n,
        insideSuccess = n run(reporter)
        if(success, success = insideSuccess))

      reporter end
      reporter dump
      success
    )
  )
  
  Runner = Origin mimic do(
    registerAtExitHook = method(
      System atExit(
        unless((ISpec didRun?) || !(ISpec shouldRun?),
          success = ISpec run
          if(ISpec shouldExit?,
            System exit(success))))
      ISpec Runner registerAtExitHook = nil
    )

    CommandLine = Origin mimic do(
      run = method(instance_ispec_options,
        result = instance_ispec_options runExamples
        ISpec didRun? = true
        result
      )
    )

    OptionParser = IOpt mimic do(
      create = method(err, out,
        newOP = self mimic
        newOP errorStream = err
        newOP outStream = out
        newOP options = ISpec Options create(newOP errorStream, newOP outStream)
        newOP)

      formatters = dict(
        specdoc: ISpec Formatter SpecDocFormatter,
        progress: ISpec Formatter ProgressBarFormatter)
      formatters[:s] = formatters[:specdoc]
      formatters[:p] = formatters[:progress]

      banner = "Usage: ispec (FILE|DIRECTORY|GLOB)+ [options]"

      on["-f", "--format"] = method("Specifies what format to use for output", format,
        fkind = formatters[:(format)]
        unless(fkind, error!("Unknown output format: #{format}"))
        options formatters << fkind mimic)

      on["-h", "--help"] = method("Display usage", @println. System exit(0))
      on["-h"] priority = -10 ; handle it before other options when present

      order! = method(argv,
        @argv = argv
        parse!(argv)
        
        ;; check if any formatter was set, or use a default.
        if(options formatters empty?,
          options formatters << formatters[:progress] mimic)

        ;; process non option arguments
        programArguments each(arg,
          if(FileSystem directory?(arg),
              options directories << arg,
              options files << arg))

        options)
    )
  )

  runTest = method(
    "runs a specific test in the given describe context",
    context, name, code, reporter,

    newContext = context mimic
    newContext fullDescription = "#{newContext fullName} #{name}"
    newContext description = name
    newContext code = code

    executionError = nil

    reporter exampleStarted(newContext)

    bind(
      rescue(Ground Condition Error, 
        fn(c, executionError ||= c)),
      rescue(ISpec Condition, 
        fn(c, executionError ||= c)),
      handle(Ground Condition,  
        fn(c, c describeContext = newContext. if(c cell?(:shouldMessage), newContext shouldMessage = c shouldMessage))),
      if(code, 
        ;; don't evaluate directly, instead send it to a macro on the newContext, which can give it a real back trace context
        code evaluateOn(newContext, newContext),

        error!(ISpec ExamplePending, text: "Not Yet Implemented")))

    reporter exampleFinished(newContext, executionError)

    (executionError nil?) || (executionError mimics?(ExamplePending))
  )

  didRun? = false

  run = method(
    "runs all the defined descriptions and specs",

    if(didRun?, return(true))
    result = ispec_options runExamples
    self didRun? = true
    result)

)
