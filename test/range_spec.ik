
use("ispec")

describe(DefaultBehavior,
  describe("..", 
    it("should create a range from 0 to 0", 
      (0..0) should have kind("Range")
      (0..0) from should == 0
      (0..0) to should == 0
    )

    it("should create a range from 0 to 1", 
      (0..1) should have kind("Range")
      (0..1) from should == 0
      (0..1) to should == 1
    )

    it("should create a range from 0 to -1", 
      (0..-1) should have kind("Range")
      (0..-1) from should == 0
      (0..-1) to should == -1
    )

    it("should create a range from other numbers", 
      (23..-342) should have kind("Range")
      (23..-342) from should == 23
      (23..-342) to should == -342
    )

    it("should create an inclusive range", 
      (0..0) inclusive? should true
    )
  )

  describe("...", 
    it("should create a range from 0 to 0", 
      (0...0) should have kind("Range")
      (0...0) from should == 0
      (0...0) to should == 0
    )

    it("should create a range from 0 to 1", 
      (0...1) should have kind("Range")
      (0...1) from should == 0
      (0...1) to should == 1
    )

    it("should create a range from 0 to -1", 
      (0...-1) should have kind("Range")
      (0...-1) from should == 0
      (0...-1) to should == -1
    )

    it("should create a range from other numbers", 
      (23...-342) should have kind("Range")
      (23...-342) from should == 23
      (23...-342) to should == -342
    )

    it("should create an inclusive range", 
      (0...0) inclusive? should be false
    )
  )
)

describe("Range", 
  describe("from", 
    it("should return the from part of the range", 
      (13..0) from should == 13
      (-42..0) from should == -42
      (0..0) from should == 0

      (13...0) from should == 13
      (-42...0) from should == -42
      (0...0) from should == 0
    )

    it("should validate the type of receiver",
      Range should checkReceiverTypeOn(:from)
    )
  )

  describe("it", 
    it("should return the to part of the range", 
      (0..13) to should == 13
      (0..-42) to should == -42
      (0..0) to should == 0

      (0...13) to should == 13
      (0...-42) to should == -42
      (0...0) to should == 0
    )
  )

  describe("inclusive?", 
    it("should return true for an inclusive range", 
      (0..13) inclusive? should be true
    )

    it("should return false for an exclusive range", 
      (0...13) inclusive? should be false
    )
  )

  describe("exclusive?", 
    it("should return false for an inclusive range", 
      (0..13) exclusive? should be false
    )

    it("should return true for an exclusive range", 
      (0...13) exclusive? should be true
    )
  )

  describe("each",
    it("should not do anything for an empty list", 
      x = 0
      (0...0) each(. x++)
      x should == 0
    )

    it("should be possible to iterate the wrong way with it",
      Ground y = []
      (10..0) each(xx, y << xx)
      y should == [10, 9, 8, 7, 6, 5, 4, 3, 2, 1, 0]

      Ground y = []
      (10...0) each(xx, y << xx)
      y should == [10, 9, 8, 7, 6, 5, 4, 3, 2, 1]
    )
    
    it("should be possible to just give it a message chain, that will be invoked on each object", 
      Ground y = []
      Ground xs = method(y << self)
      (1..3) each(xs)
      y should == [1,2,3]

      Ground y = []
      Ground xs = method(y << self)
      (1...3) each(xs)
      y should == [1,2]

      x = 0
      (1..3) each(nil. x++)
      x should == 3

      x = 0
      (1...3) each(nil. x++)
      x should == 2
    )
    
    it("should be possible to give it an argument name, and code", 
      y = []
      (1..3) each(x, y << x)
      y should == [1,2,3]

      y = []
      (1...3) each(x, y << x)
      y should == [1,2]
    )

    it("should return the object", 
      y = 1..3
      (y each(x, x)) should == y
    )
    
    it("should establish a lexical context when invoking the methods. this context will be the same for all invocations.", 
      (1..3) each(x_list, blarg=32)
      cell?(:x_list) should be false
      cell?(:blarg) should be false

      x=14
      (1..3) each(x, blarg=32)
      x should == 14
    )

    it("should be possible to give it an extra argument to get the index", 
      y = []
      (1..4) each(i, x, y << [i, x])
      y should == [[0, 1], [1, 2], [2, 3], [3, 4]]

      y = []
      (1...4) each(i, x, y << [i, x])
      y should == [[0, 1], [1, 2], [2, 3]]
    )
  )
  
  describe("==",
    it("should say equal when the elements are equal and the ranges are the same inclusivity",
      (1..5) should == (1..5)
      (1..5) should not == (1...5)
      (2..5) should == (2..5)
      (3..5) should not == (2..5)
      (3..6) should not == (3..5)
    )
  )

  describe("===", 
    it("should match something inside the range", 
      ((1..5) === 1) should be true
      ((1..5) === 2) should be true
      ((1..5) === 3) should be true
      ((1..5) === 4) should be true
      ((1..5) === 5) should be true
      ((1..5) === 1.5) should be true
      ((1..5) === 4.9999) should be true
      ((1...5) === 4.9999) should be true
      ((1..5) === 4/3) should be true
    )

    it("should match even when using inverted ranges",
      (5..1) should === 5
      (5..1) should === 4
      (5..1) should === 3
      (5..1) should === 2
      (5..1) should === 1
      (5..1) should not === 0
      (5..1) should not === 6
      (5...1) should not === 1
      (5...1) should === 2
      (5...1) should === 3
      (5...1) should === 4
      (5...1) should === 5
      (5...1) should not === 6
    )

    it("should not match something outside the range", 
      ((1..5) === 0) should be false
      ((1...5) === 5) should be false
      ((1..5) === 0.5) should be false
      ((1..5) === 5.000001) should be false
      ((1...5) === 5.0) should be false
      ((1..5) === 1/3) should be false

      ((1..5) === :foo) should be false
    )
  )

  describe("inspect",
    it("should return the inspect of something inside it",
      ("foo"..method(blarg fux)) inspect should == "\"foo\"..method(blarg fux)"
      ("foo"...method(blarg fux)) inspect should == "\"foo\"...method(blarg fux)"
    )
    
    it("should return a simple string for something simple",
      (1..2) inspect should == "1..2"
      (1...2) inspect should == "1...2"
    )
  )

  describe("notice",
    it("should return the notice of something inside it",
      ("foo"..method(blarg fux)) notice should == "\"foo\"..method(...)"
      ("foo"...method(blarg fux)) notice should == "\"foo\"...method(...)"
    )

    it("should return a simple string for something simple",
      (1..2) notice should == "1..2"
      (1...2) notice should == "1...2"
    )
  )
)
