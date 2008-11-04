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

  it "should have 'call' defined inside the call to the macro"
  it "should not evaluate it's arguments by default"
  it "should take any kinds of arguments"
  it "should return the last value in the macro"
end
