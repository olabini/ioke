include_class('ioke.lang.Runtime') { 'IokeRuntime' } unless defined?(IokeRuntime)
include_class('ioke.lang.Text') unless defined?(Text)

import Java::java.io.StringReader unless defined?(StringReader)

describe "assignment" do 
  it "should work for a simple string" do 
    ioke = IokeRuntime.get_runtime()
    result = ioke.evaluate_stream(StringReader.new(%q[a = "foo"]))
    result.java_class.name.should == 'ioke.lang.Text'
    result.text.should == "foo"

    ioke.ground.find_cell("a").should == result
  end
end
