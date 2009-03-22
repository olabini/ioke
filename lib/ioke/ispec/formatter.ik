
ISpec do(
  Formatter = Origin mimic

  Formatter do(
    TextFormatter = ISpec Formatter mimic do(
      start = method(exampleCount, @pendingExamples = [])

      examplePending = method(example, message,
        pendingExamples << [example fullDescription, message]
      )

      dumpFailure = method(counter, failure, 
        println("")
        println("#{counter})")
        println(red("#{failure header}"))
        println(red("#{failure condition report}"))
        println("  #{failure condition describeContext stackTraceAsText}"))

      dumpSummary = method(duration, exampleCount, failureCount, pendingCount,
        println("")
        println("Finished in #{duration} seconds")
        println("")

        summary = "#{exampleCount} example#{if(exampleCount == 1, "", "s")}, " 
        summary += "#{failureCount} failure#{if(failureCount == 1, "", "s")}" 
        if(pendingCount > 0,
          summary += ", #{pendingCount} pending")
        
        if(failureCount == 0,
          if(pendingCount > 0,
            println(yellow(summary)),
            println(green(summary))),
          println(red(summary))))
      
      dumpPending = method(
        unless(pendingExamples empty?,
          println("")
          println("Pending:")
          pendingExamples each(pe,
            println("#{pe[0]} (#{pe[1]})"))))

      colour = method(
        "outputs text with colour if possible",
        text, colour_code,
        
        if(System windows?,
          text,
          "#{colour_code}#{text}\e[0m"))

      green   = method(text, colour(text, "\e[32m"))
      red     = method(text, colour(text, "\e[31m"))
      magenta = method(text, colour(text, "\e[35m"))
      yellow  = method(text, colour(text, "\e[33m"))
      blue    = method(text, colour(text, "\e[34m"))
    )

    SpecDocFormatter = ISpec Formatter TextFormatter mimic do(
      addExampleGroup = method(exampleGroup, 
        super(exampleGroup)
        println("")
        println(exampleGroup fullName))

      exampleFailed = method(example, counter, failure,
        println(red("- #{example description} (FAILED - #{counter})"))
      )

      examplePassed = method(example,
        println(green("- #{example description}"))
      )

      examplePending = method(example, message,
        super(example, message)
        println(yellow("- #{example description} (PENDING: #{message})"))
      )
    )

    ProgressBarFormatter = ISpec Formatter TextFormatter mimic do(
      exampleFailed = method(example, counter, failure,
        print(red("F"))
      )

      examplePassed = method(example, 
        print(green("."))
      )

      examplePending = method(example, message, 
        super(example, message)
        print(yellow("P"))
      )

      startDump      = method(println(""))
      pass           = method(+rest, +:krest, nil) ;ignore other methods
    )

    addExampleGroup = method(exampleGroup, @exampleGroup = exampleGroup)
    start           = method(exampleCount, nil)
    exampleStarted  = method(example, nil)
    exampleFailed   = method(example, counter, failure, nil)
    examplePassed   = method(example, nil)
    examplePending  = method(example, message, nil)
    dumpFailure     = method(counter, failure, nil)
    dumpSummary     = method(duration, exampleCount, failureCount, pendingCount, nil)
    dumpPending     = method(nil)
    startDump       = method(nil)
    output          = System out mimic do(close = nil)
    close           = method(output close)
    println         = method(a, output println(a))
    print           = method(a, output print(a))
  )
)
