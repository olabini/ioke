use("iopt")

ISpec do(
  Options = Origin mimic do(
    
    create = method(err, out,
      self with(errorStream: err, outStream: out, 
        formatters: [], files: [], directories: [],
        loadPatterns: [], onlyMatching: [], onlyLines: [],
        missingFiles: [], useColour: true, hasHelp?: false))

    order = method(
      ;; if not given files nor directories
      if(files empty? && directories empty?, 
        if(FileSystem directory?("spec"), 
          directories << "spec", 
          if(FileSystem directory?("test"),
            directories << "test")))
      
      ;; check if any pattern was set or use a default
      if(loadPatterns empty?,
        loadPatterns << "**/*_spec.ik")
      
      ;; check if any formatter was set, or use a default.
      if(formatters empty?,
        formatters << ISpec Formatter ProgressBarFormatter mimic)
      
      unless(useColour, 
        formatters each(colour = method(text, +rest, text)))
      
      self)

    specsToRun = dict() do(
      values = list()
      cell("[]=") = method(key, value, 
        super(key, value)
        values << value
        value)
    )
  
    exampleAdded = method(context,
      example = context specs last
      if(!onlyLines empty? && example third kind?("Message"),
        lines = (example third first line .. example third last line)
        if(onlyLines any?(o, lines include?(o)),
          specsToRun[context fullName] ||= context with(specs: list())
          specsToRun[context fullName] specs << example)
      )
      unless(onlyMatching empty?,
        exampleDesc = "#{context fullName} #{example second}"
        if(onlyMatching any?(o, o === exampleDesc),
          specsToRun[context fullName] ||= context with(specs: list())
          specsToRun[context fullName] specs << example)
      )
    )
      
    runExamples = method(
      files each(f, use(f))
      directories each(d,
        FileSystem["#{d}/{#{loadPatterns join(",")}}"] each(f, use(f)))

      reporter = ISpec Reporter create(self)

      reporter start(0)
      success = true

      specifications = if(specsToRun empty?,  ISpec specifications, specsToRun values)
      specifications each(n,
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

      on("-h", "--help", "Display usage.", @options hasHelp? = true)

      on("-f", "--format", format, to: System out,
        fkind = formatters[:(format)]
        unless(fkind, 
          fkind = Message fromText(format) sendTo(Ground)
          unless(fkind mimics?(ISpec Formatter), 
            error!("Expected #{format} to mimic ISpec Formatter")))
        formatter = fkind mimic
        case(to,
          or("-", System out), nil,
          formatter output = java:io:PrintStream new(to))
        @options formatters << formatter
      ) do (
        cell(:documentation) = method(
          doc = list("Specify the output format to use.")
          doc << "Use the to: keyword argument to tell where to write output,"
          doc << "if given \"-\" will write to standard output."
          doc << "e.g."
          doc << "     --format specdoc to: specOut.txt"
          doc << " "
          formats = dict()
          receiver formatters each(pair, 
            if(formats key?(pair value),
              formats[pair value] << pair key,
              formats[pair value] = list(pair key)))
          doc << "Builtin formats:"
          formats each(pair,
            doc << "%-20s %s" format(pair value sort join("|"),
              pair key documentation || pair key kind))
                              
          doc << " "
          doc << "When not given a builtin format, ISpec will try to evaluate"
          doc << "the given argument to an ISpec Formatter kind"
          doc join("\n"))
      ); --format

      on("-p", "--pattern", "Limit files loaded to those matching pattern.",
        "Defaults to **/*_spec.ik.", pattern,
        @options loadPatterns << pattern)

      on("-c", "--color", "--colour", "Use colored output.", boolean true,
        @options useColour = boolean)

      on("-e", "--example", "Only execute examples marching name",
        "or if given a file, those listed in it", name_or_file,
        if(FileSystem file?(name_or_file),
          @options onlyMatching += FileSystem readFully(name_or_file) split("\n"),
          @options onlyMatching << name_or_file))

      on("-l", "--line", "Only execute examples defined at line_number", line_number,
        @options onlyLines << line_number)

      order = method(argv,
        parse!(argv)
        
        ;; process non option arguments
        programArguments each(arg,
          if(FileSystem directory?(arg),
            options directories << arg,
            if(FileSystem file?(arg),
              options files << arg,
              options missingFiles << arg)))

        options do( order ))
      
      order! = method(argv,
        order(argv)
        if(options hasHelp?, outStream println(self). System exit(0))
        unless(options missingFiles empty?,
          error!("Missing files: #{options missingFiles join(", ")}"))
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
  shouldRun? = true

  run = method(
    "runs all the defined descriptions and specs",

    if(didRun?, return(true))
    result = ispec_options runExamples
    self didRun? = true
    result)

)
