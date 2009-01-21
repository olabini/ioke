
IokeDebugger = Origin mimic do(
  NoSuchRestart = Condition Error mimic

  currentlyRunning = []

  invoke = method(condition, context,
    newDebugger = self with(condition: condition, context: context)
    newDebugger runDebugSession
  )
  
  runDebugSession = method(
    IokeDebugger currentlyRunning << self
    len = IokeDebugger currentlyRunning length
    

    newIo = io mimic
    newIo prompt = " dbg:#{len}> "

    ensure(
      loop(
        restarts = availableRestarts(self condition)
        
        "The following restarts are available:" println
        restarts each(ix, re, out println(" %s: %-20s (%s)" format(ix, re name, re report call(re))))
        out println

        value = Message fromText(newIo gets)
        if((value name == :"internal:createNumber") && (value next name == :"."),
          restartToInvoke = value evaluateOn(condition context)
          if(restarts[restartToInvoke],
            argumentNames = restarts[restartToInvoke] argumentNames
            restartArguments = argumentNames map(name,
              newIo prompt = "  dbg:#{len}:#{name}> "
              argVal = Message fromText(newIo gets) evaluateOn(condition context)
              out println("  +> #{cell(:argVal) inspect}")
              out println

              cell(:argVal)
            )

            out println
            invokeRestart(restarts[restartToInvoke], *restartArguments)
          )
          error!(IokeDebugger NoSuchRestart, number: restartToInvoke),
          
          out println(" +> #{value evaluateOn(condition context) inspect}")
          out println)
      )

      invokeRestart(:abort),

      IokeDebugger currentlyRunning = IokeDebugger currentlyRunning[0..-2])
  )
)
