
ICheck = Origin mimic
ICheck Property = Origin mimic

ICheck forAll = macro("takes zero or more generator arguments, zero or more guard arguments and zero or more classifier arguments. All of this is followed by one required code argument that will be wrapped in a lexical context. the method returns a Property with everything set correctly to execute the ICheck code",
  
  code = call arguments[-1]
  block = LexicalBlock createFrom([code], call ground)
  Property with(block: block)
)

ICheck Property check! = method(count: 100,
  count times(block call)
)
