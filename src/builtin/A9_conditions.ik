
;; Default condition hierarchy

Condition Error Arithmetic       = Condition Error mimic
Condition Error CantMimicOddball = Condition Error mimic
Condition Error Invocation       = Condition Error mimic
Condition Error NoSuchCell       = Condition Error mimic
Condition Error Type             = Condition Error mimic

Condition Error Arithmetic DivisionByZero = Condition Error Arithmetic mimic

Condition Error Invocation NotActivatable              = Condition Error Invocation mimic
Condition Error Invocation ArgumentWithoutDefaultValue = Condition Error Invocation mimic
Condition Error Invocation MismatchedArgumentCount     = Condition Error Invocation mimic
Condition Error Invocation MismatchedKeywords          = Condition Error Invocation mimic

Condition Error Type IncorrectType = Condition Error Type mimic


Condition Error Invocation MismatchedKeywords report = method(
  "returns a representation of this error, printing the given keywords that wasn't expected",

  start = message
  while((start prev) && ((start prev line) == message line),
    start = start prev)

  "didn't expect keyword arguments: #{extra inspect} given to '#{message name}'

#{context stackTraceAsText}")

Condition Warning Default report = method(
  "returns a representation of this warning. by default returns the 'text' cell",
  text)

Condition Error Default report   = method(
  "returns a representation of this error. by default returns the 'text' cell",
  text)
