
use("ispec")

describe("nil", 
  it("should have the correct kind", 
    nil should have kind("nil")
  )

  it("should not be possible to mimic", 
    fn(nil mimic) should signal(Condition Error CantMimicOddball)
  )
  
  it("should act as false in if statement", 
    if(nil, 42, 43) should == 43
  )
  
  it("should be nil", 
    nil should be nil
  )
)

describe("false", 
  it("should have the correct kind", 
    false should have kind("false")
  )

  it("should not be possible to mimic", 
    fn(false mimic) should signal(Condition Error CantMimicOddball)
  )
  
  it("should act as false in if statement", 
    if(false, 42, 43) should == 43
  )

  it("should not be nil", 
    false should not be nil
  )
)

describe("true", 
  it("should have the correct kind", 
    true should have kind("true")
  )

  it("should not be possible to mimic", 
    fn(true mimic) should signal(Condition Error CantMimicOddball)
  )
  
  it("should act as true in if statement", 
    if(true, 42, 43) should == 42
  )

  it("should not be nil", 
    true should not be nil
  )
)

describe("Base", 
  it("should have the correct kind", 
    Base kind should == "Base"
  )

  it("should have a 'mimic' cell", 
    Base cell?(:mimic) should be true
  )
)

describe("Ground", 
  it("should have the correct kind", 
    Ground should have kind("Ground")
  )

  it("should have all the expected cells", 
    Ground should have cell(:Base)
    Ground should have cell(:DefaultBehavior)
    Ground should have cell(:Ground)
    Ground should have cell(:Origin)
    Ground should have cell(:System)
    Ground should have cell(:Runtime)
    Ground should have cell(:Text)
    Ground should have cell(:Number)
    Ground should have cell(:nil)
    Ground should have cell(:true)
    Ground should have cell(:false)
    Ground should have cell(:Method)
    Ground should have cell(:DefaultMethod)
    Ground should have cell(:NativeMethod)
    Ground should have cell(:Symbol)
    Ground should have cell(:LexicalBlock)
    Ground should have cell(:Mixins)
    Ground should have cell(:Restart)
    Ground should have cell(:List)
    Ground should have cell(:Dict)
    Ground should have cell(:Set)
    Ground should have cell(:Pair)
    Ground should have cell(:DefaultMacro)
    Ground should have cell(:Call)
    Ground should have cell(:Range)
    Ground should have cell(:Condition)
    Ground should have cell(:Rescue)
    Ground should have cell(:Handler)
    Ground should have cell(:IO)
  )
)

describe("System", 
  it("should have the correct kind", 
    System should have kind("System")
  )
  
  ;     describe("ifMain", 
  ;       it("should run block when the currently running code is the main", 
  ;         runtime = IokeRuntime.get_runtime
  ;         runtime.system.data.current_program = "<eval>"
  ;         runtime.evaluate_stream("<eval>", StringReader.new("System ifMain(xx = 42)"), runtime.message, runtime.ground)
  ;         runtime.ground.find_cell(nil, nil, "xx").data.as_java_integer.should == 42
  ;       )

  ;       it("should not run block when the currently running code is not the main", 
  ;         runtime = IokeRuntime.get_runtime
  ;         runtime.system.data.current_program = "<eval>"
  ;         runtime.evaluate_stream("<eval2>", StringReader.new("System ifMain(xx = 42)"), runtime.message, runtime.ground)
  ;         runtime.ground.find_cell(nil, nil, "xx").should == runtime.nul
  ;       )
  ;     )
  
  it("should be possible to mimic system", 
    System mimic
  )
)

describe("Runtime", 
  it("should have the correct kind", 
    Runtime should have kind("Runtime")
  )
)

describe("DefaultBehavior", 
  it("should have the correct kind", 
    DefaultBehavior kind should == "DefaultBehavior"
  )
)

describe("Call", 
  it("should have the correct kind", 
    Call should have kind("Call")
  )
)

describe("Origin", 
  it("should have the correct kind", 
    Origin should have kind("Origin")
  )
)

describe("Text", 
  it("should have the correct kind", 
    Text should have kind("Text")
  )
)

describe("Range", 
  it("should have the correct kind", 
    Range should have kind("Range")
  )
)

describe("Method", 
  it("should have the correct kind", 
    cell(:Method) kind should == "Method"
  )
)

describe("DefaultMethod", 
  it("should have the correct kind", 
    cell(:DefaultMethod) kind should == "DefaultMethod"
  )
)

describe("DefaultMacro", 
  it("should have the correct kind", 
    cell(:DefaultMacro) kind should == "DefaultMacro"
  )
)

describe("NativeMethod", 
  it("should have the correct kind", 
    cell(:NativeMethod) kind should == "NativeMethod"
  )
)

describe("LexicalBlock", 
  it("should have the correct kind", 
    LexicalBlock should have kind("LexicalBlock")
  )
)

describe("Mixins", 
  it("should have the correct kind", 
    Mixins kind should == "Mixins"
  )

  it("should have Comparing defined", 
    Mixins cell?(:Comparing) should be true
  )

  it("should have Enumerable defined", 
    Mixins cell?(:Enumerable) should be true
  )

  describe("Enumerable", 
    it("should have the correct kind", 
      Mixins Enumerable kind should == "Mixins Enumerable"
    )
  )
  
  describe("Comparing", 
    it("should have the correct kind", 
      Mixins Comparing kind should == "Mixins Comparing"
    )
  )
)

describe("Message", 
  it("should have the correct kind", 
    Message should have kind("Message")
  )
)

describe("Condition", 
  it("should have the correct kind", 
    Condition should have kind("Condition")
  )
)
