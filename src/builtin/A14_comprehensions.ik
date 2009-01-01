
DefaultBehavior FlowControl for = macro(
  theCode = DefaultBehavior FlowControl cell(:for) transform(call arguments, "map", "flatMap")
  theCode evaluateOn(call ground, call ground)
)

DefaultBehavior FlowControl for:set = macro(
  theCode = DefaultBehavior FlowControl cell(:for) transform(call arguments, "map:set", "flatMap:set")
  theCode evaluateOn(call ground, call ground)
)

DefaultBehavior FlowControl for:dict = macro(
  theCode = DefaultBehavior FlowControl cell(:for) transform(call arguments, "map:dict", "flatMap:dict")
  theCode evaluateOn(call ground, call ground)
)

DefaultBehavior FlowControl cell(:for) generator? = method(msg,
  (msg next) && (msg next name == :"<-"))

DefaultBehavior FlowControl cell(:for) assignment? = method(msg,
  msg name == :"=")

DefaultBehavior FlowControl cell(:for) withAssignments = method(assignments, msg,
  currentMessage = msg
  unless(assignments empty?,
    currentMessage = assignments first deepCopy
    assignments[1..-1] each(assgn,
      ccc = assgn deepCopy
      stop = DefaultBehavior message(".")
      stop next = ccc
      currentMessage next = stop
      currentMessage = ccc)
    stop = DefaultBehavior message(".")
    stop next = msg
    currentMessage next = stop
  )
  currentMessage
)

DefaultBehavior FlowControl cell(:for) transform = method(arguments, mapName, flatMapName,
  generatorCount = arguments count(msg, generator?(msg))

  first = nil
  current = nil
  lastGenerator = nil
  lastGeneratorVarName = nil
  assignments = []

  arguments[0..-2] each(msg,
    if(generator?(msg),
      generatorCount--

      generator = msg deepCopy

      generatorSource = generator next arguments first
      generator next = nil

      generatorLast = generatorSource
      while(generatorLast next,
        generatorLast = generatorLast next)

      lastGenerator = generatorLast
      lastGeneratorVarName = generator

      mapMessage = DefaultBehavior message(if(generatorCount == 0, mapName, flatMapName))

      mapMessage appendArgument(generator)
      generatorLast next = mapMessage
      
      if(first == nil,
        first = generatorSource,

        current appendArgument(withAssignments(assignments, generatorSource))
        assignments = [])
      current = mapMessage,
      
      if(assignment?(msg),
        assignments << msg,

        filterMessage = DefaultBehavior message("filter")
        filterMessage appendArgument(lastGeneratorVarName)
        filterMessage appendArgument(withAssignments(assignments, msg))
        filterMessage next = lastGenerator next
        lastGenerator next = filterMessage)
    )
  )

  current appendArgument(withAssignments(assignments, arguments[-1]))
  first
)
