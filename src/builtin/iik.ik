

IIk = Origin mimic do(
  Exit = Condition mimic

  mainContext = Ground mimic do(

    exit = method(signal!(IIk Exit))

    aliasMethod("exit", "quit"))

  out = System out
  err = System err
  in  = System in

  mainLoop = method(
    "Runs the main loop of IIk, continously reading input from 'System in' until the interpreter is quitted in some of the standard ways",


    debugger = Origin mimic
    System currentDebugger = debugger
    debugger invoke = method(
      condition, context, 
      invokeRestart(:abort)
    )

    io = if(IIk cell?(:ReadlineInputMethod),
      ReadlineInputMethod new,
      StdioInputMethod new)

    bind(
      rescue(IIk Exit, fn(c, out println("Bye."))),
      restart(quit, fn()),
    
      loop(
        bind(
          restart(abort, fn()),

          if(io eof?, invokeRestart(:quit))

          out println("+> #{Message fromText(io gets) evaluateOn(mainContext) inspect}")
          out println)))))

use("builtin/iik/inputMethod")

System ifMain(IIk mainLoop)
