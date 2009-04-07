use("ispec")

describe("ISpec",
  describe("ExtendedDefaultBehavior",
    describe("stub!",
      it("should add a stub to an object",
        foo = Origin mimic
        foo stub(:bar)
        foo stubs length should == 1
        foo stubs first cellName should == :bar
      )
      
      it("should replace the return value of the stubbed method",
        foo = Origin mimic do(bar = 5)
        foo stub(:bar) andReturn(6)
        foo bar should == 6
      )
    )
    
    describe("stubs",
      it("should apply an empty list of stubs to an object",
        Origin mimic stubs should be empty
      )    
    )
  )
)