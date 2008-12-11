
use("ispec")

describe("Set", 
  it("should have the correct kind", 
    Set should have kind("Set")
  )

  it("should be possible to mimic", 
    x = Set mimic
    x should have kind("Set")
    x should mimic(Set)
    x should not be same(Set)
  )
  
  it("should mimic Enumerable", 
    Set should mimic(Mixins Enumerable)
  )

  describe("each", 
    it("should not do anything for an empty set", 
      x = 0. set() each(. x++). x should == 0
    )
    
    it("should be possible to just give it a message chain, that will be invoked on each object", 
      Ground y = []
      Ground x_set_spec1 = method(Ground y << self)
      set(1,2,3) each(x_set_spec1)
      Ground y sort should == [1,2,3]

      x = 0
      set(1,2,3) each(nil. x++)
      x should == 3
    )
    
    it("should be possible to give it an argument name, and code", 
      y = []
      set(1,2,3) each(x, y<<x)
      y sort should == [1,2,3]
    )

    it("should return the object", 
      y = set(1,2,3)
      (y each(x, x)) should == y
    )
    
    it("should be possible to give it an extra argument to get the index", 
      y = []
      set(1, 2, 3, 4) each(i, x, y << i)
      y should == [0,1,2,3]
    )

    it("should establish a lexical context when invoking the methods. this context will be the same for all invocations.", 
      set(1,2,3) each(x_set_spec, blarg_set_spec=32)
      cell?(:x_set_spec) should == false
      cell?(:blarg_set_spec) should == false

      x=14
      set(1,2,3) each(x, blarg=32)
      x should == 14
    )
  )

  describe("==", 
    it("should return false when sent an argument that is not a set", 
      set() should not == 1
      set(1) should not == 1
      set(1,2,3) should not == "foo"
      set() should not == fn([])
    )
    
    it("should return true for two empty sets", 
      x = set()
      x should == x

      set() should == set()
    )
    
    it("should return true for two empty sets where one has a new cell", 
      x = set()
      y = set()
      x blarg = 12
      x should == y
    )
    
    it("should return false when the two sets have an element of different types", 
      set(1) should not == set("1")
      set(1, 2, 3) should not == set("1", "2", "3")
    )

    it("should return false when the two sets have different size", 
      set(1) should not == set()
      set(1) should not == set(1,2,3)
    )
    
    it("should return true if the elements in the set are the same", 
      set(1) should == set(1)
      set("1") should == set("1")
      set(1,2,3,4,5,6,7) should == set(1,2,3,4,5,6,7)
      set(1,1,1,1,1,1,2,3,4,5,6,7) should == set(1,2,3,4,5,6,7)
      set(1,2,3,4,5,6,7) should == set(1,2,3,5,4,6,7)
    )
  )
)

describe("DefaultBehavior", 
  describe("set", 
    it("should create a new empty set when given no arguments", 
      x = set
      x should have kind("Set")
      x should not be same(Set)
      x should mimic(Set)

      x = set()
      x should have kind("Set")
      x should not be same(Set)
      x should mimic(Set)
    )
    
    it("should create a new set with the evaluated arguments", 
      result = set(1, 2, "abc", 3+42)
      result asList length should == 4
      
      outside = []
      result each(x,
        if(x mimics?(Text),
          x should == "abc",
          outside << x))
      outside sort should == [1,2,45]
    )
  )
)
