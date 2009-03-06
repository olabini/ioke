
List second = method(
  "returns the second element of this list, or nil of the list has less than two entries",
  
  [1])

List third = method(
  "returns the third element of this list, or nil of the list has less than three entries",
  
  [2])

List last = method(
  "returns the last element of this list, or nil of the list is empty",
  
  if(empty?, nil, [0-1]))

List rest = method(
  "returns a list that contains all entries except for the first one, or the empty list if this list is empty.",
  
  if(empty?, 
    DefaultBehavior [], 
    [1..0-1]))

List butLast = method(
  "returns all the entries in the list, except for the 'n' last one, where 'n' is an optional argument that defaults to 1.",
  n 1,

  end = length - n

  if(end < 0 || empty?,
    DefaultBehavior [],
    [0...end]))

List asList = method(
  "returns this list",
  self)

List ifEmpty = dmacro(
  "if this list is empty, returns the result of evaluating the argument, otherwise returns the list",

  [then]
  if(empty?,
    call argAt(0),
    self))

List ?| = dmacro(
  "if this list is empty, returns the result of evaluating the argument, otherwise returns the list",

  [then]
  if(empty?,
    call argAt(0),
    self))

List ?& = dmacro(
  "if this list is not empty, returns the result of evaluating the argument, otherwise returns the list",

  [then]
  unless(empty?,
    call argAt(0),
    self))

List do(=== = generateMatchMethod(include?))
