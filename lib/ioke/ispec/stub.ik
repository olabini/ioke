ISpec Stubs = Origin mimic do(
  initialize = method(@all_stubs = {})
  
  on = method(object, cellName nil,
    @all_stubs[object] ||= []
    if(cellName nil?, 
      @all_stubs[object], 
      @all_stubs[object] select(stub, stub cellName == cellName))
  )
  
  addStub = method(object, cellName,
    if(on(object, cellName) empty?,
      if(object cell?(cellName), object cell("stubbed:#{cellName}") = object cell(cellName))
    
      object cell(cellName) = lecro(
        ISpec stubs receive(object, cellName, call arguments map(evaluateOn(call ground)))
      )
    ) 

    stub = ISpec Stub mimic(cellName)
    on(object) << stub
    stub
  )
    
  receive = method(object, cellName, arguments, nil
    on(object, cellName) find(stub, stub matches?(arguments)) returnValue
  )
)

ISpec stubs = ISpec Stubs mimic

ISpec ExtendedDefaultBehavior do(
  stub! = method("adds a stub to this object", cellName,
    ISpec stubs addStub(self, cellName)
  )
  
  stubs = method("returns all stubs for this object",
    ISpec stubs on(self)
  )
)

ISpec Stub = Origin mimic do(
  initialize = method(cellName, 
    @cellName = cellName
    @returnValue = nil
  )
  
  matches? = true
  
  andReturn = method(returnValue, @returnValue = returnValue)
)