
DefaultBehavior Aspects before = method(+joinPoints, 
  Pointcut with(receiver: self, joinPoints: joinPoints, type: :before))

DefaultBehavior Aspects Pointcut = Origin mimic

DefaultBehavior Aspects Pointcut advice? = method(obj,
  cell(:obj) kind?("LexicalMacro") && cell(:obj) cell?(:advice)
)

DefaultBehavior Aspects Pointcut cacheCall? = method(obj,
  case(cell(:obj) kind,
    "DefaultMethod", true,
    "LexicalBlock", true,
    "LexicalMacro", true,
    "DefaultMacro", true,
    "DefaultSyntax", true,
    false)
)

DefaultBehavior Aspects Pointcut cell("<<") = method(advice,
  joinPoints each(cellName,
    primary = if(self cell(:receiver) cell?(cellName), 
      self cell(:receiver) cell(cellName), 
      macro(
        bind(restart(useValue, fn(newValue, newValue)),
          error!(Condition Error NoSuchCell, message: call message, context: call ground, receiver: call receiver, cellName: call message name))
      )
    )

    theLecro = nil
    case(type,
      :before,
      theLecro = if(cacheCall?(cell(:advice)),
        if(cacheCall?(cell(:primary)),
          lecro(
            call activateValueWithCachedArguments(cell(:advice))
            call activateValueWithCachedArguments(cell(:primary))),
          lecro(
            call activateValueWithCachedArguments(cell(:advice))
            call resendToValue(cell(:primary)))),
        if(cacheCall?(cell(:primary)),
          lecro(
            call activateValue(cell(:advice))
            call activateValueWithCachedArguments(cell(:primary))),
          lecro(
            call activateValue(cell(:advice))
            call resendToValue(cell(:primary)))))
    )

    cell(:theLecro) pointCut = self
    cell(:theLecro) primary = cell(:primary)
    cell(:theLecro) documentation = cell(:primary) documentation
    if(advice?(cell(:primary)), cell(:primary) outerAdvice = theLecro)
    self cell(:receiver) cell(cellName) = cell(:theLecro)
  )  
  self
)
