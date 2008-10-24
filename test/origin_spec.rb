include_class('ioke.lang.IokeObject') unless defined?(IokeObject)

import Java::java.io.StringReader unless defined?(StringReader)

import Java::java.io.PrintWriter unless defined?(PrintWriter)
import Java::java.io.StringWriter unless defined?(StringWriter)
import Java::java.io.InputStreamReader unless defined?(InputStreamReader)
import Java::java.lang.System unless defined?(System)

describe "Origin" do 
  describe "'print'" do 
    it "should print asText of object" do 
      sw = StringWriter.new(20)
      out = PrintWriter.new(sw)
      ioke = IokeRuntime.get_runtime(out, InputStreamReader.new(System.in), out)
      ioke.evaluate_stream(StringReader.new(%q["foobarz" print]))
      sw.to_string.should == "foobarz"
    end
  end

  describe "'println'" do 
    it "should print asText of object and then a println" do 
      sw = StringWriter.new(20)
      out = PrintWriter.new(sw)
      ioke = IokeRuntime.get_runtime(out, InputStreamReader.new(System.in), out)
      ioke.evaluate_stream(StringReader.new(%q["foobarz" println]))
      sw.to_string.should == "foobarz\n"
    end
  end
end
