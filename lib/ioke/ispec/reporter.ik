
ISpec do(
  Reporter = Origin mimic
  Reporter do(
    Failure = Origin mimic do(
      create = method(example, condition,
        newFailure = self mimic
        newFailure example = example
        newFailure condition = condition
        newFailure)

      header = method(
        if(expectationNotMet?,
          "'#{example fullDescription}' FAILED",
          "#{condition kind} in '#{example fullDescription}'"))

      expectationNotMet? = method(condition mimics?(ISpec ExpectationNotMet))
    )

    Exhaustion = Origin mimic do(
      create = method(example, result,
        newFailure = self mimic
        newFailure example = example
        newFailure result = result
        newFailure)

      header = method(
        "'#{example fullDescription}' EXHAUSTED"
      )
    )

    create = method(options,
      newReporter = self mimic
      newReporter options = options
      newReporter clear!
      newReporter)

    clear! = method(
      @exampleGroups = []
      @failures = []
      @pendingCount = 0
      @examples = []
      @startTime = nil
      @endTime = nil
    )

    formatters = method(options formatters)

    addExampleGroup = method(exampleGroup,
      formatters each( addExampleGroup(exampleGroup) )
      exampleGroups << exampleGroup)

    exampleStarted = method(example,
      formatters each( exampleStarted(example) ))

    propertyExampleStarted = method(example,
      formatters each( propertyExampleStarted(example) ))

    exampleFinished = method(example, error nil,
      examples << example
      if(error nil?,
        examplePassed(example),
        if(error mimics?(ISpec ExamplePending),
          examplePending(example, error text),
          exampleFailed(example, error))))

    propertyExampleFinished = method(example, error, result,
      examples << example
      if(error nil?,
        if(result exhausted?,
          propertyExampleExhausted(example, result),
          propertyExamplePassed(example, result)),
        propertyExampleFailed(example, error, result)))

    failure = method(example, error,
      failure = Failure create(example, error)
      failures << failure
      formatters each(exampleFailed(example, failures length, failure)))

    aliasMethod("failure", "exampleFailed")

    propertyExampleFailed = method(example, error, result,
      failure = Failure create(example, error)
      failures << failure
      formatters each(propertyExampleFailed(example, failures length, failure, result)))

    start = method(numberOfExamples,
      clear!
      @startTime = DateTime now
      formatters each(start(numberOfExamples)))

    end = method(
      @endTime = DateTime now)

    dump = method(
      formatters each(startDump)
      dumpPending
      dumpFailures
      formatters each(f,
        f dumpSummary(duration, examples length, failures length, pendingCount)
        f close)

      failures length)

    dumpFailures = method(
      if(failures empty?, return)

      failures inject(1, index, failure,
        formatters each(dumpFailure(index, failure))
        index + 1))

    dumpPending = method(formatters each(dumpPending))

    examplePassed = method(example, formatters each(examplePassed(example)))
    propertyExamplePassed = method(example, result, formatters each(propertyExamplePassed(example, result)))
    propertyExampleExhausted = method(example, result, 
      failure = Exhaustion create(example, result)
      failures << failure
      formatters each(propertyExampleExhausted(example, failures length, result)))

    examplePending = method(example, message,
      if(message nil?,
        message = "Not Yet Implemented")
      @pendingCount += 1
      formatters each(examplePending(example, message)))

    duration = method(
      if((startTime nil?) || (endTime nil?),
        "0.0",
        val = endTime - startTime
        after = val%1000
        before = (val - after)/1000
        "#{before}.#{after}"))
  )
)
