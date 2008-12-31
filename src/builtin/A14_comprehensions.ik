


DefaultBehavior FlowControl for = macro(
  theCode = DefaultBehavior FlowControl cell(:for) transform(call)
;  theCode formattedCode println
  theCode evaluateOn(call ground, self)
)

DefaultBehavior FlowControl cell(:for) transform = method(call,
  len = call arguments length
  if(len == 2,
    generator = call arguments first deepCopy

    generatorSource = generator next arguments first
    generator next = nil
    
    generatorLast = generatorSource
    while(generatorLast next,
      generatorLast = generatorLast next)

    mapMessage = DefaultBehavior message("map")
    mapMessage appendArgument(generator)
    mapMessage appendArgument(call arguments[1])

    generatorLast next = mapMessage
    
    generatorSource,

    ;;   x <- 1..5, y <- 2..3, x+y
    ;; should be
    ;; 1..5 flatMap(x, for(y <- 2..3, x+y))

    generator = call arguments first deepCopy

    generatorSource = generator next arguments first
    generator next = nil
    
    generatorLast = generatorSource
    while(generatorLast next,
      generatorLast = generatorLast next)

    mapMessage = DefaultBehavior message("flatMap")
    mapMessage appendArgument(generator)

    forMessage = DefaultBehavior message("for")
    call arguments[1..-1] each(arg,
      forMessage appendArgument(arg))

    mapMessage appendArgument(forMessage)

    generatorLast next = mapMessage
    
    generatorSource
  )
)
