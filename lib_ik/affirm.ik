
; new structure
;  Affirm Reporter
;  Affirm SpecRunner
;  Affirm Collector

Affirm = Origin mimic

use("affirm/textFormatter")
use("affirm/reporter")
use("affirm/expectations")
use("affirm/extendedDefaultBehavior")
use("affirm/describeContext")

Affirm do(
  Condition = Ground Condition mimic
  Condition ExpectationNotMet = Condition mimic
  Condition ExpectationPending = Condition mimic
  Condition UnhandledErrorCondition = Condition mimic

  runTest = method(
    "runs a specific test in the given describe context",
    context, name, code, reporter,

    newContext = context mimic
    bind(
      rescue(Affirm Condition ExpectationNotMet, 
        fn(c, reporter exampleFailed("#{newContext fullName} #{name}", 0, c))),

      reporter exampleStarted("#{newContext fullName} #{name}")
      code evaluateOn(newContext, newContext)
      reporter examplePassed("#{newContext fullName} #{name}"))
  )

  runPending = method(
    "adds a new test as pending",
    context, name, reporter,
    
    reporter examplePending("#{context fullName} #{name}", nil))

  run = method(
    "runs all the defined descriptions and specs",
    
    reporter = Reporter ProgressBarReporter mimic
    reporter start(0)

    specifications each(n,
      n run(reporter))

    reporter startDump
    reporter close
  )

  specifications = []
)

DefaultBehavior mimic!(Affirm ExtendedDefaultBehavior)
