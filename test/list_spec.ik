
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
  
  describe("inspect",
    it("should validate type of receiver",
      List should checkReceiverTypeOn(:inspect)
    )
  )
  
  describe("notice",
    it("should validate type of receiver",
      List should checkReceiverTypeOn(:notice)
    )
  )
  
  describe("at", 
    it("should return nil if empty list", 
      list at(0) should be nil
      list at(10) should be nil
      list at(0-1) should be nil
    )

    it("should return nil if argument is over the size", 
      list(1) at(1) should be nil
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
    
    it("should validate type of receiver",
      List should checkReceiverTypeOn(:at, 0)
    )
    
    it("should validate type of argument",
       fn([] at([])) should signal(Condition Error Type IncorrectType)
    )
  )

  describe("[]", 
    describe("with number argument",
      it("should return nil if empty list when given a number", 
        list[0] should be nil
        list[10] should be nil
        list[(0-1)] should be nil
      )

      it("should return nil if argument is over the size when given a number", 
        list(1)[1] should be nil
      )

      it("should return from the front if the argument is zero or positive when given a number", 
        [1,2,3,4][0] should == 1
        [1,2,3,4][1] should == 2
        [1,2,3,4][2] should == 3
        [1,2,3,4][3] should == 4
      )

      it("should return from the back if the argument is negative when given a number", 
        [1,2,3,4][0-1] should == 4
        [1,2,3,4][0-2] should == 3
        [1,2,3,4][0-3] should == 2
        [1,2,3,4][0-4] should == 1
      )

      it("should return an empty list for any range given to an empty list when given a number", 
        [][0..0] should == []
        [][0...0] should == []
        [][0..-1] should == []
        [][0...-1] should == []
        [][10..20] should == []
        [][10...20] should == []
        [][-1..20] should == []
      )
      
      it("should validate type of receiver",
        List should checkReceiverTypeOn(:"[]", 0)
      )

      it("should validate type of argument",
         fn([] []([])) should signal(Condition Error Type IncorrectType)
      )
    )
    
    describe("with range argument",
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
      x[2] should be nil
      x[3] should be nil
      x[4] should be nil
      x[5] should be nil
      x[6] should be nil
      x[7] should be nil
      x[8] should be nil
      x[9] should be nil
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
    
    it("should validate type of receiver",
      [0,1] should checkReceiverTypeOn(:"[]=",0,3)
    )
    
    it("should validate type of argument",
       fn([] [](:boris) = :beans) should signal(Condition Error Type IncorrectType)
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
      x[2] should be nil
      x[3] should be nil
      x[4] should be nil
      x[5] should be nil
      x[6] should be nil
      x[7] should be nil
      x[8] should be nil
      x[9] should be nil
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
    
    it("should validate type of receiver",
      [0,1] should checkReceiverTypeOn(:"at=",0,3)
    )
    
    it("should validate type of argument",
       fn([] at(:stilton) = :gouda) should signal(Condition Error Type IncorrectType)
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
    
    it("should validate type of receiver",
      List should checkReceiverTypeOn(:"<<", 1)
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
    
    it("should validate type of receiver",
      List should checkReceiverTypeOn(:clear!)
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
    
    it("should validate type of receiver",
      List should checkReceiverTypeOn(:size)
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
    
    it("should validate type of receiver",
      List should checkReceiverTypeOn(:length)
    )
  )

  describe("empty?", 
    it("should return true for an empty list", 
      x = []
      x empty? should be true
    )
    
    it("should return false for an non empty list", 
      x = [1]
      x empty? should be false

      x = ["abc", "cde"]
      x empty? should be false
    )
    
    it("should validate type of receiver",
      List should checkReceiverTypeOn(:empty?)
    )
  )

  describe("include?", 
    it("should return false for something not in the list", 
      [] include?(:foo) should be false
      [1] include?(2) should be false
      [1, :foo, "bar"] include?(2) should be false
    )

    it("should return true for something in the list", 
      [:foo] include?(:foo) should be true
      [1, 2] include?(2) should be true
      [2, 1, :foo, "bar"] include?(2) should be true
    )
    
    it("should validate type of receiver",
      List should checkReceiverTypeOn(:include?, "Richard Richard")
    )
  )

  describe("===", 
    it("should return false for something not in the list", 
      ([] === :foo) should be false
      ([1] === 2) should be false
      ([1, :foo, "bar"] === 2) should be false
    )

    it("should return true for something in the list", 
      ([:foo] === :foo) should be true
      ([1, 2] === 2) should be true
      ([2, 1, :foo, "bar"] === 2) should be true
    )

    it("should return true when called against List and the other is a list",
      (List === List) should be true
      (List === []) should be true
      (List === [1,2,3]) should be true
      (List === [:foo]) should be true
    )

    it("should return true when called against List and the other is not a list",
      (List === set) should be false
      (List === (1..5)) should be false
      (List === :foo) should be false
    )
  )
  
  describe("ifEmpty",
    it("should just return itself if not empty",
      [1] ifEmpty(x/0) should == [1]
      [1,2,3] ifEmpty(x/0) should == [1,2,3]
      x = [1,2]
      x ifEmpty(blarg) should be same(x)
    )

    it("should return the result of evaluating the code if empty",
      [] ifEmpty(42) should == 42
      [] ifEmpty([1,2,3]) should == [1,2,3]
    )
  )

  describe("?|",
    it("should just return itself if not empty",
      [1] ?|(x/0) should == [1]
      [1,2,3] ?|(x/0) should == [1,2,3]
      x = [1,2]
      x ?|(blarg) should be same(x)
    )

    it("should return the result of evaluating the code if empty",
      ([] ?| 42) should == 42
      ([] ?| [1,2,3]) should == [1,2,3]
    )
  )

  describe("?&",
    it("should just return itself if empty",
      ([] ?& 42) should == []
      ([] ?& [1,2,3]) should == []
    )

    it("should return the result of evaluating the code if non-empty",
      [1] ?&(10) should == 10
      [1,2,3] ?&(20) should == 20
      x = [1,2]
      x ?&([1,2,3]) should == [1,2,3]
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
      [1,2,3] each(x_list, blarg=32)
      cell?(:x_list) should be false
      cell?(:blarg) should be false

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
    
    it("should validate type of receiver",
      List should checkReceiverTypeOn(:each, 1)
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
      [] first should be nil
    )

    it("should return the first element for a non-empty list", 
      [42] first should == 42
    )
  )

  describe("second", 
    it("should return nil for an empty list", 
      [] second should be nil
    )

    it("should return nil for a list with one element", 
      [33] second should be nil
    )

    it("should return the second element for a list with more than one element", 
      [33, 45] second should == 45
    )
  )

  describe("third", 
    it("should return nil for an empty list", 
      [] third should be nil
    )

    it("should return nil for a list with one element", 
      [33] third should be nil
    )

    it("should return nil for a list with two elements", 
      [33, 15] third should be nil
    )

    it("should return the third element for a list with more than two elements", 
      [7, 25, 333] third should == 333
    )
  )

  describe("last", 
    it("should return nil for an empty list", 
      [] last should be nil
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
    
    it("should validate type of receiver",
      List should checkReceiverTypeOn(:sort)
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
    
    it("should validate type of receiver",
      List should checkReceiverTypeOn(:sort!)
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

    it("should validate type of receiver",
      List should checkReceiverTypeOn(:"+", [])
    )
    
    it("should validate type of argument",
      fn([1,2,3] + 3) should signal(Condition Error Type IncorrectType)
    )
  )

  describe("-",
    it("should return the same list when given an empty list",
      x = [1,2,3]
      (x - []) should == x
    )

    it("should return an empty list when subtracting from an empty list",
      x = [1,2,3]
      ([] - x) should == []
    )

    it("should remove all elements that are the same from the first list",
      x = [1,2,3]
      y = [2,4,6,2]
      
      (x - y) should == [1,3]
      (y - x) should == [4,6]
    )
    
    it("should validate type of receiver",
      List should checkReceiverTypeOn(:"-", [])
    )
    
    it("should validate type of argument",
      fn([1,2,3] - 3) should signal(Condition Error Type IncorrectType)
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
    
    it("should validate type of receiver",
      List should checkReceiverTypeOn(:"<=>", [])
    )
  )
  
  describe("removeAt!", 
    it("should return nil if receiver is empty list", 
      list removeAt!(0) should be nil
      list removeAt!(10) should be nil
      list removeAt!(-1) should be nil
    )

    it("should return nil if argument is greater than the list's size", 
      list(1) removeAt!(1) should be nil
    )

    it("should remove element from front if argument is zero or positive", 
      l = [1,2,3,4]
      l removeAt!(0) should == 1
      l should == [2,3,4]
    
      l = [1,2,3,4]
      l removeAt!(1) should == 2
      l should == [1,3,4]
    
      l = [1,2,3,4]
      l removeAt!(2) should == 3
      l should == [1,2,4]
    
      l = [1,2,3,4]
      l removeAt!(3) should == 4
      l should == [1,2,3]
    )

    it("should remove element from back if argument is negative", 
      l = [1,2,3,4]
      l removeAt!(-1) should == 4
      l should == [1,2,3]
    
      l = [1,2,3,4]
      l removeAt!(-2) should == 3
      l should == [1,2,4]
    
      l = [1,2,3,4]
      l removeAt!(-3) should == 2
      l should == [1,3,4]
    
      l = [1,2,3,4]
      l removeAt!(-4) should == 1
      l should == [2,3,4]
    )

    it("should not remove anything for any range if reveicer is empty list", 
      l = []
      l removeAt!(0..0) should == []
      l should == []
    
      l = []
      l removeAt!(0...0) should == []
      l should == []
    
      l = []
      l removeAt!(0..-1) should == []
      l should == []
    
      l = []
      l removeAt!(0...-1) should == []
      l should == []
    
      l = []
      l removeAt!(10..20) should == []
      l should == []
    
      l = []
      l removeAt!(10...20) should == []
      l should == []
    
      l = []
      l removeAt!(-1..20) should == []
      l should == []
    )

    it("should remove all elements for 0..-1", 
      l = []
      l removeAt!(0..-1) should == []
      l should == []
    
      l = [1,2,3]
      l removeAt!(0..-1) should == [1,2,3]
      l should == []
    
      l = ["x", "y"]
      l removeAt!(0..-1) should == ["x","y"]
      l should == []
    )

    it("should remove all except first element for 1..-1", 
      l = [1]
      l removeAt!(1..-1) should == []
      l should == [1]
    
      l = [1,2,3]
      l removeAt!(1..-1) should == [2,3]
      l should == [1]
    
      l = ["x", "y"]
      l removeAt!(1..-1) should == ["y"]
      l should == ["x"]
    )

    it("should remove all except first and last element for 1...-1", 
      l = [1,2]
      l removeAt!(1...-1) should == []
      l should == [1,2]
    
      l = [1,2,3]
      l removeAt!(1...-1) should == [2]
      l should == [1,3]
    
      l = ["x", "y", "zed", "bar"]
      l removeAt!(1...-1) should == ["y", "zed"]
      l should == ["x", "bar"]
    )

    it("should remove first element for 0..0", 
      l = [1]
      l removeAt!(0..0) should == [1]
      l should == []
    
      l = [1,2,3]
      l removeAt!(0..0) should == [1]
      l should == [2,3]
    
      l = ["x", "y"]
      l removeAt!(0..0) should == ["x"]
      l should == ["y"]
    )

    it("should not remove anything for 0...0", 
      l = [1]
      l removeAt!(0...0) should == []
      l should ==[1]
    
      l = [1,2,3]
      l removeAt!(0...0) should == []
      l should == [1,2,3]
    
      l = ["x", "y"]
      l removeAt!(0...0) should == []
      l should ==["x", "y"]
    )

    it("should remove sublist for inclusive range", 
      l = [1,2,3,4,5,6,7,8,9,10,11]
      l removeAt!(3..5) should == [4,5,6]
      l should == [1,2,3,7,8,9,10,11]
    )

    it("should remove sublist for exclusive range", 
      l = [1,2,3,4,5,6,7,8,9,10,11]
      l removeAt!(3...6) should == [4,5,6]
      l should == [1,2,3,7,8,9,10,11]
    )

    it("should remove sublist for inclusive range that ends in negative index", 
      l = [1,2,3,4,5,6,7,8,9,10,11]
      l removeAt!(3..-3) should == [4,5,6,7,8,9]
      l should == [1,2,3,10,11]
    )

    it("should remove sublist for exclusive range that ends in negative index", 
      l = [1,2,3,4,5,6,7,8,9,10,11]
      l removeAt!(3...-3) should == [4,5,6,7,8]
      l should == [1,2,3,9,10,11]
    )

    it("should remove all elements to end of list for range that ends in index greater than list's size", 
      l = [1,2,3,4,5,6,7,8,9,10,11]
      l removeAt!(5..3443343) should == [6,7,8,9,10,11]
      l should == [1,2,3,4,5]
    
      l = [1,2,3,4,5,6,7,8,9,10,11]
      l removeAt!(5...3443343) should == [6,7,8,9,10,11]
      l should == [1,2,3,4,5]
    )

    it("should not remove anything for a totally messed up indexing", 
      l = [1,2,3,4,5,6,7,8,9,10,11]
      l removeAt!(-1..3) should == []
      l should == [1,2,3,4,5,6,7,8,9,10,11]
    
      l = [1,2,3,4,5,6,7,8,9,10,11]
      l removeAt!(-1..7557) should == []
      l should == [1,2,3,4,5,6,7,8,9,10,11]
    
      l = [1,2,3,4,5,6,7,8,9,10,11]
      l removeAt!(5..4) should == []
      l should == [1,2,3,4,5,6,7,8,9,10,11]
    
      l = [1,2,3,4,5,6,7,8,9,10,11]
      l removeAt!(-1...3) should == []
      l should == [1,2,3,4,5,6,7,8,9,10,11]
    
      l = [1,2,3,4,5,6,7,8,9,10,11]
      l removeAt!(-1...7557) should == []
      l should == [1,2,3,4,5,6,7,8,9,10,11]
    
      l = [1,2,3,4,5,6,7,8,9,10,11]
      l removeAt!(5...4) should == []
      l should == [1,2,3,4,5,6,7,8,9,10,11]
    )

    it("should validate type of receiver", 
      List should checkReceiverTypeOn(:removeAt!, 0)
    )

    it("should validate type of argument", 
      fn([] removeAt!([])) should signal(Condition Error Type IncorrectType)
      fn([] removeAt!("foo")) should signal(Condition Error Type IncorrectType)
    )
  )

  describe("remove!", 
    it("should return empty list if receiver is empty list", 
      [] remove!(1) should == []
      [] remove!("a") should == []
      [] remove!(1,2) should == []
      [] remove!("a","b") should == []
    )

    it("should remove all occurrences of single argument", 
      [1,2,3,4,1,2,3,4] remove!(2) should == [1,3,4,1,3,4]
      ["a","b","c","a","b","c"] remove!("b") should == ["a","c","a","c"]
    )

    it("should remove all occurrences of multiple arguments", 
      [1,2,3,4,1,2,3,4] remove!(1,3) should == [2,4,2,4]
      [1,2,3,4,1,2,3,4] remove!(1,2,3,4) should == []
    
      ["a","b","c","a","b","c"] remove!("a","b","c") should == []
      ["a","b","c","a","b","c"] remove!("a","b") should == ["c","c"]
    )

    it("should leave list unmodified if arguments not contained in list", 
      [1,2,3,4] remove!(5) should == [1,2,3,4]
      [1,2,3,4] remove!(5,6,7) should == [1,2,3,4]
    
      ["a","b","c"] remove!("x") should == ["a","b","c"]
      ["a","b","c"] remove!("x","y","z") should == ["a","b","c"]
    )

    it("should skip arguments not contained in list", 
      [1,2,3,4,1,2,3,4] remove!(2,3,5,6) should == [1,4,1,4]
      ["a","b","c","a","b","c"] remove!("a","b","x","y") should == ["c","c"]
    )

    it("should validate type of receiver", 
      List should checkReceiverTypeOn(:remove!, 0)
    )
  )

  describe("removeFirst!", 
    it("should return empty list if receiver is empty list", 
      [] removeFirst!(1) should == []
      [] removeFirst!("a") should == []
      [] removeFirst!(1,2) should == []
      [] removeFirst!("a","b") should == []
    )

    it("should remove first occurrence of single argument", 
      [1,2,1,2] removeFirst!(2) should == [1,1,2]
      ["a","b","a","b"] removeFirst!("b") should == ["a","a","b"]
    )

    it("should remove first occurrence of multiple arguments", 
      [1,2,1,2] removeFirst!(1,2) should == [1,2]
      [1,2,1,2] removeFirst!(1,1) should == [2,2]
      [1,2,1,2] removeFirst!(1,2,1,2) should == []
    
      ["a","b","a","b"] removeFirst!("a","b") should == ["a","b"]
      ["a","b","a","b"] removeFirst!("a","a") should == ["b","b"]
      ["a","b","a","b"] removeFirst!("a","b","a","b") should == []
    )

    it("should leave list unmodified if arguments not contained in list", 
      [1,2,3,4] removeFirst!(5) should == [1,2,3,4]
      [1,2,3,4] removeFirst!(5,6,7) should == [1,2,3,4]
    
      ["a","b","c"] removeFirst!("x") should == ["a","b","c"]
      ["a","b","c"] removeFirst!("x","y","z") should == ["a","b","c"]
    )

    it("should skip arguments not contained in list", 
      [1,2,1,2] removeFirst!(2,5,6) should == [1,1,2]
      ["a","b","a","b"] removeFirst!("a","x","y") should == ["b","a","b"]
    )

    it("should validate type of receiver", 
      List should checkReceiverTypeOn(:removeFirst!, 0)
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
