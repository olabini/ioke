
DefaultBehavior FlowControl ignoreErrors = dmacro("takes one or two pices of code. runs the first code segment and returns nil if it signals an
error. If a second argument of code is given, evaluates this only when an error is encountered
and uses the result to return. if everything works as expected, ignoreErrors will just
return the result of the first evaluation",

  [protectedCode]
  bind(rescue(Condition Error, fn(c, nil)),
    protectedCode evaluateOn(call ground, call ground)),

  [protectedCode, otherwiseCode]
  bind(rescue(Condition Error, fn(c, otherwiseCode evaluateOn(call ground, call ground))),
    protectedCode evaluateOn(call ground, call ground)))

Condition ignore = dmacro("takes one or two pices of code. runs the first code segment and returns nil if it signals an
the receiver. If a second argument of code is given, evaluates this only when an error is encountered
and uses the result to return. if everything works as expected, ignore will just
return the result of the first evaluation",

  [protectedCode]
  bind(rescue(self, fn(c, nil)),
    protectedCode evaluateOn(call ground, call ground)),

  [protectedCode, otherwiseCode]
  bind(rescue(self, fn(c, otherwiseCode evaluateOn(call ground, call ground))),
    protectedCode evaluateOn(call ground, call ground)))


DefaultBehavior FlowControl passNil = dmacro(
  [code]

  currentMessage  = code
  ground = call ground
  currentReceiver = call ground

  while(currentMessage,
    currentReceiver = currentMessage sendTo(currentReceiver, ground)
    if(currentReceiver nil?,
      return(nil))
    currentMessage = currentMessage next
    if(currentMessage && currentMessage terminator?,
      currentMessage = currentMessage next
      currentReceiver = ground)
  )
  currentReceiver
)
