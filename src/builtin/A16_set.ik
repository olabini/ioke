
Set ifEmpty = dmacro(
  "if this set is empty, returns the result of evaluating the argument, otherwise returns the set",

  [theCode]
  if(empty?,
    call argAt(0),
    self))
