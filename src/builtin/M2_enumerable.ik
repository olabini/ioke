; Most of these should be able to return an enumerator instead

; Enumerable take = method("takes one non-negative number and returns as many elements from the underlying enumerable. this explicitly works with infine collections that would loop forever if you called their each directly")

; Enumerable map/collect
;    probably also add mapFn
; Enumerable inject/reduce/fold
; Enumerable asList
; Enumerable sort
; Enumerable sortBy
; Enumerable select/findAll
; Enumerable grep
; Enumerable find/detect
; Enumerable some?
; Enumerable any?
; Enumerable all?
; Enumerable zip
; Enumerable count
; Enumerable findIndex
; Enumerable reject
; Enumerable partition
; Enumerable first
; Enumerable one?
; Enumerable none?
; Enumerable member?/include?

; Enumerable takeWhile
; Enumerable drop
; Enumerable dropWhile
; Enumerable cycle

; Enumerable takeNth(n)

Mixins Enumerable asList = method(
  "will return a list created from calling each on the receiver until everything has been yielded. if a more efficient version is possible of this, the object should implement it, since other Enumerable methods will use this for some operations. note that asList is not required to return a new list",

  ;; use this form instead of [], since we might be inside of a List or a Dict
  result = list()
  self each(n, result << n)
  result)

Mixins Enumerable sort = method(
  "will return a sorted list of all the entries of this enumerable object",
  self asList sort)

Mixins Enumerable map = macro(
  "takes one or two arguments. if one argument is given, it will be evaluated as a message chain on each element in the enumerable, and then the result will be collected in a new List. if two arguments are given, the first one should be an unevaluated argument name, which will be bound inside the scope of executing the second piece of code. it's important to notice that the one argument form will establish no context, while the two argument form establishes a new lexical closure.",
  
  len = call arguments length
  ;; use this form instead of [], since we might be inside of a List or a Dict
  result = list()
  if(len == 1,
    theCode = call arguments first
    self each(n, result << theCode evaluateOn(call ground, n)),

    lexicalCode = LexicalBlock createFrom(call arguments, call ground)
    self each(n, result << lexicalCode call(n)))
  result)
