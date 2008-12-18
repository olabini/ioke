
use("ispec")

describe(Runtime,
  describe("version",
    it("should be an Origin mimic",
      Runtime version should mimic(Origin)
      Runtime version should have kind("Origin")
    )

    describe("machine",
      it("should contain ikJVM",
        Runtime version machine should == "ikJVM"
      )
    )

    describe("versionNumber",
      it("should be the correct version",
        Runtime version versionNumber should == [0,1,0]
      )
    )
  )
)
