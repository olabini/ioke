
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

      it("should transform the when part to call cond:name if it exists",
        Ground blargCalled = []
        blarg = method(Ground blargCalled << :true, 1..10)
        case(5,
          blarg, :foo) should == :foo
        blargCalled should == [:true]

        Ground wowserCalled = []
        DefaultBehavior Case cell("case:caseTestWowser") = method(+args,
          wowserCalled << :mix
          1...10)

        case(5,
          caseTestWowser, :foo) should == :foo

        case(5,
          caseTestWowser(1,2,3), :foo) should == :foo

        wowserCalled should == [:mix, :mix]

        case(5,
          caseTestWowser(1,caseTestWowser(44),3), :foo) should == :foo

        wowserCalled should == [:mix, :mix, :mix, :mix]
      )
    )

    describe("case:and",
      it("should return an object that calls === on each argument and returns true if all are true",
        Ground calledWith = []
        x = Origin mimic
        y = Origin mimic

        x === = method(other,
          Ground calledWith << [:x, other].
          true)

        y === = method(other,
          Ground calledWith << [:y, other].
          true)

        (case:and(x, y) === 42) should == true
        Ground calledWith should == [[:x, 42], [:y, 42]]

        (case:and(1..5, 3..4) === 4) should == true

        x === = method(other,
          Ground calledWith << [:x, other].
          false)

        Ground calledWith = []

        (case:and(x, y) === 43) should == false
        Ground calledWith should == [[:x, 43]]
      )
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
      it("should not take any arguments",
        fn(case:else(1)) should signal(Condition Error Invocation TooManyArguments)
      )

      it("should return an object that returns true from ===",
        (case:else() === :x) should == true
        (case:else() === nil) should == true 
        (case:else() === 42) should == true
      )
   )

    describe("case:otherwise",
      it("should not take any arguments",
        fn(case:otherwise(1)) should signal(Condition Error Invocation TooManyArguments)
      )

      it("should return an object that returns true from ===",
        (case:otherwise() === :x) should == true
        (case:otherwise() === nil) should == true 
        (case:otherwise() === 42) should == true
      )
    )
  )
)
