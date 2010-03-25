
ICheck = Origin mimic
ICheck Property = Origin mimic
ICheck Generators = Origin mimic

ICheck forAll = macro("takes zero or more generator arguments, zero or more guard arguments and zero or more classifier arguments. All of this is followed by one required code argument that will be wrapped in a lexical context. the method returns a Property with everything set correctly to execute the ICheck code",
  
  (generatorAndGuardCode, code) = (call arguments[0..-2], call arguments[-1])
  (generatorCode, guardCode) = generatorAndGuardCode partition(first, 
    first name != :"where" && first name != :"where:")

  argNames = generatorCode map(last)

  block = LexicalBlock createFrom(argNames + [code], call ground)
  lexicalScope = ICheck Generators mimic tap(mimic!(call ground))
  generators = generatorCode map(sendTo(lexicalScope, lexicalScope))
  guards = guardCode map(g, LexicalBlock createFrom(argNames + [g next], call ground))

  Property with(block: block, generators: generators, guards: guards)
)

ICheck aliasMethod("forAll", "forEvery")

ICheck Property valuesFromGenerators = method(
  result = generators map(next)
  while(!(guards all?(call(*result))),
    result = generators map(next))
  result
)

ICheck Property check! = method(count: 100,
  count times(block call(*(valuesFromGenerators)))
)

ICheck Generators integer = fnx(Origin with(next: 42))
