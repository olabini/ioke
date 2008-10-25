include_class('ioke.lang.Runtime') { 'IokeRuntime' } unless defined?(IokeRuntime)

import Java::java.io.StringReader unless defined?(StringReader)

describe "DefaultBehavior" do 
  describe "'method'" do 
    it "should return a method that returns nil when called with no arguments" do 
      ioke = IokeRuntime.get_runtime()
      ioke.evaluate_stream(StringReader.new("method call")).should == ioke.nil
      ioke.evaluate_stream(StringReader.new("method() call")).should == ioke.nil
    end
    
    it "should name itself after the slot it's assigned to if it has no name" do 
      ioke = IokeRuntime.get_runtime()
      ioke.evaluate_stream(StringReader.new("x = method(nil)")).data.name.should == "x"
    end
    
    it "should not change it's name if it already has a name" do 
      ioke = IokeRuntime.get_runtime()
      ioke.evaluate_stream(StringReader.new("x = method(nil)\ny = cell(\"x\")\ncell(\"y\")")).data.name.should == "x"
    end
    
    it "should know it's own name" do 
      ioke = IokeRuntime.get_runtime()
      ioke.evaluate_stream(StringReader.new("(x = method(nil)) name")).data.text.should == "x"
    end
  end
end

describe "DefaultMethod" do 
  it "should be possible to give it a documentation string"
  it "should report arity failures with regular arguments"
  it "should report arity failures with optional arguments"
  it "should report arity failures with regular and optional arguments"
  it "should report mismatched arguments when trying to define optional arguments before regular ones"
    
  it "should be possible to give it one optional argument with simple data" do 
    ioke = IokeRuntime.get_runtime()
    ioke.evaluate_stream(StringReader.new(<<CODE))
m = method(x 42, x)
CODE
    ioke.evaluate_stream(StringReader.new("m")).data.as_java_integer.should == 42
    ioke.evaluate_stream(StringReader.new("m(43)")).data.as_java_integer.should == 43
  end

  it "should be possible to give it one optional argument and one regular argument with simple data"
  it "should be possible to give it one regular argument and one optional argument that refers to the first one"
  it "should be possible to give it two optional arguments where the second refers to the first one"
  it "should be possible to have more complicated expression as default value"
end
