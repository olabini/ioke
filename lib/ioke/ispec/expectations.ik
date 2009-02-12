
ISpec do(
  ShouldContext = Origin mimic
  ShouldContext __mimic__ = Origin cell(:mimic)

  NotShouldContext = ShouldContext __mimic__

  ShouldContext inspect = "ISpec ShouldContext"
  ShouldContext notice  = "ISpec ShouldContext"
  NotShouldContext inspect = "ISpec NotShouldContext"
  NotShouldContext notice  = "ISpec NotShouldContext"

  ShouldContext create = method(value, shouldMessage,
    newSelf = self __mimic__
    newSelf realValue = cell(:value)
    newSelf shouldMessage = shouldMessage
    newSelf)

  ShouldContext be = method("fluff word", self)
  ShouldContext have = method("fluff word", self)

  ShouldContext pass = macro(
    realName = call message name
    msg = call message deepCopy
    msg name = "#{realName}?"
    unless(msg sendTo(self cell(:realValue), call ground),
      error!(ISpec ExpectationNotMet, text: "expected #{realValue} #{msg code} to be true", shouldMessage: self shouldMessage)))

  ShouldContext == = method(value,
    unless(realValue == value,
      if(realValue kind == "List" && value kind == "List",
        error!(ISpec ExpectationNotMet, text: "expected #{realValue inspect} to == #{value inspect}. difference: #{(realValue - value) inspect}. #{realValue length} vs #{value length}", shouldMessage: self shouldMessage),
        error!(ISpec ExpectationNotMet, text: "expected #{realValue inspect} to == #{value inspect}", shouldMessage: self shouldMessage))))

  ShouldContext close = method(value, epsilon 0.0001,
    unless(((realValue - value) < epsilon) && ((realValue - value) > -epsilon),
      error!(ISpec ExpectationNotMet, text: "expected #{realValue inspect} to be close to #{value inspect}", shouldMessage: self shouldMessage)))

  ShouldContext === = method(value,
    unless(realValue === value,
      error!(ISpec ExpectationNotMet, text: "expected #{realValue inspect} to === #{value inspect}", shouldMessage: self shouldMessage)))

  ShouldContext match = method(regex,
    unless(regex =~ realValue,
      error!(ISpec ExpectationNotMet, text: "expected #{realValue inspect} to match #{regex inspect}", shouldMessage: self shouldMessage)))

  ShouldContext checkReceiverTypeOn = method(name, +args, +:keywordArgs,
    x = Origin mimic
    x cell(name) = self cell(:realValue) cell(name)
    fn(x send(name, *args, *keywordArgs)) should signal(Condition Error Type IncorrectType)
  )

  ShouldContext signal = method(condition,
    signalled = "none"
    bind(
      rescue(Ground Condition Error, fn(c, signalled = c)),
      rescue(condition, fn(c, signalled = c)),
      realValue call)

    unless(signalled mimics?(condition),
      error!(ISpec ExpectationNotMet, text: "expected #{condition} to be signalled in #{realValue code} - got #{signalled}", shouldMessage: self shouldMessage)))

  ShouldContext offer = method(theRestart,
    rst = Ground nil
    bind(
      rescue(Ground Condition, fn(c, Ground nil)),
      handle(Ground Condition, fn(c, rst = findRestart(theRestart name))),
      realValue call)

    unless(rst name == theRestart name,
      error!(ISpec ExpectationNotMet, text: "expected a restart with name #{theRestart name} to be offered", shouldMessage: self shouldMessage)))

  ShouldContext returnFromRestart = method(+args,
    retVal = bind(
      handle(Ground Condition, fn(c, invokeRestart(*args))),
      realValue call)
    self realValue = retVal
    self
  )

  ShouldContext mimic = method(value,
    unless(realValue mimics?(value),
      error!(ISpec ExpectationNotMet, text: "expected #{realValue inspect} to mimic #{value kind}", shouldMessage: self shouldMessage)))

  ShouldContext kind = method(value nil,
    if(value nil?,
      "ISpec ShouldContext",
      unless(realValue kind?(value),
        error!(ISpec ExpectationNotMet, text: "expected #{realValue inspect} to be kind #{value kind}", shouldMessage: self shouldMessage))))

  ShouldContext true = method(
    unless(Ground true == realValue,
      error!(ISpec ExpectationNotMet, text: "expected #{realValue inspect} to be true", shouldMessage: self shouldMessage)))

  ShouldContext false = method(
    unless(Ground false == realValue,
      error!(ISpec ExpectationNotMet, text: "expected #{realValue inspect} to be false", shouldMessage: self shouldMessage)))

  ShouldContext nil = method(
    unless(Ground nil == realValue,
      error!(ISpec ExpectationNotMet, text: "expected #{realValue inspect} to be nil", shouldMessage: self shouldMessage)))

  ShouldContext not = method(
    "inverts the expected matching",
    ISpec NotShouldContext create(self))

  NotShouldContext pass = macro(
    realName = call message name
    msg = call message deepCopy
    msg name = "#{realName}?"
    if(msg sendTo(self realValue, call ground),
      error!(ISpec ExpectationNotMet, text: "expected #{realValue} #{msg code} to be false", shouldMessage: self shouldMessage)))

  NotShouldContext create = method(former,
    newSelf = self __mimic__
    newSelf outsideShouldContext = former
    newSelf realValue = former realValue
    newSelf shouldMessage = former shouldMessage
    newSelf)

  NotShouldContext == = method(value,
    if(realValue == value,
      error!(ISpec ExpectationNotMet, text: "expected #{realValue inspect} to not == #{value inspect}", shouldMessage: self shouldMessage)))

  NotShouldContext close = method(value, epsilon 0.0001,
    if(((realValue - value) < epsilon) && ((realValue - value) > -epsilon),
      error!(ISpec ExpectationNotMet, text: "expected #{realValue inspect} to not be close to #{value inspect}", shouldMessage: self shouldMessage)))

  NotShouldContext === = method(value,
    if(realValue === value,
      error!(ISpec ExpectationNotMet, text: "expected #{realValue inspect} to not === #{value inspect}", shouldMessage: self shouldMessage)))

  NotShouldContext match = method(regex,
    if(regex =~ realValue,
      error!(ISpec ExpectationNotMet, text: "expected #{realValue inspect} to not match #{regex inspect}", shouldMessage: self shouldMessage)))

  NotShouldContext signal = method(condition,
    signalled = "none"
    bind(
      rescue(Ground Condition Error, fn(c, signalled = c)),
      rescue(condition, fn(c, signalled = c)),
      realValue call)

    if(signalled mimics?(condition),
      error!(ISpec ExpectationNotMet, text: "expected #{condition} to not be signalled in #{realValue code} - got #{signalled}", shouldMessage: self shouldMessage)))

  NotShouldContext mimic = method(value,
    if(realValue mimics?(value),
      error!(ISpec ExpectationNotMet, text: "expected #{realValue inspect} to not mimic #{value kind}", shouldMessage: self shouldMessage)))

  NotShouldContext kind = method(value nil,
    if(value nil?,
      "ISpec NotShouldContext",
      if(realValue kind?(value),
        error!(ISpec ExpectationNotMet, text: "expected #{realValue inspect} to not have kind #{value kind}", shouldMessage: self shouldMessage))))

  NotShouldContext true = method(
    if(Ground true == realValue,
      error!(ISpec ExpectationNotMet, text: "expected #{realValue inspect} to not be true", shouldMessage: self shouldMessage)))

  NotShouldContext false = method(
    if(Ground false == realValue,
      error!(ISpec ExpectationNotMet, text: "expected #{realValue inspect} to not be false", shouldMessage: self shouldMessage)))

  NotShouldContext nil = method(
    if(Ground nil == realValue,
      error!(ISpec ExpectationNotMet, text: "expected #{realValue inspect} to not be nil", shouldMessage: self shouldMessage)))

  NotShouldContext checkReceiverTypeOn = method(name, +args, +:keywordArgs,
    x = Origin mimic
    x cell(name) = self cell(:realValue) cell(name)
    fn(x send(name, *args, *keywordArgs)) should not signal(Condition Error Type IncorrectType)
  )

  NotShouldContext offer = method(theRestart,
    rst = Ground nil
    bind(
      rescue(Ground Condition, fn(c, Ground nil)),
      handle(Ground Condition, fn(c, rst = findRestart(theRestart name))),
      realValue call)

    if(rst && (rst name == theRestart name),
      error!(ISpec ExpectationNotMet, text: "did not expect a restart with name #{theRestart name} to be offered", shouldMessage: self shouldMessage)))
)
