
use("ispec")

;; Design decisions
;; - immutable - only getters
;; - Only accessors up to the ninth element. Everything over that need to be pattern matched out
;; - should add accessors in the form _1, _2, _3 etc.
;; - No access by index
;; - No iteration over elements

;; -- Possible add asTuple to Enumerable... would be useful to handle what the rhs is for pattern matching
;; -- Pair should define asTuple too, of course.

describe(DefaultBehavior,
  describe("tuple",
    it("should have tests")
  )

  describe("",
    it("should have tests")
  )
)

describe(Tuple,
  it("should have the correct kind",
    Tuple kind should == "Tuple"
  )

  it("should be possible to mimic",
    x = Tuple mimic
    x should not be same(Tuple)
    x should mimic(Tuple)
    x should have kind("Tuple")
  )

  it("should mimic Comparing",
    Tuple should mimic(Mixins Comparing)
  )

  describe("<=>",
    it("should have tests")
  )

  describe("inspect",
    it("should have tests")
  )

  describe("notice",
    it("should have tests")
  )

  describe("arity",
    it("should have tests")
  )

  describe("asList",
    it("should have tests")
  )

  describe("Two",
    it("should mimic Tuple",
      Tuple Two should mimic(Tuple)
    )

    it("should have the correct kind",
      Tuple Two should have kind("Tuple Two")
    )

    it("should have accessors for the first two elements",
      Tuple Two cell?(:first) should be true
      Tuple Two cell?(:"_1") should be true

      Tuple Two cell?(:second) should be true
      Tuple Two cell?(:"_2") should be true
    )
  )

  describe("Three",
    it("should mimic Tuple Two",
      Tuple Three should mimic(Tuple Two)
    )

    it("should have the correct kind",
      Tuple Three should have kind("Tuple Three")
    )

    it("should have accessor for the third element",
      Tuple Three cell?(:third) should be true
      Tuple Three cell?(:"_3") should be true
    )
  )

  describe("Four",
    it("should mimic Tuple Three",
      Tuple Four should mimic(Tuple Three)
    )

    it("should have the correct kind",
      Tuple Four should have kind("Tuple Four")
    )

    it("should have accessor for the fourth element",
      Tuple Four cell?(:fourth) should be true
      Tuple Four cell?(:"_4") should be true
    )
  )

  describe("Five",
    it("should mimic Tuple Four",
      Tuple Five should mimic(Tuple Four)
    )

    it("should have the correct kind",
      Tuple Five should have kind("Tuple Five")
    )

    it("should have accessor for the fifth element",
      Tuple Five cell?(:fifth) should be true
      Tuple Five cell?(:"_5") should be true
    )
  )

  describe("Six",
    it("should mimic Tuple Five",
      Tuple Six should mimic(Tuple Five)
    )

    it("should have the correct kind",
      Tuple Six should have kind("Tuple Six")
    )

    it("should have accessor for the sixth element",
      Tuple Six cell?(:sixth) should be true
      Tuple Six cell?(:"_6") should be true
    )
  )

  describe("Seven",
    it("should mimic Tuple Six",
      Tuple Seven should mimic(Tuple Six)
    )

    it("should have the correct kind",
      Tuple Seven should have kind("Tuple Seven")
    )

    it("should have accessor for the seventh element",
      Tuple Seven cell?(:seventh) should be true
      Tuple Seven cell?(:"_7") should be true
    )
  )

  describe("Eight",
    it("should mimic Tuple Seven",
      Tuple Eight should mimic(Tuple Seven)
    )

    it("should have the correct kind",
      Tuple Eight should have kind("Tuple Eight")
    )

    it("should have accessor for the eighth element",
      Tuple Eight cell?(:eighth) should be true
      Tuple Eight cell?(:"_8") should be true
    )
  )

  describe("Nine",
    it("should mimic Tuple Eight",
      Tuple Nine should mimic(Tuple Eight)
    )

    it("should have the correct kind",
      Tuple Nine should have kind("Tuple Nine")
    )

    it("should have accessor for the ninth element",
      Tuple Nine cell?(:ninth) should be true
      Tuple Nine cell?(:"_9") should be true
    )
  )

  describe("Many",
    it("should mimic Tuple Nine",
      Tuple Many should mimic(Tuple Nine)
    )

    it("should have the correct kind",
      Tuple Many should have kind("Tuple Many")
    )
  )
)
