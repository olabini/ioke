include_class('ioke.lang.Runtime') { 'IokeRuntime' } unless defined?(IokeRuntime)

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
end
