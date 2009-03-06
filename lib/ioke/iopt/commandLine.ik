IOpt CommandLine = Origin mimic do(
  
  initialize = method("Parses the command line arguments given on argv using iopt to handle options.
    This method takes the following arguments:

    stopAt: When non nil, it must be a text, indicating when to stop processing arguments.
    You can use this to have your program ignore arguments before -- like many unix programs.
    
    argUntilNextOption: When true, option argument processing will stop when next option is seen.

        Suppose you have an option named --foo taking one required argument and
        an also have an option named --bar.

        If argUntilNextOption is false, parsing --foo --bar will result on a single action
        (--foo) taking one argument ('--bar'). If argUntilNextOption is true, the
        parsed command line would result in two actions, each having no arguments.

        If an argument looks like an option but that option has not been registered on the
        iopt object, then it would be treated just as any other argument. e.g. 
        Parsing --foo --man would create just an action for --foo taking argument '--man'

    includeUnknownOption: When true, unknown options will be included in the programArguments list.

    coerce: a CommandLine Coerce object or false to avoid argument coercion.

    This object has the following cells available:

        argv: The original array of command line arguments.
        iopt: The IOpt object used to parse argv.
        options: A list of objects having cells: :option, :action and :args (the option arguments)
        unknownOptions: A list of elements from argv that look like options but arent.
        programArguments: A list of elements from argv that are neither an option nor par of an option arguments
        rest: A list arguments found after stopAt
    ", 
    iopt, argv, coerce: nil, argUntilNextOption: true, includeUnknownOption: true, stopAt: nil,
    
    @iopt = iopt
    @argv = argv
    @options = list()
    @unknownOptions = list()
    @programArguments = list()
    @rest = list()
    ary = argv
    
    if(stopAt,
      ary = argv takeWhile(a, case(a, stopAt, false, true))
      @rest = argv[ary length succ .. -1])

    until(ary empty?,
      if(handler = iopt iopt:get(ary first),
        if(handler action
          , ;; a recognized option
          options << handler
          handler <=> = method(o, action <=> o action)
          handler args = handler action consume(
            ary, handler, untilNextOption: argUntilNextOption, coerce: coerce)
          ary = handler args remnant
          handler args removeCell!(:remnant)
          , ;; else it just looks like an option but isnt
          unknownOptions << ary first
          if(includeUnknownOption, programArguments << ary first)
          ary = ary rest
          ),
        ;; not an option like argument
        programArguments << ary first
        ary = ary rest))
    
    );initialize

  empty? = method(options empty?)
  
  include? = method(+options, options all?(opt, @options any?(o, opt === o option)))

  execute = method("Execute the actions by priority",
    options sort each(o, o action perform(o args, iopt)))

  Coerce = Origin mimic do (

    initialize = method(+names, +:coercions,
      coercions each(pair,
        @cell("coerce_#{pair key}?") = if(
          pair value key cell?(:activatable) && pair value key activatable,
          pair value key, 
          match = pair value key
          fn(t, match === t))
        @cell("coerce_#{pair key}") = pair value value)
      all = names + coercions keys asList
      unless(all empty?, @all = all)
    )
    
    coerce = method(txt,
      all each(name,
        if(send("coerce_#{name}?", txt), 
          return( send("coerce_#{name}", txt) )))
      txt)
    
  ) mimic (
    nil:     "nil" => method(t, nil),
    boolean: #/^(true|false)$/ => method(t, t == "true"),
    symbol:  #/^:\\w+$/ => method(t, :(t[1..-1])),
    integer: #/^[+-]?\\d+$/ => method(t,
      n = Message fromText(if(#/^[+-]/ === t, t[1..-1], t)) evaluateOn(self)
      if(#/^-/ === t, n negation, n)),
    decimal: #/^[+-]?\\d+\\.(\\d+)?([eE]\\d*)?$/ => method(t, t toDecimal)
  ); Coerce
  
 );CommandLine

