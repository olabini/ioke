
use("ispec")

describe("Base",
  describe("mimic", 
    it("should be able to mimic Origin", 
      result = Origin mimic
      result should have kind("Origin")
      result should not be same(Origin)
    )

    it("should be able to mimic Ground", 
      result = Ground mimic
      result should have kind("Ground")
      result should not be same(Ground)
    )

    it("should be able to mimic Base", 
      result = Base mimic
      result kind should == "Base"
    )

    it("should be able to mimic Text", 
      result = Text mimic
      result should have kind("Text")
      result should not be same(Text)
    )

;     it("should not be able to mimic DefaultBehavior", 
;       fn(DefaultBehavior mimic) should signal(Condition Error NoSuchCell)
;     )

    it("should not be able to mimic nil", 
      fn(nil mimic) should signal(Condition Error CantMimicOddball)
    )
  )
)
