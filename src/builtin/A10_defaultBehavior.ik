
DefaultBehavior FlowControl cell("") = method(
  "returns result of evaluating first argument", 
  n, 

  ; We need to use cell here, to not activate a method-like object
  cell(:n))

DefaultBehavior Boolean - = method(
  "returns the negation of the argument", 
  obj, 

  obj negation)

DefaultBehavior FlowControl do = macro(
  "executes the arguments with the receiver as context and ground, and then returns the receiver.", 

  call arguments each(evaluateOn(cell("@")))
  cell("@"))

DefaultBehavior Definitions fnx = macro(
  "does the same things as fn, but returns something that is activatable.",

  call resendToMethod("fn") do(
    activatable = true))

DefaultBehavior Definitions lecrox = macro(
  "does the same things as lecro, but returns something that is not activatable.",

  call resendToMethod("lecro") do(
    activatable = false))

DefaultBehavior Reflection derive = method(
  "calls mimic.", 

  mimic)

DefaultBehavior Literals cell(:"'") = macro(
  "Takes one code argument and returns the message chain corresponding to this code argument. The code is copied, so it is safe to modify the resulting chain.",

  call arguments[0] deepCopy)

DefaultBehavior Literals cell(:"`") = method(
  "Takes one argument and returns a message that wraps the value of that argument. The message has no name and will be printed empty. The message is guaranteed to be created from scratch",
  value,

  Message wrap(value))

DefaultBehavior Literals cell(:"''") = macro(
  "Takes one code argument and returns the message chain corresponding to this code argument, except that any occurrance of ` and `` will be expanded in some way, based on a set of simple rules:
the argument to ` will be evaluated and what happens will depend on what the result of this evaluation is
 - if it returns a message chain, that message chain will be spliced in at the point of the ` message.
 - if it is not a message chain, the literal value will be cached, exactly like the Message#wrap method does.
if a ` form is followed by an empty message with arguments, that empty message will be deleted and the arguments to it will be added to the result of the ` form.

if a `` is encountered, a literal ` message will be inserted at that point.

all code evaluations will happen in the ground of the caller.",

  DefaultBehavior Literals cell(:"''") translate(call arguments[0] deepCopy, call ground)
)

DefaultBehavior Literals cell(:"''") avoidArgsFor? = method(msgName,
  ;; acrobatics necessary since && is not defined yet.
  if(msgName == :"internal:createText",
    return(true))
  if(msgName == :"internal:createNumber",
    return(true))
  if(msgName == :"internal:createDecimal",
    return(true))
  if(msgName == :"internal:createRegexp",
    return(true))
  false
)

DefaultBehavior Literals cell(:"''") translate = method(msg, outside,
  realNext = msg next
  if(msg name == :"`",
    toSplice = msg evalArgAt(0, outside)
    unless(toSplice mimics?(Message),
      toSplice = `toSplice)
    thePrev = msg prev
    msg become!(toSplice)
    msg prev = thePrev
    lastM = msg last
    lastM -> realNext
    if(realNext,
      if(lastM arguments length == 0,
        if(realNext name == :"",
          realNext arguments each(args, lastM << args)
          lastM -> realNext next))),

    if(msg name == :"'",
      toSplice = msg evalArgAt(0, outside)
      toSplice = if(toSplice mimics?(Message),
        toSplice deepCopy,
        toSplice = `toSplice)
      thePrev = msg prev
      msg become!(toSplice)
      msg prev = thePrev
      lastM = msg last
      lastM -> realNext
      if(realNext,
        if(lastM arguments length == 0,
          if(realNext name == :"",
            realNext arguments each(args, lastM << args)
            lastM -> realNext next))),
    
      if(msg name == :"``",
        msg name = :"`",
        if(msg name == :"''",
          msg name = :"'"))))
  unless(avoidArgsFor?(msg name),
    msg arguments each(arg, translate(arg, outside)))
  if(msg next, translate(msg next, outside))
  msg
)

DefaultBehavior Literals list = macro(
  "Takes zero or more arguments and returns a newly created list containing the result of evaluating these arguments",

  call evaluatedArguments)

DefaultBehavior Literals cell("[]") = macro(
  "Takes zero or more arguments and returns a newly created list containing the result of evaluating these arguments",

  call evaluatedArguments)

DefaultBehavior FlowControl with = macro(
  "takes any number of keyword arguments, followed by an optional code argument. will first create a new mimic of the receiver, then evaluate all the keyword arguments in order and set cells corresponding to the names of these keyword arguments to the evaluated arguments. if a code argument is supplied, it will be evaluated in the context of the newly created object, using something similar to 'do'. returns the created object.",
  
  newObject = mimic
  call arguments each(arg, 
    if(arg keyword?, 
      newObject cell(arg name asText[0..0-2]) = arg next evaluateOn(call ground),
      newObject doMessage(arg)))
  newObject)

DefaultBehavior Conditions warn! = method(
  "takes the same kind of arguments as 'signal!', and will signal a condition. the default condition used is Condition Warning Default. a restart called 'ignore' will be established. if no rescue or restart is invoked warn! will report a warning to System err.",
  datum, +:krest,

  if(datum kind?("Text"), 
    datum = Condition Warning Default with(text: datum))
  bind(
    restart(ignore, fn(datum)),

    result = signal!(datum, *krest)
    System err println("WARNING: #{result report}")
    result))

DefaultBehavior Reflection in? = method(
  "returns true if the receiver is included in the argument. sends 'include?' to the argument to find this out",
  aList,
  
  aList include?(self))

DefaultBehavior genSym = method(n,
  fnx(
    "returns a new, unique symbol every time called. The symbol will be quite unreadable, and uses a closure to generate a new number every time that is independent from external state.", 
    :"#<GS#{n++}>")) call(0)

DefaultBehavior Definitions generateMatchMethod = syntax(
  "takes one argument that should be the name of the match method to use. need to be called with the kind as direct receiver, either in a do-block or directly.
if the match method is called 'matchFoo' and the receiver is called Foo, will generate a method that looks like this:

method(other,
  if(self same?(Foo),
    other mimics?(Foo),
    self matchFoo(other)))
",
  otherMethod = call arguments[0]

  ''(method(other, 
      if(self same?(`self), 
        other mimics?(`self),
        bind(rescue(Condition Error, fn(c, false)),
          self `(otherMethod) (other))))))

Origin do(=== = generateMatchMethod(==))
