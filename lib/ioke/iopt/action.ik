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
         kargs[:"@"] = kargs[:self] = receiver)
      call activateValue(@cell(:valueToActivate), receiver, *kargs))
    
  );ValueActivation

  CellActivation = IOpt Action mimic do (
    initialize = method(cellName,
      init
      @cellName = cellName)

    cell(:documentation) = method(
      if(receiver, @documentation = receiver cell(cellName) documentation, nil))

    argumentsCode = method(
      if(receiver, receiver cell(cellName) argumentsCode, nil))
    
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
    @options = set()
    @priority = 0
  )

  receiver = method(if(@cell?(:iopt), iopt iopt:receiver || iopt))

  <=> = method("Compare by priority", other, priority <=> other priority)
  
  cell("priority=") = method("Set the option priority. 
    Default priority level is 0.
    Negative values are higher priority for options that
    must be processed before those having priority(0).
    Positive ones are executed just after all priority(0)",
    value,
    @cell(:priority) = value
    self)

  ; The object used to coerce arguments for this action.
  coerce = nil
  coercing = method(+types, +:coersions,
    @coerce = IOpt CommandLine Coerce mimic(*types, *coersions)
    self)

  consume = method("Take arguments for this action according to its arity.
    
    The argv list must have its first element be one of the options handled by this action
    otherwise a NoActionForOption will be signaled.
    
    This method returns an object with the following cells: 

      option: The option that was processed
      remnant: The elements from argv that were not taken as arguments for this action.
      positional: A list of positional arguments for this action.
      keywords: A dict of keyword arguments for this action.
      
    ", argv, handler iopt iopt:ion(argv first), untilNextOption: true, coerce: nil,
    if(handler nil? || !options include?(handler option),
      error!(NoActionForOption, 
        text: "Cannot handle option %s not in %s" format(
          if(handler, handler option, argv first), options inspect),
        option: if(handler, handler option, argv first)))

    remnant = argv rest
    currentKey = nil
    args = list()
    klist = list()
    kmap = dict()

    coerced = fn(txt,
      if(coerce == false || @coerce == false, txt,
        (coerce || @coerce || IOpt CommandLine Coerce mimic) coerce(txt)))

    shouldContinue = fn(arg, 
      cond(
        ;; if we have found the next option
        untilNextOption && iopt[arg], false,

        ;; if we need a value for a keyword argument
        currentKey, true,
        
        !(arity names empty? || arity keywords empty?),
        (klist length + args length) < (arity keywords length + arity names length),

        arity names empty? && arity keywords empty?,
        arity krest || arity rest,
        
        arity names empty?,
        arity krest || klist length < arity keywords length,
        
        arity keywords empty?, 
        arity rest || args length < arity names length,
        
        false))

    if(handler short && handler immediate && !arity positional?,
      opt = iopt iopt:get(handler short + handler immediate)
      if(opt && opt action && opt short,
        remnant = [handler short + handler immediate] + remnant
        handler immediate = nil))
      
    if(handler immediate && arity positional?, args << coerced(handler immediate))

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
          kmap[keyword] = coerced(key immediate)
          if(key immediate, klist << keyword, currentKey = keyword))
        false,

        currentKey, ;; set last keyword if missing value
        klist << currentKey
        kmap[currentKey] = coerced(arg)
        currentKey = nil,
        
        args << coerced(arg)
        false))

    Origin with(
      option: handler option,
      remnant: remnant[(idx || 0-1)..-1],
      positional: args,
      keywords: kmap)

  );consume

  perform = method(args, iopt nil,
    messageName = args option
    let(@cell(messageName), @cell(:call),
      @iopt, if(@cell?(:iopt), iopt || @iopt, iopt),
      send(messageName, *(args positional), *(args keywords))))

  argumentsCode = nil
  arity = method(@arity = Arity from(argumentsCode))

  Arity = Origin mimic do(

    emptyCode? = method(argumentsCode,
      argumentsCode nil? || argumentsCode == "..." || argumentsCode empty?)

    from = method(activableOrCode,
      arity = mimic
      case(cell(:activableOrCode) kind,
        "Text", argumentsCode = activableOrCode,
        "nil", argumentsCode = nil,
        argumentsCode = cell(:activableOrCode) argumentsCode)
      unless(emptyCode?(argumentsCode),
        dummy = Message fromText("fn(#{argumentsCode}, nil)")
        dummy = dummy evaluateOn(dummy)
        arity names = dummy argumentNames
        arity keywords = dummy keywords
        arity rest = if(match = #/\\+([^: ,]+)/ match(argumentsCode), :(match[1]))
        arity krest = if(match = #/\\+:([^ ,]+)/ match(argumentsCode), :(match[1])))
      arity)

    initialize = method(
      @names = list()
      @keywords = list()
      @rest = nil
      @krest = nil)

    empty? = method(
      names empty? && keywords empty? && rest nil? && krest nil?)

    keywords? = method(
      !(keywords empty? && krest nil?))

    positional? = method(
      !(names empty? && rest nil?))
    
    takeKey? = method(key,
      keywords include?(key) || !krest nil?)
    
  ); Arity
  
); IOpt Action
