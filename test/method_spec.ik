
use("ispec")

describe(DefaultBehavior,
  describe("method",
    it("should return a method that returns nil when called with no arguments",
      method call should == nil
      method() call should == nil
    )
    
    it("should name itself after the slot it's assigned to if it has no name",
      (x = method(nil)) name should == "x"
    )
    
    it("should not change it's name if it already has a name",
      x = method(nil)
      y = cell("x")
      cell("y") name should == "x"
    )
    
    it("should know it's own name",
      (x = method(nil)) name should == "x"
    )
  )
)    

