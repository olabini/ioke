
DefaultBehavior FlowControl for = macro(

  generator = call arguments[0]
  varName = generator name
  generatorCode = generator next arguments first
  values = generatorCode evaluateOn(call ground, call ground)

  codeToExecute = LexicalBlock createFrom([message(varName), call arguments[1]], call ground)

  values mapFn(codeToExecute)

)
