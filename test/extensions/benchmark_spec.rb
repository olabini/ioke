include_class('ioke.lang.Runtime') { 'IokeRuntime' } unless defined?(IokeRuntime)

import Java::java.io.StringReader unless defined?(StringReader)

import Java::java.io.PrintWriter unless defined?(PrintWriter)
import Java::java.io.StringWriter unless defined?(StringWriter)
import Java::java.io.InputStreamReader unless defined?(InputStreamReader)
import Java::java.lang.System unless defined?(System)

describe "Extensions" do 
  describe "Benchmark" do 
    describe "report" do 
      it "should execute code 10x1 times by default" do 
        sw = StringWriter.new(20)
        out = PrintWriter.new(sw)
        ioke = IokeRuntime.get_runtime(out, InputStreamReader.new(System.in), out)
        ioke.evaluate_stream(StringReader.new(%q[use("benchmark");iterations = 0]))
        ioke.evaluate_stream(StringReader.new(%q[Benchmark report(iterations++)]))
        ioke.ground.get_cell(nil, nil, "iterations").data.as_java_integer.should == 10
      end
    
      it "should report the code used for benchmarking" do 
        sw = StringWriter.new(20)
        out = PrintWriter.new(sw)
        ioke = IokeRuntime.get_runtime(out, InputStreamReader.new(System.in), out)
        ioke.evaluate_stream(StringReader.new(%q[use("benchmark");iterations = 0]))
        ioke.evaluate_stream(StringReader.new(%q[Benchmark report(iterations++)]))
        str = sw.to_string.to_a
        str.length.should == 10
        str.each do |s|
          s.should match(/^\+\+\(iterations\) +0\./)
        end
      end

      it "should be possible to customize the amount of benchmarking rounds" do 
        sw = StringWriter.new(20)
        out = PrintWriter.new(sw)
        ioke = IokeRuntime.get_runtime(out, InputStreamReader.new(System.in), out)
        ioke.evaluate_stream(StringReader.new(%q[use("benchmark");iterations = 0]))
        ioke.evaluate_stream(StringReader.new(%q[Benchmark report(5, iterations++)]))
        ioke.ground.get_cell(nil, nil, "iterations").data.as_java_integer.should == 5
        str = sw.to_string.to_a
        str.length.should == 5
      end
      it "should be possible to customize the iterations for each benchmarking round" do 
        sw = StringWriter.new(20)
        out = PrintWriter.new(sw)
        ioke = IokeRuntime.get_runtime(out, InputStreamReader.new(System.in), out)
        ioke.evaluate_stream(StringReader.new(%q[use("benchmark");iterations = 0]))
        ioke.evaluate_stream(StringReader.new(%q[Benchmark report(2, 3, iterations++)]))
        ioke.ground.get_cell(nil, nil, "iterations").data.as_java_integer.should == 6
        str = sw.to_string.to_a
        str.length.should == 2
      end
    end
  end
end
