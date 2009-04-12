use("ispec")

describe("ISpec",
  ISpec stubs enabled? = false

  describe("ExtendedDefaultBehavior",
    describe("stub!",
      it("should add a stub to an object",
        foo = Origin mimic do(bar = 5)
        foo stub!(:bar)
        foo stubs length should == 1
        foo stubs first cellName should == :bar
        foo stubs first should mimic(ISpec Stub)
      )
      
      it("should replace the return value of the stubbed cell",
        foo = Origin mimic do(bar = 5)
        foo stub!(:bar) andReturn(6)
        foo bar should == 6
      )
      
      it("should hide the original implementation of the cell",
        foo = Origin mimic do(bar = 5)
        foo stub!(:bar) andReturn(6)
        foo cell("hidden:bar") should == 5
      )
      
      it("should mark the method as stubbed",
        foo = Origin mimic
        foo stub!(:bar)
        foo cell("stubbed?:bar") should be true
      )
            
      ; TODO Enhance this behavior later to allow this to occur.
      it("should not signal a condition if the stubbed cell does not exist",
        foo = Origin mimic
        fn(foo stub!(:bar) andReturn(5)) should not signal(Condition Error NoSuchCell)
        foo bar should == 5
      )
            
      it("should accumulate multiple stubs on multiple cells",
        foo = Origin mimic
        foo bar = 5
        foo stub!(:bar) andReturn(6)
        foo stub!(:baz) andReturn(7)
        foo stubs length should == 2
      )
      
      it("should accumulate multiple stubs on a single cell",
        foo = Origin mimic
        foo bar = 5
        foo stub!(:bar) andReturn(6)
        foo stub!(:bar) andReturn(7)
        ISpec stubs on(foo) map(returnValue) sort should == [ 6, 7 ]      
      )      
    )
    
    describe("mock!",    
      it("should add a mock to an object",
        foo = Origin mimic do(bar = 5)
        foo mock!(:bar)
        foo stubs length should == 1
        foo stubs first should mimic(ISpec Mock)
      )
      
      it("should replace the return value of the stubbed cell",
        foo = Origin mimic do(bar = 5)
        foo mock!(:bar) andReturn(6)
        foo bar should == 6
      )
      
      it("should hide the original implementation of the cell",
        foo = Origin mimic do(bar = 5)
        foo mock!(:bar) andReturn(6)
        foo cell("hidden:bar") should == 5
      )
      
      it("should mark the method as stubbed",
        foo = Origin mimic
        foo stub!(:bar)
        foo cell("stubbed?:bar") should be true
      )
      
      ; TODO Enhance this behavior later to allow this to occur.
      it("should not signal a condition if the stubbed cell does not exist",
        foo = Origin mimic
        fn(foo mock!(:bar) andReturn(5)) should not signal(Condition Error NoSuchCell)
        foo bar should == 5
      )
            
      it("should accumulate multiple stubs on multiple cells",
        foo = Origin mimic
        foo bar = 5
        foo mock!(:bar) andReturn(6)
        foo mock!(:baz) andReturn(7)
        foo stubs length should == 2
      )
      
      it("should accumulate multiple stubs on a single cell",
        foo = Origin mimic
        foo bar = 5
        foo mock!(:bar) andReturn(6)
        foo mock!(:bar) andReturn(7)
        ISpec stubs on(foo) map(returnValue) sort should == [ 6, 7 ]      
      )
    )
    
    describe("stubs",
      it("should apply an empty list of stubs to an object",
        Origin mimic stubs should be empty
      )    
    )
  )
  
  describe("Stub",
    describe("andReturn",
      it("should return a simple value",
        foo = Origin mimic do(bar = 5)
        foo stub!(:bar) andReturn(6)
        foo bar should == 6
      )
      
      it("should return the most recent of several stubs",
        foo = Origin mimic do(bar = 5)
        foo stub!(:bar) andReturn(6)
        foo stub!(:bar) andReturn(7)
        foo stub!(:bar) andReturn(8)
        foo bar should == 8
      )      
    )
    
    describe("withArgs",
      it("should return the stubbed value if it matches the given single argument",
        foo = Origin mimic do(bar = 5)
        foo stub!(:bar) withArgs(:anArg) andReturn(6)
        foo bar(:anArg) should == 6
      )
      
      it("should return the stubbed value if it matches the given keyed argument",
        foo = Origin mimic do(bar = 5)
        foo stub!(:bar) withArgs(baz: "qux") andReturn(6)
        foo bar(baz: "qux") should == 6
      )
      
      it("should return the stubbed value if it matches the given mixed argument",
        foo = Origin mimic do(bar = 5)
        foo stub!(:bar) withArgs("wuffie", baz: "qux") andReturn(6)
        foo bar("wuffie", baz: "qux") should == 6
      )
    
      it("should signal ISpec UnexpectedInvocation if no stub matches the given args",
        foo = Origin mimic do(bar = 5)
        foo stub!(:bar) withArgs(:arg) andReturn(6)
        fn(foo bar) should signal(ISpec UnexpectedInvocation)
      )
      
      it("should use the correct stub if there exist multiple stubs on the same cell with different expected args",
        foo = Origin mimic do(bar = 5)
        foo stub!(:bar) andReturn(6)
        foo stub!(:bar) withArgs(:right) andReturn(7)
        foo stub!(:bar) withArgs(:wrong, wrong: "again") andReturn(8)
        foo bar(:right) should == 7
      )
    )
    
    describe("satisfied?",
      it("should always be true",
        Origin mimic stub!(:bar) should be satisfied
      )
    )
    
    describe("removeStub!",
      it("should restore the hidden cell to the correct cell name",
        foo = Origin mimic do(bar = 5)
        stub = foo stub!(:bar) andReturn(6)
        stub removeStub!
        foo bar should == 5
      )
      
      it("should remove the stubbed cell entirely",
        foo = Origin mimic
        stub = foo stub!(:bar)
        stub removeStub!
        fn(foo send("hidden:bar")) should signal(Condition Error NoSuchCell)
      )
      
      it("should perform appropriately after multiple stubs and mocks have been set",
        foo = Origin mimic do(bar = 5)
        stub = foo stub!(:bar) andReturn(6)
        mock = foo mock!(:bar) andReturn(7)
        stub removeStub!
        mock removeStub!
        fn(foo send("hidden:bar")) should signal(Condition Error NoSuchCell)
        foo bar should == 5
      )
    )
  )
  
  describe("Mock",
    describe("expectedCalls",
      it("should be 1 by default",
        Origin mimic mock!(:bar) expectedCalls should == 1
      )
    )
    
    describe("actualCalls",
      it("should start at 0",
        Origin mimic mock!(:bar) actualCalls should == 0
      )
      
      it("should increment by 1 if it is called",
        foo = Origin mimic
        mock = foo mock!(:bar)
        foo bar
        mock actualCalls should == 1
      )
    )
    
    describe("satisfied?",
      it("should be false if it expects to be invoked once and has not yet been invoked",
        Origin mimic mock!(:bar) should not be satisfied
      )
      
      it("should be true if it expects to be invoked once and has been invoked once",
        foo = Origin mimic
        mock = foo mock!(:bar)
        foo bar
        mock should be satisfied
      )
      
      it("should be false if it expects to be invoked once and has been invoked twice",
        foo = Origin mimic
        mock = foo mock!(:bar)
        2 times(foo bar)
        mock should not be satisfied
      )
    )
    
    describe("never",
      it("should be satisfied if it is never invoked",
        foo = Origin mimic
        mock = foo mock!(:bar) never
        mock should be satisfied
      )
      
      it("should not be satisfied if it is invoked",
        foo = Origin mimic
        mock = foo mock!(:bar) never
        foo bar
        mock should not be satisfied        
      )
    )
    
    describe("times",
      it("should be satisfied if it expects to be invoked twice and has been invoked twice",
        foo = Origin mimic
        mock = foo mock!(:bar) times(2)
        2 times(foo bar)
        mock should be satisfied
      )
    
      it("should be not be satisfied if it exepcts to be invoked twice and has been invoked once",
        foo = Origin mimic
        mock = foo mock!(:bar) times(2)
        foo bar
        mock should not be satisfied        
      )
    
      it("should be satisfied if it expects to be invoked once or twice and is invoked once",
        foo = Origin mimic
        mock = foo mock!(:bar) times(1..2)
        foo bar
        mock should be satisfied
      )

      it("should be satisfied if it expects to be invoked once or twice and is invoked twice",
        foo = Origin mimic
        mock = foo mock!(:bar) times(1..2)
        2 times(foo bar)
        mock should be satisfied
      )
    ) 

    describe("atLeastOnce",
      it("should be not be satisfied if it expects to be invoked any number of times and has not yet been invoked",
        foo = Origin mimic
        mock = foo mock!(:bar) atLeastOnce
        mock should not be satisfied
      )
      
      it("should be satisfied if it expects to be invoked any number of times and has been invoked once",
        foo = Origin mimic
        mock = foo mock!(:bar) atLeastOnce
        foo bar
        mock should be satisfied
      )
      
      it("should be satisfied if it expects to be invoked any number of times and has been invoked a large number of times",
        foo = Origin mimic
        mock = foo mock!(:bar) atLeastOnce
        20 times(foo bar)
        mock should be satisfied        
      )
    )
  )
  
  describe("ShouldContext",      
    describe("receive",
      it("should satisfy expectations of never being called",
        fn(Origin mimic should not receive bar) should satisfyExpectations
        fn(Origin mimic should receive bar) should not satisfyExpectations
      )
      
      it("should satisfy expectations of being called multiple times",
        fn(foo = Origin mimic. foo should receive bar times(1). foo bar) should satisfyExpectations
        fn(foo = Origin mimic. foo should receive bar times(1). 2 times(foo bar)) should not satisfyExpectations
        fn(foo = Origin mimic. foo should receive bar times(2). 2 times(foo bar)) should satisfyExpectations
      )
      
      it("should satisfy expectations of multiple different kinds of calls",
        fn(foo = Origin mimic. foo should receive(bar, baz). foo bar) should not satisfyExpectations
        fn(foo = Origin mimic. foo should receive(bar, baz). foo bar. foo baz) should satisfyExpectations
        fn(foo = Origin mimic. foo should not receive(bar, baz)) should satisfyExpectations
        fn(foo = Origin mimic. foo should not receive(bar, baz). foo bar) should not satisfyExpectations
        fn(foo = Origin mimic. foo should not receive(bar, baz). foo baz) should not satisfyExpectations
      )
        
      it("should return the value from its mock",
        fn(
          foo = Origin mimic
          foo should receive bar andReturn(6)
          foo bar should == 6
        ) should satisfyExpectations
        
        fn(
          foo = Origin mimic
          foo should receive bar(:withArg) andReturn(6)
          foo bar(:withArg) should == 6
        ) should satisfyExpectations
      )
      
      it("should satisfy expectations with arguments",
        fn(foo = Origin mimic. foo should receive bar(5). foo bar) should not satisfyExpectations
        fn(foo = Origin mimic. foo should receive bar(5). foo bar(5)) should satisfyExpectations
      )
      
      it("should satisfy expectations with arguments for multiple calls",
        fn(foo = Origin mimic. foo should receive(bar, bar(5)). foo bar(5)) should not satisfyExpectations
        fn(foo = Origin mimic. foo should receive(bar, bar(5)). foo bar. foo bar(5)) should satisfyExpectations
        fn(foo = Origin mimic. foo should receive(bar(5), bar(6)). foo bar. foo bar(6)) should not satisfyExpectations
        fn(foo = Origin mimic. foo should receive(bar(5), bar(6)). foo bar(5). foo bar(6)) should satisfyExpectations
      )
    )
  )
)
