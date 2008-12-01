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
    result.data.object_id.should_not == ioke.dict.data.object_id

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

  describe "'addKeysAndValues'" do 
    it "should add the keys and values provided to the dict" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string("{} addKeysAndValues([:foo, :bar, :x], [32, 111, 4]) == {foo: 32, bar: 111, x: 4}").should == ioke.true
    end

    it "should only add as many as there are keys" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string("{} addKeysAndValues([:foo, :bar, :x], [32, 111, 4, 10, 42]) == {foo: 32, bar: 111, x: 4}").should == ioke.true
    end

    it "should return the dict" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string("v = {}. v addKeysAndValues([], []) == v").should == ioke.true
    end
  end
  
  describe "'at'" do 
    it "should return nil if empty dict" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string("dict at(:foo)").should == ioke.nil
      ioke.evaluate_string("dict at(\"bar\")").should == ioke.nil
      ioke.evaluate_string("dict at(42)").should == ioke.nil
    end

    it "should return nil if argument is over the size" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string("dict(bar: 42) at(:foo)").should == ioke.nil
    end

    it "should an element if it's in the dict" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string("{foo: 123, 321 => \"foo\", \"bax\" => 42} at(:foo) == 123").should == ioke.true
      ioke.evaluate_string("{foo: 123, 321 => \"foo\", \"bax\" => 42} at(321) == \"foo\"").should == ioke.true
      ioke.evaluate_string("{foo: 123, 321 => \"foo\", \"bax\" => 42} at(\"bax\") == 42").should == ioke.true
    end
  end

  describe "'[]'" do 
    it "should return nil if empty dict" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string("dict[:foo]").should == ioke.nil
      ioke.evaluate_string("dict[\"bar\"]").should == ioke.nil
      ioke.evaluate_string("dict[42]").should == ioke.nil
    end

    it "should return nil if argument is over the size" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string("dict(bar: 42)[:foo]").should == ioke.nil
    end

    it "should an element if it's in the dict" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string("{foo: 123, 321 => \"foo\", \"bax\" => 42}[:foo] == 123").should == ioke.true
      ioke.evaluate_string("{foo: 123, 321 => \"foo\", \"bax\" => 42}[321] == \"foo\"").should == ioke.true
      ioke.evaluate_string("{foo: 123, 321 => \"foo\", \"bax\" => 42}[\"bax\"] == 42").should == ioke.true
    end
  end
  
  describe "'[]='" do 
    it "should add an element to an empty dict" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string("x = {}. x[:foo] = :bar. x == {foo: :bar}").should == ioke.true
      ioke.evaluate_string("x = {42 => 32}. x[:foo] = :bar. x == {42 => 32, foo: :bar}").should == ioke.true
    end

    it "should overwrite an existing element" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string("x = {foo: 6666}. x[:foo] = :bar. x == {foo: :bar}").should == ioke.true
      ioke.evaluate_string("x = {foo: 6666, 42 => 32}. x[:foo] = :bar. x == {42 => 32, foo: :bar}").should == ioke.true
    end
    
    it "should return the value set" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string("({foo: 6666}[42] = :bar) == :bar").should == ioke.true
    end
  end
  
  describe "'keys'" do 
    it "should return an empty set for an empty dict" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string("{} keys == set()").should == ioke.true
    end

    it "should return the one key in an dict with one element" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string("{foo: 1} keys == set(:foo)").should == ioke.true
      ioke.evaluate_string("{1=>:foo} keys == set(1)").should == ioke.true
      ioke.evaluate_string("{\"str\" => :bar} keys == set(\"str\")").should == ioke.true
    end

    it "should return all the keys" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string("{foo: 1, bar: 2, 3 => :quux} keys == set(:foo, :bar, 3)").should == ioke.true
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
      result.data.object_id.should_not == ioke.dict.data.object_id

      ioke.evaluate_string("x mimics?(Dict)").should == ioke.true
      ioke.evaluate_string("x kind?(\"Dict\")").should == ioke.true

      result = ioke.evaluate_string("x = dict()")
      result.data.class.should == Dict
      result.data.object_id.should_not == ioke.dict.data.object_id

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
      result.data.object_id.should_not == ioke.dict.data.object_id

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
