
Affirm = Origin mimic do(
  ShouldContext = Origin mimic
  ShouldContext __mimic__ = Origin cell(:mimic)

  NotShouldContext = ShouldContext __mimic__

  ShouldContext create = method(value,
    newSelf = self __mimic__
    newSelf realValue = value
    newSelf)

  ShouldContext be = method("fluff word", self)
  ShouldContext have = method("fluff word", self)

  ShouldContext pass = macro(
    realName = call message name
    msg = call message deepCopy
    msg name = "#{realName}?"
    unless(msg sendTo(self realValue),
      error!("expected: #{realValue} #{msg code} to be true")))

  NotShouldContext pass = macro(
    realName = call message name
    msg = call message deepCopy
    msg name = "#{realName}?"
    if(msg sendTo(self realValue),
      error!("expected: #{realValue} #{msg code} to be false")))

  NotShouldContext create = method(former,
    newSelf = self __mimic__
    newSelf outsideShouldContext = former
    newSelf realValue = former realValue
    newSelf)

  ShouldContext == = method(value,
    unless(realValue == value,
      error!("expected: #{value inspect} to == #{realValue inspect}")))

  NotShouldContext == = method(value,
    if(realValue == value,
      error!("expected: #{value inspect} to not == #{realValue inspect}")))

  ShouldContext mimic = method(value,
    unless(realValue mimics?(value),
      error!("expected: #{realValue inspect} to mimic #{value kind}")))

  NotShouldContext mimic = method(value,
    if(realValue mimics?(value),
      error!("expected: #{realValue inspect} to not mimic #{value kind}")))

  ShouldContext not = method(
    "inverts the expected matching",
    Affirm NotShouldContext create(self))

  should = method(
    "the base of the whole matching of Affirm",
    Affirm ShouldContext create(self)
  )

  runTest = method(
    "runs a specific test in the given describe context",
    context, name, code,

    newContext = context mimic
    code evaluateOn(newContext, newContext)
    "SUCCEEDED: #{newContext fullName} #{name}" println
  )

  runPending = method(
    "adds a new test as pending",
    context, name, 
    
    "PENDING:   #{context fullName} #{name}" println)

  run = method(
    "runs all the defined descriptions and specs",
    specifications each(n,
      n run))

  DescribeContext = Origin mimic do(
    create = method(
      newSelf = mimic
      newSelf specs = []
      newSelf)

    fullName = method(
      "returns the name of this context, prepended with the surrounding names",
      if(cell?(:surrounding),
        "#{surrounding fullName} #{describesWhat}",
        describesWhat))

    run = method(
      "runs all the defined descriptions and specs",
      specs each(n,
        if(n first == :description,
          n second run,
          if(n first == :test,
            Affirm runTest(self, n second, n third),
            Affirm runPending(self, n second)))))

    it = macro(
      "takes one text argument, and one optional code argument. if the code argument is left out, this spec will be marked as pending",
      if(call arguments length == 1,
        self specs << [:pending, call argAt(0)],
        self specs << [:test, call argAt(0), call arguments second])
    )
  )

  specifications = []

  describe = macro(
    "takes one evaluated argument that describes what is being tested. if it's not a Text, the kind will be used in the description. the second argument should be code that will be evaluated inside a DescriptionContext, where you can use either 'describe' or 'it'.",

    describesWhat = call argAt(0)
    unless(describesWhat mimics?(Text), describesWhat = describesWhat kind)
    
    context = Affirm DescribeContext create
    context describesWhat = describesWhat

    if(self mimics?(Affirm DescribeContext),
      context surrounding = self)

    call arguments second evaluateOn(context, context)

    if(self mimics?(Affirm DescribeContext),
      self specs << [:description, context],
      Affirm specifications << context)

))

DefaultBehavior describe = Affirm cell(:describe)
DefaultBehavior should   = Affirm cell(:should)
