Number zero? = method(
  "Returns true if this number is zero.",
  @ == 0
)

Number negation = method(
  "Returns the negation of this number",

  0 - @)

Number abs = method(
  "Returns the absolute value of this number",
  if(self < 0, negation, self)
)

Number          do(=== = generateMatchMethod(==))
Number Real     do(=== = generateMatchMethod(==))
Number Rational do(=== = generateMatchMethod(==))
Number Decimal  do(=== = generateMatchMethod(==))
