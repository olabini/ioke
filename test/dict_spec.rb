include_class('ioke.lang.Runtime') { 'IokeRuntime' } unless defined?(IokeRuntime)
include_class('ioke.lang.Dict') unless defined?(Dict)

describe "Dict" do 
  it "should have the correct kind" do 
    ioke = IokeRuntime.get_runtime
    result = ioke.dict.find_cell(nil, nil, "kind")
    result.data.text.should == 'Dict'
  end

  it "should be possible to mimic" do 
    ioke = IokeRuntime.get_runtime
    result = ioke.evaluate_string("x = Dict mimic")
    result.data.class.should == Dict
    result.data.should_not == ioke.dict.data

    ioke.evaluate_string("x mimics?(Dict)").should == ioke.true
    ioke.evaluate_string("x kind?(\"Dict\")").should == ioke.true
  end
  
  it "should mimic Enumerable" do 
    ioke = IokeRuntime.get_runtime
    ioke.dict.get_mimics.should include(ioke.mixins.find_cell(nil, nil, "Enumerable"))
  end
  
  describe "'=='" do 
    it "should return false when sent an argument that is not a dict" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string("{} == 1").should == ioke.false
      ioke.evaluate_string("{1=>2} == 1").should == ioke.false
      ioke.evaluate_string("{1=>2,2=>3,3=>4} == \"foo\"").should == ioke.false
      ioke.evaluate_string("{} == method({})").should == ioke.false
    end
    
    it "should return true for two empty dicts" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string("x = {}. x == x").should == ioke.true
      ioke.evaluate_string("{} == {}").should == ioke.true
    end
    
    it "should return true for two empty dicts where one has a new cell" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string("x = {}. y = {}. x blarg = 12. x == y").should == ioke.true
    end
    
    it "should return false when the two dicts have a key element of different types" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string("{1=>2} == {\"1\"=>2}").should == ioke.false
      ioke.evaluate_string("{1=>2, 2=>3, 3=>4} == {\"1\"=>2, \"2\"=>3, \"3\"=>4}").should == ioke.false
    end

    it "should return false when the two dicts have different size" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string("{1} == {}").should == ioke.false
      ioke.evaluate_string("{1} == {1,2,3}").should == ioke.false
    end
    
    it "should return true if the elements in the dict are the same" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string("{1} == {1=>nil}").should == ioke.true
      ioke.evaluate_string("{1=>\"str\"} == {1=>\"str\"}").should == ioke.true
      ioke.evaluate_string("{\"1\"=>123} == {\"1\"=>123}").should == ioke.true
      ioke.evaluate_string("{1,2,3,4,5,6,7} == {1,2,3,4,5,6,7}").should == ioke.true
    end

    it "should return true if the elements in the dict are the same but in different order" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string("{1,2,3,4,5,6,7} == {3,4,5,6,7,1,2,3}").should == ioke.true
    end
  end
end

describe "DefaultBehavior" do 
  # These methods will NOT create Pair instances, instead it's cheating - just like keyword arguments
  # At some point these methods should also take keyword arguments, interchangably with pairs.
  describe "'dict'" do 
    it "should create a new empty dict when given no arguments" do 
      ioke = IokeRuntime.get_runtime
      result = ioke.evaluate_string("x = dict")
      result.data.class.should == Dict
      result.data.should_not == ioke.dict.data

      ioke.evaluate_string("x mimics?(Dict)").should == ioke.true
      ioke.evaluate_string("x kind?(\"Dict\")").should == ioke.true

      result = ioke.evaluate_string("x = dict()")
      result.data.class.should == Dict
      result.data.should_not == ioke.dict.data

      ioke.evaluate_string("x mimics?(Dict)").should == ioke.true
      ioke.evaluate_string("x kind?(\"Dict\")").should == ioke.true
    end
    
    it "should create a new dict with the evaluated arguments" do 
      ioke = IokeRuntime.get_runtime
      result = ioke.evaluate_string("dict(1 => 2, \"abc\" => 3+42, :foo => 123, :bar => \"x\")")
      data = result.data.map
      data.size.should == 4
    end
    
    it "should create a new dict with keyword arguments" do 
      ioke = IokeRuntime.get_runtime
      result = ioke.evaluate_string("dict(abc: 2, foo: 3+42, bar: 123, quux: \"x\")")
      data = result.data.map
      data.size.should == 4
    end

    it "should take arguments that are not keyword or pairs and add nil as value for them" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string("dict(123, \"foo\", 13+2, :bar) == dict(123=>nil, \"foo\"=>nil, 15=>nil, :bar => nil)").should == ioke.true
    end

    it "should take keyword arguments without a next pointer and add nil as value for them" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string("dict(foo:, bar:, quux:) == dict(:foo => nil, :bar => nil, :quux => nil)").should == ioke.true
    end
  end
  
  describe "'{}'" do 
    it "should create a new empty dict when given no arguments" do 
      ioke = IokeRuntime.get_runtime
      result = ioke.evaluate_string("x = {}")
      result.data.class.should == Dict
      result.data.should_not == ioke.dict.data

      ioke.evaluate_string("x mimics?(Dict)").should == ioke.true
      ioke.evaluate_string("x kind?(\"Dict\")").should == ioke.true
    end
    
    it "should create a new dict with the evaluated arguments" do 
      ioke = IokeRuntime.get_runtime
      result = ioke.evaluate_string("{1 => 2, \"abc\" => 3+42, :foo => 123, :bar => \"x\"}")
      data = result.data.map
      data.size.should == 4
    end

    it "should create a new dict with keyword arguments" do 
      ioke = IokeRuntime.get_runtime
      result = ioke.evaluate_string("{abc: 2, foo: 3+42, bar: 123, quux: \"x\"}")
      data = result.data.map
      data.size.should == 4
    end

    it "should take arguments that are not keyword or pairs and add nil as value for them" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string("{123, \"foo\", 13+2, :bar} == {123=>nil, \"foo\"=>nil, 15=>nil, :bar => nil}").should == ioke.true
    end

    it "should take keyword arguments without a next pointer and add nil as value for them" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string("{foo:, bar:, quux:} == {:foo => nil, :bar => nil, :quux => nil}").should == ioke.true
    end
  end
end
