
DefaultBehavior Literals cell("{}") = macro(
  call resendToMethod("dict"))

Dict aliasMethod("at", "[]")

Dict addKeysAndValues = method(
  "zips the keys and the values together into this dict. note that neither keys nor values need to be lists. you can use anything that is iterable with index.",
  keys, values,

  keys each(i, k,
    self[k] = values[i])

  self)

Dict ?| = dmacro(
  "if this dict is empty, returns the result of evaluating the argument, otherwise returns the dict",

  [theCode]
  if(empty?,
    call argAt(0),
    self))

Dict ?& = dmacro(
  "if this dict is non-empty, returns the result of evaluating the argument, otherwise returns the dict",

  [theCode]
  unless(empty?,
    call argAt(0),
    self))

Dict do(=== = generateMatchMethod(==))

Dict mergeWith = dmacro(
  "merges this dictionary with the first argument using different strategies defined by the second to fourth arguments",

  [>other]
  self merge(other),


  [>other, theCode]
  theCode = theCode deepCopy
  rhsName = genSym
  theCode last << message(rhsName)

  combined = {}
  other each(kv,
    if(self key?(kv key),
      call ground cell(rhsName) = kv value
      combined[kv key] = theCode evaluateOn(call ground, self[kv key]),
      combined[kv key] = kv value))
  self merge(combined),


  [>other, lhsName, theCode]
  theCode = theCode deepCopy
  rhsName = genSym
  theCode last << message(rhsName)

  combined = {}
  other each(kv,
    if(self key?(kv key),
      call ground cell(lhsName) = self[kv key]
      call ground cell(rhsName) = kv value
      combined[kv key] = theCode evaluateOn(call ground),
      combined[kv key] = kv value))
  self merge(combined),


  [>other, lhsName, rhsName, theCode]
  lexicalCode = LexicalBlock createFrom(list(lhsName, rhsName, theCode), call ground)
  combined = {}
  other each(kv,
    if(self key?(kv key),
      combined[kv key] = lexicalCode(self[kv key], kv value),
      combined[kv key] = kv value))
  self merge(combined)
)
