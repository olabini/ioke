
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
          Runtime version versionNumber should == [0,4,0]
        )
      )

      onlyWhen(System feature?(:clr),
        it("should be the correct version",
          Runtime version versionNumber should == [0,2,0]
        )
      )
    )
  )
)
