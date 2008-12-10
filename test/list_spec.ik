
use("ispec")

describe(List,
  it("should have the correct kind", 
    List should have kind("List")
  )

  it("should be possible to mimic", 
    x = List mimic
    x should not be same(List)
    x should mimic(List)
    x should have kind("List")
  )
  
  it("should mimic Enumerable", 
    List should mimic(Mixins Enumerable)
  )
  
  describe("at", 
    it("should return nil if empty list", 
      list at(0) should == nil
      list at(10) should == nil
      list at(0-1) should == nil
    )

    it("should return nil if argument is over the size", 
      list(1) at(1) should == nil
    )

    it("should return from the front if the argument is zero or positive", 
      [1,2,3,4] at(0) should == 1
      [1,2,3,4] at(1) should == 2
      [1,2,3,4] at(2) should == 3
      [1,2,3,4] at(3) should == 4
    )

    it("should return from the back if the argument is negative", 
      [1,2,3,4] at(0-1) should == 4
      [1,2,3,4] at(0-2) should == 3
      [1,2,3,4] at(0-3) should == 2
      [1,2,3,4] at(0-4) should == 1
    )
  )

  describe("[number]", 
    it("should return nil if empty list", 
      list[0] should == nil
      list[10] should == nil
      list[(0-1)] should == nil
    )

    it("should return nil if argument is over the size", 
      list(1)[1] should == nil
    )

    it("should return from the front if the argument is zero or positive", 
      [1,2,3,4][0] should == 1
      [1,2,3,4][1] should == 2
      [1,2,3,4][2] should == 3
      [1,2,3,4][3] should == 4
    )

    it("should return from the back if the argument is negative", 
      [1,2,3,4][0-1] should == 4
      [1,2,3,4][0-2] should == 3
      [1,2,3,4][0-3] should == 2
      [1,2,3,4][0-4] should == 1
    )
  )

  describe("[range]", 
    it("should return an empty list for any range given to an empty list", 
      [][0..0] should == []
      [][0...0] should == []
      [][0..-1] should == []
      [][0...-1] should == []
      [][10..20] should == []
      [][10...20] should == []
      [][-1..20] should == []
    )
    
    it("should return an equal list for 0..-1", 
      [][0..-1] should == []
      [1,2,3][0..-1] should == [1,2,3]
      ["x", "y"][0..-1] should == ["x", "y"]
    )

    it("should return all except the first element for 1..-1", 
      [1][1..-1] should == []
      [1,2,3][1..-1] should == [2,3]
      ["x", "y"][1..-1] should == ["y"]
    )

    it("should return all except for the first and last for 1...-1", 
      [1,2][1...-1] should == []
      [1,2,3][1...-1] should == [2]
      ["x", "y", "zed", "bar"][1...-1] should == ["y", "zed"]
    )

    it("should return an array with the first element for 0..0", 
      [1][0..0] should == [1]
      [1,2,3][0..0] should == [1]
      ["x", "y"][0..0] should == ["x"]
    )

    it("should return an empty array for 0...0", 
      [1][0...0] should == []
      [1,2,3][0...0] should == []
      ["x", "y"][0...0] should == []
    )

    it("should return a slice from a larger array", 
      [1,2,3,4,5,6,7,8,9,10,11][3..5] should == [4,5,6]
    )

    it("should return a correct slice for an exclusive range", 
      [1,2,3,4,5,6,7,8,9,10,11][3...6] should == [4,5,6]
    )

    it("should return a correct slice for a slice that ends in a negative index", 
      [1,2,3,4,5,6,7,8,9,10,11][3..-3] should == [4,5,6,7,8,9]
    )

    it("should return a correct slice for an exclusive slice that ends in a negative index", 
      [1,2,3,4,5,6,7,8,9,10,11][3...-3] should == [4,5,6,7,8]
    )

    it("should return all elements up to the end of the slice, if the end argument is way out there", 
      [1,2,3,4,5,6,7,8,9,10,11][5..3443343] should == [6,7,8,9,10,11]
      [1,2,3,4,5,6,7,8,9,10,11][5...3443343] should == [6,7,8,9,10,11]
    )

    it("should return an empty array for a totally messed up indexing", 
      [1,2,3,4,5,6,7,8,9,10,11][-1..3] should == []
      [1,2,3,4,5,6,7,8,9,10,11][-1..7557] should == []
      [1,2,3,4,5,6,7,8,9,10,11][5..4] should == []
      [1,2,3,4,5,6,7,8,9,10,11][-1...3] should == []
      [1,2,3,4,5,6,7,8,9,10,11][-1...7557] should == []
      [1,2,3,4,5,6,7,8,9,10,11][5...4] should == []
    )
  )  
  
  describe("[]=", 
    it("should set the first element in an empty list", 
      x = []
      x[0] = 42
      x length should == 1
      x[0] should == 42
    )
    
    it("should overwrite an existing element", 
      x = [40]
      x[0] = 42
      x length should == 1
      x[0] should == 42
    )

    it("should expand the list up to the point where the element fits, if the index is further away", 
      x = [40, 42]
      x[10] = 45
      x length should == 11
      x[0] should == 40
      x[1] should == 42
      x[2] should == nil
      x[3] should == nil
      x[4] should == nil
      x[5] should == nil
      x[6] should == nil
      x[7] should == nil
      x[8] should == nil
      x[9] should == nil
      x[10] should == 45
    )
    
    it("should be possible to set with negative indices", 
      x = [40, 42, 44, 46]
      x[-2] = 52
      x length should == 4
      x[0] should == 40
      x[1] should == 42
      x[2] should == 52
      x[3] should == 46
    )

    it("should return the value set", 
      ([40, 42, 44, 46][0] = 33+44) should == 77
    )

    it("should throw an exception if setting with negative indices outside the range", 
      fn([][0-1] = 52) should signal(Condition Error Index)
    )
  )

  describe("at=", 
    it("should set the first element in an empty list", 
      x = []
      x at(0) = 42
      x length should == 1
      x[0] should == 42
    )
    
    it("should overwrite an existing element", 
      x = [40]
      x at(0) = 42
      x length should == 1
      x[0] should == 42
    )

    it("should expand the list up to the point where the element fits, if the index is further away", 
      x = [40, 42]
      x at(10) = 45
      x length should == 11
      x[0] should == 40
      x[1] should == 42
      x[2] should == nil
      x[3] should == nil
      x[4] should == nil
      x[5] should == nil
      x[6] should == nil
      x[7] should == nil
      x[8] should == nil
      x[9] should == nil
      x[10] should == 45
    )
    
    it("should be possible to set with negative indices", 
      x = [40, 42, 44, 46]
      x at(-2) = 52
      x length should == 4
      x[0] should == 40
      x[1] should == 42
      x[2] should == 52
      x[3] should == 46
    )
    
    it("should return the value set", 
      ([40, 42, 44, 46] at(0) = 33+44) should == 77
    )

    it("should throw an exception if setting with negative indices outside the range", 
      fn([][-1] = 52) should signal(Condition Error Index)
    )
  )

  describe("<<", 
    it("should add the element at the end of an empty list", 
      x = []
      x << 42
      x length should == 1
      x[0] should == 42
    )

    it("should add the element at the end of a list with elements", 
      x = [1, 2, 3]
      x << 42
      x length should == 4
      x[0] should == 1
      x[1] should == 2
      x[2] should == 3
      x[3] should == 42
    )
    
    it("should return the list after the append", 
      x = []
      (x << 42) should == x
    )
  )
  
  describe("==", 
    it("should return false when sent an argument that is not a list", 
      [] should not == 1
      [1] should not == 1
      [1,2,3] should not == "foo"
      [] should not == fn([])
    )
    
    it("should return true for two empty lists", 
      x = []

      x should == x
      [] should == []
    )
    
    it("should return true for two empty lists where one has a new cell", 
      x = []
      y = []
      x blarg = 12

      x should == y
    )
    
    it("should return false when the two lists have an element of different types", 
      [1] should not == ["1"]
      [1, 2, 3] should not == ["1", "2", "3"]
    )

    it("should return false when the two lists have different length", 
      [1] should not == []
      [1] should not == [1,2,3]
    )
    
    it("should return true if the elements in the list are the same", 
      [1] should == [1]
      ["1"] should == ["1"]
      [1,2,3,4,5,6,7] should == [1,2,3,4,5,6,7]
    )
  )
  
  describe("clear!", 
    it("should not do anything on an empty list", 
      x = []
      x clear!
      x size should == 0
    )

    it("should clear a list that has entries", 
      x = [1,2,3,4]
      x clear!
      x size should == 0
    )
    
    it("should return the list", 
      x = [1,2,3,4]
      x clear! should == x
    )
  )

  describe("size", 
    it("should return zero for an empty list", 
      x = []
      x size should == 0
    )
    
    it("should return the size for a non-empty list", 
      [1] size should == 1
      ["abc", "cde"] size should == 2
    )
  )

  describe("length", 
    it("should return zero for an empty list", 
      x = []
      x length should == 0
    )
    
    it("should return the size for a non-empty list", 
      [1] length should == 1
      ["abc", "cde"] length should == 2
    )
  )

  describe("empty?", 
    it("should return true for an empty list", 
      x = []
      x empty? should == true
    )
    
    it("should return false for an non empty list", 
      x = [1]
      x empty? should == false

      x = ["abc", "cde"]
      x empty? should == false
    )
  )

  describe("include?", 
    it("should return false for something not in the list", 
      [] include?(:foo) should == false
      [1] include?(2) should == false
      [1, :foo, "bar"] include?(2) should == false
    )

    it("should return true for something in the list", 
      [:foo] include?(:foo) should == true
      [1, 2] include?(2) should == true
      [2, 1, :foo, "bar"] include?(2) should == true
    )
  )
  
  describe("each", 
    it("should not do anything for an empty list", 
      x = 0
      [] each(. x++)
      x should == 0
    )
    
    it("should be possible to just give it a message chain, that will be invoked on each object", 
      Ground y = []
      Ground xs = method(y << self)
      [1,2,3] each(xs)
      y should == [1,2,3]

      x = 0
      [1,2,3] each(nil. x++)
      x should == 3
    )
    
    it("should be possible to give it an argument name, and code", 
      y = []
      [1,2,3] each(x, y << x)
      y should == [1,2,3]
    )

    it("should return the object", 
      y = [1,2,3]
      (y each(x, x)) should == y
    )
    
    it("should establish a lexical context when invoking the methods. this context will be the same for all invocations.", 
      [1,2,3] each(x, blarg=32)
      cell?(:x) should == false
      cell?(:blarg) should == false

      x=14
      [1,2,3] each(x, blarg=32)
      x should == 14
    )

    it("should be possible to give it an extra argument to get the index", 
      y = []
      [1, 2, 3, 4] each(i, x, y << [i, x])
      y should == [[0, 1], [1, 2], [2, 3], [3, 4]]
    )
    
    it("should yield lists if running over a list of lists", 
      y = []
      [[1],[2],[3]] each(x, y << x)
      y should == [[1],[2],[3]]
    )
  )

;   describe("remove!", 
;     it("should have tests")
;   )

;   describe("removeAt!", 
;     it("should have tests")
;   )

;   describe("removeIf!", 
;     it("should have tests")
;   )
  
  describe("first", 
    it("should return nil for an empty list", 
      [] first should == nil
    )

    it("should return the first element for a non-empty list", 
      [42] first should == 42
    )
  )

  describe("second", 
    it("should return nil for an empty list", 
      [] second should == nil
    )

    it("should return nil for a list with one element", 
      [33] second should == nil
    )

    it("should return the second element for a list with more than one element", 
      [33, 45] second should == 45
    )
  )

  describe("third", 
    it("should return nil for an empty list", 
      [] third should == nil
    )

    it("should return nil for a list with one element", 
      [33] third should == nil
    )

    it("should return nil for a list with two elements", 
      [33, 15] third should == nil
    )

    it("should return the third element for a list with more than two elements", 
      [7, 25, 333] third should == 333
    )
  )

  describe("last", 
    it("should return nil for an empty list", 
      [] last should == nil
    )

    it("should return the only entry for a list with one element", 
      [45] last should == 45
    )

    it("should return the last entry for a list with more than one entry", 
      [33, 15, 45, 57] last should == 57
    )
  )

  describe("rest", 
    it("should return an empty list for the empty list", 
      [] rest should == []
    )

    it("should return an empty list for a list with one entry", 
      [1] rest should == []
      [2] rest should == []
      ["foo"] rest should == []
    )

    it("should return a list with the one element for a list with two entries", 
      [1, 2] rest should == [2]
    )

    it("should return a list with the rest of the elements for a larger list", 
      [1, 2, 3, 4, 5] rest should == [2, 3, 4, 5]
    )
  )

  describe("butLast", 
    it("should return an empty list for the empty list", 
      [] butLast should == []
    )

    it("should return an empty list for a list with one entry", 
      [1] butLast should == []
    )

    it("should return a list with the first entry for a list with two elements", 
      [1, 2] butLast should == [1]
    )

    it("should return an empty list for a list with two elements when given 2 as an argument", 
      [1, 2] butLast(2) should == []
    )

    it("should return a list with several entries for a longer list, without arguments", 
      [1, 2, 3, 4, 5, 6] butLast should == [1, 2, 3, 4, 5]
    )

    it("should return a list with several entries for a longer list, with an argument of 3", 
      [1, 2, 3, 4, 5, 6, 7] butLast(3) should == [1, 2, 3, 4]
    )

    it("should return the list with the same entries for an argument of zero", 
      [1, 2, 3, 4, 5, 6] butLast(0) should == [1, 2, 3, 4, 5, 6]
    )
  )

  describe("sort", 
    it("should return a new, sorted list of numbers", 
      [1, 2, 3] sort should == [1,2,3]
      [3, 2, 1] sort should == [1,2,3]
      [2, 3, 1] sort should == [1,2,3]
      [1, 3, 2] sort should == [1,2,3]
      [1, 3, 3, 3, 2, 2] sort should == [1,2,2,3,3,3]
    )

    it("should return a new, sorted list of strings", 
      ["foo", "bar", "quux"] sort should == ["bar", "foo", "quux"]
      ["foo", "Bar", "bar", "quux"] sort should == ["Bar", "bar", "foo", "quux"]
    )

    it("should return a new, sorted list of symbols", 
      [:foo, :bar, :quux] sort should == [:bar, :foo, :quux]
      [:foo, :Bar, :bar, :quux] sort should == [:Bar, :bar, :foo, :quux]
    )

    it("should sort based on '<=>", 
      Objs = Origin mimic

      x1 = Objs mimic
      x1 num = 42
      x2 = Objs mimic
      x2 num = 32
      x3 = Objs mimic
      x3 num = 52

      Objs <=> = method(other, self num <=> other num)

      [x1, x2, x3] sort should == [x2, x1, x3]
    )
  )

  describe("sort!", 
    it("should return itself", 
      x = []. x sort! uniqueHexId should == x uniqueHexId
    )

    it("should sort a list of numbers",
      [1, 2, 3] sort! should == [1,2,3]
      [3, 2, 1] sort! should == [1,2,3]
      [2, 3, 1] sort! should == [1,2,3]
      [1, 3, 2] sort! should == [1,2,3]
      [1, 3, 3, 3, 2, 2] sort! should == [1,2,2,3,3,3]
    )

    it("should sort a list of strings", 
      ["foo", "bar", "quux"] sort! should == ["bar", "foo", "quux"]
      ["foo", "Bar", "bar", "quux"] sort! should == ["Bar", "bar", "foo", "quux"]
    )

    it("should sort a list of symbols", 
      [:foo, :bar, :quux] sort! should == [:bar, :foo, :quux]
      [:foo, :Bar, :bar, :quux] sort! should == [:Bar, :bar, :foo, :quux]
    )

    it("should sort based on '<=>", 
      Objs = Origin mimic

      x1 = Objs mimic
      x1 num = 42
      x2 = Objs mimic
      x2 num = 32
      x3 = Objs mimic
      x3 num = 52

      Objs <=> = method(other, self num <=> other num)

      [x1, x2, x3] sort! should == [x2, x1, x3]
    )
  )
  
  describe("+", 
    it("should return the same list when applied to an empty list", 
      x = [1,2,3]
      (x + []) should == x

      x = [1,2,3]
      ([] + x) should == x
    )
    
    it("should add two lists together, preserving the order", 
      x = [1,2,3]
      (x + [4,5,6]) should == [1,2,3,4,5,6]

      x = [1,2,3]
      ([4,5,6] + x) should == [4,5,6,1,2,3]
    )
  )
  
  describe("<=>", 
    it("should sort based on the elements inside", 
      ([] <=> []) should == 0
      ([] <=> [1]) should == -1
      ([1] <=> []) should == 1
      ([1] <=> [1]) should == 0
      ([1,2] <=> [1]) should == 1
      ([1] <=> [1,2]) should == -1
      ([1,2] <=> [1,3]) should == -1
      ([1,3] <=> [1,2]) should == 1
    )
  )
)

describe("DefaultBehavior", 
  describe("list", 
    it("should create a new empty list when given no arguments", 
      x = list
      x should have kind("List")
      x should not be same(List)
      x should mimic(List)

      x = list()
      x should have kind("List")
      x should not be same(List)
      x should mimic(List)
    )
    
    it("should create a new list with the evaluated arguments", 
      x = list(1, 2, "abc", 3+42)
      x length should == 4
      x[0] should == 1
      x[1] should == 2
      x[2] should == "abc"
      x[3] should == 45
    )
  )
  
  describe("[]", 
    it("should create a new empty list when given no arguments", 
      x = []
      x should have kind("List")
      x should not be same(List)
      x should mimic(List)
    )
    
    it("should create a new list with the evaluated arguments", 
      x = [1, 2, "abc", 3+42]
      x length should == 4
      x[0] should == 1
      x[1] should == 2
      x[2] should == "abc"
      x[3] should == 45
    )
  )
)
