IOpt Action = Origin mimic
IOpt Action do(
  initialize = method(action, docs nil, args nil, plevel 0, receiver nil,
    @flags = set()
    @default = true
    @priority = plevel
    @callReceiver = cell(:receiver)
    @documentation = docs || cell(:action) documentation
    @argumentsCode = args || if(cell(:action) cell?(:argumentsCode), cell(:action) argumentsCode)
    @body = cell(:action))

  cell(:call) = macro(call activateValue(@cell(:body), callReceiver))

  <=> = method("Compare by priority", other, priority <=> other priority)

  cell("priority=") = method("Set the option priority. 
    Default priority level is 0.
    Negative values are higher priority for options that
    must be processed before those having priority(0).
    Positive ones are executed just after all priority(0)",
    value,
    @cell(:priority) = value
    self)
  
  handles? = method(option,
    flags find(flag, handleData(flag, option)))

  handleData = method(flag, option,
    d = dict()
    if(m = #/=/ match(option),
      option = m beforeMatch
      d[:immediate] = m afterMatch)
    cond(
      flag == option, d[:value] ||= @cell(:default),

      d empty? && #/^-[^-]/ match(flag) && m = #/^#{flag}/ match(option),
      d[:immediate] = m afterMatch,
      
      m = #/\\[(.*?)\\]/ match(flag),
      case(option,
        m beforeMatch + m afterMatch,
        d[:value] ||= @cell(:default),
        m beforeMatch + m[1] + m afterMatch,
        d[:value] ||= if(@cell?(:alternative),
          @cell(:alternative), @cell(:default) not())))
    if(d empty?, nil, d))

  cell("argumentsCode=") = method(code,
    if(code == "..." || code == "", code = nil)
    @cell(:argumentsCode) = code
    i = Origin with(names: [], keywords: [], rest: nil, krest: nil)
    unless(code, @argumentsInfo = i. return(self))
    dummy = Message fromText("fn(#{code}, nil)")
    dummy = dummy evaluateOn(dummy)
    i names = dummy argumentNames
    i keywords = dummy keywords
    i rest = if(match = #/\\+([^: ,]+)/ match(code), :(match[1]))
    i krest = if(match = #/\\+:([^ ,]+)/ match(code), :(match[1]))
    @argumentsInfo = i
    self)

  consume = method(argv,
    res = Origin mimic
    data = nil. flag = nil
    flags find(f, if(data = handleData(f, argv first), flag = f))
    unless(flag, error!("I cant handle #{argv first}"))

    info = argumentsInfo
    remnant = argv rest
    currentKey = nil
    args = list()
    klist = list()
    kmap = dict()
    
    if(data[:immediate] && info names length > 0, args << data[:immediate])

    shouldContinue = fn(arg, 
      cond(
        #/^--?/ match(arg), false, ;; found next flag
        currentKey, true, ;; expecting value for a key arg
        !(info names empty?) && !(info keywords empty?), 
        (klist length + args length) < 
        (info keywords length + info names length),
        info names empty? && info keywords empty?, 
        info krest || info rest,
        info names empty?,
        info krest || klist length < info keywords length,
        info keywords empty?, 
        info rest || args length < info names length,
        false))

    isKeyword = fn(arg,
      if(m = #/^([\\w-]+):/ match(arg),
        :(m[1]) => if(m afterMatch empty?, nil, m afterMatch)))

    idx = remnant findIndex(arg,
      cond(
        !shouldContinue(arg), true,
        
        (p = isKeyword(arg)) && ;; process keyword arg
        (info krest || info keywords include?(p key)),
        if(kmap key?(p key),
          error!("Keyword #{p key} already specified"),
          kmap[p key] = p value
          if(p value, klist << p key, currentKey = p key))
        nil, ;; continue processing
        
        currentKey, ;; set last keyword if missing value
        klist << currentKey
        kmap[currentKey] = arg
        currentKey = nil,
        
        args << arg
        nil))

    if(args empty? && kmap empty? && info names empty? &&
      !(@cell(:body) argumentsCode empty?),
      args = list(data[:immediate] || data[:value]))
    
    res flag = flag
    res remnant = remnant[(idx || 0-1)..-1]
    res named_args = args
    res keyed_args = kmap

    res)

  handle = method(argv nil, args: nil, receiver: nil, messageName: nil,
    res = if(argv, consume(argv), args)
    messageName ||= res flag
    let(@cell(messageName), @cell(:call),
      @callReceiver, @callReceiver || receiver,
      res result = send(messageName, *(res named_args), *(res keyed_args)))
    res)

  ); IOpt Action