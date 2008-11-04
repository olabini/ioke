
;; ---- !

Ground ! = method(
  "returns true if the argument is false, and false if it's true",
  arg,
  
  arg not)

;; ---- nil?

DefaultBehavior nil? = method(
  "returns false.", 

  false)

nil nil? = method(
  "returns true.", 

  true)

;; ---- false?

DefaultBehavior false? = method(
  "returns false.", 

  false)

false false? = method(
  "returns true.", 

  true)

nil false? = method(
  "returns true.", 

  true)

;; ---- true?

DefaultBehavior true? = method(
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

DefaultBehavior not = method(
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

DefaultBehavior and = macro(
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

;; ---- or

DefaultBehavior or = macro(
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
