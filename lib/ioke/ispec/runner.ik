
ISpec do(
  Options = Origin mimic do(
    create = method(err, out,
      self with(errorStream: err, outStream: out, formatters: [], files: [], directories: [], hasFormat?: false, hasHelp?: false, missingFiles: [], unknownOptions: []))
      
    shouldRun? = method(
      !hasHelp? && missingFiles empty? && unknownOptions empty? )
    
    parse! = method(
      argv each(arg,
        case(arg,
          or("-h", "--help"), self hasHelp? = true,
          "-fp", formatters << ISpec Formatter ProgressBarFormatter mimic,
          "-fs", formatters << ISpec Formatter SpecDocFormatter mimic,
          fn(file, FileSystem file?(file)), files << arg,
          fn(dir, FileSystem directory?(dir)), directories << arg,
          #/^-/, unknownOptions << arg,
          missingFiles << arg))
      if(formatters empty?,
        formatters << ISpec Formatter ProgressBarFormatter mimic)
    )

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
        unless((ISpec didRun?) || !(ISpec ispec_options shouldRun?),
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

    OptionParser = Origin mimic do(
      create = method(err, out,
        newOP = self mimic
        newOP errorStream = err
        newOP outStream = out
        newOP options = ISpec Options create(newOP errorStream, newOP outStream)
        newOP banner = "Usage: ispec (FILE|DIRECTORY|GLOB)+ [options]
  -fp show output as progress bar (default)
  -fs show output as spec doc"
        newOP)

      order! = method(argv,
        @argv = argv
        options argv = argv mimic
        options parse!
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
  shouldExit? = true

  run = method(
    "runs all the defined descriptions and specs",

    if(didRun?, return(true))
    if(ispec_options shouldRun?,
      result = ispec_options runExamples
      self didRun? = true
      result,
      ispec_options banner println))
)
