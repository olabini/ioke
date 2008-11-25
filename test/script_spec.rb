include_class('ioke.lang.Runtime') { 'IokeRuntime' } unless defined?(IokeRuntime)

import Java::java.io.PrintWriter unless defined?(PrintWriter)
import Java::java.io.StringWriter unless defined?(StringWriter)
import Java::java.io.InputStreamReader unless defined?(InputStreamReader)
import Java::java.lang.System unless defined?(System)

describe "script evaluation" do 
  describe "'hello_world.ik'" do 
    it 'should print Hello World' do 
      sw = StringWriter.new(20)
      out = PrintWriter.new(sw)
      ioke = IokeRuntime.get_runtime(out, InputStreamReader.new(System.in), out)
      ioke.evaluate_file('test/scripts/hello_world.ik', ioke.message, ioke.ground)
      sw.to_s.should == "Hello World\n"
    end
  end

  describe "'hello_world2.ik'" do 
    it 'should print Hello\nWorld' do 
      sw = StringWriter.new(20)
      out = PrintWriter.new(sw)
      ioke = IokeRuntime.get_runtime(out, InputStreamReader.new(System.in), out)
      ioke.evaluate_file('test/scripts/hello_world2.ik', ioke.message, ioke.ground)
      sw.to_s.should == "Hello\nWorld\n"
    end
  end
end
