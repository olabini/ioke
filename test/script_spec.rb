include_class('ioke.lang.Runtime') { 'IokeRuntime' }
include_class('ioke.lang.EvaluationResult')

import Java::java.io.PrintWriter
import Java::java.io.StringWriter
import Java::java.io.InputStreamReader
import Java::java.lang.System

describe "script evaluation" do 
  describe "hello_world" do 
    it 'should print Hello World' do 
      sw = StringWriter.new(20)
      out = PrintWriter.new(sw)
      ioke = IokeRuntime.get_runtime(out, InputStreamReader.new(System.in), out)
      ioke.evaluate_file('test/scripts/hello_world.ik')
      sw.to_s.should == "Hello World\n"
    end

    it 'should evaluate ok' do 
      out = PrintWriter.new(StringWriter.new(20))
      ioke = IokeRuntime.get_runtime(out, InputStreamReader.new(System.in), out)
      ioke.evaluate_file('test/scripts/hello_world.ik').should == EvaluationResult::OK
    end
  end
end
