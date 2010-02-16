

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
    escaped? = false
    inText? = false
    inAltText? = false
    inRegexp? = false
    lastChar = nil
    lastLastChar = nil
    
    lastSpecial? = method(lastChar == "#")
    
    OpenBrackets = Origin with(parens: 0, squares: 0, curlies: 0, anyOpen?: method(parens + squares + curlies > 0))
    
    initialize = method(
      @open = OpenBrackets mimic
    )
    
    checkChar = dmacro(
      [>c, >endChar, variable]
      case(c,
        "\\", @escaped? = !escaped?,
        endChar, if(!escaped?, @ cell(variable name) = false). @escaped? = false,
        else, @escaped? = false
      ))
    
    checkRegularContent = method(c,
      case(c,
        "\"", @inText? = true,
        "(", open parens++,
        ")", open parens--,
        "[", if(lastSpecial?,
            @inAltText? = true, 
            if(lastLastChar == "#" && lastChar == "r",
              @inAltRegexp? = true,
              open squares++)),
        "]", open squares--,
        "{", open curlies++,
        "}", open curlies--,
        "/", if(lastSpecial?, @inRegexp? = true),
      )
      @lastLastChar = @lastChar
      @lastChar = c)
      
      anyOpen? = method(
        data chars each(c,
          cond(
            inText?,    checkChar(c, "\"", inText?),
            inAltText?, checkChar(c, "]", inAltText?),
            inRegexp?,  checkChar(c, "/", inRegexp?),
                        checkRegularContent(c)
          ))
        open anyOpen? || inText? || inAltText? || inRegexp?
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
