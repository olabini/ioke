
use("ispec")

describe(DefaultBehavior,
  describe("FlowControl",
    describe("cond",
      it("should return nil for an empty statement",
        cond should == nil
      )

      it("should evaluate and return the result of one statement",
        cond(42+2) should == 44
      )

      it("should evaluate a condition and not do it's then part if it's false",
        Ground condTests = []
        cond(false, condTests << :ran) should == nil
        condTests should == []
      )

      it("should do the then part for a true statement",
        Ground condTests = []
        cond(true, condTests << :ran. 42) should == 42
        condTests should == [:ran]
      )

      it("should return the then part for a true statement",
        cond(true, 42+4) should == 46
      )

      it("should not execute conditions after the first true one",
        Ground condTests = []
        cond(
          true, nil,
          condTests << :cond. false, nil
        )

        condTests should == []
      )

      it("should not execute more than one true condition",
        Ground condTests = []
        cond(
          condTests << :one. true, nil,
          condTests << :two. true, nil,
          condTests << :three. true, nil
        )

        condTests should == [:one]
      )

      it("should evaluate all conditions and return the else part if they are false",
        cond(false, false, false, false, 42) should == 42
      )
    )
  )
)
