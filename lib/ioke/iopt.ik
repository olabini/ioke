IOpt = Origin mimic
use("iopt/action")
use("iopt/help")

IOpt do(
  initialize = method(
    @flags = set()
    @actions = set()
    @helps = dict(plain: IOpt Help Plain Simple mimic(self))
    @initialize = method())
  
  cell("[]") = method(option,
    if(@cell?(option) && @cell(option) mimics?(IOpt Action),
      @cell(option),
      actions find(a, a handles?(option))))

  cell("[]=") = method(+args,
    unless(value = args last,
      args[0..-2] each(k, if(@cell?(k) && @cell(k) mimics?(IOpt Action),
          @cell(k) flags each(f, @removeCell!(f))))
      return)
    unless(cell(:value) mimics?(IOpt Action),
      if(cell(:value) kind?("Text"),
        unless(value = @[value], error!("Option not defined #{value}")),
        value = IOpt Action mimic(cell(:value))))
    actions << value
    args[0..-2] each(k, value flags << k. @cell(k) = value)
    value)

  on = dmacro(
    [>forOption]
    self[forOption],

    [>flag, +body]
    
    if(cell(:flag) kind?("Text"),
      flag = list(flag)
      while(body first && body first last == body first &&
        body first name == :"internal:createText",
        a = body first evaluateOn(call ground, call receiver)
        if(#/^--?[\\w-]+/ match(a),
          flag << a
          body = body rest, break))
      handler = body inject('fn, m, a, m << a) evaluateOn(
        call ground, call receiver)
      return(self[*flag] = handler))

    receiver = cell(:flag)

    settingCell = fn(name,
      handler = lecrox(
        receiver cell(name) = call argAt(0))
      docs = "Set #{name}"
      args = unless(isQ?(name), "value")
      IOpt Action mimic(handler, docs, args))

    callingMethod = fn(name,
      handler = lecrox(call resendToValue(receiver cell(name), receiver))
      docs = if(receiver cell?(name), 
        receiver cell(name) documentation)
      args = unless(isQ?(name), 
        if(receiver cell?(name),
          if(receiver cell(name) cell?(:argumentsCode),
            receiver cell(name) argumentsCode)))
      IOpt Action mimic(handler, docs, args))

    applyingValue = fn(value,
      handler = lecrox(call resendToValue(cell(:value), receiver))
      docs = cell(:value) documentation
      args = if(cell(:value) cell?(:argumentsCode),
        cell(:value) argumentsCode)
      IOpt Action mimic(handler, docs, args))

    applyingMessage = fn(msg,
      gnd = call ground mimic
      handler = lecrox(
        args = call evaluatedArguments
        gnd it = args first
        msg evaluateOn(gnd, receiver))
      IOpt Action mimic(handler))

    cellMsg? = fn(msg, msg name == :"@" &&
      msg next && msg next next nil?) 
    
    isQ? = fn(name, name asText[-1] == "?"[0])

    flagName = fn(name, 
      name = name asText replaceAll("_", "-")
      #/[^A-Za-z0-9-]/ allMatches(name) each(m, 
        name = name replace(m, ""))
      #/[A-Z]+[a-z]*/ allMatches(name) each(m,
        name = name replace(m, "-#{m lower}"))
      name)

    action = nil
    body each(handler,
      flag = nil

      if(handler name == :"internal:createText", ;; explicit flag
        flag = handler deepCopy
        flag -> nil
        flag = flag evaluateOn(call ground)

        what = handler next
        if(cellMsg?(what),
          action = settingCell(what next name),
          what = what evaluateOn(call ground)

          if(cell(:what) kind?("Symbol"),
            action = callingMethod(what),
            if(cell(:what) kind?("Message"),
              action = applyingMessage(what),
              action = applyingValue(cell(:what))))
          ),

        ;; dont have explicit flag, built it
        if (cellMsg?(handler),
          what = handler next name
          name = flagName(what)
          flag = if(isQ?(what), "--[no-]#{name}", "--#{name}")
          action = settingCell(what), 
          what = handler evaluateOn(call ground)
          if(cell(:what) kind?("Symbol"),
            name = flagName(what)
            flag = if(isQ?(what), "--[no-]#{name}", "--#{name}")
            action = callingMethod(what),
            error!("Invalid argument")))
      )
      ;; set the flag
      unless(action, error!("Invalid arguments"))

      self[flag] = action)
    
    action) ; on


  parse = method(argv,
    @argv = argv
    ; an array to store not handled input
    @programArguments = list()
    ; first convert the strings to actions.
    ary = argv
    opts = list()
    until(ary empty?,
      if(action = self[ary first],
        res = action consume(ary)
        opts << ((action => res) do(<=> = method(o, key <=> o key)))
        ary = res remnant
        res removeCell!(:remnant),
        programArguments << ary first
        ary = ary rest))

    ;; sort them by priority to be executed
    opts sort each(pair,
      pair key handle(args: pair value, receiver: self)))

  asText = method(help(:plain) asText)

  help = dmacro(
    [>format]
    @helps[format],

    [>format, +body]
    name = (format asText[0..0] upper) + format asText[1..-1]
    msg = ('mimic << Message wrap(self))
    body each(a, msg << a)
    @helps[format] = msg sendTo(IOpt Help cell(name)))

  ); IOpt
