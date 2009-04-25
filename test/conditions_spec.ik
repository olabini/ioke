
use("ispec")

describe(DefaultBehavior,
  describe("FlowControl",
    describe("ensure",
      it("should work with just main code",
        ensure(10+10) should == 20
      )

      it("should execute all the ensure code after the main code",
        Ground ensureResults = []
        
        ensure(
          ensureResults << :mainCode,

          ensureResults << :ensureBlock1,
          
          ensureResults << :ensureBlock2)

        ensureResults should == [:mainCode, :ensureBlock1, :ensureBlock2]
      )

      it("should execute nested ensure blocks",
        Ground ensureResults = []
        
        ensure(
          ensure(
            ensure(
              ensureResults << :mainCode,
              ensureResults << :ensureBlockInner),
            ensureResults << :ensureBlockOuter),
          ensureResults << :ensureBlockOutmost)

        ensureResults should == [:mainCode, :ensureBlockInner, :ensureBlockOuter, :ensureBlockOutmost]
      )      

      it("should return the result of the main code even though there are ensure blocks",
        ensure(
          42,
          43) should == 42

        ensure(
          ensure(
            42,
            44,
            45),
          43) should == 42
      )

      it("should execute the ensure code if a restart is invoked outside",
        Ground ensureResults = []

        bind(restart(outside, fn),
          ensure(
            invokeRestart(:outside),
            
            ensureResults << :invoked))

        ensureResults should == [:invoked]
      )

      it("should execute the ensure code if a condition is rescued outside",
        Ground ensureResults = []

        bind(rescue(Condition, fn(c, nil)),
          ensure(
            signal!(Condition),
            
            ensureResults << :invoked))

        ensureResults should == [:invoked]
      )
    )
  )

  describe("Conditions",
    describe("error!", 
      it("should signal a Condition Error Default by default", 
        x = bind(
          rescue(fn(c, c)),
          error!("something"))
        x text should == "something"
        x should have kind("Condition Error Default")
      )

      it("should take an existing condition", 
        c1 = Condition mimic
        cx = nil
        bind(
          rescue(fn(c, cx = c)),
          error!(c1))
        cx should == c1
      )

      it("should take a condition mimic and a set of keyword parameters", 
        cx = bind(
          rescue(fn(c, c)),
          error!(Condition, foo: "bar"))
        cx foo should == "bar"
        cx should not == Condition
      )
    )

    describe("warn!", 
      it("should signal a Condition Warning Default by default", 
        x = bind(
          rescue(fn(c, c)),
          warn!("something"))
        x text should == "something"
        x should have kind("Condition Warning Default")
      )
      
      it("should take an existing condition", 
        c1 = Condition mimic
        cx = nil
        bind(
          rescue(fn(c, cx = c)),
          warn!(c1))
        cx should == c1
      )

      it("should take a condition mimic and a set of keyword parameters", 
        cx = bind(
          rescue(fn(c, c)),
          warn!(Condition, foo: "bar"))
        cx foo should == "bar"
        cx should not == Condition
      )

      it("should establish an ignore-restart", 
        gah = nil
        bind(
          rescue(fn(c, gah)),
          handle(fn(c, gah = findRestart(:ignore))),
          
          warn!("something")) should not be nil
      )
    )

    describe("signal!", 
      it("should take an existing condition", 
        c1 = Condition mimic
        cx = nil
        bind(
          rescue(fn(c, cx = c)),
          signal!(c1))
        cx should == c1
      )

      it("should take a condition mimic and a set of keyword parameters", 
        cx = bind(
          rescue(fn(c, c)),
          signal!(Condition, foo: "bar"))
        cx foo should == "bar"
        cx should not == Condition
      )

      it("should not execute a handler that's not applicable", 
        x = 1
        C1 = Condition mimic
        bind(
          handle(C1, fn(c, x = 42)),
          signal!("foo"))
        x should == 1
      )

      it("should execute one applicable handler", 
        x = 1
        bind(
          handle(fn(c, x = 42)),
          signal!("foo"))
        x should == 42
      )

      it("should execute two applicable handler, among some non-applicable", 
        x = []
        C1 = Condition mimic
        bind(
          handle(C1, fn(c, x << 13)),
          bind(
            handle(fn(c, x << 15)),
            bind(
              handle(C1, fn(c, x << 17)),
              bind(
                handle(Condition, fn(c, x << 19)),
                signal!("foo")))))
        x should == [19, 15]
      )

      it("should not unwind the stack when invoking handlers", 
        x = []
        bind(
          handle(fn(c, x << 2)),
          x << 1
          signal!("foo")
          x << 3
        )
        x should == [1,2,3]
      )

      it("should only invoke handlers up to the limit of the first applicable rescue", 
        x = []
        bind(
          handle(fn(c, x << 1)),
          handle(fn(c, x << 2)),
          rescue(fn(c, x << 3)),
          handle(fn(c, x << 4)),
          bind(
            handle(fn(c, x << 5)),
            handle(fn(c, x << 6)),
            bind(
              handle(fn(c, x << 7)),
              signal!("Foo"))))
        x should == [7, 6, 5, 4, 3]
      )

      it("should do nothing if no rescue has been registered for it", 
        x = 1
        signal!("foo")
        x++
        x should == 2

        x = 1
        C2 = Condition mimic
        bind(
          rescue(C2, fn(e, x = 42)),
          x++
          signal!("something")
          x++)
        x should == 3
      )

      it("should transfer control if the condition is matched", 
        x = 1
        bind(
          rescue(fn(e, x = 42)),
          signal!("something")
          x = 13)
        x should == 42
      )

      it("should transfer control to the innermost handler that matches", 
        x = 1
        C1 = Condition mimic
        C2 = Condition mimic
        bind(
          rescue(C1, fn(e, x = 42)),
          bind(
            rescue(fn(e, x = 444)),
            bind(
              rescue(C2, fn(e, x = 222)),

              signal!("something"))))
        x should == 444
      )

      it("should invoke the handler with the signalled condition", 
        x = 1
        bind(
          rescue(fn(e, x = e text)),
          signal!("something")
          x = 13)
        x should == "something"
      )

      it("should return the value of the handler from the bind of the rescue in question", 
        bind(
          rescue(fn(e, 42)),
          signal!("something")
          x = 13) should == 42
      )
    )

    describe("handle", 
      it("should take only one argument, and in that case catch all Conditions", 
        handle(fn(e, 42)) handler call(1) should == 42
        handle(fn) conditions should == [Condition]
      )

      it("should take one or more Conditions to catch", 
        c1 = Condition mimic
        c2 = Condition mimic
        handle(c1, c2, fn(e, 42)) conditions should == [c1, c2]
      )
      
      it("should return something that has kind Handler", 
        handle(fn) should have kind("Handler")
      )
    )

    describe("rescue", 
      it("should take only one argument, and in that case catch all Conditions", 
        rescue(fn(e, 42)) handler call(1) should == 42
        rescue(fn) conditions should == [Condition]
      )

      it("should take one or more Conditions to catch", 
        c1 = Condition mimic
        c2 = Condition mimic
        rescue(c1, c2, fn(e, 42)) conditions should == [c1, c2]
      )
      
      it("should return something that has kind Rescue", 
        rescue(fn) should have kind("Rescue")
      )
    )

    describe("restart", 
      it("should take an optional unevaluated name as first argument", 
        restart(blub, fn) name should == :blub
      )
      
      it("should return something that has kind Restart", 
        restart(fn) should have kind("Restart")
      )

      it("should take an optional report: argument", 
        rp = fn("report" println)
        restart(report: rp, fn) report should == rp
      )

      it("should take an optional test: argument", 
        t1 = fn("test" println)
        restart(test: t1, fn) test should == t1
      )

      it("should take a code argument", 
        restart(fn(32+43)) code call should == 75
      )
    )

    describe("bind", 
      it("should evaluate it's last argument and return the result of that", 
        bind() should be nil
        bind(42) should == 42

        bind(
          restart(fn),
          restart(fn),
          restart(fn),
          42+43
          10+12) should == 22
      )

      it("should fail if any argument except the last doesn't evaluate to a restart", 
        fn(bind(10, 10)) should signal(Condition Error Type IncorrectType)
      )
    )

    describe("availableRestarts",
      it("should return the available restarts",
        r = restart(fox, fn)
        bind(r,
          availableRestarts[0] should == r)
      )

      it("should use the test of a restart to see if it's correct",
        r = restart(fox, fn)
        Ground Cond1 = Condition mimic
        Ground calledRTest = false
        r test = fn(c, Ground calledRTest = true. c == Cond1)

        bind(r,
          availableRestarts[0] should not == r)

        calledRTest should be true
      )

      it("should get the restarts applicable",
        r = restart(fox, fn)
        Ground Cond1 = Condition mimic
        r test = fn(c, c == Cond1)

        bind(r,
          availableRestarts(Cond1)[0] should == r)
      )
    )

    describe("findRestart", 
      it("should return nil if it can't find the named restart", 
        findRestart(:foo) should be nil

        bind(
          restart(bar, fn),
          findRestart(:foo)) should be nil
      )

      it("should return the restart if found", 
        bind(
          restart(foo, fn),
          findRestart(:foo)) should not be nil

        re = restart(foo, fn)
        bind(
          re,
          findRestart(:foo)) should == re
      )

      it("should return the innermost restart for the name", 
        re1 = restart(foo, fn)
        re2 = restart(foo, fn)
        re3 = restart(foo, fn)
        bind(
          re1,
          bind(
            re2,
            bind(
              re3,
              findRestart(:foo)))) should == re3

        re1 = restart(foo, fn)
        re2 = restart(foo, fn)
        re3 = restart(foo, fn)
        bind(
          re1,
          bind(
            re2,
            bind(
              re3,
              bind(
                restart(bar, fn),
                findRestart(:foo))))) should == re3
      )

      it("should fail when given nil", 
        fn(findRestart(nil)) should signal(Condition Error Type IncorrectType)

        fn(bind(
            restart,
            findRestart(nil))) should signal(Condition Error Invocation TooFewArguments)

        fn(bind(
            restart(foo, fn),
            findRestart(nil))) should signal(Condition Error Type IncorrectType)
      )

      it("should take a restart as argument and return it when that restart is active", 
        re = restart(foo, fn)
        bind(
          restart(foo, fn),
          bind(
            re,
            bind(
              restart(foo, fn),
              findRestart(re)))) should == re
      )

      it("should take a restart as argument and return nil when that restart is not active", 
        re = restart(foo, fn)
        bind(
          restart(foo, fn),
          bind(
            restart(foo, fn),
            findRestart(re))) should be nil
      )
    )

    describe("invokeRestart", 
      it("should fail if no restarts of the name is active", 
        fn(invokeRestart(:bar)) should signal(Condition Error RestartNotActive)

        fn(bind(
            restart(foo, fn()),
            invokeRestart(:bar))) should signal(Condition Error RestartNotActive)

        fn(bind(
            restart(foo, fn()),
            bind(
              restart(foo, fn()),
              invokeRestart(:bar)))) should signal(Condition Error RestartNotActive)
      )

      it("should fail if no restarts of the restart is active", 
        fn(re = restart(bar, fn)
          invokeRestart(re)) should signal(Condition Error RestartNotActive)

        fn(re = restart(bar, fn)
          bind(
            restart(foo, fn),
            invokeRestart(re))) should signal(Condition Error RestartNotActive)

        fn(re = restart(bar, fn)
          bind(
            restart(foo, fn),
            bind(
              restart(foo, fn),
              invokeRestart(re)))) should signal(Condition Error RestartNotActive)
      )
      
      it("should invoke a restart when given the name", 
        x = 1
        bind(
          restart(foo, fn(x = 42. 13)),
          invokeRestart(:foo)) should == 13
        x should == 42
      )

      it("should invoke a restart when given the restart", 
        x = 1
        re = restart(foo, fn(x = 42. 13))
        bind(
          re,
          invokeRestart(re)) should == 13
        x should == 42
      )
      
      it("should invoke the innermost restart when given the name", 
        x = 1
        invoked = 0
        bind(
          restart(foo, fn(invoked++. x = 42. 13)),
          bind(
            restart(foo, fn(invoked++. x = 43. 14)),
            bind(
              restart(foo, fn(invoked++. x = 44. 15)),
              invokeRestart(:foo)))) should == 15
        x should == 44
        invoked should == 1
      )

      it("should invoke the right restart when given an instance", 
        x = 1
        invoked = 0
        re = restart(foo, fn(invoked++. x=24. 16))
        bind(
          restart(foo, fn(invoked++. x = 42. 13)),
          bind(
            re,
            bind(
              restart(foo, fn(invoked++. x = 43. 14)),
              bind(
                restart(foo, fn(invoked++. x = 44. 15)),
                invokeRestart(re))))) should == 16
        x should == 24
        invoked should == 1
      )

      it("should take arguments and pass these along to the restart", 
        bind(
          restart(foo, fn(x, x)),
          invokeRestart(:foo, 13)) should == 13

        bind(
          restart(foo, fn(x, y, x)),
          invokeRestart(:foo, 13, 15)) should == 13

        bind(
          restart(foo, fn(x, y, y)),
          invokeRestart(:foo, 13, 15)) should == 15
      )
    )
  )
)

