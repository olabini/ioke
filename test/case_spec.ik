
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
        case(42) should be nil

        case(42,
          1..10 , :one) should be nil
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

        case:and(x, y) should === 42
        Ground calledWith should == [[:x, 42], [:y, 42]]

        case:and(1..5, 3..4) should === 4

        x === = method(other,
          Ground calledWith << [:x, other].
          false)

        Ground calledWith = []

        (case:and(x, y) === 43) should be false
        Ground calledWith should == [[:x, 43]]
      )

      it("should be possible to use within a case-expression",
        case(42, and(1..50, 40..45), :foo) should == :foo
        case(42, and(and(40..43), 40..45), :foo) should == :foo
        case(42, and(and(and(40..43, 10...12)), 40..45), :foo) should be nil
      )
    )

    describe("case:or",
      it("should return an object that calls === on each argument and returns true if at least one are true",
        Ground calledWith = []
        x = Origin mimic
        y = Origin mimic

        x === = method(other,
          Ground calledWith << [:x, other].
          true)

        y === = method(other,
          Ground calledWith << [:y, other].
          true)

        (case:or(x, y) === 42) should be true
        Ground calledWith should == [[:x, 42]]

        (case:or(1..3, 3..4) === 4) should be true

        x === = method(other,
          Ground calledWith << [:x, other].
          false)

        (case:or(x, x) === 43) should be false

        Ground calledWith = []

        (case:or(x, y) === 43) should be true
        Ground calledWith should == [[:x, 43], [:y, 43]]
      )

      it("should be possible to use within a case-expression",
        case(42, or(1..40, 40..45), :foo) should == :foo
        case(42, or(or(50..53), 40..45), :foo) should == :foo
        case(42, or(or(or(30..33, 10...12)), 40..41), :foo) should be nil
      )
    )

    describe("case:not",
      it("should take exactly one argument",
        fn(case:not()) should signal(Condition Error Invocation TooFewArguments)
        fn(case:not(1,2)) should signal(Condition Error Invocation TooManyArguments)
      )

      it("should return an object that when calling === on it will return the inverse of the argument to it",
        (case:not(1..5) === 0) should be true
        (case:not(1..5) === 1) should be false
        (case:not(1..5) === 2) should be false
        (case:not(1..5) === 3) should be false
        (case:not(1..5) === 4) should be false
        (case:not(1..5) === 5) should be false
        (case:not(1..5) === 6) should be true

        (case:not(1...5) === 0) should be true
        (case:not(1...5) === 1) should be false
        (case:not(1...5) === 2) should be false
        (case:not(1...5) === 3) should be false
        (case:not(1...5) === 4) should be false
        (case:not(1...5) === 5) should be true
        (case:not(1...5) === 6) should be true
      )

      it("should be possible to use within a case-expression",
        case(42, not(1..30), :foo) should == :foo
        case(42, not(not(not(30..33))), :foo) should == :foo
        case(42, not(not(30..33)), :foo) should be nil
      )
    )

    describe("case:nand",
      it("should take at least one argument",
        fn(case:nand()) should signal(Condition Error Invocation TooFewArguments)
      )

      it("should return an object that fulfills the nand protocal when called with ===",
        (case:nand(1..5) === 2) should be false
        (case:nand(1..5) === 6) should be true

        (case:nand(1..5, 1...3) === 2) should be false
        (case:nand(1..5, 1...2) === 6) should be true
        (case:nand(1..5, 1..7)  === 6) should be true
        (case:nand(1..7, 1..5)  === 6) should be true

        (case:nand(1..5, 1...3, 2..3) === 2) should be false

        (case:nand(1..5, 1...2, 1..3) === 6) should be true
        (case:nand(1..5, 1..7, 1..3)  === 6) should be true
        (case:nand(1..7, 1..5, 1..3)  === 6) should be true

        (case:nand(1..5, 1...2, 1..100) === 6) should be true
        (case:nand(1..5, 1..7, 1..100)  === 6) should be true
        (case:nand(1..7, 1..5, 1..100)  === 6) should be true
      )

      it("should be possible to use within a case-expression",
        case(42, nand(1..30), :foo) should == :foo
        case(42, nand(nand(1..50, 43..50), 42..43), :foo) should be nil
        case(42, nand(nand(1..50, 40..50), 43..44), :foo) should == :foo
      )
    )

    describe("case:nor",
      it("should take at least one argument",
        fn(case:nor()) should signal(Condition Error Invocation TooFewArguments)
      )

      it("should return an object that fulfills the nor protocal when called with ===",
        (case:nor(1..5) === 2) should be false
        (case:nor(1..5) === 6) should be true

        (case:nor(1..5, 1...3) === 2) should be false
        (case:nor(1..5, 1...2) === 6) should be true
        (case:nor(1..5, 1..7)  === 6) should be false
        (case:nor(1..7, 1..5)  === 6) should be false

        (case:nor(1..5, 1...3, 2..3) === 2) should be false

        (case:nor(1..5, 1...2, 1..3) === 6) should be true
        (case:nor(1..5, 1..7, 1..3)  === 6) should be false
        (case:nor(1..7, 1..5, 1..3)  === 6) should be false

        (case:nor(1..5, 1...2, 1..100) === 6) should be false
        (case:nor(1..5, 1..7, 1..100)  === 6) should be false
        (case:nor(1..7, 1..5, 1..100)  === 6) should be false
      )

      it("should be possible to use within a case-expression",
        case(42, nor(1..30), :foo) should == :foo
        case(42, nor(nor(1..50, 43..50), 42..43), :foo) should be nil
        case(42, nor(nor(1..50, 40..50), 43..44), :foo) should == :foo
      )
    )

    describe("case:xor",
      it("should take at least one argument",
        fn(case:xor()) should signal(Condition Error Invocation TooFewArguments)
      )

      it("should return an object that fulfills the xor protocal when called with ===",
        (case:xor(1..5) === 2) should be true
        (case:xor(1..5) === 6) should be false

        (case:xor(1..5, 1...3) === 2) should be false
        (case:xor(1..5, 1...2) === 6) should be false
        (case:xor(1..5, 1..7)  === 6) should be true
        (case:xor(1..7, 1..5)  === 6) should be true

        (case:xor(1..5, 1...3, 2..3) === 2) should be false

        (case:xor(1..5, 1...2, 1..3) === 6) should be false
        (case:xor(1..5, 1..7, 1..3)  === 6) should be true
        (case:xor(1..7, 1..5, 1..3)  === 6) should be true

        (case:xor(1..5, 1...2, 1..100) === 6) should be true
        (case:xor(1..5, 1..7, 1..100)  === 6) should be false
        (case:xor(1..7, 1..5, 1..100)  === 6) should be false
      )

      it("should be possible to use within a case-expression",
        case(42, xor(1..50), :foo) should == :foo
        case(42, xor(xor(1..50, 43..50), 42..43), :foo) should be nil
        case(42, xor(xor(1..50, 40..50), 42..44), :foo) should == :foo
      )
    )

    describe("case:else",
      it("should not take any arguments",
        fn(case:else(1)) should signal(Condition Error Invocation TooManyArguments)
      )

      it("should return an object that returns true from ===",
        (case:else() === :x) should be true
        (case:else() === nil) should be true 
        (case:else() === 42) should be true
      )
   )

    describe("case:otherwise",
      it("should not take any arguments",
        fn(case:otherwise(1)) should signal(Condition Error Invocation TooManyArguments)
      )

      it("should return an object that returns true from ===",
        (case:otherwise() === :x) should be true
        (case:otherwise() === nil) should be true 
        (case:otherwise() === 42) should be true
      )
    )
  )
)
