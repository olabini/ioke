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
    it "should have tests"
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
