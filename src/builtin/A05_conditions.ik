
;; Default condition hierarchy

Condition Error Arithmetic       = Condition Error mimic
Condition Error CantMimicOddball = Condition Error mimic
Condition Error Invocation       = Condition Error mimic
Condition Error IO               = Condition Error mimic
Condition Error Load             = Condition Error mimic
Condition Error NoSuchCell       = Condition Error mimic
Condition Error ModifyOnFrozen   = Condition Error mimic
Condition Error Type             = Condition Error mimic
Condition Error Index            = Condition Error mimic
Condition Error RestartNotActive = Condition Error mimic
Condition Error CommandLine      = Condition Error mimic
Condition Error JavaException    = Condition Error mimic
Condition Error Parser           = Condition Error mimic


Condition Error Parser OpShuffle                       = Condition Error Parser mimic

Condition Error CommandLine DontUnderstandOption       = Condition Error CommandLine mimic

Condition Error Arithmetic DivisionByZero              = Condition Error Arithmetic mimic
Condition Error Arithmetic NotParseable                = Condition Error Arithmetic mimic

Condition Error Invocation NotActivatable              = Condition Error Invocation mimic
Condition Error Invocation ArgumentWithoutDefaultValue = Condition Error Invocation mimic
Condition Error Invocation TooFewArguments             = Condition Error Invocation mimic
Condition Error Invocation TooManyArguments            = Condition Error Invocation mimic
Condition Error Invocation MismatchedKeywords          = Condition Error Invocation mimic
Condition Error Invocation NotSpreadable               = Condition Error Invocation mimic
Condition Error Invocation NoMatch                     = Condition Error Invocation mimic

Condition Error Type IncorrectType = Condition Error Type mimic

Condition Error text = "condition reported"

Condition report = method(
  "default implementation of reporting that only prints the name of the condition, and a stack trace",
  
  "#{self text} (#{self kind})

#{context stackTraceAsText}")


Condition Error JavaException report = method(
  "returns a representation of this error, showing some information about the java exception",
  
  stackTrace = "%[  %s\n%]" format(self exceptionStackTrace)

  "#{self exceptionType}: #{self exceptionMessage} (#{self kind})

#{stackTrace}

#{message asStackTraceText}
#{context stackTraceAsText}")

Condition Error Load report = method(
  "returns a representation of this error, showing the name of the module that couldn't be loaded, and if an ioexception occured, the message and stack trace of this",
  
  "couldn't load module '#{moduleName}' (#{self kind})

#{message asStackTraceText}
#{context stackTraceAsText}")


Condition Error noticeFor = method(obj,
  bind(rescue(Condition Error, fn(c, obj kind)),
    if(obj cell?(:notice),
      obj notice,
      obj kind)))

Condition Error NoSuchCell report = method(
  "returns a representation of this error, showing the name of the missing cell and the object that didn't have it",

  "couldn't find cell '#{cellName}' on '#{noticeFor(receiver)}' (#{self kind})

#{message asStackTraceText}
#{context stackTraceAsText}")


Condition Error Invocation MismatchedKeywords report = method(
  "returns a representation of this error, printing the given keywords that wasn't expected",

  "didn't expect keyword arguments: #{noticeFor(extra)} given to '#{message name}' (#{self kind})

#{message asStackTraceText}
#{context stackTraceAsText}")


Condition Error Invocation TooManyArguments report = method(
  "returns a representation of this error, printing the given argument values that wasn't expected",

  "didn't expect these arguments: #{noticeFor(extra)} given to '#{message name}' (#{self kind})

#{message asStackTraceText}
#{context stackTraceAsText}")


Condition Error Invocation TooFewArguments report = method(
  "returns a representation of this error, printing how many arguments were missing",

  "didn't get enough arguments: #{missing} missing, to '#{message name}' (#{self kind})

#{message asStackTraceText}
#{context stackTraceAsText}")


Condition Error Invocation ArgumentWithoutDefaultValue report = method(
  "returns a representation of this error, printing the name and position of the argument that didn't have a default value",

  "didn't get a default value to argument '#{argumentName}' at position #{index}, following an optional argument when defining a method (#{self kind})

#{message asStackTraceText}
#{context stackTraceAsText}")


Condition Error Invocation NotSpreadable report = method(
  "returns a representation of this error, printing the object that couldn't be spread",

  "can't spread value '#{noticeFor(given)}' given to method '#{message name}' (#{self kind})

#{message asStackTraceText}
#{context stackTraceAsText}")

Condition Error Invocation NoMatch report = method(
  "returns a representation of this error",

  "couldn't match arguments to '#{message name}' (#{self kind})

#{message asStackTraceText}
#{context stackTraceAsText}")

Condition Warning Default report = method(
  "returns a representation of this warning. by default returns the 'text' cell",
  text)

Condition Error Default report   = method(
  "returns a representation of this error. by default returns the 'text' cell",
  text)