describe(Restart, 
  it("should have a name", 
    Restart name should be nil
  )
  
  it("should have a report cell", 
    Restart report should have kind("LexicalBlock")
  )

  it("should have a test cell", 
    Restart test should have kind("LexicalBlock")
  )

  it("should have a code cell", 
    Restart code should have kind("LexicalBlock")
  )
)

describe(Condition, 
  it("should have the right kind", 
    Condition should have kind("Condition")
  )
  
  describe(Condition Default, 
    it("should have the right kind", 
      Condition Default should have kind("Condition Default")
    )
  )

  describe(Condition Warning, 
    it("should have the right kind", 
      Condition Warning should have kind("Condition Warning")
    )

    describe(Condition Warning Default, 
      it("should have the right kind", 
        Condition Warning Default should have kind("Condition Warning Default")
      )
    )
  )
  
  describe(Condition Error, 
    it("should have the right kind", 
      Condition Error should have kind("Condition Error")
    )

    describe(Condition Error Default, 
      it("should have the right kind", 
        Condition Error Default should have kind("Condition Error Default")
      )
    )
    
    describe(Condition Error Load, 
      it("should have the right kind", 
        Condition Error Load should have kind("Condition Error Load")
      )
    )

    describe(Condition Error IO, 
      it("should have the right kind", 
        Condition Error IO should have kind("Condition Error IO")
      )
    )

    describe(Condition Error Arithmetic, 
      it("should have the right kind", 
        Condition Error Arithmetic should have kind("Condition Error Arithmetic")
      )

      describe(Condition Error Arithmetic DivisionByZero, 
        it("should have the right kind", 
          Condition Error Arithmetic DivisionByZero should have kind("Condition Error Arithmetic DivisionByZero")
        )
      )

      describe(Condition Error Arithmetic NotParseable, 
        it("should have the right kind", 
          Condition Error Arithmetic NotParseable should have kind("Condition Error Arithmetic NotParseable")
        )
      )
    )
    
    describe(Condition Error ModifyOnFrozen, 
      it("should have the right kind", 
        Condition Error ModifyOnFrozen should have kind("Condition Error ModifyOnFrozen")
      )
    )

    describe(Condition Error NoSuchCell, 
      it("should have the right kind", 
        Condition Error NoSuchCell should have kind("Condition Error NoSuchCell")
      )
    )

    describe(Condition Error Invocation, 
      it("should have the right kind", 
        Condition Error Invocation should have kind("Condition Error Invocation")
      )

      describe(Condition Error Invocation NotActivatable, 
        it("should have the right kind", 
          Condition Error Invocation NotActivatable should have kind("Condition Error Invocation NotActivatable")
        )
      )

      describe(Condition Error Invocation ArgumentWithoutDefaultValue, 
        it("should have the right kind", 
          Condition Error Invocation ArgumentWithoutDefaultValue should have kind("Condition Error Invocation ArgumentWithoutDefaultValue")
        )
      )

      describe(Condition Error Invocation TooManyArguments, 
        it("should have the right kind", 
          Condition Error Invocation TooManyArguments should have kind("Condition Error Invocation TooManyArguments")
        )
      )

      describe(Condition Error Invocation TooFewArguments, 
        it("should have the right kind", 
          Condition Error Invocation TooFewArguments should have kind("Condition Error Invocation TooFewArguments")
        )
      )

      describe(Condition Error Invocation MismatchedKeywords, 
        it("should have the right kind", 
          Condition Error Invocation MismatchedKeywords should have kind("Condition Error Invocation MismatchedKeywords")
        )
      )

      describe(Condition Error Invocation NotSpreadable, 
        it("should have the right kind", 
          Condition Error Invocation NotSpreadable should have kind("Condition Error Invocation NotSpreadable")
        )
      )

      describe(Condition Error Invocation NoMatch, 
        it("should have the right kind", 
          Condition Error Invocation NoMatch should have kind("Condition Error Invocation NoMatch")
        )
      )
    )
    
    describe(Condition Error CantMimicOddball, 
      it("should have the right kind", 
        Condition Error CantMimicOddball should have kind("Condition Error CantMimicOddball")
      )
    )

    describe(Condition Error Index, 
      it("should have the right kind", 
        Condition Error Index should have kind("Condition Error Index")
      )
    )

    describe(Condition Error RestartNotActive, 
      it("should have the right kind", 
        Condition Error RestartNotActive should have kind("Condition Error RestartNotActive")
      )
    )

    describe(Condition Error NativeException, 
      it("should have the right kind", 
        Condition Error NativeException should have kind("Condition Error NativeException")
      )
    )

    describe(Condition Error Parser, 
      it("should have the right kind", 
        Condition Error Parser should have kind("Condition Error Parser")
      )

      describe(Condition Error Parser OpShuffle, 
        it("should have the right kind", 
          Condition Error Parser OpShuffle should have kind("Condition Error Parser OpShuffle")
        )
      )
    )
    
    describe(Condition Error CommandLine, 
      it("should have the right kind", 
        Condition Error CommandLine should have kind("Condition Error CommandLine")
      )

      describe(Condition Error CommandLine DontUnderstandOption, 
        it("should have the right kind", 
          Condition Error CommandLine DontUnderstandOption should have kind("Condition Error CommandLine DontUnderstandOption")
        )
      )
    )

    describe(Condition Error Type, 
      it("should have the right kind", 
        Condition Error Type should have kind("Condition Error Type")
      )

      describe(Condition Error Type IncorrectType, 
        it("should have the right kind", 
          Condition Error Type IncorrectType should have kind("Condition Error Type IncorrectType")
        )
      )
    )
  )
)
