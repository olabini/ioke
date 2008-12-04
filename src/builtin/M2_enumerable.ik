

; Enumerable select/findAll
; Enumerable all?
; Enumerable count

; Most of these should be able to return an enumerator instead

; Enumerable take = method("takes one non-negative number and returns as many elements from the underlying enumerable. this explicitly works with infine collections that would loop forever if you called their each directly")

; Enumerable sortBy
; Enumerable grep
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
  self each(n, result << cell(:n))
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
    self each(n, result << theCode evaluateOn(call ground, cell(:n))),

    lexicalCode = LexicalBlock createFrom(call arguments, call ground)
    self each(n, result << lexicalCode call(cell(:n))))
  result)

Mixins Enumerable mapFn = method(
  "takes zero or more arguments that evaluates to lexical blocks. these blocks should all take one argument. these blocks will be chained together and applied on each element in the receiver. the final result will be collected into a list. the evaluation happens left-to-right, meaning the first method invoked will be the first argument.",
  +blocks,

  ;; use this form instead of [], since we might be inside of a List or a Dict
  result = list()

  self each(n,
    current = cell(:n)
    blocks each(b, current = cell(:b) call(cell(:current)))
    result << current)

  result)

Mixins Enumerable any? = macro(
  "takes zero, one or two arguments. if zero arguments, returns true if any of the elements yielded by each is true, otherwise false. if one argument, expects it to be a message chain. if that message chain, when applied to the current element returns a true value, the method returns true. finally, if two arguments are given, the first argument is an unevaluated name and the second is a code element. these will together be turned into a lexical block and tested against the values in this element. if it returns true for any element, this method returns true, otherwise false.",
  
  len = call arguments length
  if(len == 0,
    self each(n, if(cell(:n), return(true))),

    if(len == 1,
      theCode = call arguments first
      self each(n, if(theCode evaluateOn(call ground, cell(:n)), return(true))),
      
      lexicalCode = LexicalBlock createFrom(call arguments, call ground)
      self each(n, if(lexicalCode call(cell(:n)), return(true)))))
  false)

Mixins Enumerable none? = macro(
  "takes zero, one or two arguments. if zero arguments, returns false if any of the elements yielded by each is true, otherwise true. if one argument, expects it to be a message chain. if that message chain, when applied to the current element returns a true value, the method returns false. finally, if two arguments are given, the first argument is an unevaluated name and the second is a code element. these will together be turned into a lexical block and tested against the values in this element. if it returns true for any element, this method returns false, otherwise true.",
  
  len = call arguments length
  if(len == 0,
    self each(n, if(cell(:n), return(false))),

    if(len == 1,
      theCode = call arguments first
      self each(n, if(theCode evaluateOn(call ground, cell(:n)), return(false))),
      
      lexicalCode = LexicalBlock createFrom(call arguments, call ground)
      self each(n, if(lexicalCode call(cell(:n)), return(false)))))
  true)

Mixins Enumerable some = macro(
  "takes zero, one or two arguments. if zero arguments, returns the first element that is true, otherwise false. if one argument, expects it to be a message chain. if that message chain, when applied to the current element returns a true value, that value is return. finally, if two arguments are given, the first argument is an unevaluated name and the second is a code element. these will together be turned into a lexical block and tested against the values in this element. if it returns true for any element, that value will be returned, otherwise false.",
  
  len = call arguments length
  if(len == 0,
    self each(n, if(cell(:n), return(it))),

    if(len == 1,
      theCode = call arguments first
      self each(n, if(theCode evaluateOn(call ground, cell(:n)), return(it))),
      
      lexicalCode = LexicalBlock createFrom(call arguments, call ground)
      self each(n, if(lexicalCode call(cell(:n)), return(it)))))
  false)

Mixins Enumerable find = macro(
  "takes zero, one or two arguments. if zero arguments, returns the first element that is true, otherwise nil. if one argument, expects it to be a message chain. if that message chain, when applied to the current element returns a true value, the corresponding element is returned. finally, if two arguments are given, the first argument is an unevaluated name and the second is a code element. these will together be turned into a lexical block and tested against the values in this element. if it returns true for any element, the element will be retuend, otherwise nil.",
  
  len = call arguments length
  if(len == 0,
    self each(n, if(cell(:n), return(it))),

    if(len == 1,
      theCode = call arguments first
      self each(n, if(theCode evaluateOn(call ground, cell(:n)), return(cell(:n)))),
      
      lexicalCode = LexicalBlock createFrom(call arguments, call ground)
      self each(n, if(lexicalCode call(cell(:n)), return(cell(:n))))))
  nil)

Mixins Enumerable inject = macro(
  "takes one, two, three or four arguments. all versions need an initial sum, code to execute, a place to put the current sum in the code, and a place to stick the current element of the enumerable. if one argument, it has to be a message chain. this message chain will be applied on the current sum. the element will be appended to the argument list of the last message send in the chain. the initial sum is the first element, and the code will be executed once less than the size of the enumerable due to this. if two arguments given, the first argument is the name of the variable to put the current element in, and the message will still be sent to the sum - and the initial sum works the same way as for one argument. when three arguments are given, the whole thing will be turned into a lexical closure, where the first argument is the name of the sum variable, the second argument is the name of the element variable, and the last argument is the code. when given four arguments, the only difference is that the first argument will be evaluated as the initial sum.",

  len = call arguments length
  outsideGround = call ground

  if(len == 1,
    elementName = genSym
    theCode = call arguments first deepCopy
    last = theCode
    while(last next,
      last = last next)

    last appendArgument(message(elementName))

    sum = nil

    self each(i, n,
      if(i == 0,
        sum = cell(:n),
        
        outsideGround cell(elementName) = cell(:n)
        sum = theCode evaluateOn(outsideGround, cell(:sum))))

    return(sum),

    if(len == 2,
      elementName = call arguments first name
      theCode = call arguments second

      sum = nil

      self each(i, n,
        if(i == 0,
          sum = cell(:n),
        
          call ground cell(elementName) = cell(:n)
          sum = theCode evaluateOn(call ground, cell(:sum))))

      return(sum),

      if(len == 3,
        lexicalCode = LexicalBlock createFrom(call arguments, call ground)
        sum = nil
        self each(i, n,
          if(i == 0,
            sum = cell(:n),
            sum = lexicalCode call(cell(:sum), cell(:n))))
        return(sum),

        ; len == 4
        sum = call argAt(0)
        lexicalCode = LexicalBlock createFrom(call arguments[1..-1], call ground)
        self each(n,
          sum = lexicalCode call(cell(:sum), cell(:n)))
        return(sum)
      )))
  nil) 

Mixins Enumerable flatMap = macro(
  "expects to get the same kind of arguments as map, and that each map operation returns a list. these lists will then be folded into a single list.",

  call resendToMethod("map") fold(+))

Mixins Enumerable aliasMethod("map", "collect")
Mixins Enumerable aliasMethod("mapFn", "collectFn")
Mixins Enumerable aliasMethod("find", "detect")
Mixins Enumerable aliasMethod("inject", "reduce")
Mixins Enumerable aliasMethod("inject", "fold")
