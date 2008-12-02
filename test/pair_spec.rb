include_class('ioke.lang.Runtime') { 'IokeRuntime' } unless defined?(IokeRuntime)
include_class('ioke.lang.Pair') unless defined?(Pair)

describe "Pair" do 
  it "should have the correct kind" do 
    ioke = IokeRuntime.get_runtime
    result = ioke.pair.find_cell(nil, nil, "kind")
    result.data.text.should == 'Pair'
  end

  it "should be possible to mimic" do 
    ioke = IokeRuntime.get_runtime
    result = ioke.evaluate_string("x = Pair mimic")
    result.data.class.should == Pair
    result.data.object_id.should_not == ioke.pair.data.object_id

    ioke.evaluate_string("x mimics?(Pair)").should == ioke.true
    ioke.evaluate_string("x kind?(\"Pair\")").should == ioke.true
  end
  
  it "should mimic Enumerable" do 
    ioke = IokeRuntime.get_runtime
    ioke.pair.get_mimics.should include(ioke.mixins.find_cell(nil, nil, "Enumerable"))
  end

  it "should mimic Comparing" do 
    ioke = IokeRuntime.get_runtime
    ioke.pair.get_mimics.should include(ioke.mixins.find_cell(nil, nil, "Comparing"))
  end

  describe "'first'" do 
    it "should return the first element" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string("(1=>2) first == 1").should == ioke.true
    end
  end

  describe "'key'" do 
    it "should return the first element" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string("(1=>2) key == 1").should == ioke.true
    end
  end

  describe "'second'" do 
    it "should return the second element" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string("(1=>2) second == 2").should == ioke.true
    end
  end

  describe "'value'" do 
    it "should return the second element" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string("(1=>2) value == 2").should == ioke.true
    end
  end
  
  describe "'<=>'" do 
    it "should first compare the first value and return the result of that" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string("((1=>1) <=> (2=>1)) == 1<=>2").should == ioke.true
      ioke.evaluate_string("((4=>1) <=> (3=>1)) == 4<=>3").should == ioke.true
    end
    
    it "should then compare the second value and return the result of that" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string("((1=>1) <=> (1=>2)) == 1<=>2").should == ioke.true
      ioke.evaluate_string("((1=>4) <=> (1=>3)) == 4<=>3").should == ioke.true
    end
  end
end

describe "DefaultBehavior" do 
  describe "'=>'" do 
    it "should return a new pair for simple objects" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string("23 => 15").data.first.data.as_java_integer.should == 23
      ioke.evaluate_string("23 => 15").data.second.data.as_java_integer.should == 15

      ioke.evaluate_string('"str" => "foo"').data.first.data.text.should == "str"
      ioke.evaluate_string('"str" => "foo"').data.second.data.text.should == "foo"
    end

    it "should return a new pair for more complicated expressions" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string("23+15-2 => 3332323+2").data.first.data.as_java_integer.should == 36
      ioke.evaluate_string("23+15-2 => 3332323+2").data.second.data.as_java_integer.should == 3332325
    end
  end
end
