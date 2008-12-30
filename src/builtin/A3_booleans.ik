
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

true ifTrue = macro(
  "Evaluates the argument and returns true",

  call argAt(0)
  @)

false ifTrue = macro(
  "Does not evaluate argument and returns false",

  @)

;; ---- ifFalse

true ifFalse = macro(
  "Does not evaluate argument and returns true",

  @)

false ifFalse = macro(
  "Evaluates the argument and returns false",

  call argAt(0)
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

;; ---- and

DefaultBehavior Boolean and = macro(
  "Evaluates the argument and returns the result",

  call argAt(0))

DefaultBehavior Boolean cell("&&") = macro(
  "Evaluates the argument and returns the result",

  call argAt(0))

true and = macro(
  "Evaluates the argument and returns the result",

  call argAt(0))

false and = macro(
  "Does not evaluate argument and returns false",

  false)

nil and = macro(
  "Does not evaluate argument and returns nil",

  nil)

;; ---- &&

true aliasMethod("and", "&&")
false aliasMethod("and", "&&")
nil aliasMethod("and", "&&")

;; ---- or

DefaultBehavior Boolean or = macro(
  "Does not evaluate argument and returns self",

  @)

DefaultBehavior Boolean cell("||") = macro(
  "Does not evaluate argument and returns self",

  @)

true or = macro(
  "Does not evaluate argument and returns true",

  true)

false or = macro(
  "Evaluates the argument and returns the result",

  call argAt(0))

nil or = macro(
  "Evaluates the argument and returns the result",

  call argAt(0))

;; ---- ||

true aliasMethod("or", "||")
false aliasMethod("or", "||")
nil aliasMethod("or", "||")

;; ---- xor

DefaultBehavior Boolean xor = macro(
  "Evaluates the argument and returns the inverse of the argument",

  if(call argAt(0), false, true))

true xor = macro(
  "Evaluates the argument and returns the inverse of the argument",

  if(call argAt(0), false, true))

false xor = macro(
  "Evaluates the argument and returns the inverse of the inverse of the argument",

  if(call argAt(0), true, false))

nil xor = macro(
  "Evaluates the argument and returns the inverse of the inverse of the argument",

  if(call argAt(0), true, false))

;; ---- nor

DefaultBehavior Boolean nor = macro(
  "Does not evaluate its argument and returns false",

  false)

true nor = macro(
  "Does not evaluate its argument and returns false",

  false)

false nor = macro(
  "Evaluates its argument and returns the inverse of it",

  if(call argAt(0), false, true))

nil nor = macro(
  "Evaluates its argument and returns the inverse of it",

  if(call argAt(0), false, true))

;; ---- nand

DefaultBehavior Boolean nand = macro(
  "Evaluates its argument and returns the inverse of it",

  if(call argAt(0), false, true))

true nand = macro(
  "Evaluates its argument and returns the inverse of it",

  if(call argAt(0), false, true))

false nand = macro(
  "Does not evaluate its argument and returns true",

  true)

nil nand = macro(
  "Does not evaluate its argument and returns true",

  true)


nil inspect = "nil"
nil notice = "nil"

true inspect = "true"
true notice = "true"

false inspect = "false"
false notice = "false"
