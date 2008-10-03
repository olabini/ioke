include_class('ioke.lang.Runtime') { 'IokeRuntime' } unless defined?(IokeRuntime)

import Java::java.io.StringReader unless defined?(StringReader)

describe "DefaultBehavior method" do 
  it "should return a method that returns nil when called with no arguments" do 
    ioke = IokeRuntime.get_runtime()
    ioke.evaluate_stream(StringReader.new("method() call")).should == ioke.nil
  end
  
  it "should name itself after the slot it's assigned to if it has no name"
  it "should not change it's name if it already has a name"
end
