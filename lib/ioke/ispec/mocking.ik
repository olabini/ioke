use("blank_slate")

ISpec do(
  UnexpectedInvocation = ISpec Condition mimic
  
  StubWrangler = Origin mimic do(
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
      foundStub = on(object) select(stub, stub cellName asText == cellName && stub matches?(posArgs, namedArgs)) last
      if(foundStub nil?,
        error!(ISpec UnexpectedInvocation, text: buildInvocationFailureText(object, cellName, posArgs, namedArgs)),
        foundStub invoke)
    )
    
    buildInvocationFailureText = method(object, cellName, posArgs, namedArgs,
      "couldn't find matching mock or stub for #{cellName} with arguments #{posArgs}, #{namedArgs}.\nSimilar expectations:\n" +
      on(object) select(stub, stub cellName == cellName) map(stub,
        " - #{stub kind} #{stub cellName}
          (#{if(stub expectedArgs == ISpec Stub AnyArgs, "any arguments", stub expectedArgs join(", "))}) 
          returning #{stub returnValues join(", ")}
          (#{if(stub satisfied?, "satisfied", "not yet satisfied")})" replaceAll(#/\n/, "")) ifEmpty(["none"]) join("\n")
    )

    allMocks = method(@stubs select(mimics?(ISpec Mock)))

    verifyAndClear! = method(raiseOnFail enabled?,
      ensure(
        if(raiseOnFail, allMocks each(mock, unless(mock satisfied?, mock signal!)))
        @stubs each(stub, stub removeStub!),
        @stubs clear!)
    )

    enabled? = Ground true
  )

  stubs = ISpec StubWrangler mimic

  Stub = Origin mimic do(
    AnyArgs = Origin mimic
    
    create = method(object, cellName,
      stub = self with(owner: object, cellName: cellName asText, returnValues: [], expectedArgs: AnyArgs, toSignal: Ground nil)
      stub performStub!
      stub
    )

    satisfied? = Ground true
    invocable? = Ground true

    withArgs = method(
      "Modifies the expectation so that the expected cell must be called with the given arguments.
      Arguments may be either positional or named. Positional arguments must be given in the order
      in which they are expected to be invoked.",
      
      +posArgs, +:namedArgs,
      
      @expectedArgs = [ posArgs, namedArgs ]
      self
    )

    matches? = method(posArgs, namedArgs,
      @expectedArgs == AnyArgs || [ posArgs, namedArgs ] == @expectedArgs
    )

    invoke = method(
      if(@toSignal not nil?,
        signal!(@toSignal),
        if(returnValues size > 1, returnValues shift!, returnValues first))
    )

    andReturn = method(
      "Modifies the expectation to return the given values in the given order upon invocation.
      One or more return values may be specified. If one value is given, that value will always
      be returned upon invocation. If multiple values are given, each will be returned upon
      successive invocation in the order in which they were given.",
      
      +returnValues, 
      @returnValues = @returnValues + returnValues
      self
    )
    
    andSignal = method(
      "Modifies the expectation to signal the given condition upon invocation.",
      
      signal,
      @toSignal = signal
      self
    )

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
    create = method(object, cellName,
      mock = super(object, cellName)
      mock expectedCalls = 1..1
      mock actualCalls = 0
      mock negated? = false
      mock
    )
    
    times = method(
      "Modify the expectation to indicate that it must be invoked the given number of times.
      The given argument may be either a number or a range of numbers.",
      n, 
      @expectedCalls = if(n cell?(:include?), n, (n..n))
      self
    )
    
    never = method(
      "Modify the expectation to indicate that it must never be invoked.", 
      times(0))
      
    once = method(
      "Modify the expectation to indicate that it must be invoked once.", 
      times(1))
      
    twice = method(
      "Modify the expectation to indicate that it must be invoked twice.",
      times(2))
      
    atLeastOnce = method(
      "Modify the expectation to indicate that it must be invoked at least once.", 
      times(1..(Number Infinity)))
      
    anyNumberOfTimes = method(
      "Modify the expectation to indicate that it may be invoked any number of times.", 
      times(0..(Number Infinity)))
    
    negate! = method(
      "Invert the call count expectations of this mock.",
      self negated? = true. self
    )
    
    invoke = method(@actualCalls += 1. super)
    
    satisfied? = method(      
      @expectedCalls include?(@actualCalls) xor negated?
    )
    
    invocable? = method(
      if(@negated?,
        (@actualCalls + 1) < (@expectedCalls from),
        @actualCalls < (@expectedCalls to))
    )
    
    matches? = method(posArgs, namedArgs,
      super(posArgs, namedArgs) && invocable?
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
  
  DescribeContext do(
    after(ISpec stubs verifyAndClear!)
    
    mock! = macro("Creates a new mock object that mimics BlankSlate.",
      buildStubWithMethod(:mock!, call arguments, call ground)
    )
  
    stub! = macro("Creates a new stub object that mimics BlankSlate.",
      buildStubWithMethod(:stub!, call arguments, call ground)
    )
    
    buildStubWithMethod = method(stubMethod, callArguments, callGround,
      stubObject = ISpec StubTemplate mimic
    
      callArguments each(expectation,
        if(expectation name asText =~ #/:$/, ; hash syntax
          stubObject send(stubMethod, expectation name asText replace(#/:$/, "")) andReturn(expectation next evaluateOn(callGround)),
          
          stubExpectation = stubObject send(stubMethod, expectation name) withArgs(*(expectation arguments map(evaluateOn(callGround))))
          furtherExpectations = expectation next
          unless(furtherExpectations nil? || furtherExpectations terminator?, furtherExpectations sendTo(stubExpectation))
        )
      )
      stubObject      
    )
  )
  
  StubTemplate = BlankSlate mimic do(
    pass = macro(
      __invoke__(call message name, *(call arguments))
    )
  
    __invoke__ = method(cellName, +posArgs, +:namedArgs,
      ISpec stubs invoke(self, cellName, posArgs, namedArgs)
    )
  )
  
  ShouldContext signalMock! = method(
    failFn = fn(ISpec stubs verifyAndClear!(Ground false). self realValue call. ISpec stubs verifyAndClear!(Ground true))
    signalled = Origin with(text: "no unexpected invocations")
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
      slurpExpectations(call arguments, call message next, call ground)
      Origin mimic do(pass = method(nil)) ; Ensure rest of message chain is a no-op.
    )
  )
  
  ShouldContext slurpExpectations = method(expectations, furtherExpectations, ground,
    expectations map(expectation,
      mock = generateMock(expectation, ground)
      unless(furtherExpectations nil? || furtherExpectations terminator?, furtherExpectations sendTo(mock))
      mock)
  )
  
  ShouldContext generateMock = method(message, ground,
    self realValue mock!(message name) withArgs(*(message arguments map(evaluateOn(ground))))
  )  

  NotShouldContext receive = macro(
    if(call arguments empty?,
      Origin mimic with(pass: generateMock(call message next, call ground) negate!),
      slurpExpectations(call arguments, call message next, call ground) each(negate!)
      Origin mimic do(pass = method(nil)) ; Ensure rest of message chain is a no-op.
    )
  )
)