Arity do (
  
  fromArgumentsCode = method(argumentsCode,
    case(argumentsCode,
      or(nil, ""), taking:nothing,
      "...", taking:everything,
      msg = Message fromText("from(#{argumentsCode})")
      if(msg next, error!("Invalid argumentsCode: "+argumentsCode))
      msg sendTo(self))
  )

  required = method("Return the names of required positional arguments.",
    positionals(false))
  
  optional = method("Return the names of optional positional arguments.",
    positionals(true) - positionals(false))

  min = method("Return the minimun number of positional arguments", positionals(false) length)
  max = method("Return the maximum number of positional arguments. A negative value indicates rest positional arguments.",
    cond(takeNothing?, 0,
      takeEverything?, -1,
      rest, -1 * (positionals(true) length + 1),
      positionals(true) length)
  )

  takeKeyword? = method(keyword,
    if(krest, true,
      keywords include?(keyword)))

  takeNothing? = method("Return true if this arity takes nothing. For things that take no arguments at all.", 
    self == taking:nothing)

  takeEverything? = method("Return true if this arity takes everything. As is the case for macros or created from argumentsCode ... , it's also the arity needed to activate a non-activatable value", 
    self == taking:everything)

  satisfied? = macro(call resendToMethod(:apply) order == 0)
  satisfiedOn? = macro(call resendToMethod(:applyOn) order == 0)

  apply = macro("Invoke arguments with this message without evaluating them",
    arguments(call message)
  )
  
  applyOn = macro("First argument must be an evaluated value, rest is the message arguments. arguments will be evaluated on the first argument.",
    on = call argAt(0)
    msg = call arguments rest inject('apply, m, a, m << a)
    arguments(msg, context: on)
  )

  arguments = method("Obtain arguments from message according to this arity.
    If a context is given, the arguments will be evaluated on context.
    
    This method returns an Arguments object, see its documentation for available cells.
    
    If the message arguments contain an splatted argument and no context is given, an
    Condition Error Invocation NotSpreadable condition will be signaled.
    ", message, context: nil, signalErrors: false,
    req = required
    o = Arguments mimic(message arguments)
    o given = message arguments

    arg = nil
    signalError = fn(+r, +:k,
      if(signalErrors,
        error!(*r, *k, message: message, context: context,
          receiver: self, given: arg, info: o)))
    
    addKeyword = fn(key, value, 
      cond(
        takeNothing?, o extraKeywords[key] = value,
        takeEverything?, o krest[key] = value,
        keywords include?(key), o keywords[key] = value,
        krest, o krest[key] = value,
        o extraKeywords[key] = value))
    
    addPositional = fn(value, 
      cond(
        takeNothing?, o extraPositional << value,
        takeEverything?, o rest << value,
        o positional length < positionals(true) length, o positional << value,
        rest, o rest << value,
        o extraPositional << value))
    
    message arguments each(arg,
      cond(
        ; a keyword argument
        arg keyword?,
        name = :(arg name asText[0..-2])
        arg = if(context, arg next evaluateOn(context), arg next)
        addKeyword(name, arg),
        
        ; an splat argument
        arg name == :"*" && arg arguments length == 1,
        arg = arg arguments first
        if(context, 
          arg = arg evaluateOn(context)
          case(arg
            List, ;; splatten positional arguments
            arg each(a, addPositional(a))
            Dict, ;; splatten keyword arguments
            arg each(p, addKeyword(p key, p value))
            ;; Not spreadable.
            o notSpreadable << arg
            signalError(Condition Error Invocation NotSpreadable)),
          o notSpreadable << arg
          signalError(Condition Error Invocation NotSpreadable)),
        
        ;; a positional keyword
        arg = if(context, arg evaluateOn(context), arg)
        addPositional(arg)
      )); each arg
  
    if(o positional length < min, 
      ; missing positional arguments
      o missing = required[o positional length..-1]
      o order = -1 * (o missing length)
      signalError(Condition Error Invocation TooFewArguments, howMany: o missing length),

      ; too many arguments
      if((o extraPositional length) + (o extraKeywords size) > 0,
        o order = (o extraPositional length) + (o extraKeywords size)
        if(o extraPositional empty?,
          signalError(Condition Error Invocation MismatchedKeywords, howMany: o extraKeywords size),
          signalError(Condition Error Invocation TooManyArguments, howMany: o order)),
                
        ; correct number of arguments
        o order = 0))
    o
  )

  Arguments = Origin mimic do (

    documentation = "Arity argument assignment.
    This object must be populated by using an Arity mimic.
    The following cells are available:

    positional - list of positional arguments 
    keywords   - dict of keyword arguments 
    rest       - list of rest positional arguments (includes all if this arity takes anything)
    krest      - dict of rest keyword arguments (includes all if this arity takes anything)
    extraPositional - list of unexpected positional arguments (includes all if this arity takes nothing)
    extraKeywords - list of unexpected keyword arguments (includes all if this arity takes nothing)
    missing    - list of missing positional argument names.
    order      - zero if satisfied, n < 0 for n missing required arguments, n > 0 for n unexpected args.
    length     - length of all arguments given (includes splatted count)
    "
    
    initialize = method(arguments, 
      @order = nil ; not processed
      @given = arguments
      @positional = list
      @keywords = dict
      @rest = list
      @krest = dict
      @extraPositional = list
      @extraKeywords = dict
      @missing = list
      @notSpreadable = list)

    length = method("Return the length of all arguments given",
      positional length + keywords size + rest length + krest size +
      extraPositional length + extraKeywords size
    )

  )
  
)

cell(:DefaultMethod) cell(:arity) = method(Arity fromArgumentsCode(argumentsCode))
cell(:DefaultMacro)  cell(:arity) = method(Arity fromArgumentsCode(argumentsCode))
cell(:DefaultSyntax) cell(:arity) = method(Arity fromArgumentsCode(argumentsCode))
cell(:JavaMethod)    cell(:arity) = method(Arity fromArgumentsCode(argumentsCode))
cell(:LexicalBlock)  cell(:arity) = method(Arity fromArgumentsCode(argumentsCode))
cell(:LexicalMacro)  cell(:arity) = method(Arity fromArgumentsCode(argumentsCode))

