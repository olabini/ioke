
Set ifEmpty = macro(
  "if this set is empty, returns the result of evaluating the argument, otherwise returns the set",
  if(empty?,
    call argAt(0),
    self))
