
Mixins Comparing <=> = method(
  "should be overridden - will result in an inconsistent ordering by always returning -1 except when comparing to itself, and then it will return 0",
  other,

  if(cell(:other) kind == "Mixins Comparing",
    0,
    (0-1)))

Mixins Comparing < = method(
  "return true if the receiver is less than the argument, otherwise false",
  other,

  (<=> other) == (0-1))

Mixins Comparing <= = method(
  "return true if the receiver is less than or equal to the argument, otherwise false",
  other,
  
  result = (<=> other)
  result && result != 1)

Mixins Comparing aliasMethod("<=", "≤")

Mixins Comparing > = method(
  "return true if the receiver is greater than the argument, otherwise false",
  other,
  
  (<=> other) == 1)

Mixins Comparing >= = method(
  "return true if the receiver is greater than or equal to the argument, otherwise false",
  other,
  
  result = (<=> other)
  result && result != (0-1))

Mixins Comparing aliasMethod(">=", "≥")

Mixins Comparing == = method(
  "return true if the receiver is equal to the argument, otherwise false",
  other,

  (<=> cell(:other)) == 0)

Mixins Comparing != = method(
  "return true if the receiver is not equal to the argument, otherwise false",
  other,
  
  !((<=> other) == 0))

Mixins Comparing aliasMethod("!=", "≠")
