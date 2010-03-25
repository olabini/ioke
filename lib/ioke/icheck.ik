
ICheck = Origin mimic
ICheck Property = Origin mimic
ICheck Generators = Origin mimic

ICheck forAll = macro("takes zero or more generator arguments, zero or more guard arguments and zero or more classifier arguments. All of this is followed by one required code argument that will be wrapped in a lexical context. the method returns a Property with everything set correctly to execute the ICheck code",
  
  (generatorClassiftAndGuardCode, code) = (call arguments[0..-2], call arguments[-1])
  (generatorAndClassifyCode, guardCode) = generatorClassiftAndGuardCode partition(first, 
    first name != :"where" && first name != :"where:")
  (generatorCode, classifyCode) = generatorAndClassifyCode partition(first,
    first name != :"classify" && first name != :"classifyAs")

  argNames = generatorCode map(last)

  block = LexicalBlock createFrom(argNames + [code], call ground)
  lexicalScope = ICheck Generators mimic tap(mimic!(call ground))
  generators = generatorCode map(sendTo(lexicalScope, lexicalScope))
  guards = guardCode map(g, LexicalBlock createFrom(argNames + [g next], call ground))
  classifiers = classifyCode map(cc, 
    Origin with(
      name: cc arguments[0] name,
      predicate: LexicalBlock createFrom(argNames + [cc next], call ground)))

  Property with(block: block, generators: generators, guards: guards, classifiers: classifiers)
)

ICheck aliasMethod("forAll", "forEvery")

ICheck Property valuesFromGenerators = method(
  result = generators map(next)
  while(!(guards all?(call(*result))),
    result = generators map(next))
  result
)

ICheck Property classify = method(values, result,
  classifiers select(predicate call(*values)) each(cl,
    result classifier[cl name] += 1)
)

ICheck Property check! = method(count: 100,
  result = Origin with(classifier: {} withDefault(0))
  count times(
    values = valuesFromGenerators
    classify(values, result)
    block call(*values))
  result
)

ICheck Generators integer = fnx(Origin with(next: 42))
