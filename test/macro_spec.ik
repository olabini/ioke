
use("ispec")

describe(DefaultBehavior, 
  describe("macro", 
    it("should return a macro that returns nil when called with no arguments", 
      macro call should be nil
      macro() call should be nil
    )
    
    it("should name itself after the slot it's assigned to if it has no name", 
      x = macro(nil)
      cell(:x) name should == "x"
    )
    
    it("should not change it's name if it already has a name", 
      x = macro(nil)
      y = cell(:x)
      cell(:y) name should == "x"
    )
    
    it("should know it's own name", 
      (x = macro(nil)) name should == "x"
    )
  )
)

describe("DefaultMacro", 
  it("should be possible to give it a documentation string", 
    macro("foo is bar", nil) documentation should == "foo is bar"
  )

  it("should signal a condition if activating the kind",
    fn(DefaultMacro) should signal(Condition Error Invocation NotActivatable)
  )

  it("should have @ return the receiving object inside of a macro", 
    obj = Origin mimic
    obj atSign = macro(@)
    obj2 = obj mimic
    obj atSign should == obj
    obj2 atSign should == obj2
  )

  it("should have @@ return the executing macro inside of a macro", 
    obj = Origin mimic
    obj atAtSign = macro(@@)
    obj2 = obj mimic
    obj atAtSign should == obj cell(:atAtSign)
    obj2 atAtSign should == obj2 cell(:atAtSign)
  )

  it("should have 'self' return the receiving object inside of a macro", 
    obj = Origin mimic
    obj selfMacro = macro(self)
    obj2 = obj mimic
    obj selfMacro should == obj
    obj2 selfMacro should == obj2
  )

  it("should have 'call' defined inside the call to the macro", 
    result = macro(call) call
    result should have kind("Call")
  )
  
  it("should not evaluate it's arguments by default", 
    x=42
    macro(nil) call(x=13)
    x should == 42
  )

  it("should take any kinds of arguments", 
    x = macro(nil)
    x(13, 42, foo: 42*13) should be nil
  )

  it("should return the last value in the macro", 
    x = macro(nil. 42+13)
    x should == 55
  )
  
  it("should be possible to return from it prematurely, with return", 
    Ground x_macro_spec = 42
    m = macro(if(true, return(:bar)). Ground x_macro_spec = 24)
    m() should == :bar
    x_macro_spec should == 42
  )

  it("should return even from inside of a lexical block", 
    x = method(block, block call)
    y = macro(
      x(fn(return(42)))
      43)
    y should == 42
  )

  describe("name",
    it("should validate type of receiver",
      cell("DefaultMacro") should checkReceiverTypeOn(:name)
    )
  )

  describe("message",
    it("should validate type of receiver",
      cell("DefaultMacro") should checkReceiverTypeOn(:message)
    )
  )

  describe("argumentsCode",
    it("should validate type of receiver",
      cell("DefaultMacro") should checkReceiverTypeOn(:argumentsCode)
    )
  )

  describe("inspect",
    it("should validate type of receiver",
      cell("DefaultMacro") should checkReceiverTypeOn(:inspect)
    )
  )

  describe("notice",
    it("should validate type of receiver",
      cell("DefaultMacro") should checkReceiverTypeOn(:notice)
    )
  )

  describe("code",
    it("should validate type of receiver",
      cell("DefaultMacro") should checkReceiverTypeOn(:code)
    )
  )

  describe("formattedCode",
    it("should validate type of receiver",
      cell("DefaultMacro") should checkReceiverTypeOn(:formattedCode)
    )
  )
)
