
use("ispec")

CustomEnumerable = Origin mimic
CustomEnumerable mimic!(Mixins Enumerable)
CustomEnumerable each = macro(
  len = call arguments length
  
  if(len == 1,
    first = call arguments first
    first evaluateOn(call ground, "3first")
    first evaluateOn(call ground, "1second")
    first evaluateOn(call ground, "2third"),

    if(len == 2,
      lexical = LexicalBlock createFrom(call arguments, call ground)
      lexical call("3first")
      lexical call("1second")
      lexical call("2third"),

      lexical = LexicalBlock createFrom(call arguments, call ground)
      lexical call(0, "3first")
      lexical call(1, "1second")
      lexical call(2, "2third"))))

CustomEnumerable2 = Origin mimic
CustomEnumerable2 mimic!(Mixins Enumerable)
CustomEnumerable2 each = macro(
  len = call arguments length
  
  if(len == 1,
    first = call arguments first
    first evaluateOn(call ground, 42)
    first evaluateOn(call ground, 16)
    first evaluateOn(call ground, 17),
    if(len == 2,
      lexical = LexicalBlock createFrom(call arguments, call ground)
      lexical call(42)
      lexical call(16)
      lexical call(17),

      lexical = LexicalBlock createFrom(call arguments, call ground)
      lexical call(0, 42)
      lexical call(1, 16)
      lexical call(2, 17))))

