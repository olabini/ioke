ISpec do(
  UnexpectedInvocation = Condition mimic
  
  Stubs = Origin mimic do(
    initialize = method(@all_stubs = {})

    on = method(object, cellName nil,
      @all_stubs[object] ||= []
      if(cellName nil?, 
        @all_stubs[object], 
        @all_stubs[object] select(stub, stub cellName == cellName))
    )

    addStub = method(object, cellName, stubBase ISpec Stub,
      if(on(object, cellName) empty?,
        if(object cell?(cellName), object cell("stubbed:#{cellName}") = object cell(cellName))

        object cell(cellName) = fnx(+posArgs, +:namedArgs,
          ISpec stubs receive(object, cellName, posArgs, namedArgs)
        )
      ) 

      stub = stubBase create(cellName)
      on(object) << stub
      stub
    )
    
    addMock = method(object, cellName,
      addStub(object, cellName, ISpec Mock)
    )

    receive = method(object, cellName, posArgs, namedArgs,
      foundStub = on(object, cellName) select(stub, stub matches?(posArgs, namedArgs)) last 
      if(foundStub nil?, 
        error!(ISpec UnexpectedInvocation, message: "couldn't find matching stub for #{cellName}"), 
        foundStub invoke)
    )
  )
  
  stubs = ISpec Stubs mimic
  
  ExtendedDefaultBehavior do(
    stub! = method("adds a stub to this object", cellName,
      ISpec stubs addStub(self, cellName)
    )
    
    mock! = method("adds a mock to this object", cellName,
      ISpec stubs addMock(self, cellName)
    )

    stubs = method("returns all stubs for this object",
      ISpec stubs on(self)
    )
  )
  
  Stub = Origin mimic do(
    create = method(cellName, 
      self with(cellName: cellName)
    )
    
    returnValue = nil
    expectedArgs = [ [], {} ]
    satisfied? = true

    withArgs = method(+posArgs, +:namedArgs,
      @expectedArgs = [ posArgs, namedArgs ]
      self
    )

    matches? = method(posArgs, namedArgs,
      [ posArgs, namedArgs ] == @expectedArgs
    )
    
    invoke = method(returnValue)

    andReturn = method(returnValue, @returnValue = returnValue)
  )
  
  Mock = Stub mimic do(
    expectedCalls = 1
    
    actualCalls   = 0
    
    never = method(times(0))
    
    once  = method(times(1))
    
    times = method(n, @expectedCalls = n. self)
    
    invoke = method(@actualCalls += 1. returnValue)
    
    atLeastOnce = method(times(1..(Number Infinity)))
    
    satisfied? = method(
      if(@expectedCalls cell?(:include?),
        @expectedCalls include?(@actualCalls),
        @expectedCalls == @actualCalls)
    )
  )
)