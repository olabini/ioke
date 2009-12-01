
DefaultBehavior FlowControl for = syntax(
  DefaultBehavior FlowControl cell(:for) transform(call arguments, "map", "flatMap")
)

DefaultBehavior FlowControl for:set = syntax(
  DefaultBehavior FlowControl cell(:for) transform(call arguments, "map:set", "flatMap:set")
)

DefaultBehavior FlowControl for:dict = syntax(
  DefaultBehavior FlowControl cell(:for) transform(call arguments, "map:dict", "flatMap:dict")
)

DefaultBehavior FlowControl p:for = syntax(
  DefaultBehavior FlowControl cell(:for) transform(call arguments, "p:map", "p:flatMap")
)

DefaultBehavior FlowControl p:for:set = syntax(
  DefaultBehavior FlowControl cell(:for) transform(call arguments, "p:map:set", "p:flatMap:set")
)

DefaultBehavior FlowControl p:for:dict = syntax(
  DefaultBehavior FlowControl cell(:for) transform(call arguments, "p:map:dict", "p:flatMap:dict")
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
      (currentMessage -> '.) -> ccc
      currentMessage = ccc)
    (currentMessage -> '.) -> msg
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
      generator -> nil

      generatorLast = generatorSource last

      lastGenerator = generatorLast
      lastGeneratorVarName = generator

      mapMessage = DefaultBehavior message(if(generatorCount == 0, mapName, flatMapName))

      mapMessage << generator
      generatorLast next = mapMessage

      if(first == nil,
        first = generatorSource,

        current << withAssignments(assignments, generatorSource)
        assignments = [])
      current = mapMessage,

      if(assignment?(msg),
        assignments << msg,

        filterMessage = ('filter << lastGeneratorVarName) << withAssignments(assignments, msg)
        filterMessage -> lastGenerator next
        lastGenerator -> filterMessage)
    )
  )

  current << withAssignments(assignments, arguments[-1])
  first
)
