Affirm do(
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
      rescue(Ground Condition, 
        fn(c, executionError ||= c. "gah: got: #{c}")),
      handle(Affirm Condition, 
        fn(c, c describeContext = newContext)),
      if(code, 
        ;; don't evaluate directly, instead send it to a macro on the newContext, which can give it a real back trace context
        code evaluateOn(newContext, newContext),

        error!(Affirm ExamplePending, text: "Not Yet Implemented")))

    reporter exampleFinished(newContext, executionError)

    (executionError nil?) || (executionError mimics?(ExamplePending))
  )

  run = method(
    "runs all the defined descriptions and specs",

    options = Origin with(formatters: [Formatter ProgressBarFormatter mimic])
    reporter = Reporter create(options)

    reporter start(0)
    success = true
    specifications each(n,
      insideSuccess = n run(reporter)
      if(success, success = insideSuccess))

    reporter end
    reporter dump
    success
  )
)
