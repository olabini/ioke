include_class('ioke.lang.Runtime') { 'IokeRuntime' } unless defined?(IokeRuntime)

import Java::java.io.StringReader unless defined?(StringReader)
import Java::java.io.PrintWriter unless defined?(PrintWriter)
import Java::java.io.StringWriter unless defined?(StringWriter)
import Java::java.io.InputStreamReader unless defined?(InputStreamReader)
import Java::java.lang.System unless defined?(System)

describe "IO" do 
  it "should have the correct kind" do 
    ioke = IokeRuntime.get_runtime
    ioke.evaluate_string('IO kind == "IO"').should == ioke.true
  end

  describe "'print'" do 
    it "should print asText of object" do 
      sw = StringWriter.new(20)
      out = PrintWriter.new(sw)
      ioke = IokeRuntime.get_runtime(out, InputStreamReader.new(System.in), out)

      ioke.evaluate_string('System out print("foobarz")')
      sw.to_string.should == "foobarz"
    end
  end

  describe "'println'" do 
    it "should print asText of object and then a println" do 
      sw = StringWriter.new(20)
      out = PrintWriter.new(sw)
      ioke = IokeRuntime.get_runtime(out, InputStreamReader.new(System.in), out)

      ioke.evaluate_string('System out println("foobarz")')
      sw.to_string.should == "foobarz\n"
    end
  end
  
  describe "'read'" do 
    it "should return a simple message representation when reading something simple" do 
      sw = StringWriter.new(20)
      out = PrintWriter.new(sw)
      ioke = IokeRuntime.get_runtime(out, StringReader.new("foo"), out)
      ioke.evaluate_string('System in read').to_string.should == "foo"
    end

    it "should return a more complicated message representation when reading something more complicated" do 
      sw = StringWriter.new(20)
      out = PrintWriter.new(sw)
      ioke = IokeRuntime.get_runtime(out, StringReader.new("foo + bar(123)"), out)
      ioke.evaluate_string('System in read').to_string.should == "foo +(bar(123))"
    end
  end
end

describe "System" do 
  describe "'out'" do 
    it "should be an IO object" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string('System out kind?("IO")').should == ioke.true
    end
  end
  
  describe "'err'" do 
    it "should be an IO object" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string('System err kind?("IO")').should == ioke.true
    end
  end

  describe "'in'" do 
    it "should be an IO object" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string('System in kind?("IO")').should == ioke.true
    end
  end
end
