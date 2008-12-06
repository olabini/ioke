
Affirm do(
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
      error!(Affirm ExpectationNotMet, text: "expected #{realValue} #{msg code} to be true")))

  NotShouldContext pass = macro(
    realName = call message name
    msg = call message deepCopy
    msg name = "#{realName}?"
    if(msg sendTo(self realValue),
      error!(Affirm ExpectationNotMet, text: "expected #{realValue} #{msg code} to be false")))

  NotShouldContext create = method(former,
    newSelf = self __mimic__
    newSelf outsideShouldContext = former
    newSelf realValue = former realValue
    newSelf)

  ShouldContext == = method(value,
    unless(realValue == value,
      error!(Affirm ExpectationNotMet, text: "expected #{value inspect} to == #{realValue inspect}")))

  NotShouldContext == = method(value,
    if(realValue == value,
      error!(Affirm ExpectationNotMet, text: "expected #{value inspect} to not == #{realValue inspect}")))

  ShouldContext mimic = method(value,
    unless(realValue mimics?(value),
      error!(Affirm ExpectationNotMet, text: "expected #{realValue inspect} to mimic #{value kind}")))

  NotShouldContext mimic = method(value,
    if(realValue mimics?(value),
      error!(Affirm ExpectationNotMet, text: "expected #{realValue inspect} to not mimic #{value kind}")))

  ShouldContext not = method(
    "inverts the expected matching",
    Affirm NotShouldContext create(self))
)
