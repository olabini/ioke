
;; Default condition hierarchy

Condition Error Arithmetic       = Condition Error mimic
Condition Error CantMimicOddball = Condition Error mimic
Condition Error Invocation       = Condition Error mimic
Condition Error NoSuchCell       = Condition Error mimic
Condition Error Type             = Condition Error mimic

Condition Error Arithmetic DivisionByZero = Condition Error Arithmetic mimic

Condition Error Invocation NotActivatable              = Condition Error Invocation mimic
Condition Error Invocation ArgumentWithoutDefaultValue = Condition Error Invocation mimic
Condition Error Invocation TooFewArguments             = Condition Error Invocation mimic
Condition Error Invocation TooManyArguments            = Condition Error Invocation mimic
Condition Error Invocation MismatchedKeywords          = Condition Error Invocation mimic
Condition Error Invocation NotSpreadable               = Condition Error Invocation mimic

Condition Error Type IncorrectType = Condition Error Type mimic


;; ALL REPORTS NEED TO ADD message stackTraceElement as first line. change context to do the same thing


Condition Error NoSuchCell report = method(
  "returns a representation of this error, showing the name of the missing cell and the object that didn't have it",

  "couldn't find cell '#{cellName}' on '#{receiver inspect}' (#{self kind})

#{context stackTraceAsText}")

Condition Error Invocation MismatchedKeywords report = method(
  "returns a representation of this error, printing the given keywords that wasn't expected",

  "didn't expect keyword arguments: #{extra inspect} given to '#{message name}' (#{self kind})

#{context stackTraceAsText}")


Condition Error Invocation TooManyArguments report = method(
  "returns a representation of this error, printing the given argument values that wasn't expected",

  "didn't expect these arguments: #{extra inspect} given to '#{message name}' (#{self kind})

#{context stackTraceAsText}")


Condition Error Invocation TooFewArguments report = method(
  "returns a representation of this error, printing how many arguments were missing",

  "didn't get enough arguments: #{missing} missing, to '#{message name}' (#{self kind})

#{context stackTraceAsText}")


Condition Error Invocation ArgumentWithoutDefaultValue report = method(
  "returns a representation of this error, printing the name and position of the argument that didn't have a default value",

  "didn't get a default value to argument '#{argumentName}' at position #{index}, following an optional argument when defining a method (#{self kind})

#{context stackTraceAsText}")


Condition Error Invocation NotSpreadable report = method(
  "returns a representation of this error, printing the object that couldn't be spread",

  "can't spread value '#{given inspect}' given to method '#{message name}' (#{self kind})

#{context stackTraceAsText}")



Condition Warning Default report = method(
  "returns a representation of this warning. by default returns the 'text' cell",
  text)

Condition Error Default report   = method(
  "returns a representation of this error. by default returns the 'text' cell",
  text)
