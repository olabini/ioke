
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

    describe("map:set",
      it("should return an empty set for an empty enumerable",
        [] map:set(x, x+2) should == set
        {} map:set(x, x+2) should == set
        set map:set(x, x+2) should == set
      )
      
      it("should return the same set for something that only returns itself",
        [1, 2, 3] map:set(x, x) should == set(1, 2, 3)
      )

      it("should take one argument and apply the inside",
        [1, 2, 3] map:set(+2) should == set(3, 4, 5)
        [1, 2, 3] map:set(. 1) should == set(1)
      )

      it("should take two arguments and apply the code with the argument name bound",
        [1, 2, 3] map:set(x, x+3) should == set(4, 5, 6)
        [1, 2, 3] map:set(x, 1) should == set(1)
      )      
    )

    describe("map:dict",
      it("should return an empty dict for an empty enumerable",
        [] map:dict(x, x+2) should == dict
        {} map:dict(x, x+2) should == dict
        set map:dict(x, x+2) should == dict
      )
      
      it("should return the same dict for something that only returns itself",
        [1, 2, 3] map:dict(x, x=>x) should == dict(1=>1, 2=>2, 3=>3)
      )

      it("should take one argument and apply the inside",
        [1, 2, 3] map:dict(=>2) should == dict(1=>2, 2=>2, 3=>2)
        [1, 2, 3] map:dict(. 1=>1) should == dict(1=>1)
      )

      it("should take two arguments and apply the code with the argument name bound",
        [1, 2, 3] map:dict(x, x=>x+3) should == dict(1=>4, 2=>5, 3=>6)
        [1, 2, 3] map:dict(x, x=>1) should == dict(1=>1, 2=>1, 3=>1)
        [1, 2, 3] map:dict(x, x) should == dict(1=>nil, 2=>nil, 3=>nil)
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

    describe("collect:set",
      it("should return an empty set for an empty enumerable",
        [] collect:set(x, x+2) should == set
        {} collect:set(x, x+2) should == set
        set collect:set(x, x+2) should == set
      )
      
      it("should return the same set for something that only returns itself",
        [1, 2, 3] collect:set(x, x) should == set(1, 2, 3)
      )

      it("should take one argument and apply the inside",
        [1, 2, 3] collect:set(+2) should == set(3, 4, 5)
        [1, 2, 3] collect:set(. 1) should == set(1)
      )

      it("should take two arguments and apply the code with the argument name bound",
        [1, 2, 3] collect:set(x, x+3) should == set(4, 5, 6)
        [1, 2, 3] collect:set(x, 1) should == set(1)
      )      
    )

    describe("collect:dict",
      it("should return an empty dict for an empty enumerable",
        [] collect:dict(x, x+2) should == dict
        {} collect:dict(x, x+2) should == dict
        set collect:dict(x, x+2) should == dict
      )
      
      it("should return the same dict for something that only returns itself",
        [1, 2, 3] collect:dict(x, x=>x) should == dict(1=>1, 2=>2, 3=>3)
      )

      it("should take one argument and apply the inside",
        [1, 2, 3] collect:dict(=>2) should == dict(1=>2, 2=>2, 3=>2)
        [1, 2, 3] collect:dict(. 1=>1) should == dict(1=>1)
      )

      it("should take two arguments and apply the code with the argument name bound",
        [1, 2, 3] collect:dict(x, x=>x+3) should == dict(1=>4, 2=>5, 3=>6)
        [1, 2, 3] collect:dict(x, x=>1) should == dict(1=>1, 2=>1, 3=>1)
        [1, 2, 3] collect:dict(x, x) should == dict(1=>nil, 2=>nil, 3=>nil)
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
        [nil,false,nil] any? should be false
        [nil,false,true] any? should be true
        CustomEnumerable any? should be true
      )

      it("should take one argument that is a predicate that is applied to each element in the enumeration", 
        [1,2,3] any?(==2) should be true
        [nil,false,nil] any?(nil?) should be true
        [nil,false,true] any?(==2) should be false
        CustomEnumerable any?(!= "foo") should be true
      )

      it("should take two arguments that will be turned into a lexical block and applied", 
        [1,2,3] any?(x, x==2) should be true
        [nil,false,nil] any?(x, x nil?) should be true
        [nil,false,true] any?(x, x==2) should = =false
        CustomEnumerable any?(x, x != "foo") should be true
      )
    )

    describe("none?", 
      it("should take zero arguments and just check if any of the values are true, and then return false", 
        [1,2,3] none? should be false
        [nil,false,nil] none? should be true
        [nil,false,true] none? should be false
        CustomEnumerable none? should be false
      )

      it("should take one argument that is a predicate that is applied to each element in the enumeration", 
        [1,2,3] none?(==2) should be false
        [nil,false,nil] none?(nil?) should be false
        [nil,false,true] none?(==2) should be true
        CustomEnumerable none?(!= "foo") should be false
      )

      it("should take two arguments that will be turned into a lexical block and applied", 
        [1,2,3] none?(x, x==2) should be false
        [nil,false,nil] none?(x, x nil?) should be false
        [nil,false,true] none?(x, x==2) should be true
        CustomEnumerable none?(x, x != "foo") should be false
      )
    )

    describe("some", 
      it("should take zero arguments and just check if any of the values are true, and then return it", 
        [1,2,3] some should == 1
        [nil,false,nil] some should be false
        [nil,false,true] some should be true
        CustomEnumerable some should == "3first"
      )

      it("should take one argument that is a predicate that is applied to each element in the enumeration", 
        [1,2,3] some(==2 && 3) should == 3
        [nil,false,nil] some(nil? && 42) should == 42
        [nil,false,true] some(==2 && 3) should be false
        CustomEnumerable some(!= "foo" && "blarg") should == "blarg"
      )

      it("should take two arguments that will be turned into a lexical block and applied", 
        [1,2,3] some(x, x==2 && 3) should == 3
        [nil,false,nil] some(x, x nil? && 42) should == 42
        [nil,false,true] some(x, x==2 && 3) should be false
        CustomEnumerable some(x, x != "foo" && "blarg") should == "blarg"
      )
    )

    describe("find", 
      it("should take zero arguments and just check if any of the values are true, and then return it", 
        [1,2,3] find should == 1
        [nil,false,nil] find should be nil
        [nil,false,true] find should be true
        CustomEnumerable find should == "3first"
      )

      it("should take one argument that is a predicate that is applied to each element in the enumeration", 
        [1,2,3] find(==2) should == 2
        [nil,false,nil] find(nil?) should be nil
        [nil,false,true] find(==2) should be nil
        CustomEnumerable find(!= "foo") should == "3first"
      )

      it("should take two arguments that will be turned into a lexical block and applied", 
        [1,2,3] find(x, x==2) should == 2
        [nil,false,nil] find(x, x nil?) should be nil
        [nil,false,true] find(x, x==2) should be nil
        CustomEnumerable find(x, x != "foo") should == "3first"
      )
    )

    describe("detect", 
      it("should take zero arguments and just check if any of the values are true, and then return it", 
        [1,2,3] detect should == 1
        [nil,false,nil] detect should be nil
        [nil,false,true] detect should be true
        CustomEnumerable detect should == "3first"
      )

      it("should take one argument that is a predicate that is applied to each element in the enumeration", 
        [1,2,3] detect(==2) should == 2
        [nil,false,nil] detect(nil?) should be nil
        [nil,false,true] detect(==2) should be nil
        CustomEnumerable detect(!= "foo") should == "3first"
      )

      it("should take two arguments that will be turned into a lexical block and applied", 
        [1,2,3] detect(x, x==2) should == 2
        [nil,false,nil] detect(x, x nil?) should be nil
        [nil,false,true] detect(x, x==2) should be nil
        CustomEnumerable detect(x, x != "foo") should == "3first"
      )
    )


    describe("inject",
      ;; inject needs: a start value, an argument name, a sum argument name, and code
      ;; versions:
      
      ;; inject(+)                                  => inject(    sum,    x,    sum    +(x))
      ;; inject(x, + x)                             => inject(    sumArg, x,    sumArg +(x))
      ;; inject(sumArg, xArg, sumArg + xArg)        => inject(    sumArg, xArg, sumArg + xArg)
      ;; inject("", sumArg, xArg, sumArg + xArg)    => inject("", sumArg, xArg, sumArg +(xArg))

      it("should take one argument that is a message chain and apply that on the sum, with the current arg as argument", 
        [1,2,3] inject(+) should == 6
        [1,2,3] inject(*(5) -) should == 12
        CustomEnumerable2 inject(-) should == 9
      )

      it("should take two arguments that is an argument name and a message chain and apply that on the sum", 
        [1,2,3] inject(x, + x*2) should == 11
        [1,2,3] inject(x, *(5) - x) should == 12
        CustomEnumerable2 inject(x, - x) should == 9
      )

      it("should take three arguments that is the sum name, the argument name and code to apply", 
        [1,2,3] inject(sum, x, sum + x*2) should == 11
        [1,2,3] inject(sum, x, sum *(5) - x) should == 12
        CustomEnumerable2 inject(sum, x, sum - x) should == 9
      )

      it("should take four arguments that is the initial value, the sum name, the argument name and code to apply", 
        [1,2,3] inject(13, sum, x, sum + x*2) should == 25
        [1,2,3] inject(1, sum, x, sum *(5) - x) should == 87
        CustomEnumerable2 inject(100, sum, x, sum - x) should == 25
      )
    )    

    describe("reduce",
      ;; reduce needs: a start value, an argument name, a sum argument name, and code
      ;; versions:
      
      ;; reduce(+)                                  => reduce(    sum,    x,    sum    +(x))
      ;; reduce(x, + x)                             => reduce(    sumArg, x,    sumArg +(x))
      ;; reduce(sumArg, xArg, sumArg + xArg)        => reduce(    sumArg, xArg, sumArg + xArg)
      ;; reduce("", sumArg, xArg, sumArg + xArg)    => reduce("", sumArg, xArg, sumArg +(xArg))

      it("should take one argument that is a message chain and apply that on the sum, with the current arg as argument", 
        [1,2,3] reduce(+) should == 6
        [1,2,3] reduce(*(5) -) should == 12
        CustomEnumerable2 reduce(-) should == 9
      )

      it("should take two arguments that is an argument name and a message chain and apply that on the sum", 
        [1,2,3] reduce(x, + x*2) should == 11
        [1,2,3] reduce(x, *(5) - x) should == 12
        CustomEnumerable2 reduce(x, - x) should == 9
      )

      it("should take three arguments that is the sum name, the argument name and code to apply", 
        [1,2,3] reduce(sum, x, sum + x*2) should == 11
        [1,2,3] reduce(sum, x, sum *(5) - x) should == 12
        CustomEnumerable2 reduce(sum, x, sum - x) should == 9
      )

      it("should take four arguments that is the initial value, the sum name, the argument name and code to apply", 
        [1,2,3] reduce(13, sum, x, sum + x*2) should == 25
        [1,2,3] reduce(1, sum, x, sum *(5) - x) should == 87
        CustomEnumerable2 reduce(100, sum, x, sum - x) should == 25
      )
    )    

    describe("fold",
      ;; fold needs: a start value, an argument name, a sum argument name, and code
      ;; versions:
      
      ;; fold(+)                                  => fold(    sum,    x,    sum    +(x))
      ;; fold(x, + x)                             => fold(    sumArg, x,    sumArg +(x))
      ;; fold(sumArg, xArg, sumArg + xArg)        => fold(    sumArg, xArg, sumArg + xArg)
      ;; fold("", sumArg, xArg, sumArg + xArg)    => fold("", sumArg, xArg, sumArg +(xArg))

      it("should take one argument that is a message chain and apply that on the sum, with the current arg as argument", 
        [1,2,3] fold(+) should == 6
        [1,2,3] fold(*(5) -) should == 12
        CustomEnumerable2 fold(-) should == 9
      )

      it("should take two arguments that is an argument name and a message chain and apply that on the sum", 
        [1,2,3] fold(x, + x*2) should == 11
        [1,2,3] fold(x, *(5) - x) should == 12
        CustomEnumerable2 fold(x, - x) should == 9
      )

      it("should take three arguments that is the sum name, the argument name and code to apply", 
        [1,2,3] fold(sum, x, sum + x*2) should == 11
        [1,2,3] fold(sum, x, sum *(5) - x) should == 12
        CustomEnumerable2 fold(sum, x, sum - x) should == 9
      )

      it("should take four arguments that is the initial value, the sum name, the argument name and code to apply", 
        [1,2,3] fold(13, sum, x, sum + x*2) should == 25
        [1,2,3] fold(1, sum, x, sum *(5) - x) should == 87
        CustomEnumerable2 fold(100, sum, x, sum - x) should == 25
      )
    )
    
    describe("flatMap", 
      it("should return a correct flattened list", 
        [1,2,3] flatMap(x, [x]) should == [1,2,3]
        [1,2,3] flatMap(x, [x, x+10, x+20]) should == [1,11,21,2,12,22,3,13,23]
        [4,5,6] flatMap(x, [x+20, x+10, x]) should == [24,14,4,25,15,5,26,16,6]
      )
    )

    describe("flatMap:set", 
      it("should return a correct flattened set", 
        [1,2,3] flatMap:set(x, set(x)) should == set(1,2,3)
        [1,2,3] flatMap:set(x, set(x, x+10, x+20)) should == set(1,11,21,2,12,22,3,13,23)
        [4,5,6] flatMap:set(x, set(x+20, x+10, x)) should == set(24,14,4,25,15,5,26,16,6)
      )
    )

    describe("flatMap:dict", 
      it("should return a correct flattened dict", 
        [1,2,3] flatMap:dict(x, dict(x=>x+2)) should == dict(1=>3,2=>4,3=>5)
        [1,2,3] flatMap:dict(x, dict(x=>nil, (x+10)=>nil, (x+20)=>nil)) should == dict(1=>nil,11=>nil,21=>nil,2=>nil,12=>nil,22=>nil,3=>nil,13=>nil,23=>nil)
        [4,5,6] flatMap:dict(x, dict((x+20)=>nil, (x+10)=>nil, x=>nil)) should == dict(24=>nil,14=>nil,4=>nil,25=>nil,15=>nil,5=>nil,26=>nil,16=>nil,6=>nil)
      )
    )
    
    describe("select", 
      it("should take zero arguments and return a list with only the true values", 
        [1,2,3] select should == [1,2,3]
        [nil,false,nil] select should == []
        [nil,false,true] select should == [true]
        CustomEnumerable select should == CustomEnumerable asList
      )

      it("should take one argument that ends up being a predicate and return a list of the values that is true", 
        [1,2,3] select(>1) should == [2,3]
        [nil,false,nil] select(nil?) should == [nil, nil]
        [nil,false,true] select(==2) should == []
        CustomEnumerable select([0...1] != "1") should == ["3first", "2third"]
      )

      it("should take two arguments that ends up being a predicate and return a list of the values that is true", 
        [1,2,3] select(x, x>1) should == [2,3]
        [nil,false,nil] select(x, x nil?) should == [nil, nil]
        [nil,false,true] select(x, x==2) should == []
        CustomEnumerable select(x, x != "2third") should == ["3first", "1second"]
      )
    )

    describe("findAll", 
      it("should take zero arguments and return a list with only the true values", 
        [1,2,3] findAll should == [1,2,3]
        [nil,false,nil] findAll should == []
        [nil,false,true] findAll should == [true]
        CustomEnumerable findAll should == CustomEnumerable asList
      )

      it("should take one argument that ends up being a predicate and return a list of the values that is true", 
        [1,2,3] findAll(>1) should == [2,3]
        [nil,false,nil] findAll(nil?) should == [nil, nil]
        [nil,false,true] findAll(==2) should == []
        CustomEnumerable findAll([0...1] != "1") should == ["3first", "2third"]
      )

      it("should take two arguments that ends up being a predicate and return a list of the values that is true", 
        [1,2,3] findAll(x, x>1) should == [2,3]
        [nil,false,nil] findAll(x, x nil?) should == [nil, nil]
        [nil,false,true] findAll(x, x==2) should == []
        CustomEnumerable findAll(x, x != "2third") should == ["3first", "1second"]
      )
    )

    describe("filter", 
      it("should take zero arguments and return a list with only the true values", 
        [1,2,3] filter should == [1,2,3]
        [nil,false,nil] filter should == []
        [nil,false,true] filter should == [true]
        CustomEnumerable filter should == CustomEnumerable asList
      )

      it("should take one argument that ends up being a predicate and return a list of the values that is true", 
        [1,2,3] filter(>1) should == [2,3]
        [nil,false,nil] filter(nil?) should == [nil, nil]
        [nil,false,true] filter(==2) should == []
        CustomEnumerable filter([0...1] != "1") should == ["3first", "2third"]
      )

      it("should take two arguments that ends up being a predicate and return a list of the values that is true", 
        [1,2,3] filter(x, x>1) should == [2,3]
        [nil,false,nil] filter(x, x nil?) should == [nil, nil]
        [nil,false,true] filter(x, x==2) should == []
        CustomEnumerable filter(x, x != "2third") should == ["3first", "1second"]
      )
    )
    
    describe("all?", 
      it("should take zero arguments and just check if all of the values are true", 
        [1,2,3] all? should be true
        [nil,false,nil] all? should be false
        [nil,false,true] all? should be false
        CustomEnumerable all? should be true
      )

      it("should take one argument that is a predicate that is applied to each element in the enumeration", 
        [1,2,3] all?(==2) should be false
        [1,2,3] all?(>0) should be true
        [nil,false,nil] all?(nil?) should be false
        [nil,false,true] all?(==2) should be false
        CustomEnumerable all?(!= "foo") should be true
      )

      it("should take two arguments that will be turned into a lexical block and applied", 
        [1,2,3] all?(x, x==2) should be false
        [1,2,3] all?(x, x<4) should be true
        [nil,false,nil] all?(x, x nil?) should be false
        [nil,nil,nil] all?(x, x nil?) should be true
        [nil,false,true] all?(x, x==2) should be false
        CustomEnumerable all?(x, x != "foo") should be true
      )
    )
    
    describe("count", 
      it("should take zero arguments and return how many elements there are", 
        [1,2,3] count should == 3
        [nil,false] count should == 2
        [nil,false,true] count should == 3
        CustomEnumerable count should == 3
      )

      it("should take one element that is a predicate, and return how many matches it", 
        [1,2,3] count(>1) should == 2
        [nil,false,nil] count(nil?) should == 2
        [nil,false,true] count(==2) should == 0
        CustomEnumerable count([0...1] != "1") should == 2
      )

      it("should take two elements that turn into a lexical block and returns how many matches it", 
        [1,2,3] count(x, x>1) should == 2
        [nil,false,nil] count(x, x nil?) should == 2
        [nil,false,true] count(x, x==2) should == 0
        CustomEnumerable count(x, x != "2third") should == 2
      )
    )

    describe("reject", 
      it("should take one argument that ends up being a predicate and return a list of the values that is false", 
        [1,2,3] reject(>1) should == [1]
        [nil,false,nil] reject(nil?) should == [false]
        [nil,false,true] reject(==2) should == [nil,false,true]
        CustomEnumerable reject([0...1] == "1") should == ["3first", "2third"]
      )

      it("should take two arguments that ends up being a predicate and return a list of the values that is false", 
        [1,2,3] reject(x, x>1) should == [1]
        [nil,false,nil] reject(x, x nil?) should == [false]
        [nil,false,true] reject(x, x==2) should == [nil,false,true]
        CustomEnumerable reject(x, x == "2third") should == ["3first", "1second"]
      )
    )
    
    describe("first", 
      it("should return nil for an empty collection", 
        set first should be nil
      )

      it("should take an optional argument of how many to return", 
        set first(0) should == []
        set first(1) should == []
        set first(2) should == []
      )
      
      it("should return the first element for a non-empty collection", 
        set(42) first should == 42
        CustomEnumerable first should == "3first"
      )
      
      it("should return the first n elements for a non-empty collection", 
        set(42) first(0) should == []
        set(42) first(1) should == [42]
        set(42) first(2) should == [42]
        [42, 44, 46] first(2) should == [42, 44]
        set(42, 44, 46) first(3) sort should == [42, 44, 46]
        CustomEnumerable first(2) should == ["3first", "1second"]
      )
    )

    describe("one?", 
      it("should take zero arguments and just check if exactly one of the values are true, and then return true", 
        [1,2,3] one? should be false
        [nil,false,nil] one? should be false
        [nil,false,true] one? should be true
        CustomEnumerable one? should be false
      )

      it("should take one argument that is a predicate that is applied to each element in the enumeration", 
        [1,2,3] one?(==2) should be true
        [nil,false,nil] one?(nil?) should be false
        [nil,false,true] one?(==2) should be false
        CustomEnumerable one?(== "3first") should be true
      )

      it("should take two arguments that will be turned into a lexical block and applied", 
        [1,2,3] one?(x, x==2) should be true
        [nil,false,nil] one?(x, x nil?) should be false
        [nil,false,true] one?(x, x==2) should be false
        CustomEnumerable one?(x, x == "3first") should be true
      )
    )
    
    describe("findIndex", 
      it("should take zero arguments and just check if any of the values are true, and then return the index of it", 
        [1,2,3] findIndex should == 0
        [nil,false,nil] findIndex should be nil
        [nil,false,true] findIndex should == 2
        CustomEnumerable findIndex should == 0
      )

      it("should take one argument that is a predicate that is applied to each element in the enumeration", 
        [1,2,3] findIndex(==2) should == 1
        [nil,false,nil] findIndex(nil?) should == 0
        [nil,false,true] findIndex(==2) should be nil
        CustomEnumerable findIndex(!= "foo") should == 0
      )

      it("should take two arguments that will be turned into a lexical block and applied", 
        [1,2,3] findIndex(x, x==2) should == 1
        [nil,false,nil] findIndex(x, x nil?) should == 0
        [nil,false,true] findIndex(x, x==2) should be nil
        CustomEnumerable findIndex(x, x != "foo") should == 0
      )
    )

    describe("partition", 
      it("should take zero arguments and just divide all the true and false values", 
        [1,2,3] partition should == [[1,2,3],[]]
        [nil,false,nil] partition should == [[], [nil, false, nil]]
        [nil,false,true] partition should == [[true], [nil, false]]
        CustomEnumerable partition should == [["3first", "1second", "2third"], []]
      )

      it("should take one argument that is a predicate that is applied to each element in the enumeration", 
        [1,2,3] partition(==2) should == [[2], [1,3]]
        [nil,false,nil] partition(nil?) should  == [[nil,nil], [false]]
        [nil,false,true] partition(==2) should == [[], [nil, false, true]]
        CustomEnumerable partition(!= "foo") should == [["3first", "1second", "2third"], []]
      )

      it("should take two arguments that will be turned into a lexical block and applied", 
        [1,2,3] partition(x, x==2) should == [[2], [1,3]]
        [nil,false,nil] partition(x, x nil?) should == [[nil,nil], [false]]
        [nil,false,true] partition(x, x==2) should == [[], [nil, false, true]]
        CustomEnumerable partition(x, x != "foo") should == [["3first", "1second", "2third"], []]
      )
    )

    describe("include?", 
      it("should return true if the element is in the enumeration", 
        [1,2,3] include?(2) should be true
        CustomEnumerable include?("1second") should be true
      )

      it("should return false if the element is not in the enumeration", 
        [1,2,3] include?(0) should be false
        CustomEnumerable include?("2second") should be false
      )
    )

    describe("member?", 
      it("should return true if the element is in the enumeration", 
        [1,2,3] member?(2) should be true
        CustomEnumerable member?("1second") should be true
      )

      it("should return false if the element is not in the enumeration", 
        [1,2,3] member?(0) should be false
        CustomEnumerable member?("2second") should be false
      )
    )

    describe("take", 
      it("should return a list with as many elements as requested", 
        [1,2,3] take(0) should == []
        [1,2,3] take(1) should == [1]
        [1,2,3] take(2) should == [1,2]
        [1,2,3] take(3) should == [1,2,3]
        CustomEnumerable take(2) should == ["3first", "1second"]
      )

      it("should not take more elements than the length of the collection", 
        [1,2,3] take(4) should == [1,2,3]
        [1,2,3] take(10) should == [1,2,3]
        CustomEnumerable take(200) should == ["3first", "1second", "2third"]
      )
    )

    describe("takeWhile", 
      it("should take zero arguments and return everything up until the point where a value is false", 
        [1,2,3] takeWhile should == [1,2,3]
        [1,2,nil,false] takeWhile should == [1,2]
        [1,2,false,3,4,nil,false] takeWhile should == [1,2]
        CustomEnumerable takeWhile should == ["3first", "1second", "2third"]
      )
      
      it("should take one argument and apply it as a message chain, return a list with all elements until the block returns false", 
        [1,2,3] takeWhile(<3) should == [1,2]
        [1,2,3] takeWhile(!=2) should == [1]
        CustomEnumerable takeWhile(!="2third") should == ["3first", "1second"]
      )

      it("should take two arguments and apply the lexical block created from it, and return a list with all elements until the block returns false", 
        [1,2,3] takeWhile(x, x<3) should == [1,2]
        [1,2,3] takeWhile(x, x != 2) should == [1]
        CustomEnumerable takeWhile(x, x != "2third") should == ["3first", "1second"]
      )
    )

    describe("drop", 
      it("should return a list without as many elements as requested", 
        [1,2,3] drop(0) should == [1,2,3]
        [1,2,3] drop(1) should == [2,3]
        [1,2,3] drop(2) should == [3]
        [1,2,3] drop(3) should == []
        CustomEnumerable drop(2) should == ["2third"]
      )

      it("should not drop more elements than the length of the collection", 
        [1,2,3] drop(4) should == []
        [1,2,3] drop(10) should == []
        CustomEnumerable drop(200) should == []
      )
    )

    describe("dropWhile", 
      it("should take zero arguments and return everything after the point where a value is true", 
        [1,2,3] dropWhile should == []
        [1,2,nil,false] dropWhile should == [nil,false]
        [1,2,false,3,4,nil,false] dropWhile should == [false,3,4,nil,false]
        CustomEnumerable dropWhile should == []
      )
      
      it("should take one argument and apply it as a message chain, return a list with all elements after the block returns false", 
        [1,2,3] dropWhile(<3) should == [3]
        [1,2,3] dropWhile(!=2) should == [2,3]
        CustomEnumerable dropWhile(!="2third") should == ["2third"]
      )

      it("should take two arguments and apply the lexical block created from it, and return a list with all elements after the block returns false", 
        [1,2,3] dropWhile(x, x<3) should == [3]
        [1,2,3] dropWhile(x, x != 2) should == [2,3]
        CustomEnumerable dropWhile(x, x != "2third") should == ["2third"]
      )
    )

    describe("cycle", 
      it("should not do anything for an empty collection", 
        x = 1
        [] cycle(_, x = 2) should be nil
        x should == 1
      )

      it("should repeat until stopped", 
        Ground res = []
        m1 = method(
          [1,2,3] cycle(x, 
            if(Ground res length == 10, return)
            Ground res << x))
        m1
        Ground res should == [1,2,3,1,2,3,1,2,3,1]
      )

      it("should only call each once", 
        CustomEnumerable3 = Origin mimic
        CustomEnumerable3 mimic!(Mixins Enumerable)
        CustomEnumerable3 eachCalled = 0 
        CustomEnumerable3 each = macro(
          eachCalled++
          len = call arguments length
          
          if(len == 1,
            first = call arguments first
            first evaluateOn(call ground, "3first")
            first evaluateOn(call ground, "1second")
            first evaluateOn(call ground, "2third"),
            
            lexical = LexicalBlock createFrom(call arguments, call ground)
            lexical call("3first")
            lexical call("1second")
            lexical call("2third")))

        m = method(
          iter = 0
          CustomEnumerable3 cycle(_, if(iter == 10, return). iter++))
        m
        CustomEnumerable3 eachCalled should == 1
      )

      it("should take one argument and apply it", 
        Ground res = []
        m1 = method(
          [1,2,3] cycle(+1. if(Ground res length == 10, return). Ground res << "foo"))
        m1
      )

      it("should take two arguments and turn it into a lexical block to apply", 
        Ground res = []
        m1 = method(
          [1,2,3] cycle(x, if(Ground res length == 10, return). Ground res << x))
        m1
        Ground res should == [1,2,3,1,2,3,1,2,3,1]
      )
    )

    describe("sortBy", 
      it("should take one argument and apply that for sorting", 
        {a: 3, b: 2, c: 1} sortBy(value) should == [:c => 1, :b => 2, :a => 3]
      )
      
      it("should take two arguments and turn that into a lexical block and use that for sorting", 
        {a: 3, b: 2, c: 1} sortBy(x, x value) should == [:c => 1, :b => 2, :a => 3]
      )
    )

    describe("zip", 
      it("should take zero arguments and just zip the elements", 
        [1,2,3] zip should == [[1], [2], [3]]
      )

      it("should take one argument as a list and zip the elements together", 
        [1,2,3] zip([5,6,7]) should == [[1, 5], [2, 6], [3, 7]]
        [1,2,3] zip([5,6,7,8]) should == [[1, 5], [2, 6], [3, 7]]
      )

      it("should supply nils if the second list isn't long enough", 
        [1,2,3] zip([5,6]) should == [[1, 5], [2, 6], [3, nil]]
      )

      it("should zip together several lists", 
        [1,2,3] zip([5,6,7],[10,11,12],[15,16,17]) should == [[1,5,10,15], [2,6,11,16], [3,7,12,17]]
      )

      it("should take a fn as last argument and call that instead of returning a list", 
        x = [] 

        [1,2,3] zip([5,6,7], 
          fn(arg, x << arg)) should be nil

        x should == [[1,5],[2,6],[3,7]]
      )
    )

    describe("grep", 
      it("should take one argument and return everything that matches with ===", 
        [1,2,3,4,5,6,7,8,9] grep(2..5) should == [2,3,4,5]

        customObj = Origin mimic
        customObj === = method(other, (other < 3) || (other > 5))
        [1,2,3,4,5,6,7,8,9] grep(customObj) should == [1,2,6,7,8,9]
      )
      
      it("should take two arguments where the second argument is a message chain and return the result of calling that chain on everything that matches with ===", 
        [1,2,3,4,5,6,7,8,9] grep(2..5, + 1) should == [3,4,5,6]

        customObj = Origin mimic
        customObj === = method(other, (other < 3) || (other > 5))
        [1,2,3,4,5,6,7,8,9] grep(customObj, + 1) should == [2,3,7,8,9,10]
      )

      it("should take three arguments where the second and third arguments gets turned into a lexical block to apply to all that matches with ===", 
        [1,2,3,4,5,6,7,8,9] grep(2..5, x, (x + 1) asText) should == ["3","4","5","6"]

        customObj = Origin mimic
        customObj === = method(other, (other < 3) || (other > 5))
        [1,2,3,4,5,6,7,8,9] grep(customObj, x, (x+1) asText) should == ["2","3","7","8","9","10"]
      )
    )

    describe("max",
      it("should return the maximum using the <=> operator if no arguments are given",
        [1,2,3,4] max should == 4
        set(5,6,7,153,1) max should == 153
        ["a","b","c"] max should == "c"
      )

      it("should accept a message chain, and use that to create the comparison criteria",
        [1,2,3,4] max(*(-1)) should == 1
        set(5,6,7,153,1) max(*(-1)) should == 1
        ["abc","bfooo","cc"] max(length) should == "bfooo"
      )

      it("should accept a variable name and code, and use that to create the comparison criteria",
        [1,2,3,4] max(x, 10-x) should == 1
        set(5,6,7,153,1) max(x, if(x > 100, -x, x)) should == 7
        ["abc","bfooo","cc"] max(x, x[1]) should == "bfooo"
      )
    )

    describe("min",
      it("should return the minimum using the <=> operator if no arguments are given",
        [1,2,3,4] min should == 1
        set(5,6,7,153,1) min should == 1
        ["a","b","c"] min should == "a"
      )

      it("should accept a message chain, and use that to create the comparison criteria",
        [1,2,3,4] min(*(-1)) should == 4
        set(5,6,7,153,1) min(*(-1)) should == 153
        ["abc","bfooo","cc"] min(length) should == "cc"
      )

      it("should accept a variable name and code, and use that to create the comparison criteria",
        [1,2,3,4] min(x, 10-x) should == 4
        set(5,6,7,153,1) min(x, if(x > 100, -x, x)) should == 153
        ["abc","bfooo","cc"] min(x, x[1]) should == "abc"
      )
    )
    
    describe("join",
      describe("with no arguments",
        it("should convert an empty list to an empty string",
           [] join should == ""
          #{} join should == ""
        )
        
        it("should convert a list with one element to it's equivalent as text",
          ["tempestuous turmoil"] join should == "tempestuous turmoil"
           [1] join should == "1"
          #{1} join should == "1"
        )
        
        it("should convert a list with multiple elements to a flat string of all its elements as text",
          ["a","man","walked","into","a","bar..."]  join should == "amanwalkedintoabar..."
           [1,2,3,4,5] join should == "12345"
        )
      )
      
      describe("with one argument",
        it("should convert an empty list to an empty string",
           [] join("glue") should == ""
          #{} join("glue") should == ""
        )
        
        it("should convert a list with one element to it's equivalent as text",
          ["tempestuous turmoil"]  join("glue") should == "tempestuous turmoil"
          #{"tempestuous turmoil"} join("glue") should == "tempestuous turmoil"
           [1] join("glue") should == "1"
          #{1} join("glue") should == "1"
        )
        
        it("should convert a list with multiple elements to a flat string of all its elements as text",
          ["a","man","walked","into","a","bar..."] join(" ") should == "a man walked into a bar..."
          [1,2,3,4,5] join(", ") should == "1, 2, 3, 4, 5"
          #{1,2,3} join(" ") split(" ") sort should == ["1", "2", "3"] ;;account for sets being unordered
        )
      )
    )
  )
)
