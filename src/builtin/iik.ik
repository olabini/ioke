

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
    lastChar = nil
    lastLastChar = nil
    
    lastSpecial? = method(lastChar == "#")
    lastAltRegexp? = method(lastLastChar == "#" && lastChar == "r")
    
    OpenBrackets = Origin with(parens: 0, squares: 0, curlies: 0, anyOpen?: method(parens + squares + curlies > 0))
    
    initialize = method(
      @open = OpenBrackets mimic
    )
    
    DelimitedState = Origin mimic do(
      escaped? = false
      nextState = method(c,
        result = self
        case(c,
          "\\", @escaped? = !escaped?,
          end, if(!escaped?, result = nesting RegularState with(nesting: nesting)). @escaped? = false,
          else, @escaped? = false)
        result
      )
      open? = true
    )

    TextState = DelimitedState with(end: "\"")
    AltTextState = DelimitedState with(end: "]")
    RegexpState = DelimitedState with(end: "/")
    AltRegexpState = DelimitedState with(end: "]")
    
    RegularState = Origin mimic do(
      open? = false
      nextState = method(c,
        next = case(c,
          "\"", nesting TextState with(nesting: nesting),
          "(", nesting open parens++. self,
          ")", nesting open parens--. self,
          "[", cond(
                nesting lastSpecial?,  nesting AltTextState with(nesting: nesting), 
                nesting lastAltRegexp?, nesting AltRegexpState with(nesting: nesting),
                                nesting open squares++. self),
          "]", nesting open squares--. self,
          "{", nesting open curlies++. self,
          "}", nesting open curlies--. self,
          "/", if(nesting lastSpecial?, nesting RegexpState with(nesting: nesting), self),
          else, self
          )
        nesting lastLastChar = nesting lastChar
        nesting lastChar = c
        next
      )
    )
    
    anyOpen? = method(
      state = data chars fold(RegularState with(nesting: self), state, c, state nextState(c))
      open anyOpen? || state open?
    )
  )
  
  nested? = method(data,
    Nesting with(data: data) anyOpen?
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
