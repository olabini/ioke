include_class('ioke.lang.Runtime') { 'IokeRuntime' } unless defined?(IokeRuntime)
include_class('ioke.lang.exceptions.ControlFlow') unless defined?(ControlFlow)

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
  
  describe "'exit'" do 
    it "should throw a ControlFlow.Exit exception" do 
      ioke = IokeRuntime.get_runtime
      begin 
        ioke.evaluate_string('System exit')
        true.should be_false
      rescue NativeException => cfe
        cfe.cause.should be_kind_of(ControlFlow::Exit)
      end
    end

    it "should exit with 1 if no argument is given" do 
      ioke = IokeRuntime.get_runtime
      begin 
        ioke.evaluate_string('System exit')
        true.should be_false
      rescue NativeException => cfe
        cfe.cause.exit_value.should == 1
      end
    end

    it "should take an argument that is the exit code to use" do 
      ioke = IokeRuntime.get_runtime
      begin 
        ioke.evaluate_string('System exit(31)')
        true.should be_false
      rescue NativeException => cfe
        cfe.cause.exit_value.should == 31
      end
    end
  end
end
