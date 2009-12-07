
Set ifEmpty = dmacro(
  "if this set is empty, returns the result of evaluating the argument, otherwise returns the set",

  [theCode]
  if(empty?,
    call argAt(0),
    self))

Set ?| = dmacro(
  "if this set is empty, returns the result of evaluating the argument, otherwise returns the set",

  [theCode]
  if(empty?,
    call argAt(0),
    self))

Set ?& = dmacro(
  "if this set is non-empty, returns the result of evaluating the argument, otherwise returns the set",

  [theCode]
  unless(empty?,
    call argAt(0),
    self))

Set do(=== = generateMatchMethod(include?))

Set ∪ = method(
  "returns a new set that is the set-theoretic union of this set and the argument set",
  other,

  self + other)

Set cell("∈") = method(
  "returns true if the argument is in the set",
  element,

  include?(element))

Set cell("∉") = method(
  "returns false if the argument is in the set",
  element,

  !include?(element))

DefaultBehavior Literals cell("∅") = method(
  "returns a new empty set",

  #{})
