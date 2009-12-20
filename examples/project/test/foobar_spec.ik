
use("foobarius")
use("ispec")

describe(Foobarius,
  it("should mimic Origin",
    Foobarius should mimic(Origin))

  describe("Board",
    describe("yay",
      it("should return the addition of the two numbers",
        Foobarius Board yay(2, 40) should == 42
      )
    )
  )

  describe("SnowBoard",
    describe("yay3",
      it("should return the multiplication of the two numbers",
        Foobarius SnowBoard yay3(21, 2) should == 42
      )
    )
  )
)

describe(Origin,
  describe("blah",
    it("should return 42",
      blah should == 42
    )
  )
)

describe(DefaultBehavior,
  describe("Definitions",
    describe("mummy",
      it("should return a mummy",
        mummy should == :tot
      )
    )
  )
)
