
use("foobarius")
use("ispec")

describe(Foobarius,
  describe("SubWoofer",
    describe("foo",
      it("should be one indexed",
        x = Foobarius SubWoofer mimic
        x[0] = 10
        x[1] = 11
        x[2] = 12
        x foo(1) should == 10
      )
    )
  )

  describe("NixEffector",
    it("should mimic Foobarius",
      Foobarius NixEffector should mimic(Foobarius)
    )
  )
)
