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

    if(len == 2,
      lexical = LexicalBlock createFrom(call arguments, call ground)
      lexical call("3first")
      lexical call("1second")
      lexical call("2third"),

      lexical = LexicalBlock createFrom(call arguments, call ground)
      lexical call(0, "3first")
      lexical call(1, "1second")
      lexical call(2, "2third"))))
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
        ioke.evaluate_string("[nil,false,true] partition(==2) == [[], [nil, false, true]]").should == ioke.true
        ioke.evaluate_string(<<CODE).should == ioke.true
#$CUSTOM_ENUMERABLE_STRING
CustomEnumerable partition(!= "foo") == [["3first", "1second", "2third"], []]
CODE
      end

      it "should take two arguments that will be turned into a lexical block and applied" do 
        ioke = IokeRuntime.get_runtime
        ioke.evaluate_string("[1,2,3] partition(x, x==2) == [[2], [1,3]]").should == ioke.true
        ioke.evaluate_string("[nil,false,nil] partition(x, x nil?) == [[nil,nil], [false]]").should == ioke.true
        ioke.evaluate_string("[nil,false,true] partition(x, x==2) == [[], [nil, false, true]]").should == ioke.true
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
        ioke.evaluate_string("[1,2,3] takeWhile(x, x != 2) == [1]").should == ioke.true
        ioke.evaluate_string(<<CODE).should == ioke.true
#$CUSTOM_ENUMERABLE_STRING
CustomEnumerable takeWhile(x, x != "2third") == ["3first", "1second"]
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
        ioke.evaluate_string("[1,2,3] dropWhile(x, x != 2) == [2,3]").should == ioke.true
        ioke.evaluate_string(<<CODE).should == ioke.true
#$CUSTOM_ENUMERABLE_STRING
CustomEnumerable dropWhile(x, x != "2third") == ["2third"]
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
res = []
m1 = method(
  [1,2,3] cycle(+1. if(Ground res length == 10, return). Ground res << "foo"))
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
        ioke.evaluate_string('[1,2,3,4,5,6,7,8,9] grep(2..5, + 1) == [3,4,5,6]').should == ioke.true
        ioke.evaluate_string(<<CODE).should == ioke.true
customObj = Origin mimic
customObj === = method(other, (other < 3) || (other > 5))
[1,2,3,4,5,6,7,8,9] grep(customObj, + 1) == [2,3,7,8,9,10]
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
