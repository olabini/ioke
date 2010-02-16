

IIk = Origin mimic do(
  Exit = Condition mimic

  mainContext = Origin mimic do(

    exit = method(signal!(IIk Exit))
    abort = method(invokeRestart(:abort))

    aliasMethod("exit", "quit"))

  out = System out
  err = System err
  in  = System in
  
  Nesting = Origin mimic do(
    RegularState = Origin mimic do(
      open? = false
      next = method(text, nestStack,
        IIk Nesting AvailableStates some(matchAgainst(text, nestStack))
      )
      
      matchAgainst = method(text, ignored,
        (text[1..-1], self)
      )
    )

    DelimitedState = Origin mimic do(
      open? = true
      escaped? = false
      startLength = 1
      next = method(text, ignored,
        rest = text[1..-1]
        case(text,
          #/\A\\/, (rest, with(escaped?: !escaped?)),
          #/\A#{end}/, if(!escaped?, (rest, IIk Nesting RegularState), (rest, with(escaped?: !escaped?))),
          else, if(escaped?, (rest, with(escaped?: !escaped?)), (rest, self)))
      )
      matchAgainst = method(text, ignored,
        if(#/\A#{start}/ =~ text, (text[(startLength)..-1], self))      
      )
    )

    TextState = DelimitedState with(start: #["], end: #["])
    AltTextState = DelimitedState with(start: #/\#\[/, end: "]", startLength: 2)
    RegexpState = DelimitedState with(start: #/\#\//, end: "/", startLength: 2)
    AltRegexpState = DelimitedState with(start: #/\#r\[/, end: "]", startLength: 3)

    DelimitedMarker = Origin mimic do(
      startLength = 1
      matchAgainst = method(text, nestStack,
        (case(text,
          #/\A#{start}/, nestStack push!(self). text[(startLength)..-1],
          #/\A#{end}/, nestStack pop!. text[1..-1],
          else, return nil
        ), IIk Nesting RegularState)
      )      
    )

    ParenthesisMarker = DelimitedMarker with(start: #/\(/, end: #/\)/)
    ListMarker = DelimitedMarker with(start: #/\[/, end: #/\]/)
    DictMarker = DelimitedMarker with(start: #/\{/, end: "}")
    SetMarker = DelimitedMarker with(start: #/\#\{/, end: "}", startLength: 2)

    AvailableStates = [ParenthesisMarker, ListMarker, DictMarker, SetMarker, TextState, AltTextState, RegexpState, AltRegexpState, RegularState]
    
    anyOpen? = method(openCount > 0)

    openCount = method(
      nestStack = []
      currentState = RegularState
      textLeft = data

      while(!textLeft empty?,
        (textLeft, currentState) = currentState next(textLeft, nestStack)
      )

      nestStack length + if(currentState open?, 1, 0)
    )
  )
  
  nested? = method(data,
    Nesting with(data: data) anyOpen?
  )

  nesting = method(data,
    Nesting with(data: data) openCount
  )

  mainLoop = method(
    "Runs the main loop of IIk, continously reading input from 'System in' until the interpreter is quitted in some of the standard ways",


    io = if(IIk cell?(:ReadlineInputMethod),
      ReadlineInputMethod new,
      StdioInputMethod new)

    System currentDebugger = IokeDebugger with(io: io, out: out)

    FileSystem["~/.iikrc"] each(x, use(x))

    if(io mimics?(ReadlineInputMethod),
      FileSystem["~/.iikhistory"] each(x,
        h = io HISTORY
        FileSystem readFully(x) split("\n") map(replaceAll("\r", "")) each(val,
          h << val)
    ))

    bind(
      rescue(IIk Exit, fn(c, out println("Bye."))),
      restart(quit, fn()),

      loop(
        bind(
          restart(abort, fn()),

          data = io gets
          while(nested?(data),
            data += io gets
          )

          FileSystem withOpenFile("~/.iikhistory", fn(f,
              unless(data empty?, f print(data))))

          if(!data || (io eof?), invokeRestart(:quit))

          out println("+> #{Message fromText(data) evaluateOn(mainContext) inspect}")
          out println)))))

use("builtin/iik/inputMethod")

bind(
  rescue(Condition Error Load, fn(ignored, nil)),
  use("debugger"))

System ifMain(IIk mainLoop)
