
Affirm do(
  Formatter = Origin mimic

  Formatter do(
    TextFormatter = Affirm Formatter mimic do(
      start = method(exampleCount, @pendingExamples = [])

      examplePending = method(example, message,
        pendingExamples << [example fullDescription, message]
      )

      dumpFailure = method(counter, failure, 
        "" println
        "#{counter})" println
        red("#{failure header}") println
        red("#{failure condition text}") println
        "  #{failure condition describeContext stackTraceAsText}" println)

      dumpSummary = method(duration, exampleCount, failureCount, pendingCount,
        "" println
        "Finished in #{duration} seconds" println
        "" println

        summary = "#{exampleCount} example#{if(exampleCount == 1, "", "s")}, " 
        summary += "#{failureCount} failure#{if(failureCount == 1, "", "s")}" 
        if(pendingCount > 0,
          summary += ", #{pendingCount} pending")
        
        if(failureCount == 0,
          if(pendingCount > 0,
            yellow(summary) println,
            green(summary) println),
          red(summary) println))
      
      dumpPending = method(
        unless(pendingExamples empty?,
          "" println
          "Pending:" println
          pendingExamples each(pe,
            "#{pe[0]} (#{pe[1]})" println)))

      colour = method(
        "outputs text with colour if possible",
        text, colour_code,

        "#{colour_code}#{text}\e[0m")

      green   = method(text, colour(text, "\e[32m"))
      red     = method(text, colour(text, "\e[31m"))
      magenta = method(text, colour(text, "\e[35m"))
      yellow  = method(text, colour(text, "\e[33m"))
      blue    = method(text, colour(text, "\e[34m"))
    )

    SpecDocFormatter = Affirm Formatter TextFormatter mimic do(
      addExampleGroup = method(exampleGroup, 
        super(exampleGroup)
        "" println
        exampleGroup fullName println)

      exampleFailed = method(example, counter, failure,
        red("- #{example description} (FAILED - #{counter})") println
      )

      examplePassed = method(example,
        green("- #{example description}") println
      )

      examplePending = method(example, message,
        super(example, message)
        yellow("- #{example description} (PENDING: #{message})") println
      )
    )

    ProgressBarFormatter = Affirm Formatter TextFormatter mimic do(
      exampleFailed = method(example, counter, failure,
        red("F") print
      )

      examplePassed = method(example, 
        green(".") print
      )

      examplePending = method(example, message, 
        super(example, message)
        yellow("P") print
      )

      startDump      = method("" println)
      pass           = method(+rest, +:krest, nil) ;ignore other methods
    )

    addExampleGroup = method(exampleGroup, @exampleGroup = exampleGroup)
    start           = method(exampleCount, nil)
    exampleStarted  = method(example, nil)
    exampleFailed   = method(example, counter, failure, nil)
    examplePassed   = method(example, nil)
    examplePending  = method(example, message, nil)
    startDump       = method()
    dumpFailure     = method(counter, failure, nil)
    dumpSummary     = method(duration, exampleCount, failureCount, pendingCount, nil)
    dumpPending     = method(nil)
    close           = method(nil)
  )
)
