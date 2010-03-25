
ICheck = Origin mimic
ICheck Property = Origin mimic
ICheck Generators = Origin mimic

ICheck forAll = macro("takes zero or more generator arguments, zero or more guard arguments and zero or more classifier arguments. All of this is followed by one required code argument that will be wrapped in a lexical context. the method returns a Property with everything set correctly to execute the ICheck code",
  
  (generators, code) = (call arguments[0..-2], call arguments[-1])
  argNames = generators map(last)

  block = LexicalBlock createFrom(argNames + [code], call ground)
  lexicalScope = ICheck Generators mimic
  lexicalScope mimic!(call ground)
  Property with(block: block, generators: generators map(sendTo(lexicalScope, lexicalScope)))
)

ICheck Property valuesFromGenerators = method(
  generators map(next)
)

ICheck Property check! = method(count: 100,
  count times(block call(*(valuesFromGenerators)))
)

ICheck Generators integer = fnx(Origin with(next: 42))
