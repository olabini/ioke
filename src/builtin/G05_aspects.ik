
DefaultBehavior Aspects before = method(cellName, 
  Pointcut with(receiver: self, cellName: cellName, type: :before))

DefaultBehavior Aspects Pointcut = Origin mimic
DefaultBehavior Aspects Pointcut cell("<<") = method(advice,
  originalValue = if(self cell(:receiver) cell?(cellName), 
    self cell(:receiver) cell(cellName), 
    nil ;; this should really an fn that throws a no such cell thingy
  )

  case(type,
    :before,
    theLecro = lecro(
      call activateValue(cell(:advice))
      call resendToValue(cell(:originalValue)))
    cell(:theLecro) pointCut = self
    self cell(:receiver) cell(cellName) = cell(:theLecro)
  )
  
  self
)
