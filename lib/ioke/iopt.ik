IOpt = Origin mimic 
;; read the guide at iopt/help.ik
use("iopt/conditions")
use("iopt/action")
use("iopt/help")

IOpt do(
  
  initialize = method(
    @iopt:receiver = nil
    @iopt:actions = dict()
    @iopt:help = dict(plain: IOpt Help Plain Simple mimic(self))
    @initialize = method())

  iopt:ion = method("If the argument is a valid option name, it returns
    an object with the following cells: 
    
    long: non-nil if it is a long option.
    flag: e.g. -f, --foo. this value can be used to look for the
          the option action.
    immediate: if non-nil indicates this option has an immediate value,
               for example in --foo=bar the inlined value should be bar
               for short options like -l22 it should be 22.

    If the argument is not a valid option name, return nil.

    IOpt imposes no restriction on how an option looks like, by default
    this method handles traditional unix style options. -f --foo. 
    But you can easily change that and have your options look like you
    want for example like Mike tasks or windows /? style flags if you
    override this method.
    ", arg,
    if(m = #/^-({long}-)?({name}[\\w_-]+)(=({immediate}.+))?$/ match(arg),
      if(m long nil? && m immediate nil? && m name length > 1,
        m immediate = m name[1..-1]
        m name = m name[0..0])
      m flag = if(m long, "--", "-") + m name
      m))

  iopt:key = method("Return non-nil if the argument is an option keyword.
    If non-nil, the object should have the following cells defined:

    name: The keyword name
    immediate: The value if it has been provided with the keyword.

    ", arg,
    #/({name}[\\w_-]+):({immediate}.+)?$/ match(arg))

  iopt:get = method("Return the handler for option", option,
    if(opt = iopt:ion(option),
      if(opt action = iopt:actions[opt flag],
        unless(opt action mimics?(IOpt Action),
          signal!(NoActionForOption, text: "Not a valid flag: #{option}",
            option: option, value: opt action))
        opt)))
  
  cell("[]") = method("Return the action handling the option given as argument",
    option, if(opt = iopt:get(option), opt action))
  
  cell("[]=") = macro("Create an option that handles the flags given as indeces 
    using the action provided at the RHS.
      
    This action can be one of several things:
    
    nil - Will unregister the flags from this object.
    Symbol - Will create an Action CellActivation that will activate the cell with
             that name upon execution.
    :@     - Will create an Action CellAssignment that will store the required 
             option argument on the named cell.
             e.g. :@here will store its value in cell(:here)
    Text   - Will create an alias for the RHS option.
    Action - Will register the flags being handled by the given action.
    Message - Will create an Action MessageEvaluation that will evaluate the 
              message given on the action receiver.
    value  - Will create an Action ValueActivation that will activate the given
             value, this can anything like Method, LexicalContext, Macros, etc.
    ",
    options = set()
    call arguments butLast each(i, a, 
      a = call argAt(i)
      unless(m = iopt:ion(a), 
        signal!(MalformedFlag, text: "Not a valid flag: #{a}", name: a))
      options << m flag)
    action = call arguments last
    action = if(action name == :":@" && action next && action next next nil?, 
      Action CellAssignment mimic(action next name),
      call argAt(call arguments length - 1))
    case(cell(:action) kind,
      "nil",  options each(o, iopt:actions[o] = nil). return,
        
      "Symbol",
      if(action asText[0..0] == "@", ;; assign a cell
        action = Action CellAssignment mimic(:(action asText[1..-1])),
        action = Action CellActivation mimic(action)),
        
      "Text", 
      o = iopt:ion(action)
      unless(o, 
        error!(MalformedFlag, text: "Not a valid flag: #{action}", name: action))
      unless(action = iopt:actions[o flag],
        signal!(NoActionForOption, 
          text: "No action registered for flag #{o flag}", option: o flag)),
        
      "Message",
      action = Action MessageEvaluation mimic(action),
        
      unless(cell(:action) mimics?(Action),
        action = Action ValueActivation mimic(cell(:action))))
    
    action iopt = self
    if(@cell("iopt:receiver"), action receiver = iopt:receiver)
    
    options each(o, action flags << o. iopt:actions[o] = action)
    action)

  on = dmacro("You can use this to create actions having an object as receiver.

    - If the first arguments are flags, the remaining arguments
       are used to create a LexicalBlock to handle the option.

         on(\"-h\", \"--help\", \"Show help\", @println. System exit)
       
    - If only given one argument, will return a mimic of self, having
      the only argument as receiver for all actions created with it.

         opts = IOpt on(myApp)
         opts[\"--path\"] = :setPath
         opts[\"-f\"] = fn(doSomething)

         --path will set the cell(:setPath) on myApp object.
         -f will call the method having myApp as receiver.

     - If the first argument is an object the remaining arguments
       are used to create a lexicalBlock to handle the action, having
       the first argument as receiver.
         
          on(myApp, \"-f\", doSomething)

     - If the last argument is just a symbol, it will be used to 
       create either an IOpt Action CellAssignment or IOpt Action CellActivation

          ;; will activate myApp cell(:setPath) upon execution
          on(myApp, \"--path\", \"Set the path to use\", :setPath)

          ;; will assign the value of myApp cell(:output)
          on(myApp, \"--output\", \"Write to this file\", :@output)
      
    ",
    []
    self,
    
    [>receiver]
    other = @mimic
    other iopt:receiver = cell(:receiver)
    other,


    [>receiver, +args]
    flags = list()
    body = nil
    action = nil
    if(cell(:receiver) kind?("Text"), 
      unless(option = iopt:ion(receiver),
        signal!(MalformedFlag, text: "Not a valid flag: #{receiver}", name: receiver))
      receiver = nil
      flags << option flag)
    while(args first name == :"internal:createText" && args first last == args first && 
      option = iopt:ion(args first evaluateOn(call ground, call receiver)),
      flags << option flag
      args = args rest)
    body = args inject('fn, m, a, m << a) evaluateOn(call ground, call receiver)
    
    if(args last symbol?,
      name = if(args last name == :":@", 
        :("@#{args last next name}"), call argAt(call arguments length - 1))
      action = flags inject(name, a, f, @[f] = a)
      if(cell(:body) documentation, action documentation = cell(:body) documentation),
      action = flags inject(cell(:body), a, f, @[f] = a))
    
    if(cell(:receiver), action receiver = cell(:receiver))
    action
  );on

  cell("on=") = dmacro(
    [first, second, +rest]
    call resendToValue(@cell(:on))
  )

  ParsedCommandLine = Origin mimic do(
    
    initialize = method(iopt, argv, argStopAtNextFlag: true,
      @iopt = iopt
      ; store the original argv
      @argv = argv
      ; an array to store not handled input
      @rest = list()
      
      ; first convert the strings to option objects.
      @options = list()

      ary = argv
      until(ary empty?,
        if(;; we can handle this option
           option = iopt iopt:get(ary first),
           options << option
           option <=> = method(o, action <=> o action)
           option args = option action consume(
             ary, option, stopAtNextFlag: argStopAtNextFlag)
           ary = option args remnant
           option args removeCell!(:remnant),
           ;; else it is not an option, we add it to rest
           rest << ary first
           ary = ary rest))
    );initialize
    
    execute = method("Execute the actions by priority",
      options sort each(o, o action perform(o args, iopt))
    )
    
  );ParsedCommandLine

  parse = method("Execute the options specified on argv.
    
    This method will first obtain the actions for each option present on argv,
    consume option arguments for each of them accoding to their arity. 
    
    The argument given to this method will be stored at cell argv on this object.
    Elements from argv not consumed by any option will be available at 
    programArguments cell on this object.
    
    After processing the command line, each action will be executed by priority.
    ", argv, argStopAtNextFlag: true,
    parsed = ParsedCommandLine mimic(self, argv, argStopAtNextFlag: argStopAtNextFlag)
    @argv = parsed argv
    @programArguments = parsed rest
    parsed execute
  );parse

  asText = method(help(:plain) asText)

  help = dmacro(
    [>format]
    iopt:help[format],

    [>format, +body]
    name = (format asText[0..0] upper) + format asText[1..-1]
    msg = ('mimic << Message wrap(self))
    body each(a, msg << a)
    iopt:help[format] = msg sendTo(IOpt Help cell(name)))
  
); IOpt
