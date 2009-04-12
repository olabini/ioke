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

    signal! = method(
      expectedMessage = if(@expectedCalls cell?(:include?),
        "between #{@expectedCalls from} and #{expectedCalls to} time(s)",
        ordinalize(@expectedCalls))
      actualMessage = ordinalize(@actualCalls)

      error!(ISpec UnexpectedInvocation,
        text: "#{@cellName} mock expected to be called #{expectedMessage}, but it was called #{actualMessage}")
    )

    ordinalize = method(n,
      cond(
        n == 0, "never",
        n == 1, "once",
        "exactly #{n} times")
    )
  )

  ShouldContext satisfyExpectations = method(
    fn(
      ISpec stubs verifyAndClear!(Ground false)
      self realValue call
      ISpec stubs verifyAndClear!(Ground true)
    ) should not signal(ISpec UnexpectedInvocation)
  )

  NotShouldContext satisfyExpectations = method(
    fn(
      ISpec stubs verifyAndClear!(Ground false)
      self realValue call
      ISpec stubs verifyAndClear!(Ground true)
    ) should signal(ISpec UnexpectedInvocation)
  )

  ShouldContext receive = macro(
    if(call arguments empty?,
      Origin mimic with(pass: generateMock(call message next, call ground)),
      call arguments each(expectation, generateMock(expectation, call ground))
    )
  )

  NotShouldContext receive = macro(
    if(call arguments empty?,
      Origin mimic with(pass: generateMock(call message next, call ground) never),
      call arguments each(expectation, generateMock(expectation, call ground) never)
    )
  )

  ShouldContext generateMock = method(message, ground,
    self realValue mock!(message name) withArgs(*(message arguments map(evaluateOn(ground))))
  )

  ; Add hook for verifying stubs
  DescribeContext after(
    ISpec stubs verifyAndClear!
  )
)