

IIk = Origin mimic do(
  Exit = Condition mimic

  mainContext = Origin mimic do(

    exit = method(signal!(IIk Exit))
    abort = method(invokeRestart(:abort))

    aliasMethod("exit", "quit"))

  out = System out
  err = System err
  in  = System in
  
  nested? = method(data,
    escaped? = false. inText? = false. inAltText? = false. couldBeText? = false
    open = Origin with(parens: 0, squares: 0, anyOpen?: method(parens + squares > 0))

    checkText = fnx(c,
      case(c,
        "\\", escaped? = !escaped?,
        "\"", if(!escaped?, inText? = false). escaped? = false,
      ))

    checkAltText = fnx(c,
      case(c,
        "\\", escaped? = !escaped?,
        "]", if(!escaped?, inAltText? = false). escaped? = false
      ))
    
    checkRegularContent = fnx(c,
      case(c,
        "\"", inText? = true,
        "(", open parens++,
        ")", open parens--,
        "[", if(couldBeText?, inAltText? = true. couldBeText? = false, open squares++),
        "]", open squares--,
        "#", couldBeText? = true
      ))

    data chars each(c,
      if(inText?,
        checkText(c),
        if(inAltText?,
          checkAltText(c),
          checkRegularContent(c))))
    open anyOpen? || inText? || inAltText?)

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
