
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
