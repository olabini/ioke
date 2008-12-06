
Affirm do(
  Reporter = Origin mimic
  Reporter do(
    mimic!(Affirm TextFormatter)

    SpecDocReporter = Affirm Reporter mimic

    ProgressBarReporter = Affirm Reporter mimic do(
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
