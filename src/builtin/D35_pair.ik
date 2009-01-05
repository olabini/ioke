
Pair <=> = method(
  "compares this pair against the argument, returning -1, 0 or 1 based on which one is larger, first comparing the 'first', then comparing the 'second'",
  other,
  
  result = self first <=> other first

  if(result == 0,
    result = self second <=> other second)

  result)

Pair do(=== = generateMatchMethod(==))

