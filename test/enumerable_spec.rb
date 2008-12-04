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
  end
end
