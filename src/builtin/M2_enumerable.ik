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

  result = []
  self each(n, result << n)
  result)

Mixins Enumerable sort = method(
  "will return a sorted list of all the entries of this enumerable object",
  self asList sort)