describe(Mixins,
  describe(Mixins Enumerable,
    describe("sort",
      it("should return a sorted list based on all the entries",
        set(4,4,2,1,4,23,6,4,7,21) sort should == [1, 2, 4, 6, 7, 21, 23]
      )
    )

    describe("asList",
      it("should return a list from a list",
        [1,2,3] asList should == [1,2,3]
      )
      
      it("should return a list based on all things yielded to each",
        CustomEnumerable asList should == ["3first", "1second", "2third"]
      )      
    )

    describe("map",
      it("should return an empty list for an empty enumerable",
        [] map(x, x+2) should == []
        {} map(x, x+2) should == []
        set map(x, x+2) should == []
      )
      
      it("should return the same list for something that only returns itself",
        [1, 2, 3] map(x, x) should == [1, 2, 3]
      )

      it("should take one argument and apply the inside",
        [1, 2, 3] map(+2) should == [3, 4, 5]
        [1, 2, 3] map(. 1) should == [1, 1, 1]
      )

      it("should take two arguments and apply the code with the argument name bound",
        [1, 2, 3] map(x, x+3) should == [4, 5, 6]
        [1, 2, 3] map(x, 1) should == [1, 1, 1]
      )      
    )

    describe("mapFn", 
      it("should take zero arguments and just return the elements in a list", 
        [1, 2, 3] mapFn should == [1, 2, 3]
        CustomEnumerable mapFn should == ["3first", "1second", "2third"]
      )
      
      it("should take one lexical block argument and apply that to each element, and return the result in a list", 
        x = fn(arg, arg+2). [1, 2, 3] mapFn(x) should == [3, 4, 5]
        x = fn(arg, arg[0..2])
        CustomEnumerable mapFn(x) should == ["3fi", "1se", "2th"]
      )

      it("should take several lexical blocks and chain them together", 
        x = fn(arg, arg+2). x2 = fn(arg, arg*2). [1, 2, 3] mapFn(x, x2) should == [6, 8, 10]
        x = fn(arg, arg[0..2])
        x2 = fn(arg, arg + "flurg")
        CustomEnumerable mapFn(x, x2) should == ["3fiflurg", "1seflurg", "2thflurg"]
      )
    )
    
    describe("collect", 
      it("should return an empty list for an empty enumerable", 
        [] collect(x, x+2) should == []
        {} collect(x, x+2) should == []
        set collect(x, x+2) should == []
      )
      
      it("should return the same list for something that only returns itself", 
        [1, 2, 3] collect(x, x) should == [1, 2, 3]
      )

      it("should take one argument and apply the inside", 
        [1, 2, 3] collect(+2) should == [3, 4, 5]
        [1, 2, 3] collect(. 1) should == [1, 1, 1]
      )

      it("should take two arguments and apply the code with the argument name bound", 
        [1, 2, 3] collect(x, x+3) should == [4, 5, 6]
        [1, 2, 3] collect(x, 1) should == [1, 1, 1]
      )
    )

    describe("collectFn", 
      it("should take zero arguments and just return the elements in a list", 
        [1, 2, 3] collectFn should == [1, 2, 3]
        CustomEnumerable collectFn should == ["3first", "1second", "2third"]
      )
      
      it("should take one lexical block argument and apply that to each element, and return the result in a list", 
        x = fn(arg, arg+2). [1, 2, 3] collectFn(x) should == [3, 4, 5]
        x = fn(arg, arg[0..2])
        CustomEnumerable collectFn(x) should == ["3fi", "1se", "2th"]
      )

      it("should take several lexical blocks and chain them together", 
        x = fn(arg, arg+2). x2 = fn(arg, arg*2). [1, 2, 3] collectFn(x, x2) should == [6, 8, 10]
        x = fn(arg, arg[0..2])
        x2 = fn(arg, arg + "flurg")
        CustomEnumerable collectFn(x, x2) should == ["3fiflurg", "1seflurg", "2thflurg"]
      )
    )
    
    describe("any?", 
      it("should take zero arguments and just check if any of the values are true", 
        [1,2,3] any?
        [nil,false,nil] any? should == false
        [nil,false,true] any? should == true
        CustomEnumerable any? should == true
      )

      it("should take one argument that is a predicate that is applied to each element in the enumeration", 
        [1,2,3] any?(==2) should == true
        [nil,false,nil] any?(nil?) should == true
        [nil,false,true] any?(==2) should == false
        CustomEnumerable any?(!= "foo") should == true
      )

      it("should take two arguments that will be turned into a lexical block and applied", 
        [1,2,3] any?(x, x==2) should == true
        [nil,false,nil] any?(x, x nil?) should == true
        [nil,false,true] any?(x, x==2) should = =false
        CustomEnumerable any?(x, x != "foo") should == true
      )
    )

    describe("none?", 
      it("should take zero arguments and just check if any of the values are true, and then return false", 
        [1,2,3] none? should == false
        [nil,false,nil] none? should == true
        [nil,false,true] none? should == false
        CustomEnumerable none? should == false
      )

      it("should take one argument that is a predicate that is applied to each element in the enumeration", 
        [1,2,3] none?(==2) should == false
        [nil,false,nil] none?(nil?) should == false
        [nil,false,true] none?(==2) should == true
        CustomEnumerable none?(!= "foo") should == false
      )

      it("should take two arguments that will be turned into a lexical block and applied", 
        [1,2,3] none?(x, x==2) should == false
        [nil,false,nil] none?(x, x nil?) should == false
        [nil,false,true] none?(x, x==2) should == true
        CustomEnumerable none?(x, x != "foo") should == false
      )
    )

    describe("some", 
      it("should take zero arguments and just check if any of the values are true, and then return it", 
        [1,2,3] some should == 1
        [nil,false,nil] some should == false
        [nil,false,true] some should == true
        CustomEnumerable some should == "3first"
      )

      it("should take one argument that is a predicate that is applied to each element in the enumeration", 
        [1,2,3] some(==2 && 3) should == 3
        [nil,false,nil] some(nil? && 42) should == 42
        [nil,false,true] some(==2 && 3) should == false
        CustomEnumerable some(!= "foo" && "blarg") should == "blarg"
      )

      it("should take two arguments that will be turned into a lexical block and applied", 
        [1,2,3] some(x, x==2 && 3) should == 3
        [nil,false,nil] some(x, x nil? && 42) should == 42
        [nil,false,true] some(x, x==2 && 3) should == false
        CustomEnumerable some(x, x != "foo" && "blarg") should == "blarg"
      )
    )

    describe("find", 
      it("should take zero arguments and just check if any of the values are true, and then return it", 
        [1,2,3] find should == 1
        [nil,false,nil] find should == nil
        [nil,false,true] find should == true
        CustomEnumerable find should == "3first"
      )

      it("should take one argument that is a predicate that is applied to each element in the enumeration", 
        [1,2,3] find(==2) should == 2
        [nil,false,nil] find(nil?) should == nil
        [nil,false,true] find(==2) should == nil
        CustomEnumerable find(!= "foo") should == "3first"
      )

      it("should take two arguments that will be turned into a lexical block and applied", 
        [1,2,3] find(x, x==2) should == 2
        [nil,false,nil] find(x, x nil?) should == nil
        [nil,false,true] find(x, x==2) should == nil
        CustomEnumerable find(x, x != "foo") should == "3first"
      )
    )

    describe("detect", 
      it("should take zero arguments and just check if any of the values are true, and then return it", 
        [1,2,3] detect should == 1
        [nil,false,nil] detect should == nil
        [nil,false,true] detect should == true
        CustomEnumerable detect should == "3first"
      )

      it("should take one argument that is a predicate that is applied to each element in the enumeration", 
        [1,2,3] detect(==2) should == 2
        [nil,false,nil] detect(nil?) should == nil
        [nil,false,true] detect(==2) should == nil
        CustomEnumerable detect(!= "foo") should == "3first"
      )

      it("should take two arguments that will be turned into a lexical block and applied", 
        [1,2,3] detect(x, x==2) should == 2
        [nil,false,nil] detect(x, x nil?) should == nil
        [nil,false,true] detect(x, x==2) should == nil
        CustomEnumerable detect(x, x != "foo") should == "3first"
      )
    )
  )
)
