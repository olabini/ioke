include_class('ioke.lang.Runtime') { 'IokeRuntime' } unless defined?(IokeRuntime)

describe "DefaultBehavior" do 
  describe "'macro'" do 
    it "should return a macro that returns nil when called with no arguments" do 
      ioke = IokeRuntime.get_runtime()
      ioke.evaluate_string("macro call").should == ioke.nil
      ioke.evaluate_string("macro() call").should == ioke.nil
    end
    
    it "should name itself after the slot it's assigned to if it has no name" do 
      ioke = IokeRuntime.get_runtime()
      ioke.evaluate_string("x = macro(nil)").data.name.should == "x"
    end
    
    it "should not change it's name if it already has a name" do 
      ioke = IokeRuntime.get_runtime()
      ioke.evaluate_string("x = macro(nil). y = cell(:x). cell(:y)").data.name.should == "x"
    end
    
    it "should know it's own name" do 
      ioke = IokeRuntime.get_runtime()
      ioke.evaluate_string("(x = macro(nil)) name").data.text.should == "x"
    end
  end
end

describe "DefaultMacro" do 
  it "should be possible to give it a documentation string" do 
    ioke = IokeRuntime.get_runtime()
    ioke.evaluate_string("macro(\"foo is bar\", nil) documentation").data.text.should == "foo is bar"
  end

  it "should have @ return the receiving object inside of a macro" do 
    ioke = IokeRuntime.get_runtime()
    ioke.evaluate_string(<<CODE)
obj = Origin mimic
obj atSign = macro(@)
obj2 = obj mimic
CODE
    ioke.evaluate_string("obj atSign").should == ioke.ground.find_cell(nil,nil,"obj")
    ioke.evaluate_string("obj2 atSign").should == ioke.ground.find_cell(nil,nil,"obj2")
  end

  it "should have 'self' return the receiving object inside of a macro" do 
    ioke = IokeRuntime.get_runtime()
    ioke.evaluate_string(<<CODE)
obj = Origin mimic
obj selfMacro = macro(self)
obj2 = obj mimic
CODE
    ioke.evaluate_string("obj selfMacro").should == ioke.ground.find_cell(nil,nil,"obj")
    ioke.evaluate_string("obj2 selfMacro").should == ioke.ground.find_cell(nil,nil,"obj2")
  end

  it "should have 'call' defined inside the call to the macro" do 
    ioke = IokeRuntime.get_runtime()
    result = ioke.evaluate_string("macro(call) call")
    result.find_cell(nil, nil, "kind").data.text.should == "Call"
  end
  
  it "should not evaluate it's arguments by default" do 
    ioke = IokeRuntime.get_runtime()
    ioke.evaluate_string("x=42. macro(nil) call(x=13). x").data.as_java_integer.should == 42
  end

  it "should take any kinds of arguments" do 
    ioke = IokeRuntime.get_runtime()
    ioke.evaluate_string("x=macro(nil). x(13, 42, foo: 42*13)").should == ioke.nil
  end

  it "should return the last value in the macro" do 
    ioke = IokeRuntime.get_runtime()
    ioke.evaluate_string("x=macro(nil. 42+13.). x").data.as_java_integer.should == 55
  end
  
  it "should be possible to return from it prematurely, with return" do 
    ioke = IokeRuntime.get_runtime
    ioke.evaluate_string(<<CODE).should == ioke.true
x = 42
m = macro(if(true, return(:bar)). Ground x = 24)
(m() == :bar) && (x == 42)
CODE
  end
end
