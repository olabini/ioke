include_class('ioke.lang.Runtime') { 'IokeRuntime' } unless defined?(IokeRuntime)

$CUSTOM_ENUMERABLE_STRING = <<CODE
CustomEnumerable = Origin mimic
CustomEnumerable mimic!(Mixins Enumerable)
CustomEnumerable each = macro(
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
CODE

$CUSTOM_ENUMERABLE_STRING2 = <<CODE
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
CODE

describe "Mixins" do 
  describe "Enumerable" do 
    describe "'sort'" do 
      it "should return a sorted list based on all the entries" do  
        ioke = IokeRuntime.get_runtime
        ioke.evaluate_string(<<CODE).should == ioke.true
set(4,4,2,1,4,23,6,4,7,21) sort == [1, 2, 4, 6, 7, 21, 23]
CODE
      end
    end
    
    describe "'asList'" do 
      it "should return a list from a list" do 
        ioke = IokeRuntime.get_runtime
        ioke.evaluate_string("[1,2,3] asList == [1,2,3]").should == ioke.true
      end
      
      it "should return a list based on all things yielded to each" do 
        ioke = IokeRuntime.get_runtime
        ioke.evaluate_string(<<CODE).should == ioke.true
#$CUSTOM_ENUMERABLE_STRING
CustomEnumerable asList == ["3first", "1second", "2third"]
CODE
      end
    end
    
    describe "'map'" do 
      it "should return an empty list for an empty enumerable" do 
        ioke = IokeRuntime.get_runtime
        ioke.evaluate_string("[] map(x, x+2) == []").should == ioke.true
        ioke.evaluate_string("{} map(x, x+2) == []").should == ioke.true
        ioke.evaluate_string("set map(x, x+2) == []").should == ioke.true
      end
      
      it "should return the same list for something that only returns itself" do 
        ioke = IokeRuntime.get_runtime
        ioke.evaluate_string("[1, 2, 3] map(x, x) == [1, 2, 3]").should == ioke.true
      end

      it "should take one argument and apply the inside" do 
        ioke = IokeRuntime.get_runtime
        ioke.evaluate_string("[1, 2, 3] map(+2) == [3, 4, 5]").should == ioke.true
        ioke.evaluate_string("[1, 2, 3] map(. 1) == [1, 1, 1]").should == ioke.true
      end

      it "should take two arguments and apply the code with the argument name bound" do 
        ioke = IokeRuntime.get_runtime
        ioke.evaluate_string("[1, 2, 3] map(x, x+3) == [4, 5, 6]").should == ioke.true
        ioke.evaluate_string("[1, 2, 3] map(x, 1) == [1, 1, 1]").should == ioke.true
      end
    end

    describe "'mapFn'" do 
      it "should take zero arguments and just return the elements in a list" do 
        ioke = IokeRuntime.get_runtime
        ioke.evaluate_string("[1, 2, 3] mapFn == [1, 2, 3]").should == ioke.true
        ioke.evaluate_string(<<CODE).should == ioke.true
#$CUSTOM_ENUMERABLE_STRING
CustomEnumerable mapFn == ["3first", "1second", "2third"]
CODE
      end
      
      it "should take one lexical block argument and apply that to each element, and return the result in a list" do 
        ioke = IokeRuntime.get_runtime
        ioke.evaluate_string("x = fn(arg, arg+2). [1, 2, 3] mapFn(x) == [3, 4, 5]").should == ioke.true
        ioke.evaluate_string(<<CODE).should == ioke.true
#$CUSTOM_ENUMERABLE_STRING
x = fn(arg, arg[0..2])
CustomEnumerable mapFn(x) == ["3fi", "1se", "2th"]
CODE
      end

      it "should take several lexical blocks and chain them together" do 
        ioke = IokeRuntime.get_runtime
        ioke.evaluate_string("x = fn(arg, arg+2). x2 = fn(arg, arg*2). [1, 2, 3] mapFn(x, x2) == [6, 8, 10]").should == ioke.true
        ioke.evaluate_string(<<CODE).should == ioke.true
#$CUSTOM_ENUMERABLE_STRING
x = fn(arg, arg[0..2])
x2 = fn(arg, arg + "flurg")
CustomEnumerable mapFn(x, x2) == ["3fiflurg", "1seflurg", "2thflurg"]
CODE
      end
    end
    
    describe "'collect'" do 
      it "should return an empty list for an empty enumerable" do 
        ioke = IokeRuntime.get_runtime
        ioke.evaluate_string("[] collect(x, x+2) == []").should == ioke.true
        ioke.evaluate_string("{} collect(x, x+2) == []").should == ioke.true
        ioke.evaluate_string("set collect(x, x+2) == []").should == ioke.true
      end
      
      it "should return the same list for something that only returns itself" do 
        ioke = IokeRuntime.get_runtime
        ioke.evaluate_string("[1, 2, 3] collect(x, x) == [1, 2, 3]").should == ioke.true
      end

      it "should take one argument and apply the inside" do 
        ioke = IokeRuntime.get_runtime
        ioke.evaluate_string("[1, 2, 3] collect(+2) == [3, 4, 5]").should == ioke.true
        ioke.evaluate_string("[1, 2, 3] collect(. 1) == [1, 1, 1]").should == ioke.true
      end

      it "should take two arguments and apply the code with the argument name bound" do 
        ioke = IokeRuntime.get_runtime
        ioke.evaluate_string("[1, 2, 3] collect(x, x+3) == [4, 5, 6]").should == ioke.true
        ioke.evaluate_string("[1, 2, 3] collect(x, 1) == [1, 1, 1]").should == ioke.true
      end
    end

    describe "'collectFn'" do 
      it "should take zero arguments and just return the elements in a list" do 
        ioke = IokeRuntime.get_runtime
        ioke.evaluate_string("[1, 2, 3] collectFn == [1, 2, 3]").should == ioke.true
        ioke.evaluate_string(<<CODE).should == ioke.true
#$CUSTOM_ENUMERABLE_STRING
CustomEnumerable collectFn == ["3first", "1second", "2third"]
CODE
      end
      
      it "should take one lexical block argument and apply that to each element, and return the result in a list" do 
        ioke = IokeRuntime.get_runtime
        ioke.evaluate_string("x = fn(arg, arg+2). [1, 2, 3] collectFn(x) == [3, 4, 5]").should == ioke.true
        ioke.evaluate_string(<<CODE).should == ioke.true
#$CUSTOM_ENUMERABLE_STRING
x = fn(arg, arg[0..2])
CustomEnumerable collectFn(x) == ["3fi", "1se", "2th"]
CODE
      end

      it "should take several lexical blocks and chain them together" do 
        ioke = IokeRuntime.get_runtime
        ioke.evaluate_string("x = fn(arg, arg+2). x2 = fn(arg, arg*2). [1, 2, 3] collectFn(x, x2) == [6, 8, 10]").should == ioke.true
        ioke.evaluate_string(<<CODE).should == ioke.true
#$CUSTOM_ENUMERABLE_STRING
x = fn(arg, arg[0..2])
x2 = fn(arg, arg + "flurg")
CustomEnumerable collectFn(x, x2) == ["3fiflurg", "1seflurg", "2thflurg"]
CODE
      end
    end
    
    describe "'any?'" do 
      it "should take zero arguments and just check if any of the values are true" do 
        ioke = IokeRuntime.get_runtime
        ioke.evaluate_string("[1,2,3] any?").should == ioke.true
        ioke.evaluate_string("[nil,false,nil] any?").should == ioke.false
        ioke.evaluate_string("[nil,false,true] any?").should == ioke.true
        ioke.evaluate_string(<<CODE).should == ioke.true
#$CUSTOM_ENUMERABLE_STRING
CustomEnumerable any?
CODE
      end

      it "should take one argument that is a predicate that is applied to each element in the enumeration" do 
        ioke = IokeRuntime.get_runtime
        ioke.evaluate_string("[1,2,3] any?(==2)").should == ioke.true
        ioke.evaluate_string("[nil,false,nil] any?(nil?)").should == ioke.true
        ioke.evaluate_string("[nil,false,true] any?(==2)").should == ioke.false
        ioke.evaluate_string(<<CODE).should == ioke.true
#$CUSTOM_ENUMERABLE_STRING
CustomEnumerable any?(!= "foo")
CODE
      end

      it "should take two arguments that will be turned into a lexical block and applied" do 
        ioke = IokeRuntime.get_runtime
        ioke.evaluate_string("[1,2,3] any?(x, x==2)").should == ioke.true
        ioke.evaluate_string("[nil,false,nil] any?(x, x nil?)").should == ioke.true
        ioke.evaluate_string("[nil,false,true] any?(x, x==2)").should == ioke.false
        ioke.evaluate_string(<<CODE).should == ioke.true
#$CUSTOM_ENUMERABLE_STRING
CustomEnumerable any?(x, x != "foo")
CODE
      end
    end

    describe "'none?'" do 
      it "should take zero arguments and just check if any of the values are true, and then return false" do 
        ioke = IokeRuntime.get_runtime
        ioke.evaluate_string("[1,2,3] none?").should == ioke.false
        ioke.evaluate_string("[nil,false,nil] none?").should == ioke.true
        ioke.evaluate_string("[nil,false,true] none?").should == ioke.false
        ioke.evaluate_string(<<CODE).should == ioke.false
#$CUSTOM_ENUMERABLE_STRING
CustomEnumerable none?
CODE
      end

      it "should take one argument that is a predicate that is applied to each element in the enumeration" do 
        ioke = IokeRuntime.get_runtime
        ioke.evaluate_string("[1,2,3] none?(==2)").should == ioke.false
        ioke.evaluate_string("[nil,false,nil] none?(nil?)").should == ioke.false
        ioke.evaluate_string("[nil,false,true] none?(==2)").should == ioke.true
        ioke.evaluate_string(<<CODE).should == ioke.false
#$CUSTOM_ENUMERABLE_STRING
CustomEnumerable none?(!= "foo")
CODE
      end

      it "should take two arguments that will be turned into a lexical block and applied" do 
        ioke = IokeRuntime.get_runtime
        ioke.evaluate_string("[1,2,3] none?(x, x==2)").should == ioke.false
        ioke.evaluate_string("[nil,false,nil] none?(x, x nil?)").should == ioke.false
        ioke.evaluate_string("[nil,false,true] none?(x, x==2)").should == ioke.true
        ioke.evaluate_string(<<CODE).should == ioke.false
#$CUSTOM_ENUMERABLE_STRING
CustomEnumerable none?(x, x != "foo")
CODE
      end
    end

    describe "'some'" do 
      it "should take zero arguments and just check if any of the values are true, and then return it" do 
        ioke = IokeRuntime.get_runtime
        ioke.evaluate_string("[1,2,3] some == 1").should == ioke.true
        ioke.evaluate_string("[nil,false,nil] some").should == ioke.false
        ioke.evaluate_string("[nil,false,true] some == true").should == ioke.true
        ioke.evaluate_string(<<CODE).should == ioke.true
#$CUSTOM_ENUMERABLE_STRING
CustomEnumerable some == "3first"
CODE
      end

      it "should take one argument that is a predicate that is applied to each element in the enumeration" do 
        ioke = IokeRuntime.get_runtime
        ioke.evaluate_string("[1,2,3] some(==2 && 3) == 3").should == ioke.true
        ioke.evaluate_string("[nil,false,nil] some(nil? && 42) == 42").should == ioke.true
        ioke.evaluate_string("[nil,false,true] some(==2 && 3)").should == ioke.false
        ioke.evaluate_string(<<CODE).should == ioke.true
#$CUSTOM_ENUMERABLE_STRING
CustomEnumerable some(!= "foo" && "blarg") == "blarg"
CODE
      end

      it "should take two arguments that will be turned into a lexical block and applied" do 
        ioke = IokeRuntime.get_runtime
        ioke.evaluate_string("[1,2,3] some(x, x==2 && 3) == 3").should == ioke.true
        ioke.evaluate_string("[nil,false,nil] some(x, x nil? && 42) == 42").should == ioke.true
        ioke.evaluate_string("[nil,false,true] some(x, x==2 && 3)").should == ioke.false
        ioke.evaluate_string(<<CODE).should == ioke.true
#$CUSTOM_ENUMERABLE_STRING
CustomEnumerable some(x, x != "foo" && "blarg") == "blarg"
CODE
      end
    end

    describe "'find'" do 
      it "should take zero arguments and just check if any of the values are true, and then return it" do 
        ioke = IokeRuntime.get_runtime
        ioke.evaluate_string("[1,2,3] find == 1").should == ioke.true
        ioke.evaluate_string("[nil,false,nil] find").should == ioke.nil
        ioke.evaluate_string("[nil,false,true] find == true").should == ioke.true
        ioke.evaluate_string(<<CODE).should == ioke.true
#$CUSTOM_ENUMERABLE_STRING
CustomEnumerable find == "3first"
CODE
      end

      it "should take one argument that is a predicate that is applied to each element in the enumeration" do 
        ioke = IokeRuntime.get_runtime
        ioke.evaluate_string("[1,2,3] find(==2) == 2").should == ioke.true
        ioke.evaluate_string("[nil,false,nil] find(nil?) == nil").should == ioke.true
        ioke.evaluate_string("[nil,false,true] find(==2)").should == ioke.nil
        ioke.evaluate_string(<<CODE).should == ioke.true
#$CUSTOM_ENUMERABLE_STRING
CustomEnumerable find(!= "foo") == "3first"
CODE
      end

      it "should take two arguments that will be turned into a lexical block and applied" do 
        ioke = IokeRuntime.get_runtime
        ioke.evaluate_string("[1,2,3] find(x, x==2) == 2").should == ioke.true
        ioke.evaluate_string("[nil,false,nil] find(x, x nil?) == nil").should == ioke.true
        ioke.evaluate_string("[nil,false,true] find(x, x==2)").should == ioke.nil
        ioke.evaluate_string(<<CODE).should == ioke.true
#$CUSTOM_ENUMERABLE_STRING
CustomEnumerable find(x, x != "foo") == "3first"
CODE
      end
    end

    describe "'detect'" do 
      it "should take zero arguments and just check if any of the values are true, and then return it" do 
        ioke = IokeRuntime.get_runtime
        ioke.evaluate_string("[1,2,3] detect == 1").should == ioke.true
        ioke.evaluate_string("[nil,false,nil] detect").should == ioke.nil
        ioke.evaluate_string("[nil,false,true] detect == true").should == ioke.true
        ioke.evaluate_string(<<CODE).should == ioke.true
#$CUSTOM_ENUMERABLE_STRING
CustomEnumerable detect == "3first"
CODE
      end

      it "should take one argument that is a predicate that is applied to each element in the enumeration" do 
        ioke = IokeRuntime.get_runtime
        ioke.evaluate_string("[1,2,3] detect(==2) == 2").should == ioke.true
        ioke.evaluate_string("[nil,false,nil] detect(nil?) == nil").should == ioke.true
        ioke.evaluate_string("[nil,false,true] detect(==2)").should == ioke.nil
        ioke.evaluate_string(<<CODE).should == ioke.true
#$CUSTOM_ENUMERABLE_STRING
CustomEnumerable detect(!= "foo") == "3first"
CODE
      end

      it "should take two arguments that will be turned into a lexical block and applied" do 
        ioke = IokeRuntime.get_runtime
        ioke.evaluate_string("[1,2,3] detect(x, x==2) == 2").should == ioke.true
        ioke.evaluate_string("[nil,false,nil] detect(x, x nil?) == nil").should == ioke.true
        ioke.evaluate_string("[nil,false,true] detect(x, x==2)").should == ioke.nil
        ioke.evaluate_string(<<CODE).should == ioke.true
#$CUSTOM_ENUMERABLE_STRING
CustomEnumerable detect(x, x != "foo") == "3first"
CODE
      end
    end

    describe "'filter'" do 
      it "should take zero arguments and just check if any of the values are true, and then return it" do 
        ioke = IokeRuntime.get_runtime
        ioke.evaluate_string("[1,2,3] filter == 1").should == ioke.true
        ioke.evaluate_string("[nil,false,nil] filter").should == ioke.nil
        ioke.evaluate_string("[nil,false,true] filter == true").should == ioke.true
        ioke.evaluate_string(<<CODE).should == ioke.true
#$CUSTOM_ENUMERABLE_STRING
CustomEnumerable filter == "3first"
CODE
      end

      it "should take one argument that is a predicate that is applied to each element in the enumeration" do 
        ioke = IokeRuntime.get_runtime
        ioke.evaluate_string("[1,2,3] filter(==2) == 2").should == ioke.true
        ioke.evaluate_string("[nil,false,nil] filter(nil?) == nil").should == ioke.true
        ioke.evaluate_string("[nil,false,true] filter(==2)").should == ioke.nil
        ioke.evaluate_string(<<CODE).should == ioke.true
#$CUSTOM_ENUMERABLE_STRING
CustomEnumerable filter(!= "foo") == "3first"
CODE
      end

      it "should take two arguments that will be turned into a lexical block and applied" do 
        ioke = IokeRuntime.get_runtime
        ioke.evaluate_string("[1,2,3] filter(x, x==2) == 2").should == ioke.true
        ioke.evaluate_string("[nil,false,nil] filter(x, x nil?) == nil").should == ioke.true
        ioke.evaluate_string("[nil,false,true] filter(x, x==2)").should == ioke.nil
        ioke.evaluate_string(<<CODE).should == ioke.true
#$CUSTOM_ENUMERABLE_STRING
CustomEnumerable filter(x, x != "foo") == "3first"
CODE
      end
    end
    
    describe "'inject'" do
      # inject needs: a start value, an argument name, a sum argument name, and code
      # versions:
      
      # inject(+)                                  => inject(    sum,    x,    sum    +(x))
      # inject(x, + x)                             => inject(    sumArg, x,    sumArg +(x))
      # inject(sumArg, xArg, sumArg + xArg)        => inject(    sumArg, xArg, sumArg + xArg)
      # inject("", sumArg, xArg, sumArg + xArg)    => inject("", sumArg, xArg, sumArg +(xArg))

      it "should take one argument that is a message chain and apply that on the sum, with the current arg as argument" do 
        ioke = IokeRuntime.get_runtime
        ioke.evaluate_string("[1,2,3] inject(+) == 6").should == ioke.true
        ioke.evaluate_string("[1,2,3] inject(*(5) -) == 12").should == ioke.true
        ioke.evaluate_string(<<CODE).should == ioke.true
#$CUSTOM_ENUMERABLE_STRING2
CustomEnumerable2 inject(-) == 9
CODE
      end

      it "should take two arguments that is an argument name and a message chain and apply that on the sum" do 
        ioke = IokeRuntime.get_runtime
        ioke.evaluate_string("[1,2,3] inject(x, + x*2) == 11").should == ioke.true
        ioke.evaluate_string("[1,2,3] inject(x, *(5) - x) == 12").should == ioke.true
        ioke.evaluate_string(<<CODE).should == ioke.true
#$CUSTOM_ENUMERABLE_STRING2
CustomEnumerable2 inject(x, - x) == 9
CODE
      end

      it "should take three arguments that is the sum name, the argument name and code to apply" do 
        ioke = IokeRuntime.get_runtime
        ioke.evaluate_string("[1,2,3] inject(sum, x, sum + x*2) == 11").should == ioke.true
        ioke.evaluate_string("[1,2,3] inject(sum, x, sum *(5) - x) == 12").should == ioke.true
        ioke.evaluate_string(<<CODE).should == ioke.true
#$CUSTOM_ENUMERABLE_STRING2
CustomEnumerable2 inject(sum, x, sum - x) == 9
CODE
      end

      it "should take four arguments that is the initial value, the sum name, the argument name and code to apply" do 
        ioke = IokeRuntime.get_runtime
        ioke.evaluate_string("[1,2,3] inject(13, sum, x, sum + x*2) == 25").should == ioke.true
        ioke.evaluate_string("[1,2,3] inject(1, sum, x, sum *(5) - x) == 87").should == ioke.true
        ioke.evaluate_string(<<CODE).should == ioke.true
#$CUSTOM_ENUMERABLE_STRING2
CustomEnumerable2 inject(100, sum, x, sum - x) == 25
CODE
      end
    end    

    describe "'reduce'" do
      # reduce needs: a start value, an argument name, a sum argument name, and code
      # versions:
      
      # reduce(+)                                  => reduce(    sum,    x,    sum    +(x))
      # reduce(x, + x)                             => reduce(    sumArg, x,    sumArg +(x))
      # reduce(sumArg, xArg, sumArg + xArg)        => reduce(    sumArg, xArg, sumArg + xArg)
      # reduce("", sumArg, xArg, sumArg + xArg)    => reduce("", sumArg, xArg, sumArg +(xArg))

      it "should take one argument that is a message chain and apply that on the sum, with the current arg as argument" do 
        ioke = IokeRuntime.get_runtime
        ioke.evaluate_string("[1,2,3] reduce(+) == 6").should == ioke.true
        ioke.evaluate_string("[1,2,3] reduce(*(5) -) == 12").should == ioke.true
        ioke.evaluate_string(<<CODE).should == ioke.true
#$CUSTOM_ENUMERABLE_STRING2
CustomEnumerable2 reduce(-) == 9
CODE
      end

      it "should take two arguments that is an argument name and a message chain and apply that on the sum" do 
        ioke = IokeRuntime.get_runtime
        ioke.evaluate_string("[1,2,3] reduce(x, + x*2) == 11").should == ioke.true
        ioke.evaluate_string("[1,2,3] reduce(x, *(5) - x) == 12").should == ioke.true
        ioke.evaluate_string(<<CODE).should == ioke.true
#$CUSTOM_ENUMERABLE_STRING2
CustomEnumerable2 reduce(x, - x) == 9
CODE
      end

      it "should take three arguments that is the sum name, the argument name and code to apply" do 
        ioke = IokeRuntime.get_runtime
        ioke.evaluate_string("[1,2,3] reduce(sum, x, sum + x*2) == 11").should == ioke.true
        ioke.evaluate_string("[1,2,3] reduce(sum, x, sum *(5) - x) == 12").should == ioke.true
        ioke.evaluate_string(<<CODE).should == ioke.true
#$CUSTOM_ENUMERABLE_STRING2
CustomEnumerable2 reduce(sum, x, sum - x) == 9
CODE
      end

      it "should take four arguments that is the initial value, the sum name, the argument name and code to apply" do 
        ioke = IokeRuntime.get_runtime
        ioke.evaluate_string("[1,2,3] reduce(13, sum, x, sum + x*2) == 25").should == ioke.true
        ioke.evaluate_string("[1,2,3] reduce(1, sum, x, sum *(5) - x) == 87").should == ioke.true
        ioke.evaluate_string(<<CODE).should == ioke.true
#$CUSTOM_ENUMERABLE_STRING2
CustomEnumerable2 reduce(100, sum, x, sum - x) == 25
CODE
      end
    end    

    describe "'fold'" do
      # fold needs: a start value, an argument name, a sum argument name, and code
      # versions:
      
      # fold(+)                                  => fold(    sum,    x,    sum    +(x))
      # fold(x, + x)                             => fold(    sumArg, x,    sumArg +(x))
      # fold(sumArg, xArg, sumArg + xArg)        => fold(    sumArg, xArg, sumArg + xArg)
      # fold("", sumArg, xArg, sumArg + xArg)    => fold("", sumArg, xArg, sumArg +(xArg))

      it "should take one argument that is a message chain and apply that on the sum, with the current arg as argument" do 
        ioke = IokeRuntime.get_runtime
        ioke.evaluate_string("[1,2,3] fold(+) == 6").should == ioke.true
        ioke.evaluate_string("[1,2,3] fold(*(5) -) == 12").should == ioke.true
        ioke.evaluate_string(<<CODE).should == ioke.true
#$CUSTOM_ENUMERABLE_STRING2
CustomEnumerable2 fold(-) == 9
CODE
      end

      it "should take two arguments that is an argument name and a message chain and apply that on the sum" do 
        ioke = IokeRuntime.get_runtime
        ioke.evaluate_string("[1,2,3] fold(x, + x*2) == 11").should == ioke.true
        ioke.evaluate_string("[1,2,3] fold(x, *(5) - x) == 12").should == ioke.true
        ioke.evaluate_string(<<CODE).should == ioke.true
#$CUSTOM_ENUMERABLE_STRING2
CustomEnumerable2 fold(x, - x) == 9
CODE
      end

      it "should take three arguments that is the sum name, the argument name and code to apply" do 
        ioke = IokeRuntime.get_runtime
        ioke.evaluate_string("[1,2,3] fold(sum, x, sum + x*2) == 11").should == ioke.true
        ioke.evaluate_string("[1,2,3] fold(sum, x, sum *(5) - x) == 12").should == ioke.true
        ioke.evaluate_string(<<CODE).should == ioke.true
#$CUSTOM_ENUMERABLE_STRING2
CustomEnumerable2 fold(sum, x, sum - x) == 9
CODE
      end

      it "should take four arguments that is the initial value, the sum name, the argument name and code to apply" do 
        ioke = IokeRuntime.get_runtime
        ioke.evaluate_string("[1,2,3] fold(13, sum, x, sum + x*2) == 25").should == ioke.true
        ioke.evaluate_string("[1,2,3] fold(1, sum, x, sum *(5) - x) == 87").should == ioke.true
        ioke.evaluate_string(<<CODE).should == ioke.true
#$CUSTOM_ENUMERABLE_STRING2
CustomEnumerable2 fold(100, sum, x, sum - x) == 25
CODE
      end
    end
    
    describe "'flatMap'" do 
      it "should return a correct flattened map" do 
        ioke = IokeRuntime.get_runtime
        ioke.evaluate_string("[1,2,3] flatMap(x, [x]) == [1,2,3]").should == ioke.true
        ioke.evaluate_string("[1,2,3] flatMap(x, [x, x+10, x+20]) == [1,11,21,2,12,22,3,13,23]").should == ioke.true
        ioke.evaluate_string("[4,5,6] flatMap(x, [x+20, x+10, x]) == [24,14,4,25,15,5,26,16,6]").should == ioke.true
      end
    end
    
    describe "'select'" do 
      it "should take zero arguments and return a list with only the true values" do 
        ioke = IokeRuntime.get_runtime
        ioke.evaluate_string("[1,2,3] select == [1,2,3]").should == ioke.true
        ioke.evaluate_string("[nil,false,nil] select == []").should == ioke.true
        ioke.evaluate_string("[nil,false,true] select == [true]").should == ioke.true
        ioke.evaluate_string(<<CODE).should == ioke.true
#$CUSTOM_ENUMERABLE_STRING
CustomEnumerable select == CustomEnumerable asList
CODE
      end

      it "should take one argument that ends up being a predicate and return a list of the values that is true" do 
        ioke = IokeRuntime.get_runtime
        ioke.evaluate_string("[1,2,3] select(>1) == [2,3]").should == ioke.true
        ioke.evaluate_string("[nil,false,nil] select(nil?) == [nil, nil]").should == ioke.true
        ioke.evaluate_string("[nil,false,true] select(==2) == []").should == ioke.true
        ioke.evaluate_string(<<CODE).should == ioke.true
#$CUSTOM_ENUMERABLE_STRING
CustomEnumerable select([0...1] != "1") == ["3first", "2third"]
CODE
      end

      it "should take two arguments that ends up being a predicate and return a list of the values that is true" do 
        ioke = IokeRuntime.get_runtime
        ioke.evaluate_string("[1,2,3] select(x, x>1) == [2,3]").should == ioke.true
        ioke.evaluate_string("[nil,false,nil] select(x, x nil?) == [nil, nil]").should == ioke.true
        ioke.evaluate_string("[nil,false,true] select(x, x==2) == []").should == ioke.true
        ioke.evaluate_string(<<CODE).should == ioke.true
#$CUSTOM_ENUMERABLE_STRING
CustomEnumerable select(x, x != "2third") == ["3first", "1second"]
CODE
      end
    end

    describe "'findAll'" do 
      it "should take zero arguments and return a list with only the true values" do 
        ioke = IokeRuntime.get_runtime
        ioke.evaluate_string("[1,2,3] findAll == [1,2,3]").should == ioke.true
        ioke.evaluate_string("[nil,false,nil] findAll == []").should == ioke.true
        ioke.evaluate_string("[nil,false,true] findAll == [true]").should == ioke.true
        ioke.evaluate_string(<<CODE).should == ioke.true
#$CUSTOM_ENUMERABLE_STRING
CustomEnumerable findAll == CustomEnumerable asList
CODE
      end

      it "should take one argument that ends up being a predicate and return a list of the values that is true" do 
        ioke = IokeRuntime.get_runtime
        ioke.evaluate_string("[1,2,3] findAll(>1) == [2,3]").should == ioke.true
        ioke.evaluate_string("[nil,false,nil] findAll(nil?) == [nil, nil]").should == ioke.true
        ioke.evaluate_string("[nil,false,true] findAll(==2) == []").should == ioke.true
        ioke.evaluate_string(<<CODE).should == ioke.true
#$CUSTOM_ENUMERABLE_STRING
CustomEnumerable findAll([0...1] != "1") == ["3first", "2third"]
CODE
      end

      it "should take two arguments that ends up being a predicate and return a list of the values that is true" do 
        ioke = IokeRuntime.get_runtime
        ioke.evaluate_string("[1,2,3] findAll(x, x>1) == [2,3]").should == ioke.true
        ioke.evaluate_string("[nil,false,nil] findAll(x, x nil?) == [nil, nil]").should == ioke.true
        ioke.evaluate_string("[nil,false,true] findAll(x, x==2) == []").should == ioke.true
        ioke.evaluate_string(<<CODE).should == ioke.true
#$CUSTOM_ENUMERABLE_STRING
CustomEnumerable findAll(x, x != "2third") == ["3first", "1second"]
CODE
      end
    end

    describe "'all?'" do 
      it "should take zero arguments and just check if all of the values are true" do 
        ioke = IokeRuntime.get_runtime
        ioke.evaluate_string("[1,2,3] all?").should == ioke.true
        ioke.evaluate_string("[nil,false,nil] all?").should == ioke.false
        ioke.evaluate_string("[nil,false,true] all? == false").should == ioke.true
        ioke.evaluate_string(<<CODE).should == ioke.true
#$CUSTOM_ENUMERABLE_STRING
CustomEnumerable all?
CODE
      end

      it "should take one argument that is a predicate that is applied to each element in the enumeration" do 
        ioke = IokeRuntime.get_runtime
        ioke.evaluate_string("[1,2,3] all?(==2)").should == ioke.false
        ioke.evaluate_string("[1,2,3] all?(>0)").should == ioke.true
        ioke.evaluate_string("[nil,false,nil] all?(nil?)").should == ioke.false
        ioke.evaluate_string("[nil,false,true] all?(==2)").should == ioke.false
        ioke.evaluate_string(<<CODE).should == ioke.true
#$CUSTOM_ENUMERABLE_STRING
CustomEnumerable all?(!= "foo")
CODE
      end

      it "should take two arguments that will be turned into a lexical block and applied" do 
        ioke = IokeRuntime.get_runtime
        ioke.evaluate_string("[1,2,3] all?(x, x==2)").should == ioke.false
        ioke.evaluate_string("[1,2,3] all?(x, x<4)").should == ioke.true
        ioke.evaluate_string("[nil,false,nil] all?(x, x nil?)").should == ioke.false
        ioke.evaluate_string("[nil,nil,nil] all?(x, x nil?)").should == ioke.true
        ioke.evaluate_string("[nil,false,true] all?(x, x==2)").should == ioke.false
        ioke.evaluate_string(<<CODE).should == ioke.true
#$CUSTOM_ENUMERABLE_STRING
CustomEnumerable all?(x, x != "foo")
CODE
      end
    end
    
    describe "'count'" do 
      it "should take zero arguments and return how many elements there are" do 
        ioke = IokeRuntime.get_runtime
        ioke.evaluate_string("[1,2,3] count == 3").should == ioke.true
        ioke.evaluate_string("[nil,false] count == 2").should == ioke.true
        ioke.evaluate_string("[nil,false,true] count == 3").should == ioke.true
        ioke.evaluate_string(<<CODE).should == ioke.true
#$CUSTOM_ENUMERABLE_STRING
CustomEnumerable count == 3
CODE
      end

      it "should take one element that is a predicate, and return how many matches it" do 
        ioke = IokeRuntime.get_runtime
        ioke.evaluate_string("[1,2,3] count(>1) == 2").should == ioke.true
        ioke.evaluate_string("[nil,false,nil] count(nil?) == 2").should == ioke.true
        ioke.evaluate_string("[nil,false,true] count(==2) == 0").should == ioke.true
        ioke.evaluate_string(<<CODE).should == ioke.true
#$CUSTOM_ENUMERABLE_STRING
CustomEnumerable count([0...1] != "1") == 2
CODE
      end

      it "should take two elements that turn into a lexical block and returns how many matches it" do 
        ioke = IokeRuntime.get_runtime
        ioke.evaluate_string("[1,2,3] count(x, x>1) == 2").should == ioke.true
        ioke.evaluate_string("[nil,false,nil] count(x, x nil?) == 2").should == ioke.true
        ioke.evaluate_string("[nil,false,true] count(x, x==2) == 0").should == ioke.true
        ioke.evaluate_string(<<CODE).should == ioke.true
#$CUSTOM_ENUMERABLE_STRING
CustomEnumerable count(x, x != "2third") == 2
CODE
      end
    end

    describe "'reject'" do 
      it "should take one argument that ends up being a predicate and return a list of the values that is false" do 
        ioke = IokeRuntime.get_runtime
        ioke.evaluate_string("[1,2,3] reject(>1) == [1]").should == ioke.true
        ioke.evaluate_string("[nil,false,nil] reject(nil?) == [false]").should == ioke.true
        ioke.evaluate_string("[nil,false,true] reject(==2) == [nil,false,true]").should == ioke.true
        ioke.evaluate_string(<<CODE).should == ioke.true
#$CUSTOM_ENUMERABLE_STRING
CustomEnumerable reject([0...1] == "1") == ["3first", "2third"]
CODE
      end

      it "should take two arguments that ends up being a predicate and return a list of the values that is false" do 
        ioke = IokeRuntime.get_runtime
        ioke.evaluate_string("[1,2,3] reject(x, x>1) == [1]").should == ioke.true
        ioke.evaluate_string("[nil,false,nil] reject(x, x nil?) == [false]").should == ioke.true
        ioke.evaluate_string("[nil,false,true] reject(x, x==2) == [nil,false,true]").should == ioke.true
        ioke.evaluate_string(<<CODE).should == ioke.true
#$CUSTOM_ENUMERABLE_STRING
CustomEnumerable reject(x, x == "2third") == ["3first", "1second"]
CODE
      end
    end
    
    describe "'first'" do 
      it "should return nil for an empty collection" do 
        ioke = IokeRuntime.get_runtime
        ioke.evaluate_string("set first == nil").should == ioke.true
      end

      it "should take an optional argument of how many to return" do 
        ioke = IokeRuntime.get_runtime
        ioke.evaluate_string("set first(0) == []").should == ioke.true
        ioke.evaluate_string("set first(1) == [nil]").should == ioke.true
        ioke.evaluate_string("set first(2) == [nil, nil]").should == ioke.true
      end
      
      it "should return the first element for a non-empty collection" do 
        ioke = IokeRuntime.get_runtime
        ioke.evaluate_string("set(42) first == 42").should == ioke.true
        ioke.evaluate_string(<<CODE).should == ioke.true
#$CUSTOM_ENUMERABLE_STRING
CustomEnumerable first == "3first"
CODE
      end
      
      it "should return the first n elements for a non-empty collection" do 
        ioke = IokeRuntime.get_runtime
        ioke.evaluate_string("set(42) first(0) == []").should == ioke.true
        ioke.evaluate_string("set(42) first(1) == [42]").should == ioke.true
        ioke.evaluate_string("set(42) first(2) == [42, nil]").should == ioke.true
        ioke.evaluate_string("set(42, 44, 46) first(2) == [42, 44] sort").should == ioke.true
        ioke.evaluate_string("set(42, 44, 46) first(3) == [42, 44, 46] sort").should == ioke.true
        ioke.evaluate_string(<<CODE).should == ioke.true
#$CUSTOM_ENUMERABLE_STRING
CustomEnumerable first(2) == ["3first", "1second"]
CODE
      end
    end

    describe "'one?'" do 
      it "should take zero arguments and just check if exactly one of the values are true, and then return true" do 
        ioke = IokeRuntime.get_runtime
        ioke.evaluate_string("[1,2,3] one?").should == ioke.false
        ioke.evaluate_string("[nil,false,nil] one?").should == ioke.false
        ioke.evaluate_string("[nil,false,true] one?").should == ioke.true
        ioke.evaluate_string(<<CODE).should == ioke.false
#$CUSTOM_ENUMERABLE_STRING
CustomEnumerable one?
CODE
      end

      it "should take one argument that is a predicate that is applied to each element in the enumeration" do 
        ioke = IokeRuntime.get_runtime
        ioke.evaluate_string("[1,2,3] one?(==2)").should == ioke.true
        ioke.evaluate_string("[nil,false,nil] one?(nil?)").should == ioke.false
        ioke.evaluate_string("[nil,false,true] one?(==2)").should == ioke.false
        ioke.evaluate_string(<<CODE).should == ioke.true
#$CUSTOM_ENUMERABLE_STRING
CustomEnumerable one?(== "3first")
CODE
      end

      it "should take two arguments that will be turned into a lexical block and applied" do 
        ioke = IokeRuntime.get_runtime
        ioke.evaluate_string("[1,2,3] one?(x, x==2)").should == ioke.true
        ioke.evaluate_string("[nil,false,nil] one?(x, x nil?)").should == ioke.false
        ioke.evaluate_string("[nil,false,true] one?(x, x==2)").should == ioke.false
        ioke.evaluate_string(<<CODE).should == ioke.true
#$CUSTOM_ENUMERABLE_STRING
CustomEnumerable one?(x, x == "3first")
CODE
      end
    end
    
    describe "findIndex" do 
      it "should take zero arguments and just check if any of the values are true, and then return the index of it" do 
        ioke = IokeRuntime.get_runtime
        ioke.evaluate_string("[1,2,3] findIndex == 0").should == ioke.true
        ioke.evaluate_string("[nil,false,nil] findIndex").should == ioke.nil
        ioke.evaluate_string("[nil,false,true] findIndex == 2").should == ioke.true
        ioke.evaluate_string(<<CODE).should == ioke.true
#$CUSTOM_ENUMERABLE_STRING
CustomEnumerable findIndex == 0
CODE
      end

      it "should take one argument that is a predicate that is applied to each element in the enumeration" do 
        ioke = IokeRuntime.get_runtime
        ioke.evaluate_string("[1,2,3] findIndex(==2) == 1").should == ioke.true
        ioke.evaluate_string("[nil,false,nil] findIndex(nil?) == 0").should == ioke.true
        ioke.evaluate_string("[nil,false,true] findIndex(==2)").should == ioke.nil
        ioke.evaluate_string(<<CODE).should == ioke.true
#$CUSTOM_ENUMERABLE_STRING
CustomEnumerable findIndex(!= "foo") == 0
CODE
      end

      it "should take two arguments that will be turned into a lexical block and applied" do 
        ioke = IokeRuntime.get_runtime
        ioke.evaluate_string("[1,2,3] findIndex(x, x==2) == 1").should == ioke.true
        ioke.evaluate_string("[nil,false,nil] findIndex(x, x nil?) == 0").should == ioke.true
        ioke.evaluate_string("[nil,false,true] findIndex(x, x==2)").should == ioke.nil
        ioke.evaluate_string(<<CODE).should == ioke.true
#$CUSTOM_ENUMERABLE_STRING
CustomEnumerable findIndex(x, x != "foo") == 0
CODE
      end
    end

    describe "partition" do 
      it "should take zero arguments and just divide all the true and false values" do 
        ioke = IokeRuntime.get_runtime
        ioke.evaluate_string("[1,2,3] partition == [[1,2,3],[]]").should == ioke.true
        ioke.evaluate_string("[nil,false,nil] partition == [[], [nil, false, nil]]").should == ioke.true
        ioke.evaluate_string("[nil,false,true] partition == [[true], [nil, false]]").should == ioke.true
        ioke.evaluate_string(<<CODE).should == ioke.true
#$CUSTOM_ENUMERABLE_STRING
CustomEnumerable partition == [["3first", "1second", "2third"], []]
CODE
      end

      it "should take one argument that is a predicate that is applied to each element in the enumeration" do 
        ioke = IokeRuntime.get_runtime
        ioke.evaluate_string("[1,2,3] partition(==2) == [[2], [1,3]]").should == ioke.true
        ioke.evaluate_string("[nil,false,nil] partition(nil?) == [[nil,nil], [false]]").should == ioke.true
        ioke.evaluate_string("[nil,false,true] partition(==2) == [[true], [nil, false]]").should == ioke.true
        ioke.evaluate_string(<<CODE).should == ioke.true
#$CUSTOM_ENUMERABLE_STRING
CustomEnumerable partition(!= "foo") == [["3first", "1second", "2third"], []]
CODE
      end

      it "should take two arguments that will be turned into a lexical block and applied" do 
        ioke = IokeRuntime.get_runtime
        ioke.evaluate_string("[1,2,3] partition(x, x==2) == [[2], [1,3]]").should == ioke.true
        ioke.evaluate_string("[nil,false,nil] partition(x, x nil?) == [[nil,nil], [false]]").should == ioke.true
        ioke.evaluate_string("[nil,false,true] partition(x, x==2) == [[true], [nil, false]]").should == ioke.true
        ioke.evaluate_string(<<CODE).should == ioke.true
#$CUSTOM_ENUMERABLE_STRING
CustomEnumerable partition(x, x != "foo") == [["3first", "1second", "2third"], []]
CODE
      end
    end
    
    describe "'include?'" do 
      it "should return true if the element is in the enumeration" do 
        ioke = IokeRuntime.get_runtime
        ioke.evaluate_string("[1,2,3] include?(2)").should == ioke.true
        ioke.evaluate_string(<<CODE).should == ioke.true
#$CUSTOM_ENUMERABLE_STRING
CustomEnumerable include?("1second")
CODE
      end

      it "should return false if the element is not in the enumeration" do 
        ioke = IokeRuntime.get_runtime
        ioke.evaluate_string("[1,2,3] include?(0)").should == ioke.false
        ioke.evaluate_string(<<CODE).should == ioke.false
#$CUSTOM_ENUMERABLE_STRING
CustomEnumerable include?("2second")
CODE
      end
    end

    describe "'member?'" do 
      it "should return true if the element is in the enumeration" do 
        ioke = IokeRuntime.get_runtime
        ioke.evaluate_string("[1,2,3] member?(2)").should == ioke.true
        ioke.evaluate_string(<<CODE).should == ioke.true
#$CUSTOM_ENUMERABLE_STRING
CustomEnumerable member?("1second")
CODE
      end

      it "should return false if the element is not in the enumeration" do 
        ioke = IokeRuntime.get_runtime
        ioke.evaluate_string("[1,2,3] member?(0)").should == ioke.false
        ioke.evaluate_string(<<CODE).should == ioke.false
#$CUSTOM_ENUMERABLE_STRING
CustomEnumerable member?("2second")
CODE
      end
    end
    
    describe "'take'" do 
      it "should return a list with as many elements as requested" do 
        ioke = IokeRuntime.get_runtime
        ioke.evaluate_string("[1,2,3] take(0) == []").should == ioke.true
        ioke.evaluate_string("[1,2,3] take(1) == [1]").should == ioke.true
        ioke.evaluate_string("[1,2,3] take(2) == [1,2]").should == ioke.true
        ioke.evaluate_string("[1,2,3] take(3) == [1,2,3]").should == ioke.true
        ioke.evaluate_string(<<CODE).should == ioke.true
#$CUSTOM_ENUMERABLE_STRING
CustomEnumerable take(2) == ["3first", "1second"]
CODE
      end

      it "should not take more elements than the length of the collection" do 
        ioke = IokeRuntime.get_runtime
        ioke.evaluate_string("[1,2,3] take(4) == [1,2,3]").should == ioke.true
        ioke.evaluate_string("[1,2,3] take(10) == [1,2,3]").should == ioke.true
        ioke.evaluate_string(<<CODE).should == ioke.true
#$CUSTOM_ENUMERABLE_STRING
CustomEnumerable take(200) == ["3first", "1second", "2third"]
CODE
      end
    end
    
    describe "'takeWhile'" do 
      it "should take zero arguments and return everything up until the point where a value is false" do 
        ioke = IokeRuntime.get_runtime
        ioke.evaluate_string("[1,2,3] takeWhile == [1,2,3]").should == ioke.true
        ioke.evaluate_string("[1,2,nil,false] takeWhile == [1,2]").should == ioke.true
        ioke.evaluate_string("[1,2,false,3,4,nil,false] takeWhile == [1,2]").should == ioke.true
        ioke.evaluate_string(<<CODE).should == ioke.true
#$CUSTOM_ENUMERABLE_STRING
CustomEnumerable takeWhile == ["3first", "1second", "2third"]
CODE
      end
      
      it "should take one argument and apply it as a message chain, return a list with all elements until the block returns false" do 
        ioke = IokeRuntime.get_runtime
        ioke.evaluate_string("[1,2,3] takeWhile(<3) == [1,2]").should == ioke.true
        ioke.evaluate_string("[1,2,3] takeWhile(!=2) == [1]").should == ioke.true
        ioke.evaluate_string(<<CODE).should == ioke.true
#$CUSTOM_ENUMERABLE_STRING
CustomEnumerable takeWhile(!="2third") == ["3first", "1second"]
CODE
      end

      it "should take two arguments and apply the lexical block created from it, and return a list with all elements until the block returns false" do 
        ioke = IokeRuntime.get_runtime
        ioke.evaluate_string("[1,2,3] takeWhile(x, x<3) == [1,2]").should == ioke.true
        ioke.evaluate_string("[1,2,3] takeWhile(x, x!=2) == [1]").should == ioke.true
        ioke.evaluate_string(<<CODE).should == ioke.true
#$CUSTOM_ENUMERABLE_STRING
CustomEnumerable takeWhile(x, x!="2third") == ["3first", "1second"]
CODE
      end
    end

    describe "'drop'" do 
      it "should return a list without as many elements as requested" do 
        ioke = IokeRuntime.get_runtime
        ioke.evaluate_string("[1,2,3] drop(0) == [1,2,3]").should == ioke.true
        ioke.evaluate_string("[1,2,3] drop(1) == [2,3]").should == ioke.true
        ioke.evaluate_string("[1,2,3] drop(2) == [3]").should == ioke.true
        ioke.evaluate_string("[1,2,3] drop(3) == []").should == ioke.true
        ioke.evaluate_string(<<CODE).should == ioke.true
#$CUSTOM_ENUMERABLE_STRING
CustomEnumerable drop(2) == ["2third"]
CODE
      end

      it "should not drop more elements than the length of the collection" do 
        ioke = IokeRuntime.get_runtime
        ioke.evaluate_string("[1,2,3] drop(4) == []").should == ioke.true
        ioke.evaluate_string("[1,2,3] drop(10) == []").should == ioke.true
        ioke.evaluate_string(<<CODE).should == ioke.true
#$CUSTOM_ENUMERABLE_STRING
CustomEnumerable drop(200) == []
CODE
      end
    end

    describe "'dropWhile'" do 
      it "should take zero arguments and return everything after the point where a value is true" do 
        ioke = IokeRuntime.get_runtime
        ioke.evaluate_string("[1,2,3] dropWhile == []").should == ioke.true
        ioke.evaluate_string("[1,2,nil,false] dropWhile == [nil,false]").should == ioke.true
        ioke.evaluate_string("[1,2,false,3,4,nil,false] dropWhile == [false,3,4,nil,false]").should == ioke.true
        ioke.evaluate_string(<<CODE).should == ioke.true
#$CUSTOM_ENUMERABLE_STRING
CustomEnumerable dropWhile == []
CODE
      end
      
      it "should take one argument and apply it as a message chain, return a list with all elements after the block returns false" do 
        ioke = IokeRuntime.get_runtime
        ioke.evaluate_string("[1,2,3] dropWhile(<3) == [3]").should == ioke.true
        ioke.evaluate_string("[1,2,3] dropWhile(!=2) == [2,3]").should == ioke.true
        ioke.evaluate_string(<<CODE).should == ioke.true
#$CUSTOM_ENUMERABLE_STRING
CustomEnumerable dropWhile(!="2third") == ["2third"]
CODE
      end

      it "should take two arguments and apply the lexical block created from it, and return a list with all elements after the block returns false" do 
        ioke = IokeRuntime.get_runtime
        ioke.evaluate_string("[1,2,3] dropWhile(x, x<3) == [3]").should == ioke.true
        ioke.evaluate_string("[1,2,3] dropWhile(x, x!=2) == [2,3]").should == ioke.true
        ioke.evaluate_string(<<CODE).should == ioke.true
#$CUSTOM_ENUMERABLE_STRING
CustomEnumerable dropWhile(x, x!="2third") == ["2third"]
CODE
      end
    end
    
    describe "'cycle'" do 
      it "should not do anything for an empty collection" do 
        ioke = IokeRuntime.get_runtime
        ioke.evaluate_string("x = 1. ([] cycle(_, x = 2) == nil) && (x == 1)").should == ioke.true
      end

      it "should repeat until stopped" do 
        ioke = IokeRuntime.get_runtime
        ioke.evaluate_string(<<CODE).should == ioke.true
res = []
m1 = method(
  [1,2,3] cycle(x, if(Ground res length == 10, return). Ground res << x))
m1
res == [1,2,3,1,2,3,1,2,3,1]
CODE
      end

      it "should only call each once" do 
        ioke = IokeRuntime.get_runtime
        ioke.evaluate_string(<<CODE).should == ioke.true
CustomEnumerable = Origin mimic
CustomEnumerable mimic!(Mixins Enumerable)
CustomEnumerable eachCalled = 0 
CustomEnumerable each = macro(
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
  CustomEnumerable cycle(_, if(iter == 10, return). iter++))
m
CustomEnumerable eachCalled == 1
CODE
      end

      it "should take one argument and apply it" do 
        ioke = IokeRuntime.get_runtime
        ioke.evaluate_string(<<CODE)
m1 = method(
  [1,2,3] cycle(+1. if(Ground res length == 10, return)))
m1
CODE
      end

      it "should take two arguments and turn it into a lexical block to apply" do 
        ioke = IokeRuntime.get_runtime
        ioke.evaluate_string(<<CODE).should == ioke.true
res = []
m1 = method(
  [1,2,3] cycle(x, if(Ground res length == 10, return). Ground res << x))
m1
res == [1,2,3,1,2,3,1,2,3,1]
CODE
      end
    end
    
    describe "'sortBy'" do 
      it "should take one argument and apply that for sorting" do 
        ioke = IokeRuntime.get_runtime
        ioke.evaluate_string("{a: 3, b: 2, c: 1} sortBy(value) == [:c => 1, :b => 2, :a => 3]").should == ioke.true
      end
      
      it "should take two arguments and turn that into a lexical block and use that for sorting" do 
        ioke = IokeRuntime.get_runtime
        ioke.evaluate_string("{a: 3, b: 2, c: 1} sortBy(x, x value) == [:c => 1, :b => 2, :a => 3]").should == ioke.true
      end
    end
    
    describe "'zip'" do 
      it "should take zero arguments and just zip the elements" do 
        ioke = IokeRuntime.get_runtime
        ioke.evaluate_string("[1,2,3] zip == [[1], [2], [3]]").should == ioke.true
      end

      it "should take one argument as a list and zip the elements together" do 
        ioke = IokeRuntime.get_runtime
        ioke.evaluate_string("[1,2,3] zip([5,6,7]) == [[1, 5], [2, 6], [3, 7]]").should == ioke.true
        ioke.evaluate_string("[1,2,3] zip([5,6,7,8]) == [[1, 5], [2, 6], [3, 7]]").should == ioke.true
      end

      it "should supply nils if the second list isn't long enough" do 
        ioke = IokeRuntime.get_runtime
        ioke.evaluate_string("[1,2,3] zip([5,6]) == [[1, 5], [2, 6], [3, nil]]").should == ioke.true
      end

      it "should zip together several lists" do 
        ioke = IokeRuntime.get_runtime
        ioke.evaluate_string("[1,2,3] zip([5,6,7],[10,11,12],[15,16,17]) == [[1,5,10,15], [2,6,11,16], [3,7,12,17]]").should == ioke.true
      end

      it "should take a fn as last argument and call that instead of returning a list" do 
        ioke = IokeRuntime.get_runtime
        ioke.evaluate_string("x = []. ([1,2,3] zip([5,6,7], fn(arg, x << arg)) == nil) && (x == [[1,5],[2,6],[3,7]])").should == ioke.true
      end
    end

    describe "'grep'" do 
      it "should take one argument and return everything that matches with ===" do 
        ioke = IokeRuntime.get_runtime
        ioke.evaluate_string("[1,2,3,4,5,6,7,8,9] grep(2..5) == [2,3,4,5]").should == ioke.true
        ioke.evaluate_string(<<CODE).should == ioke.true
customObj = Origin mimic
customObj === = method(other, (other < 3) || (other > 5))
[1,2,3,4,5,6,7,8,9] grep(customObj) == [1,2,6,7,8,9]
CODE
      end
      
      it "should take two arguments where the second argument is a message chain and return the result of calling that chain on everything that matches with ===" do 
        ioke = IokeRuntime.get_runtime
        ioke.evaluate_string('[1,2,3,4,5,6,7,8,9] grep(2..5, +(1) asText) == ["3","4","5","6"]').should == ioke.true
        ioke.evaluate_string(<<CODE).should == ioke.true
customObj = Origin mimic
customObj === = method(other, (other < 3) || (other > 5))
[1,2,3,4,5,6,7,8,9] grep(customObj, +(1) asText) == ["2","3","7","8","9","10"]
CODE
      end

      it "should take three arguments where the second and third arguments gets turned into a lexical block to apply to all that matches with ===" do 
        ioke = IokeRuntime.get_runtime
        ioke.evaluate_string('[1,2,3,4,5,6,7,8,9] grep(2..5, x, (x + 1) asText) == ["3","4","5","6"]').should == ioke.true
        ioke.evaluate_string(<<CODE).should == ioke.true
customObj = Origin mimic
customObj === = method(other, (other < 3) || (other > 5))
[1,2,3,4,5,6,7,8,9] grep(customObj, x, (x+1) asText) == ["2","3","7","8","9","10"]
CODE
      end
    end
  end
end
