
use("ispec")

describe(DefaultBehavior,
  describe("syntax",
    it("should name itself after the slot it's assigned to if it has no name", 
      x = syntax(nil)
      cell(:x) name should == "x"
    )
    
    it("should not change it's name if it already has a name", 
      x = syntax(nil)
      y = cell(:x)
      cell(:y) name should == "x"
    )
    
    it("should know it's own name", 
      (x = syntax(nil)) name should == "x"
    )
  )
)

describe("DefaultSyntax",
  it("should just remove itself if nil is returned",
    Ground syntaxTest = []
    ss = syntax(syntaxTest << :called. nil)
    
    3 times(syntaxTest << :times1. ss. syntaxTest << :times2.)

    syntaxTest should == [:times1, :called, :times2, :times1, :times2, :times1, :times2]
  )

  it("should work at the beginning of a message chain",
    ss = syntax(Message from(1+1))
    block = fn(ss * 2)
    block call should == 4
    block call should == 4
  )

  it("should work at the end of a message chain",
    ss = syntax(Message from(1+1))
    block = fn(nil. ss)
    block call should == 2
    block call should == 2
  )

  it("should work as a regular argument",
    Ground syntaxTest = []
    ss = syntax(syntaxTest << :called. Message from(1+1))
    mm = method(arg, arg)

    block = fn(mm(ss))

    block call should == 2
    block call should == 2

    syntaxTest should == [:called]
  )

  it("should be possible to give it a documentation string", 
    syntax("foo is bar", nil) documentation should == "foo is bar"
  )

  it("should signal a condition if activating the kind",
    fn(DefaultSyntax) should signal(Condition Error Invocation NotActivatable)
  )

  it("should have @ return the receiving object inside of a macro", 
    Ground syntaxTest = []
    obj = Origin mimic
    obj atSign = syntax(syntaxTest << @. nil)
    obj2 = obj mimic
    obj atSign
    obj2 atSign
    syntaxTest should == [obj, obj2]
  )

  it("should have @@ return the executing syntax inside of a syntax", 
    Ground syntaxTest = []
    obj = Origin mimic
    obj atAtSign = syntax(syntaxTest << @@. nil)
    obj2 = obj mimic
    obj atAtSign
    obj2 atAtSign
    syntaxTest should == [obj cell(:atAtSign), obj2 cell(:atAtSign)]
  )

  it("should have 'self' return the receiving object inside of a macro", 
    Ground syntaxTest = []
    obj = Origin mimic
    obj atSign = syntax(syntaxTest << self. nil)
    obj2 = obj mimic
    obj atSign
    obj2 atSign
    syntaxTest should == [obj, obj2]
  )

  it("should have 'call' defined inside the call to the macro", 
    Ground syntaxTest = []
    syntax(syntaxTest << call. nil) call
    syntaxTest[0] should have kind("Call")
  )
  
  it("should not evaluate it's arguments by default", 
    x=42
    syntax(nil) call(x=13)
    x should == 42
  )

  it("should take any kinds of arguments", 
    x = syntax(nil)
    x(13, 42, foo: 42*13)
  )

  it("should be possible to return from it prematurely, with return", 
    Ground x_syntax_spec = 42
    m = syntax(if(true, return(nil)). Ground x_syntax_spec = 24)
    m()
    x_syntax_spec should == 42
  )

  it("should return even from inside of a lexical block", 
    Ground x_syntax_spec = 42
    Ground x = method(block, block call)
    m = syntax(
      Ground x(fn(Ground x_syntax_spec = 43. return(nil)))
      Ground x_syntax_spec = 44. nil)
    m()
    x_syntax_spec should == 43
  )

  describe("name",
    it("should validate type of receiver",
      syntax should checkReceiverTypeOn(:name)
    )
  )

  describe("expand",
    it("should validate type of receiver",
      syntax should checkReceiverTypeOn(:expand)
    )
  )

  describe("message",
    it("should validate type of receiver",
      syntax should checkReceiverTypeOn(:message)
    )
  )

  describe("argumentsCode",
    it("should validate type of receiver",
      syntax should checkReceiverTypeOn(:argumentsCode)
    )
  )

  describe("inspect",
    it("should validate type of receiver",
      syntax should checkReceiverTypeOn(:inspect)
    )
  )

  describe("notice",
    it("should validate type of receiver",
      syntax should checkReceiverTypeOn(:notice)
    )
  )

  describe("code",
    it("should validate type of receiver",
      syntax should checkReceiverTypeOn(:code)
    )
  )

  describe("formattedCode",
    it("should validate type of receiver",
      syntax should checkReceiverTypeOn(:formattedCode)
    )
  )
)
