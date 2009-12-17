use("ispec")

describe(Pair,
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

    it("should validate type of receiver",
      Pair should checkReceiverTypeOn(:first)
    )
  )

  describe("key",
    it("should return the first element",
      (1 => 2) key should == 1)

    it("should validate type of receiver",
      Pair should checkReceiverTypeOn(:key)
    )
  )

  describe("second",
    it("should return the second element",
      (1 => 2) second should == 2)

    it("should validate type of receiver",
      Pair should checkReceiverTypeOn(:second)
    )
  )

  describe("value",
    it("should return the second element",
      (1 => 2) value should == 2)

    it("should validate type of receiver",
      Pair should checkReceiverTypeOn(:value)
    )
  )

  describe("asTuple",
    it("should return a tuple with the two elements in it",
      (1 => 2) asTuple should == tuple(1,2)
      ("blarg" => :foo) asTuple should == tuple("blarg",:foo)
    )
  )

  describe("<=>",
    it("should first compare the first value and return the result of that",
      ((1=>1) <=> (2=>1)) should == (1<=>2)
      ((4=>1) <=> (3=>1)) should == (4<=>3))

    it("should then compare the second value and return the result of that",
      ((1=>1) <=> (1=>2)) should == (1<=>2)
      ((1=>4) <=> (1=>3)) should == (4<=>3))
  )

  describe("inspect",
    it("should return the inspect of something inside it",
      ("foo" => method(blarg fux)) inspect should == "\"foo\" => method(blarg fux)"
    )

    it("should return a simple string for something simple",
      (1 => 2) inspect should == "1 => 2"
    )

    it("should validate type of receiver",
      Pair should checkReceiverTypeOn(:inspect)
    )
  )

  describe("notice",
    it("should return the notice of something inside it",
      ("foo" => method(blarg fux)) notice should == "\"foo\" => method(...)"
    )

    it("should return a simple string for something simple",
      (1 => 2) notice should == "1 => 2"
    )

    it("should validate type of receiver",
      Pair should checkReceiverTypeOn(:notice)
    )
  )

  describe("hash",
    it("should be derived from the constituent elements",
      (1 => 2) hash should == (1 => 2) hash
      (1 => 2) hash should not == (1 => 1) hash
    )
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
