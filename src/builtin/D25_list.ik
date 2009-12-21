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

List do(=== = generateMatchMethod(==))

List compact = method(
  "returns a new list that is a mimic of the current list, except that all nils are removed from it",
  newList = self mimic
  newList compact!
  newList)

List assoc = method(
  "takes an object, and returns the first list in this list that has that object as its first element. if it can't be found, returns nil.",
  obj,
  self find(el,
    el mimics?(List) && el length > 0 && el[0] == obj))

List rassoc = method(
  "takes an object, and returns the first list in this list that has that object as its second element. if it can't be found, returns nil.",
  obj,
  self find(el,
    el mimics?(List) && el length > 1 && el[1] == obj))

List reverse = method(
  "returns a new list that is a mimic of the current list, except that the order of all elements are reversed",
  newList = self mimic
  newList reverse!
  newList)

List flatten = method(
  "returns a new list that is a mimic of the current list, with all elements flattened in it",
  newList = self mimic
  newList flatten!
  newList)

List cell("*") = method(
  "takes either a text or a number. if given a text, it works like join, while if it gets a number, it will return a new list repeated as many times as the number argument",
  sepOrRep,

  if(sepOrRep mimics?(Text),
    self join(sepOrRep),

    result = list()
    sepOrRep times(result concat!(self))
    result))

List index = method(
  "takes an object and returns the index of the first occurance of that object in this list, or nil if it doesn't exist",
  obj,
  self each(index, element,
    if(element == obj,
      return index))
  nil)

List rindex = method(
  "takes an object and returns the index of the last occurance of that object in this list, or nil if it doesn't exist",
  obj,
  ((self size - 1)..0) each(index,
    if(self[index] == obj,
      return index))
  nil)

List random = method(
  "returns a random element from the list. Returns nil if the list is empty.",
  if(length > 0,
    [System randomNumber % length],
    nil))

List randomIndex = method(
  "returns the index of a random element from the list. Returns nil if the list is empty.",
  if(length > 0,
    System randomNumber % length,
    nil))

List pick = method(
  "picks a random element from the list. If a quantity is specified it returns a list of that size picked randomly which is a subset of the original list. If the specified quantity is greater than the length of the list, the returned list will be padded with nils.",
  quantity nil,

  if(quantity,
    result = list()
    notPicked = self mimic
    quantity times(
      result << notPicked removeAt!(System randomNumber % (notPicked length)))
    result,

    random))

List pick! = method(
  "picks and removes a random element from the list. If a quantity is specified it modifies the list by removing that many random elements and returning them in a new list. If the specified quantity is greater than the length of the list, the returned list will be padded with nils.",
  quantity nil,

  if(quantity,
    result = list()
    quantity times(
      if(length > 0,
        result << removeAt!(randomIndex),
        result << nil))
    result,

    removeAt!(randomIndex)))

List choose = method(
  "chooses a random element from the list. If a quantity is specified it returns a sequence of random elements each chosen from the complete list (and therefore may contain duplicates)",
  quantity nil,

  if(quantity,
    outerList = self
    left = quantity
    Sequence with(
      next?: fnx(left > 0),
      next: fnx(left--. outerList random)),

    random))

List shuffle = method(
  "return a new list containing the same elements as the original list with their positions distributed randomly.",
  pick(length))

List shuffle! = method(
  "shuffles the list by randomly distributing the position of its elements",
  notPicked = self mimic
  notPicked length times(index,
    randomIndex = System randomNumber % (notPicked length)
    [index] = notPicked removeAt!(randomIndex))
  self)