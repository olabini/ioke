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
    )
    
    describe("stubs",
      it("should apply an empty list of stubs to an object",
        Origin mimic stubs should be empty
      )    
    )
  )
)