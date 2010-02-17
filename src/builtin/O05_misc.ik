
DefaultBehavior FlowControl tap = dmacro("takes one or two arguments that represent code. Will yield the receiver and then return the receiver after executing the given code",
  [code]
  code evaluateOn(call ground, self)
  self,

  [argName, code]
  LexicalBlock createFrom(list(argName, code), call ground) call(self)
  self
)
