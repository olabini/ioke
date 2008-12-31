
DefaultBehavior FlowControl for = macro(
  theCode = DefaultBehavior FlowControl cell(:for) transform(call arguments, "map", "flatMap")
  theCode evaluateOn(call ground, self)
)

DefaultBehavior FlowControl for:set = macro(
  theCode = DefaultBehavior FlowControl cell(:for) transform(call arguments, "map:set", "flatMap:set")
  theCode evaluateOn(call ground, self)
)

DefaultBehavior FlowControl cell(:for) generator? = method(msg,
  (msg next) && (msg next name == :"<-"))

DefaultBehavior FlowControl cell(:for) transform = method(arguments, mapName, flatMapName,
  generatorCount = arguments count(msg, 
    DefaultBehavior FlowControl cell(:for) generator?(msg))

  first = nil
  current = nil
  lastGenerator = nil
  lastGeneratorVarName = nil
  assignments = []

  arguments[0..-2] each(msg,
    if(DefaultBehavior FlowControl cell(:for) generator?(msg),
      generatorCount--

      generator = msg deepCopy

      generatorSource = generator next arguments first
      generator next = nil

      generatorLast = generatorSource
      while(generatorLast next,
        generatorLast = generatorLast next)

      lastGenerator = generatorLast
      lastGeneratorVarName = generator

      mapMessage = nil
      if(generatorCount == 0,
        mapMessage = DefaultBehavior message(mapName),
        mapMessage = DefaultBehavior message(flatMapName))

      mapMessage appendArgument(generator)
      generatorLast next = mapMessage
      
      if(first == nil,
        first = generatorSource,

        currentMessage = generatorSource
        unless(assignments empty?,
          currentMessage = assignments first deepCopy
          assignments[1..-1] each(assgn,
            ccc = assgn deepCopy
            mm = DefaultBehavior message(".")
            mm next = ccc
            currentMessage next = mm
            currentMessage = ccc)
          assignments = []
          mm = DefaultBehavior message(".")
          mm next = generatorSource
          currentMessage next = mm
        )
        current appendArgument(currentMessage))
      current = mapMessage,
      
      if(msg name == :"=",
        assignments << msg,

        filterMessage = DefaultBehavior message("filter")
        filterMessage appendArgument(lastGeneratorVarName)
        currentMessage = msg
        unless(assignments empty?,
          currentMessage = assignments first deepCopy
          assignments[1..-1] each(assgn,
            ccc = assgn deepCopy
            mm = DefaultBehavior message(".")
            mm next = ccc
            currentMessage next = mm
            currentMessage = ccc)
          mm = DefaultBehavior message(".")
          mm next = msg
          currentMessage next = mm
        )

        filterMessage appendArgument(currentMessage)
        filterMessage next = lastGenerator next
        lastGenerator next = filterMessage)
    )
  )

  currentMessage = arguments[-1]
  unless(assignments empty?,
    currentMessage = assignments first deepCopy
    assignments[1..-1] each(assgn,
      ccc = assgn deepCopy
      mm = DefaultBehavior message(".")
      mm next = ccc
      currentMessage next = mm
      currentMessage = ccc)
    mm = DefaultBehavior message(".")
    mm next = arguments[-1]
    currentMessage next = mm
  )
  current appendArgument(currentMessage)
  first
)
