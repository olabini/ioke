

IIk = Origin mimic

IIk Exit = Condition mimic

IIk mainContext = Ground mimic do(
  exit = method(signal!(IIk Exit))
  aliasMethod("exit", "quit"))

IIk out = System out
IIk err = System err
IIk in  = System in

IIk mainLoop = method(
  "Runs the main loop of IIk, continously reading input from 'System in' until the interpreter is quitted in some of the standard ways",


  debugger = Origin mimic
  System currentDebugger = debugger
  debugger invoke = method(
    condition, context, 
    invokeRestart(:abort)
  )

  bind(
    rescue(IIk Exit, fn(c, out println("Bye."))),
    restart(quit, fn()),

    loop(
      bind(
        restart(abort, fn()),

        out print("iik> ")
        out println("+> #{in read evaluateOn(mainContext) inspect}")
        out println))))

System ifMain(IIk mainLoop)
