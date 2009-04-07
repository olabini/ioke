ISpec UnexpectedInvocation = Condition mimic

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
    
      object cell(cellName) = fnx(+posArgs, +:namedArgs,
        ISpec stubs receive(object, cellName, posArgs, namedArgs)
      )
    ) 

    stub = ISpec Stub mimic(cellName)
    on(object) << stub
    stub
  )
    
  receive = method(object, cellName, posArgs, namedArgs,
    foundStub = on(object, cellName) select(stub, stub matches?(posArgs, namedArgs)) last 
    if(foundStub nil?, error!(ISpec UnexpectedInvocation, message: "couldn't find matching stub for #{cellName}"), foundStub returnValue)
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
    @expectedArgs = [ [], {} ]
  )
  
  withArgs = method(+posArgs, +:namedArgs,
    @expectedArgs = [ posArgs, namedArgs ]
    self
  )
  
  matches? = method(posArgs, namedArgs,
    [ posArgs, namedArgs ] == @expectedArgs
  )
  
  andReturn = method(returnValue, @returnValue = returnValue)
)