
use("ispec")

describe("Symbol",
  it("should have the correct kind", 
    Symbol should have kind("Symbol")
  )

  it("should not be possible to mimic", 
    fn(:foo mimic) should signal(Condition Error CantMimicOddball)
  )
  
  it("should evaluate to itself", 
    :foo_bar should == :foo_bar
  )
  
  it("should evaluate to the same instance every time referenced", 
    :foo x = 13
    :foo x should == 13
  )
)
