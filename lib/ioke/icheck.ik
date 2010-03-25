
ICheck = Origin mimic
ICheck Property = Origin mimic

ICheck forAll = macro("takes zero or more generator arguments, zero or more guard arguments and zero or more classifier arguments. All of this is followed by one required code argument that will be wrapped in a lexical context. the method returns a Property with everything set correctly to execute the ICheck code",
  
  (generators, code) = (call arguments[0..-2], call arguments[-1])
  argNames = generators map(last)

  block = LexicalBlock createFrom(argNames + [code], call ground)
  Property with(block: block, generators: generators)
)

ICheck Property valuesFromGenerators = method(
  generators map(. 42)
)

ICheck Property check! = method(count: 100,
  count times(block call(*(valuesFromGenerators)))
)
