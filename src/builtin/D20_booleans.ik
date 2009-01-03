
;; ---- and

true and = macro(
  "Evaluates the argument and returns the result",

  call argAt(0))
true aliasMethod("and", "&&")

false and = macro(
  "Does not evaluate argument and returns false",

  false)
false aliasMethod("and", "&&")

true or = macro(
  "Does not evaluate argument and returns true",

  true)
true aliasMethod("or", "||")

false or = macro(
  "Evaluates the argument and returns the result",

  call argAt(0))
false aliasMethod("or", "||")

nil or = macro(
  "Evaluates the argument and returns the result",

  call argAt(0))
nil aliasMethod("or", "||")

nil and = dmacro(
  "Does not evaluate argument and returns nil",
  
  [then]
  nil)
nil aliasMethod("and", "&&")

DefaultBehavior Boolean or = dmacro(
  "Does not evaluate argument and returns self",

  [then]
  @)

DefaultBehavior Boolean cell("||") = dmacro(
  "Does not evaluate argument and returns self",

  [then]
  @)

DefaultBehavior Boolean and = dmacro(
  "Evaluates the argument and returns the result",

  [>then]
  then)

DefaultBehavior Boolean cell("&&") = dmacro(
  "Evaluates the argument and returns the result",

  [>then]
  then)


;; ---- !

DefaultBehavior Boolean ! = method(
  "returns true if the argument is false, and false if it's true",
  arg,
  
  arg not)

;; ---- nil?

DefaultBehavior Boolean nil? = method(
  "returns false.", 

  false)

nil nil? = method(
  "returns true.", 

  true)

;; ---- false?

DefaultBehavior Boolean false? = method(
  "returns false.", 

  false)

false false? = method(
  "returns true.", 

  true)

nil false? = method(
  "returns true.", 

  true)

;; ---- true?

DefaultBehavior Boolean true? = method(
  "returns true", 

  true)

false true? = method(
  "returns false", 

  false)

nil true? = method(
  "returns false", 

  false)

;; ---- ifTrue

true ifTrue = dmacro(
  "Evaluates the argument and returns true",

  [>then]
  @)

false ifTrue = dmacro(
  "Does not evaluate argument and returns false",

  [then]
  @)

;; ---- ifFalse

true ifFalse = dmacro(
  "Does not evaluate argument and returns true",

  [then]
  @)

false ifFalse = dmacro(
  "Evaluates the argument and returns false",

  [>then]
  @)

;; ---- not

DefaultBehavior Boolean not = method(
  "Does not evaluate arguments and returns nil",

  nil)

true not = method(
  "Does not evaluate arguments and returns false",

  false)

false not = method(
  "Does not evaluate arguments and returns true",

  true)

nil not = method(
  "Does not evaluate arguments and returns true",

  true)


;; ---- xor

DefaultBehavior Boolean xor = dmacro(
  "Evaluates the argument and returns the inverse of the argument",

  [>then]
  if(then, false, true))

true xor = dmacro(
  "Evaluates the argument and returns the inverse of the argument",

  [>then]
  if(then, false, true))

false xor = dmacro(
  "Evaluates the argument and returns the inverse of the inverse of the argument",

  [>then]
  if(then, true, false))

nil xor = dmacro(
  "Evaluates the argument and returns the inverse of the inverse of the argument",

  [>then]
  if(then, true, false))

;; ---- nor

DefaultBehavior Boolean nor = dmacro(
  "Does not evaluate its argument and returns false",

  [other]
  false)

true nor = dmacro(
  "Does not evaluate its argument and returns false",

  [other]
  false)

false nor = dmacro(
  "Evaluates its argument and returns the inverse of it",

  [>other]
  if(other, false, true))

nil nor = dmacro(
  "Evaluates its argument and returns the inverse of it",

  [>other]
  if(other, false, true))

;; ---- nand

DefaultBehavior Boolean nand = dmacro(
  "Evaluates its argument and returns the inverse of it",
  
  [>other]
  if(other, false, true))

true nand = dmacro(
  "Evaluates its argument and returns the inverse of it",

  [>other]
  if(other, false, true))

false nand = dmacro(
  "Does not evaluate its argument and returns true",

  [other]
  true)

nil nand = dmacro(
  "Does not evaluate its argument and returns true",

  [other]
  true)


nil inspect = "nil"
nil notice = "nil"

true inspect = "true"
true notice = "true"

false inspect = "false"
false notice = "false"
