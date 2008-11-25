

IIk = Origin mimic

IIk Exit = Condition mimic
IIk mainContext = Ground mimic
IIk mainContext exit = method(signal!(IIk Exit))
IIk mainContext aliasMethod("exit", "quit")

IIk mainLoop = method(
  "Runs the main loop of IIk, continously reading input from 'System in' until the interpreter is quitted in some of the standard ways",

  out = System out
  err = System err
  in  = System in

  bind(
    rescue(IIk Exit, fn(c, out println("Bye."))),
    loop(
      bind(
        rescue(Condition Error, fn(c, err println("*** - #{c report}"))),
        out print("iik> ")
        out println("+> #{in read evaluateOn(mainContext) inspect}")
        out println))))

System ifMain(IIk mainLoop)
