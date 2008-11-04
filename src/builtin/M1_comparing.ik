
Mixins Comparing < = method(
  "return true if the receiver is less than the argument, otherwise false",
  other,
  
  (@ <=> other) == -1)

Mixins Comparing <= = method(
  "return true if the receiver is less than or equal to the argument, otherwise false",
  other,
  
  (@ <=> other) != 1)

Mixins Comparing > = method(
  "return true if the receiver is greater than the argument, otherwise false",
  other,
  
  (@ <=> other) == 1)

Mixins Comparing >= = method(
  "return true if the receiver is greater than or equal to the argument, otherwise false",
  other,
  
  (@ <=> other) != -1)

Mixins Comparing == = method(
  "return true if the receiver is equal to the argument, otherwise false",
  other,
  
  (@ <=> other) == 0)

Mixins Comparing != = method(
  "return true if the receiver is not equal to the argument, otherwise false",
  other,
  
  !((@ <=> other) == 0))
