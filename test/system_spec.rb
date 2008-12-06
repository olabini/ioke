include_class('ioke.lang.Runtime') { 'IokeRuntime' } unless defined?(IokeRuntime)

import Java::java.io.StringReader unless defined?(StringReader)
import Java::java.io.PrintWriter unless defined?(PrintWriter)
import Java::java.io.StringWriter unless defined?(StringWriter)
import Java::java.io.InputStreamReader unless defined?(InputStreamReader)
import Java::java.lang.System unless defined?(System)

describe "System" do 
  it "should have the correct kind" do 
    ioke = IokeRuntime.get_runtime
    result = ioke.system.find_cell(nil, nil, "kind")
    result.data.text.should == 'System'
  end

  describe "'programArguments'" do 
    it "should be possible to get all the arguments to the program" do 
      ioke = IokeRuntime.get_runtime
      ioke.add_argument("foo")
      ioke.add_argument("bar.ik")
      ioke.add_argument("-II ik")

      ioke.evaluate_string('System programArguments == ["foo", "bar.ik", "-II ik"]').should == ioke.true
    end
  end
end
