
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

  describe("empty?", 
    it("should return true for an empty set", 
      x = set
      x empty? should be true
    )
    
    it("should return false for an non empty set", 
      x = set(1)
      x empty? should be false

      x = set("abc", "cde")
      x empty? should be false
    )

    it("should validate type of receiver",
      Set should checkReceiverTypeOn(:empty?)
    )
  )

  describe("ifEmpty",
    it("should just return itself if not empty",
      set(1) ifEmpty(x/0) should == set(1)
      set(1,2,3) ifEmpty(x/0) should == set(1,2,3)
      x = set(1,2)
      x ifEmpty(blarg) should be same(x)
    )

    it("should return the result of evaluating the code if empty",
      set ifEmpty(42) should == 42
      set ifEmpty([1,2,3]) should == [1,2,3]
    )
  )

  describe("?|",
    it("should just return itself if not empty",
      set(1) ?|(x/0) should == set(1)
      set(1,2,3) ?|(x/0) should == set(1,2,3)
      x = set(1,2)
      x ?|(blarg) should be same(x)
    )

    it("should return the result of evaluating the code if empty",
      set ?|(42) should == 42
      set ?|([1,2,3]) should == [1,2,3]
    )
  )

  describe("?&",
    it("should just return itself if empty",
      (set ?& 42) should == set
      (set ?& [1,2,3]) should == set
    )

    it("should return the result of evaluating the code if non-empty",
      set(1) ?&(10) should == 10
      set(1,2,3) ?&(20) should == 20
      x = set(1,2)
      x ?&([1,2,3]) should == [1,2,3]
    )
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
      cell?(:x_set_spec) should be false
      cell?(:blarg_set_spec) should be false

      x=14
      set(1,2,3) each(x, blarg=32)
      x should == 14
    )

    it("should validate type of receiver",
      Set should checkReceiverTypeOn(:each, "foo")
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

  describe("<<",
    it("should add an element that isn't part of the set already",
      x = set(1)
      x << 2
      x should == set(1,2)
    )

    it("should not add an element that is part of the set already",
      x = set(1,2,3)
      x << 2
      x should == set(1,2,3)
    )

    it("should return the set after adding",
      x = set(1)
      (x << 2) should be same(x)
    )

    it("should validate type of receiver",
      Set should checkReceiverTypeOn(:"<<", 2)
    )
  )

  describe("include?", 
    it("should match something in the set", 
      set(1) include?(1) should be true
      set(1,2) include?(2) should be true
      set(2,3,1) include?(3) should be true
      set("foo", "bar") include?("foo") should be true
    )

    it("should not match something not in the set", 
      set(1) include?(2) should be false
      set(1,2) include?(3) should be false
      set(2,3,1) include?(:bar) should be false
      set("foo", "bar") include?(:bar) should be false
    )

    it("should validate type of receiver",
      Set should checkReceiverTypeOn(:include?, 42)
    )
  )


  describe("===", 
    it("should return false for something not in the set", 
      (set === :foo) should be false
      (set(1) === 2) should be false
      (set(1, :foo, "bar") === 2) should be false
    )

    it("should return true for something in the set", 
      (set(:foo) === :foo) should be true
      (set(1, 2) === 2) should be true
      (set(2, 1, :foo, "bar") === 2) should be true
    )

    it("should return true when called against Set and the other is a set",
      (Set === Set) should be true
      (Set === set) should be true
      (Set === set(1,2,3)) should be true
      (Set === set(:foo)) should be true
    )

    it("should return true when called against Set and the other is not a set",
      (Set === []) should be false
      (Set === (1..5)) should be false
      (Set === :foo) should be false
    )
  )

  describe("+",
    it("should add two sets",
      (set(1,2) + set(1,3)) should == set(1,2,3)
    )

    it("should validate type of argument",
      fn(set(2) + 3) should signal(Condition Error Type IncorrectType)
    )

    it("should validate type of receiver",
      Set should checkReceiverTypeOn(:"+", set(2))
    )
  )

  describe("remove!",
    it("should remove entry from set",
      set(1,2) remove!(1) should == set(2)
    )

    it("should validate type of receiver",
      Set should checkReceiverTypeOn(:remove!, 42)
    )
  )

  describe("inspect",
    it("should validate type of receiver",
      Set should checkReceiverTypeOn(:inspect)
    )
  )

  describe("notice",
    it("should validate type of receiver",
      Set should checkReceiverTypeOn(:notice)
    )
  )

  describe("withIdentitySemantics!",
    it("should validate type of receiver",
      Set should checkReceiverTypeOn(:withIdentitySemantics!)
    )
  )
)

describe("Literal syntax for set",
  it("should have the correct kind",
    #{} should have kind("Set")
  )
  
  it("should see \#{} as identical to set()",
    #{} should == set()
  )
  
  it("should see \#{1,2,3,4,5} as identical to set(1,2,3,4,5)",
    #{1,2,3,4,5} should == set(1,2,3,4,5)
  )
  
  it("should see two similar literals as being the same",
    #{1,2,3,4,5} should == #{1,2,3,4,5}
  )
  
  it("should see to disimmilar literals as being different",
    #{1,2,3,4,5,6} should not == #{1,2,3,4,5}
  )
  
  it("should be possible to insert elements to sets defined using the literal syntax",
   (#{1,2,3,4,5} << 6 )should == #{1,2,3,4,5,6}
  )
  
  it("should be possible to insert elements to sets defined using the literal syntax",
   (#{1,2,3,4,5} << 6 )should not == #{1,2,3,4,5}
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
