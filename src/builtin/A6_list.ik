
List first = method(
  "returns the first element of this list, or nil of the list is empty",
  
  @[0])

List second = method(
  "returns the second element of this list, or nil of the list has less than two entries",
  
  @[1])

List third = method(
  "returns the third element of this list, or nil of the list has less than three entries",
  
  @[2])

List last = method(
  "returns the last element of this list, or nil of the list is empty",
  
  if(@empty?, nil, @[-1]))

List rest = method(
  "returns a list that contains all entries except for the first one, or the empty list if this list is empty.",
  
  if(@empty?, [], @[1..-1]))

List butLast = method(
  "returns all the entries in the list, except for the 'n' last one, where 'n' is an optional argument that defaults to 1.",
  n 1,
  
  if(@empty?, [], @[0 ..( -(n))]))
