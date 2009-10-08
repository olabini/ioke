
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
