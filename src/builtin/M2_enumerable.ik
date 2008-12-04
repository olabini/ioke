

; Enumerable inject/reduce/fold
; Enumerable select/findAll

; Enumerable some
; Enumerable any?
; Enumerable all?

; Enumerable count




; Most of these should be able to return an enumerator instead

; Enumerable take = method("takes one non-negative number and returns as many elements from the underlying enumerable. this explicitly works with infine collections that would loop forever if you called their each directly")

; Enumerable sortBy
; Enumerable grep
; Enumerable find/detect
; Enumerable zip
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

Mixins Enumerable mapFn = method(
  "takes zero or more arguments that evaluates to lexical blocks. these blocks should all take one argument. these blocks will be chained together and applied on each element in the receiver. the final result will be collected into a list. the evaluation happens left-to-right, meaning the first method invoked will be the first argument.",
  +blocks,

  ;; use this form instead of [], since we might be inside of a List or a Dict
  result = list()

  self each(n,
    current = n
    blocks each(b, current = cell(:b) call(current))
    result << current)

  result)

Mixins Enumerable aliasMethod("map", "collect")
Mixins Enumerable aliasMethod("mapFn", "collectFn")

Mixins Enumerable any? = macro(
  "takes zero, one or two arguments. if zero arguments, returns true if any of the elements yielded by each is true, otherwise false. if one argument, expects it to be a message chain. if that message chain, when applied to the current element returns a true value, the method returns true. finally, if two arguments are given, the first argument is an unevaluated name and the second is a code element. these will together be turned into a lexical block and tested against the values in this element. if it returns true for any element, this method returns true, otherwise false.",
  
  len = call arguments length
  if(len == 0,
    self each(n, if(n, return(true))),

    if(len == 1,
      theCode = call arguments first
      self each(n, if(theCode evaluateOn(call ground, n), return(true))),
      
      lexicalCode = LexicalBlock createFrom(call arguments, call ground)
      self each(n, if(lexicalCode call(n), return(true)))))
  false)

Mixins Enumerable none? = macro(
  "takes zero, one or two arguments. if zero arguments, returns false if any of the elements yielded by each is true, otherwise true. if one argument, expects it to be a message chain. if that message chain, when applied to the current element returns a true value, the method returns false. finally, if two arguments are given, the first argument is an unevaluated name and the second is a code element. these will together be turned into a lexical block and tested against the values in this element. if it returns true for any element, this method returns false, otherwise true.",
  
  len = call arguments length
  if(len == 0,
    self each(n, if(n, return(false))),

    if(len == 1,
      theCode = call arguments first
      self each(n, if(theCode evaluateOn(call ground, n), return(false))),
      
      lexicalCode = LexicalBlock createFrom(call arguments, call ground)
      self each(n, if(lexicalCode call(n), return(false)))))
  true)

Mixins Enumerable some = macro(
  "takes zero, one or two arguments. if zero arguments, returns the first element that is true, otherwise false. if one argument, expects it to be a message chain. if that message chain, when applied to the current element returns a true value, that value is return. finally, if two arguments are given, the first argument is an unevaluated name and the second is a code element. these will together be turned into a lexical block and tested against the values in this element. if it returns true for any element, that value will be returned, otherwise false.",
  
  len = call arguments length
  if(len == 0,
    self each(n, if(n, return(it))),

    if(len == 1,
      theCode = call arguments first
      self each(n, if(theCode evaluateOn(call ground, n), return(it))),
      
      lexicalCode = LexicalBlock createFrom(call arguments, call ground)
      self each(n, if(lexicalCode call(n), return(it)))))
  false)
