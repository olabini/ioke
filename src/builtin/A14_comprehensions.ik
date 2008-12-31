
DefaultBehavior FlowControl for = macro(
  theCode = DefaultBehavior FlowControl cell(:for) transform(call arguments)
;  theCode formattedCode println
  theCode evaluateOn(call ground, self)
)

DefaultBehavior FlowControl cell(:for) generator? = method(msg,
  (msg next) && (msg next name == :"<-"))

DefaultBehavior FlowControl cell(:for) transform = method(arguments,
  ;;   x <- 1..5, x
  ;; should be
  ;;   1..5 map(x, x)

  ;;   x <- 1..5, y <- 2..3, x+y
  ;; should be
  ;;   1..5 flatMap(x, for(y <- 2..3, x+y))

  ;;   x <- 1..5, x<3, x
  ;; should be
  ;;   1..5 filter(x, x<3) map(x, x)

  generatorCount = arguments count(msg, 
    DefaultBehavior FlowControl cell(:for) generator?(msg))

  first = nil
  current = nil
  lastGenerator = nil
  lastGeneratorVarName = nil
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
        mapMessage = DefaultBehavior message("map"),
        mapMessage = DefaultBehavior message("flatMap"))

      mapMessage appendArgument(generator)
      generatorLast next = mapMessage
      
      if(first == nil,
        first = generatorSource,
        current appendArgument(generatorSource))
      current = mapMessage,
      
      filterMessage = DefaultBehavior message("filter")
      filterMessage appendArgument(lastGeneratorVarName)
      filterMessage appendArgument(msg)
      filterMessage next = lastGenerator next
      lastGenerator next = filterMessage
    )
  )
  current appendArgument(arguments[-1])
  first
)
