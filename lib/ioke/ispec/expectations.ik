
ISpec do(
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
      ;; these should save away the same line message
      error!(ISpec ExpectationNotMet, text: "expected #{realValue} #{msg code} to be true")))


  ShouldContext == = method(value,
    unless(realValue == value,
      ;; these should save away the same line message
      error!(ISpec ExpectationNotMet, text: "expected #{value inspect} to == #{realValue inspect}")))

  ShouldContext signal = method(condition,
    signalled = "none"
    bind(
      rescue(Ground Condition Error, fn(c, signalled = c)),
      rescue(condition, fn(c, signalled = c)),
      realValue call)

    unless(signalled mimics?(condition),
      ;; these should save away the same line message
      error!(ISpec ExpectationNotMet, text: "expected #{condition} to be signalled in #{realValue code} - got #{signalled}")))

  ShouldContext mimic = method(value,
    unless(realValue mimics?(value),
      ;; these should save away the same line message
      error!(ISpec ExpectationNotMet, text: "expected #{realValue inspect} to mimic #{value kind}")))

  ShouldContext not = method(
    "inverts the expected matching",
    ISpec NotShouldContext create(self))

  NotShouldContext pass = macro(
    realName = call message name
    msg = call message deepCopy
    msg name = "#{realName}?"
    if(msg sendTo(self realValue),
      ;; these should save away the same line message
      error!(ISpec ExpectationNotMet, text: "expected #{realValue} #{msg code} to be false")))

  NotShouldContext create = method(former,
    newSelf = self __mimic__
    newSelf outsideShouldContext = former
    newSelf realValue = former realValue
    newSelf)

  NotShouldContext == = method(value,
    if(realValue == value,
      ;; these should save away the same line message
      error!(ISpec ExpectationNotMet, text: "expected #{value inspect} to not == #{realValue inspect}")))

  NotShouldContext signal = method(condition,
    signalled = "none"
    bind(
      rescue(Ground Condition Error, fn(c, signalled = c)),
      rescue(condition, fn(c, signalled = c)),
      realValue call)

    if(signalled mimics?(condition),
      ;; these should save away the same line message
      error!(ISpec ExpectationNotMet, text: "expected #{condition} to not be signalled in #{realValue code} - got #{signalled}")))

  NotShouldContext mimic = method(value,
    if(realValue mimics?(value),
      ;; these should save away the same line message
      error!(ISpec ExpectationNotMet, text: "expected #{realValue inspect} to not mimic #{value kind}")))
)
