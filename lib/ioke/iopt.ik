IOpt = Origin mimic 
;; read the documentation at iopt/doc.ik
use("iopt/conditions")
use("iopt/commandLine")
use("iopt/action")
use("iopt/help")

IOpt do(
  
  initialize = method(
    @iopt:receiver = nil
    @iopt:actions = dict()
    @iopt:help = dict(plain: IOpt Help Plain Simple mimic(self))
    @initialize = method())

  iopt:ion = method("If the argument is a valid option name, it MUST return
    an object with the following cells:
    
    short: an string like '-' if it is a short option, otherwise nil.
           this value must be '-' or whatever prefix you use for short options.
    option e.g. '-f', '--foo'. this value will be used to look for the
           the option action by the iopt:get method.
    immediate: if non-nil indicates this option has an immediate value,
               for example in --foo=bar the inlined value should be bar
               for short options like -l22 it should be 22.

    If the argument is not a valid option name, return nil.

    IOpt imposes no restriction on how an option looks like, by default
    this method handles traditional unix style options. -f --foo. 
    But you can easily change that and have your options look like you
    want for example like Mike tasks or windows /? style options if you
    override this method.
    ", arg,
    if(m = #/^-({long}-)?({name}[\\w_-]+)(=({immediate}.+))?$/ match(arg),
      if(m long nil? && m immediate nil? && m name length > 1,
        m immediate = m name[1..-1]
        m name = m name[0..0])
      m short = if(m long, nil, "-")
      m option = if(m long, "--", "-") + m name
      m))

  iopt:key = method("Return non-nil if the argument is an option keyword.
    If non-nil, the object should have the following cells defined:

    name: The keyword name
    immediate: The value if it has been provided with the keyword.

    ", arg,
    #/({name}[\\w_-]+):({immediate}.+)?$/ match(arg))

  iopt:get = method("Return the handler for option", arg,
    if(handler = iopt:ion(arg),
      if(handler action = iopt:actions[handler option],
        unless(handler action mimics?(IOpt Action),
          signal!(NoActionForOption, text: "Not a valid action for #{arg}",
            option: arg, value: handler action)))
      handler))
  
  cell("[]") = method("Return the action handling the option given as argument",
    arg, if(h = iopt:get(arg), if(h cell?(:action), h action)))
  
  cell("[]=") = macro("Create an action that handles the options given as indeces.
    This RHS action can be one of several things:
    
    nil - Will unregister the options from this object.
    Symbol - Will create an Action CellActivation that will activate the cell with
             that name upon execution.
    :@     - Will create an Action CellAssignment that will store the required 
             option argument on the named cell.
             e.g. :@here will store its value in cell(:here)
    Text   - Will create an alias for the RHS option.
    Action - Will register the action to handle options.
    Message - Will create an Action MessageEvaluation that will evaluate the 
              message given on the action receiver.
    value  - Will create an Action ValueActivation that will activate the given
             value, this can anything like Method, LexicalContext, Macros, etc.
    ",
    options = set()
    call arguments butLast each(i, a, 
      a = call argAt(i)
      unless(m = iopt:ion(a), 
        signal!(MalformedOption, text: "Not a valid option: #{a}", option: a))
      options << m option)
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
        signal!(MalformedOption, text: "Not a valid option: #{action}", option: action))
      unless(action = iopt:actions[o option],
        signal!(NoActionForOption, 
          text: "No action registered for option #{o option}", option: o option)),
        
      "Message",
      action = Action MessageEvaluation mimic(action),
        
      unless(cell(:action) mimics?(Action),
        action = Action ValueActivation mimic(cell(:action))))
    
    action iopt = self
    if(@cell("iopt:receiver"), action receiver = iopt:receiver)
    
    options each(o, action options << o. iopt:actions[o] = action)
    action)

  on = dmacro("You can use this to create actions having an object as receiver.

    - If the first arguments are options, the remaining arguments
      will be used to create a LexicalBlock which will be the action handler.
      These lexical blocks can access '@' and 'self' cells that reference
      the action receiver. (in this case the iopt object itself)

         on(\"-h\", \"--help\", \"Show help\", @println. System exit)
       
    - If only given one argument, will return a mimic of self, having
      the given argument as receiver for all actions created with it.

         opts = IOpt on(myApp)
         opts on(\"--me\", \"Print myApp\", @println)
         opts on(\"--path\", \"Set the path cell on myApp\", :@path)
         opts on(\"-f\", \"Call method doSomething on myApp\", :doSomething)

     - If the first argument is an object the remaining arguments
       are used to create a lexicalBlock to handle the action, having
       the first argument as receiver.
         
          on(myApp, \"-v\", \"Print myApp version\", @version println)
    ",
    []
    self,
    
    [>receiver]
    other = @mimic
    other iopt:receiver = cell(:receiver)
    other,


    [>receiver, +args]
    options = list()
    body = nil
    action = nil
    if(cell(:receiver) kind?("Text"), 
      unless(handler = iopt:ion(receiver),
        signal!(MalformedOption, text: "Not a valid option: #{receiver}", option: receiver))
      receiver = nil
      options << handler option)
    while(args first name == :"internal:createText" && args first last == args first && 
      handler = iopt:ion(args first evaluateOn(call ground, call receiver)),
      options << handler option
      args = args rest)
    body = args inject('fn, m, a, m << a) evaluateOn(call ground, call receiver)
    
    if(args last symbol?,
      name = if(args last name == :":@", 
        :("@#{args last next name}"), call argAt(call arguments length - 1))
      action = options inject(name, a, f, @[f] = a)
      if(cell(:body) documentation, action documentation = cell(:body) documentation),
      action = options inject(cell(:body), a, f, @[f] = a))
    
    if(cell(:receiver), action receiver = cell(:receiver))
    action
  );on

  cell("on=") = dmacro(
    [first, second, +rest]
    call resendToValue(@cell(:on))
  )

  parse! = method("Execute the options specified on argv.
    
    This method will first obtain the actions for each option present on argv,
    consume option arguments for each of them according to their arity. 
    
    The argument given to this method will be stored at cell argv on this object.
    Elements from argv not consumed by any option will be available at 
    programArguments cell on this object.
    
    After processing the command line, each action will be executed by priority.
    
    See CommandLine initialize for a list of keyword arguments
    ", argv, errorUnknownOptions: true, +:krest,
    cmd = CommandLine mimic(self, argv, *krest)
    @argv = cmd argv
    @programArguments = cmd programArguments
    @rest = cmd rest
    
    if(errorUnknownOptions && !cmd unknownOptions empty?,
      error!(UnknownOption, text: "Unknown options: %[%s %]" format(cmd unknownOptions)))

    cmd execute
  );parse!

  parse = method("Just parse the command line, don't execute actions.
    
    If you need to do advanced stuff, like validate mutual exclusive options, or handle
    unknown options in some way, executing only some actions under certain conditions, 
    then this method is for you.
    
    See CommandLine initialize for a list of keyword arguments",
    argv, +:krest,
    CommandLine mimic(self, argv, *krest))

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
