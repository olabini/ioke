
DefaultBehavior FlowControl tap = dmacro("takes one or two arguments that represent code. Will yield the receiver and then return the receiver after executing the given code",
  [code]
  code evaluateOn(call ground, self)
  self,

  [argName, code]
  LexicalBlock createFrom(list(argName, code), call ground) call(self)
  self
)

DefaultBehavior FlowControl rap = macro("takes one or more message chains. Will call these on the receiver, then return the receiver",
  call arguments each(code,
    code evaluateOn(call ground, self))
  self
)

DefaultBehavior FlowControl tapping = DefaultBehavior FlowControl cell(:rap)

