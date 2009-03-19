
use("ispec")
use("blank_slate")

describe("BlankSlate",
  describe("create",
    it("should be possible to create a new one with it",
      aNew = BlankSlate create(
        fn(bs,
          bs pass = macro(call [call message name, call evaluatedArguments])))

      aNew foo should == [:foo, []]
      aNew foo(42+2, 13) should == [:foo, [44, 13]]
    )
  )
)
