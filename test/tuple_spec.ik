
use("ispec")

describe(DefaultBehavior,
  describe("tuple",
    it("should return the right kind of tuple for up to nine elements",
      tuple should be same(Tuple)
      tuple(1,2) should mimic(Tuple Two)
      tuple(1,2,3) should mimic(Tuple Three)
      tuple(1,2,3,4) should mimic(Tuple Four)
      tuple(1,2,3,4,5) should mimic(Tuple Five)
      tuple(1,2,3,4,5,6) should mimic(Tuple Six)
      tuple(1,2,3,4,5,6,7) should mimic(Tuple Seven)
      tuple(1,2,3,4,5,6,7,8) should mimic(Tuple Eight)
      tuple(1,2,3,4,5,6,7,8,9) should mimic(Tuple Nine)
      tuple(1,2,3,4,5,6,7,8,9,10) should mimic(Tuple Many)
      tuple(1,2,3,4,5,6,7,8,9,10,11) should mimic(Tuple Many)
    )

    it("should add accessor methods for Tuple Many tuples",
      tx = tuple(1,2,3,4,5,6,7,8,"9",42,"blarg")
      tx _9 should == "9"
      tx _10 should == 42
      tx _11 should == "blarg"
    )

    it("should set the elements correctly",
      tx = tuple(5,4,3,2,1)
      tx first should == 5
      tx _1 should == 5

      tx second should == 4
      tx _2 should == 4

      tx third should == 3
      tx _3 should == 3

      tx fourth should == 2
      tx _4 should == 2

      tx fifth should == 1
      tx _5 should == 1
    )
  )

  describe("",
    it("should return the object sent in to it if one argument is given",
      x = (42+5)
      x should == 47
    )

    it("should return the empty tuple if no arguments are given",
      =(x, ())
      x should be(Tuple)
    )

    it("should delegate to the tuple method for all other cases",
      x = (1,2,3,4)
      x should mimic(Tuple Four)
    )
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
    it("should sort based on the elements inside",
      (tuple <=> tuple) should == 0
      (tuple <=> tuple(1,2)) should == -1
      (tuple(1,2) <=> tuple) should == 1
      (tuple(1,2) <=> tuple(1,2)) should == 0
      (tuple(1,2,3) <=> tuple(1,2)) should == 1
      (tuple(1,2) <=> tuple(1,2,3)) should == -1
      (tuple(1,2,3) <=> tuple(1,3,3)) should == -1
      (tuple(1,3,3) <=> tuple(1,2,3)) should == 1
    )
  )

  describe("==",
    it("should check equality",
      (tuple == tuple) should be true
      (tuple == tuple(1,2)) should be false
      (tuple(1,2) == tuple) should be false
      (tuple(1,2) == tuple(1,2)) should be true
      (tuple(1,2,3) == tuple(1,2)) should be false
      (tuple(1,2) == tuple(1,2,3)) should be false
      (tuple(1,2,3) == tuple(1,3,3)) should be false
      (tuple(1,3,3) == tuple(1,2,3)) should be false
      (tuple(1,tuple(1,2),3) == tuple(1,tuple(1,2),3)) should be true
    )
  )

  describe("!=",
    it("should check inequality",
      (tuple != tuple) should be false
      (tuple != tuple(1,2)) should be true
      (tuple(1,2) != tuple) should be true
      (tuple(1,2) != tuple(1,2)) should be false
      (tuple(1,2,3) != tuple(1,2)) should be true
      (tuple(1,2) != tuple(1,2,3)) should be true
      (tuple(1,2,3) != tuple(1,3,3)) should be true
      (tuple(1,3,3) != tuple(1,2,3)) should be true
      (tuple(1,tuple(1,2),3) != tuple(1,tuple(1,2),3)) should be false
    )
  )

  describe("inspect",
    it("should return something within parenthesis",
      tuple inspect should == "()"
    )

    it("should return the inspect format of things inside",
      tuple(method(nil), method(f, f b), fn(a b)) inspect should == "(method(nil), method(f, f b), fn(a b))"
    )

    it("should return the list of elements separated with , ",
      tuple(1, 2, :foo, "bar") inspect should == "(1, 2, :foo, \"bar\")"
    )
  )

  describe("notice",
    it("should return something within parenthesis",
      tuple notice should == "()"
    )

    it("should return the notice format of things inside",
      tuple(method, method, fn) notice should == "(method(...), method(...), fn(...))"
    )

    it("should return the list of elements separated with , ",
      tuple(1, 2, :foo, "bar") notice should == "(1, 2, :foo, \"bar\")"
    )
  )

  describe("arity",
    it("should return the arity of the tuple",
      tuple arity should == 0
      tuple(1,3) arity should == 2
      tuple(tuple(1,3), 42, 5) arity should == 3
      tuple(1,3,5,7,9,2,4,6,8,111) arity should == 10
    )
  )

  describe("asList",
    it("should return the elements in the tuple as a list",
      tuple asList should == []
      tuple(1,2,3) asList should == [1,2,3]
      tuple(3,3) asList should == [3,3]
    )
  )

  describe("asTuple",
    it("should return itself",
      x = tuple
      x asTuple should be(x)
      x = tuple(1,2,3,555)
      x asTuple should be(x)
    )
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
