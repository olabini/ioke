
ICheck = Origin mimic
ICheck Property = Origin mimic
ICheck Generators = Origin mimic
ICheck Condition = Ground Condition mimic
ICheck ReachedMaxDiscarded = ICheck Condition mimic

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

ICheck Property currentSize = 0
ICheck Property valuesFromGenerators = method(generators map(next))

ICheck Property classify = method(values, result,
  classifiers select(predicate call(*values)) each(cl,
    result classifier[cl name] += 1)
)

ICheck Property computeSize = method(maxSuccess, maxSize, successful, discarded,
  maxMod = maxSuccess % maxSize
  if((successful div(maxSize) * maxSize + maxSize) <= maxSuccess ||
    successful >= maxSuccess ||
    maxMod == 0, (successful % maxSize),
    (successful % maxSize) * (maxSize div(maxMod))) + discarded div(10))

ICheck Property check! = method(maxSuccess: 100, maxDiscard: 500, maxSize: 100,
  result = Origin with(classifier: {} withDefault(0), succeeded: 0, discarded: 0)
  while(result succeeded < maxSuccess && result discarded < maxDiscard,
    size = computeSize(maxSuccess, maxDiscard, result succeeded, result discarded)
    values = let(ICheck Property currentSize, size,
      valuesFromGenerators)
    if(!(guards all?(call(*values))),
      result discarded += 1,
      classify(values, result)
      block call(*values)
      result succeeded += 1)
  )
  result
)

ICheck Generator = Origin mimic
ICheck Generators do(
  choose = method(start, end, 
    d = end-start+1
    start + (System randomNumber abs % d))

  sized = dmacro(
    [argName, code]
    block = LexicalBlock createFrom(Ground[argName, code], call ground)
    ICheck Generator with(next: fnx(block(ICheck Property currentSize))))

  gen = dmacro(
    [code]
    block = LexicalBlock createFrom(Ground[code], call ground)
    ICheck Generator with(next: fnx(block call)))

  oneOf = method(+choices,
    len = choices length
    gen(
      r = choices[choose(0, len - 1)]
      if(r mimics?(ICheck Generator),
        r next,
        r)
  ))

  choice = method(start, end,
    gen(choose(start, end)))

  int = sized(n, choose(-n, n))
  integer = cell(:int)

  nat = sized(n, choose(0, n))
  natural = cell(:nat)

  decimal = sized(n,
    (a, b, c) = (1..3) map(_, choose(-n, n))
    a + (b / (c abs + 1.0))
  )

  ratio = sized(n, 
    result = nil
    loop(
      num = choose(-n, n)
      denum = choose(-n, n)
      if(denum != 0,
        result = num / denum
        if(result mimics?(Number Ratio),
          break)
      )
    )
    result
  )

  rational = oneOf(ratio, int)

  bool = oneOf(true, false)
  boolean = cell(:bool)

  kleene = oneOf(true, false, nil)
  kleenean = cell(:kleene)

  list = method(element,
    element = if(element mimics?(ICheck Generator),
      element,
      Origin with(next: element))
    sized(size, 
        result = Ground list
        choose(0, size) times(
          result << element next
        )
        result
    ))
  [] = cell(:list)

  text = method(
    cGen = oneOf(choice(0, 127), choice(0, 255))
    sized(n,
      result = Ground list
      choose(0, n) times(
        result << cGen next char
      )
      result join("")
    )
  )

  set = method(element,
    element = if(element mimics?(ICheck Generator),
      element,
      Origin with(next: element))
    sized(size,
        result = Ground set
        choose(0, size) times(
          result << element next
        )
        result
    ))

  range = method(startElement, endElement,
    (startElement, endElement) = Ground[startElement, endElement] map(element,
      if(element mimics?(ICheck Generator),
        element,
        Origin with(next: element)))
    gen((startElement next)..(endElement next))
  )

  xrange = method(startElement, endElement,
    (startElement, endElement) = Ground[startElement, endElement] map(element,
      if(element mimics?(ICheck Generator),
        element,
        Origin with(next: element)))
    gen((startElement next)...(endElement next))
  )

  => = method(startElement, endElement,
    (startElement, endElement) = Ground[startElement, endElement] map(element,
      if(element mimics?(ICheck Generator),
        element,
        Origin with(next: element)))
    gen((startElement next) => (endElement next))
  )
)
