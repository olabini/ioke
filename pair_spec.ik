use("affirm")

describe(Pair,
;  it("should report pending stuff")
  it("should have the correct kind",
    Pair kind should == "Pair")

  it("should have the wrong kind",
    Pair kind should not == "Pairx")

  it("should be possible to mimic",
    x = Pair mimic
    x should not be same(Pair)
    x should mimic(Pair)
    x should have kind("Pair"))

  it("should mimic Enumerable",
    Pair should mimic(Mixins Enumerable))

  it("should mimic Comparing",
    Pair should mimic(Mixins Comparing))

  describe("first",
    it("should return the first element",
      (1 => 2) first should == 1)
  )

  describe("key",
    it("should return the first element",
      (1 => 2) key should == 1)
  )

  describe("second",
    it("should return the second element",
      (1 => 2) second should == 2)
  )

  describe("value",
    it("should return the second element",
      (1 => 2) value should == 2)
  )

  describe("<=>",
    it("should first compare the first value and return the result of that",
      ((1=>1) <=> (2=>1)) should == (1<=>2)
      ((4=>1) <=> (3=>1)) should == (4<=>3))

    it("should then compare the second value and return the result of that",
      ((1=>1) <=> (1=>2)) should == (1<=>2)
      ((1=>4) <=> (1=>3)) should == (4<=>3))
  )
)

describe(DefaultBehavior,
  describe("=>",
    it("should return a new pair for simple objects",
      (23 => 15) first  should == 23
      (23 => 15) second should == 15

      ("str" => "foo") first  should == "str"
      ("str" => "foo") second should == "foo")

    it("should return a new pair for more complicated expressions",
      (23+15-2 => 3332323+2) first  should == 36
      (23+15-2 => 3332323+2) second should == 3332325)
  )
)

Affirm run
