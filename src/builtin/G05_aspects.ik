
DefaultBehavior Aspects before = method(cellName, 
  Pointcut with(receiver: self, cellName: cellName, type: :before))

DefaultBehavior Aspects Pointcut = Origin mimic

DefaultBehavior Aspects Pointcut advice? = method(obj,
  cell(:obj) kind?("LexicalMacro") && cell(:obj) cell?(:advice)
)

DefaultBehavior Aspects Pointcut cell("<<") = method(advice,
  primary = if(self cell(:receiver) cell?(cellName), 
    self cell(:receiver) cell(cellName), 
    nil ;; this should really an fn that throws a no such cell thingy
  )

  case(type,
    :before,
    theLecro = lecro(
      call activateValue(cell(:advice))
      call resendToValue(cell(:primary)))
    cell(:theLecro) pointCut = self
    cell(:theLecro) primary = cell(:primary)
    if(advice?(cell(:primary)), cell(:primary) outerAdvice = theLecro)
    self cell(:receiver) cell(cellName) = cell(:theLecro)
  )
  
  self
)
