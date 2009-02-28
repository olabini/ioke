

IIk = Origin mimic do(
  Exit = Condition mimic

  mainContext = Origin mimic do(

    exit = method(signal!(IIk Exit))
    abort = method(invokeRestart(:abort))

    aliasMethod("exit", "quit"))

  out = System out
  err = System err
  in  = System in

  mainLoop = method(
    "Runs the main loop of IIk, continously reading input from 'System in' until the interpreter is quitted in some of the standard ways",


    io = if(IIk cell?(:ReadlineInputMethod),
      ReadlineInputMethod new,
      StdioInputMethod new)

    System currentDebugger = IokeDebugger with(io: io, out: out)

    bind(
      rescue(IIk Exit, fn(c, out println("Bye."))),
      restart(quit, fn()),

      loop(
        bind(
          restart(abort, fn()),

          data = io gets

          if(!data || (io eof?), invokeRestart(:quit))

          out println("+> #{Message fromText(data) evaluateOn(mainContext) inspect}")
          out println)))))

use("builtin/iik/inputMethod")

bind(
  rescue(Condition Error Load, fn(ignored, nil)),
  use("debugger"))

System ifMain(IIk mainLoop)
