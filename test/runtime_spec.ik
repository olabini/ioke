
use("ispec")

describe(Runtime,
  describe("version",
    it("should be an Origin mimic",
      Runtime version should mimic(Origin)
      Runtime version should have kind("Origin")
    )

    describe("machine",
      onlyWhen(System feature?(:java),
        it("should contain ikj",
          Runtime version machine should == "ikj"
        )
      )

      onlyWhen(System feature?(:clr),
        it("should contain ikc",
          Runtime version machine should == "ikc"
        )
      )
    )

    describe("versionNumber",
      onlyWhen(System feature?(:java),
        it("should be the correct version",
          Runtime version versionNumber should == [0,4,1]
        )
      )

      onlyWhen(System feature?(:clr),
        it("should be the correct version",
          Runtime version versionNumber should == [0,4,1]
        )
      )
    )
  )

  describe("nodeId",
    it("should return 1 for the first runtime running in the same process space",
      Runtime nodeId should == 1
    )

    ; it("should return something that is not 1 for the next created runtime",
    ;   Runtime create nodeId should not == 1
    ; )
  )
)
