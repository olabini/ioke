ISpec do(
  UnexpectedInvocation = ISpec Condition mimic

  Stubs = Origin mimic do(
    initialize = method(@stubs = [])

    on = method(object, @stubs select(stub, stub owner == object))

    addStub = method(object, cellName, stubBase ISpec Stub,
      stub = stubBase create(object, cellName)
      stubs << stub
      stub
    )

    addMock = method(object, cellName,
      addStub(object, cellName, ISpec Mock)
    )

    invoke = method(object, cellName, posArgs, namedArgs,
      foundStub = on(object) select(stub, stub cellName == cellName && stub matches?(posArgs, namedArgs)) last
      if(foundStub nil?,
        error!(ISpec UnexpectedInvocation, text: "couldn't find matching mock or stub for #{cellName}"),
        foundStub invoke)
    )

    allMocks = method(@stubs select(mimics?(ISpec Mock)))

    verifyAndClear! = method(raiseOnFail enabled?,
      if(raiseOnFail, allMocks each(mock, unless(mock satisfied?, mock signal!)))
      @stubs each(stub, stub removeStub!)
      @stubs clear!
    )

    enabled? = Ground true
  )

  stubs = ISpec Stubs mimic

  ExtendedDefaultBehavior do(
    stub! = method("adds a stub to this object", cellName nil, +:cellNamesAndReturnValues,
      if(!cellName nil?,
        ISpec stubs addStub(self, cellName),
        cellNamesAndReturnValues each(pair,
          ISpec stubs addStub(self, pair key) andReturn(pair value))
      )
    )

    mock! = method("adds a mock to this object", cellName,
      ISpec stubs addMock(self, cellName)
    )

    stubs = method("returns all stubs for this object",
      ISpec stubs on(self)
    )
  )

  Stub = Origin mimic do(
    create = method(object, cellName,
      stub = self with(owner: object, cellName: cellName)
      stub performStub!
      stub
    )

    returnValue = nil
    expectedArgs = [ [], {} ]
    satisfied? = Ground true

    withArgs = method(+posArgs, +:namedArgs,
      @expectedArgs = [ posArgs, namedArgs ]
      self
    )

    matches? = method(posArgs, namedArgs,
      [ posArgs, namedArgs ] == @expectedArgs
    )

    invoke = method(returnValue)

    andReturn = method(returnValue, @returnValue = returnValue. self)

    performStub! = method(
      unless(alreadyStubbed?,
        @owner cell("stubbed?:#{@cellName}") = Ground true

        if(@owner cell?(@cellName), @owner cell("hidden:#{@cellName}") = @owner cell(@cellName))

        @owner cell(@cellName) = fnx(+posArgs, +:namedArgs,
          ISpec stubs invoke(@owner, @cellName, posArgs, namedArgs))
      )
    )

    removeStub! = method(
      if(alreadyStubbed?,
        @owner removeCell!(@cellName)
        @owner removeCell!("stubbed?:#{@cellName}")
        if(@owner cell?("hidden:#{@cellName}"),
          @owner cell(@cellName) = @owner cell("hidden:#{@cellName}")
          @owner removeCell!("hidden:#{@cellName}"))
      )
    )

    alreadyStubbed? = method(@owner cell?("stubbed?:#{@cellName}"))
  )

  Mock = Stub mimic do(
    expectedCalls = 1
    actualCalls   = 0
    negated?      = false
    
    never = method(times(0))
    once  = method(times(1))
    times = method(n, @expectedCalls = n. self)
    atLeastOnce = method(times(1..(Number Infinity)))

    invoke = method(@actualCalls += 1. returnValue)
    
    negate! = method(self negated? = true. self)
    
    satisfied? = method(
      expectationMatched? = if(@expectedCalls cell?(:include?),
        @expectedCalls include?(@actualCalls),
        @expectedCalls == @actualCalls)
      
      expectationMatched? xor negated?
    )

    signal! = method(
      expectedMessage = if(@expectedCalls cell?(:include?),
        "between #{@expectedCalls from} and #{expectedCalls to} time(s)",
        ordinalize(@expectedCalls))
      actualMessage = ordinalize(@actualCalls)
        
      error!(ISpec UnexpectedInvocation, 
        text: "'#{@cellName}' expected to be called #{expectedMessage}, but it was called #{actualMessage}")
    )

    ordinalize = method(n,
      cond(
        n == 0, "never",
        n == 1, "once",
        "exactly #{n} times")
    )
  )
  
  DescribeContext do(
    after(ISpec stubs verifyAndClear!)
    
    mock = macro(
      mockObject = ISpec MockTemplate mimic
    
      call arguments each(expectation,
        if(expectation name asText =~ #/:$/, ; hash syntax
          mockObject mock!(expectation name asText replace(#/:$/, "")) andReturn(expectation next evaluateOn(call ground)),
        
          furtherExpectations = expectation next
          mockExpectation = mockObject mock!(expectation name) withArgs(*(expectation arguments map(evaluateOn(call ground))))
          unless(furtherExpectations nil? || furtherExpectations terminator?, furtherExpectations sendTo(mockExpectation))
        )
      )
      mockObject
    )
  
    stub = method(+:cellsAndValues,
      stubObject = Origin mimic
      cellsAndValues each(pair,
        stubObject stub!(pair key) andReturn(pair value)
      )
      stubObject
    )
  )
  
  MockTemplate = Origin mimic do(
    pass = macro(
      __invoke__(call message name, *(call arguments))
    )
  
    __invoke__ = method(cellName, +posArgs, +:namedArgs,
      ISpec stubs invoke(self, cellName, posArgs, namedArgs)
    )
  )
  
  ShouldContext signalMock! = method(
    failFn = fn(ISpec stubs verifyAndClear!(Ground false). self realValue call. ISpec stubs verifyAndClear!(Ground true))
    signalled = "none"
    bind(rescue(ISpec UnexpectedInvocation, fn(c, signalled = c)), failFn call)
    signalled
  )

  ShouldContext satisfyExpectations = method(
    if((signal = signalMock!) mimics?(ISpec UnexpectedInvocation),
      error!(ISpec ExpectationNotMet, text: "#{signal text}, code: #{realValue code}", shouldMessage: self shouldMessage))
  )

  NotShouldContext satisfyExpectations = method(
    unless((signal = signalMock!) mimics?(ISpec UnexpectedInvocation),
      error!(ISpec ExpectationNotMet, text: "#{signal text}, code: #{realValue code}", shouldMessage: self shouldMessage))
  )

  ShouldContext receive = macro(
    if(call arguments empty?,
      Origin mimic with(pass: generateMock(call message next, call ground)),
      
      furtherExpectations = call message next
      call arguments each(expectation, 
        mock = generateMock(expectation, call ground)
        unless(furtherExpectations nil? || furtherExpectations terminator?, furtherExpectations sendTo(mock))
        mock)
      Origin mimic do(pass = method(nil))
    )
  )

  NotShouldContext receive = macro(
    if(call arguments empty?,
      Origin mimic with(pass: generateMock(call message next, call ground) negate!),

      furtherExpectations = call message next
      call arguments each(expectation, 
        mock = generateMock(expectation, call ground) negate!
        unless(furtherExpectations nil? || furtherExpectations terminator?, furtherExpectations sendTo(mock))
        mock)
      Origin mimic do(pass = method(nil))
    )
  )

  ShouldContext generateMock = method(message, ground,
    self realValue mock!(message name) withArgs(*(message arguments map(evaluateOn(ground))))
  )
)