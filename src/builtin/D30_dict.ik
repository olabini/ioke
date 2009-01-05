
DefaultBehavior Literals cell("{}") = macro(
  call resendToMethod("dict"))

Dict aliasMethod("at", "[]")

Dict addKeysAndValues = method(
  "zips the keys and the values together into this dict. note that neither keys nor values need to be lists. you can use anything that is iterable with index.",
  keys, values, 

  keys each(i, k, 
    self[k] = values[i])

  self)

Dict do(=== = generateMatchMethod(==))
