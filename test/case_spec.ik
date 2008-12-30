
use("ispec")

describe(DefaultBehavior,
  describe("Case",
    describe("case",
      it("should only evaluate the first value once",
        Ground caseTests = []
        case((caseTests << :evaluated. 44),
          1..42, :one,
          43..45, :two)

        caseTests should == [:evaluated]
      )

      it("should only evaluate the when part of each entry until something returns true",
        Ground caseTests = []
        case(42,
          (caseTests << :one. 1..30), :onex,
          (caseTests << :two. 2..40), :twox,
          (caseTests << :three. 3..44), :threex,
          (caseTests << :four. 4..45), :fourx)

        caseTests should == [:one, :two, :three]
      )

      it("should return the value of the then part that succeeds",
        case(42,
          1..10 , :one,
          10..30, :two,
          30..50, :three,
          50..60, :four) should == :three
      )

      it("should return nil if no part matches",
        case(42) should == nil

        case(42,
          1..10 , :one) should == nil
      )

      it("should execute the last statement if there is no when part for it",
        case(42,
          1..10 , :one,
                  42+2) should == 44
      )

      it("should call === with the result of the condition on each when part",
        Ground caseTests = []
        obj = Origin mimic
        obj cell("===") = method(other, caseTests << other. false)

        case(44*2,
          obj, "blah",
          obj, "bluh"
        )

        caseTests should == [88, 88]
      )

      it("should transform the when part to call cond:name if it exists")
    )

    describe("case:and",
      it("should have tests")
    )

    describe("case:or",
      it("should have tests")
    )

    describe("case:not",
      it("should have tests")
    )

    describe("case:nand",
      it("should have tests")
    )

    describe("case:nor",
      it("should have tests")
    )

    describe("case:xor",
      it("should have tests")
    )

    describe("case:else",
      it("should have tests")
    )

    describe("case:otherwise",
      it("should have tests")
    )
  )
)
