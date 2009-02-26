IOpt Action = Origin mimic
IOpt Action do(

  ValueActivation = IOpt Action mimic do (
    initialize = method(valueToActivate,
      init
      @valueToActivate = cell(:valueToActivate)
      @argumentsCode = cell(:valueToActivate) argumentsCode
      @documentation = cell(:valueToActivate) documentation)

    call = macro(
      kargs = dict()
      if(@cell(:valueToActivate) kind?("LexicalBlock") ||
         @cell(:valueToActivate) kind?("LexicalMacro"),
         kargs[:it] = receiver)
      call activateValue(@cell(:valueToActivate), receiver, *kargs))
    
  );ValueActivation

  CellActivation = IOpt Action mimic do (
    initialize = method(cellName,
      init
      @cellName = cellName)

    cell(:documentation) = method(
      @documentation = receiver cell(cellName) documentation)

    arity = method(
      @argumentsCode = receiver cell(cellName) argumentsCode
      @arity)
    
    call = macro(call resendToValue(receiver cell(cellName), receiver))
    
  );CellActivation

  CellAssignment = IOpt Action mimic do (
    initialize = method(cellName,
      init
      @cellName = cellName
      @documentation = "Set #{cellName asText}"
      @argumentsCode = cellName asText)

    call = method(value, receiver cell(cellName) = value)
    
  );CellAssinment

  MessageEvaluation = IOpt Action mimic do (
    initialize = method(messageToEval,
      init
      @documentation = "Evaluate message #{messageToEval code}"
      @argumentsCode = nil
      @messageToEval = messageToEval)

    call = dmacro(
      []
      messageToEval evaluateOn(call ground, receiver),

      [>value]
      messageToEval evaluateOn(call ground with(it: value), receiver))
    
  );MessageEvaluation

  init = method(
    @flags = set()
    @priority = 0
  )

  receiver = method(iopt iopt:receiver || iopt)

  <=> = method("Compare by priority", other, priority <=> other priority)
  
  cell("priority=") = method("Set the option priority. 
    Default priority level is 0.
    Negative values are higher priority for options that
    must be processed before those having priority(0).
    Positive ones are executed just after all priority(0)",
    value,
    @cell(:priority) = value
    self)

  consume = method(argv,
    option = iopt iopt:ion(argv first)
    if(option nil? || !flags include?(option flag),
      error!(NoActionForOption, 
        text: "Cannot handle flag %s not in ([%%s,%])" format(
          if(option, option flag, argv first), flags),
        option: if(option, option flag, argv first)))

    remnant = argv rest
    currentKey = nil
    args = list()
    klist = list()
    kmap = dict()
    
    if(option immediate && arity names length > 0, args << option immediate)

    shouldContinue = fn(arg, 
      cond(
        iopt[arg], false, ;; found next flag

        currentKey, true, ;; expecting value for a key arg
        
        !(arity names empty?) && !(arity keywords empty?), 
        (klist length + args length) < (arity keywords length + arity names length),

        arity names empty? && arity keywords empty?,
        arity krest || arity rest,
        
        arity names empty?,
        arity krest || klist length < arity keywords length,
        
        arity keywords empty?, 
        arity rest || args length < arity names length,
        
        false))

    idx = remnant findIndex(arg,
      cond(
        !shouldContinue(arg), true,
        
        (key = iopt iopt:key(arg)) && 
        (arity krest || arity keywords include?(:(key name))),
        keyword = :(key name)
        if(kmap key?(keyword),
          error!(OptionKeywordAlreadyProvided, 
            text: "Keyword #{keyword} was specified more than once.",
            keyword: keyword),
          kmap[keyword] = key immediate
          if(key immediate, klist << keyword, currentKey = keyword))
        false,

        currentKey, ;; set last keyword if missing value
        klist << currentKey
        kmap[currentKey] = arg
        currentKey = nil,
        
        args << arg
        false))

    Origin with(
      flag: option flag, 
      remnant: remnant[(idx || 0-1)..-1],
      positional: args,
      keywords: kmap)

    );consume

  perform = method(optionArgs, iopt nil, 
    messageName = optionArgs flag
    let(@cell(messageName), @cell(:call),
      @iopt, iopt || @iopt,
      send(messageName, *(optionArgs positional), *(optionArgs keywords))))

  arityFrom = method(argumentsCode, 
    i = Origin with(names: [], keywords: [], rest: nil, krest: nil)
    if(argumentsCode nil? || argumentsCode == "..." || argumentsCode empty?, return(i))
    dummy = Message fromText("fn(#{argumentsCode}, nil)")
    dummy = dummy evaluateOn(dummy)
    i names = dummy argumentNames
    i keywords = dummy keywords
    i rest = if(match = #/\\+([^: ,]+)/ match(argumentsCode), :(match[1]))
    i krest = if(match = #/\\+:([^ ,]+)/ match(argumentsCode), :(match[1]))
    i)

  cell("argumentsCode=") = method(code,
    @cell(:argumentsCode) = code
    @arity = arityFrom(code)
    self)
  
); IOpt Action
