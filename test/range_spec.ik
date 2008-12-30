
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
      (0...0) inclusive? should == false
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
      (0..13) inclusive? should == true
    )

    it("should return false for an exclusive range", 
      (0...13) inclusive? should == false
    )
  )

  describe("exclusive?", 
    it("should return false for an inclusive range", 
      (0..13) exclusive? should == false
    )

    it("should return true for an exclusive range", 
      (0...13) exclusive? should == true
    )
  )

  describe("each",
    it("should not do anything for an empty list", 
      x = 0
      (0...0) each(. x++)
      x should == 0
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
      cell?(:x_list) should == false
      cell?(:blarg) should == false

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
  
  describe("===", 
    it("should match something inside the range", 
      ((1..5) === 1) should == true
      ((1..5) === 2) should == true
      ((1..5) === 3) should == true
      ((1..5) === 4) should == true
      ((1..5) === 5) should == true
      ((1..5) === 1.5) should == true
      ((1..5) === 4.9999) should == true
      ((1...5) === 4.9999) should == true
      ((1..5) === 4/3) should == true
    )

    it("should not match something outside the range", 
      ((1..5) === 0) should == false
      ((1...5) === 5) should == false
      ((1..5) === 0.5) should == false
      ((1..5) === 5.000001) should == false
      ((1...5) === 5.0) should == false
      ((1..5) === 1/3) should == false

      ((1..5) === :foo) should == false
    )
  )

  describe("inspect",
    it("should have tests")
  )

  describe("notice",
    it("should have tests")
  )
)
