include_class('ioke.lang.Runtime') { 'IokeRuntime' } unless defined?(IokeRuntime)

import Java::java.io.StringReader unless defined?(StringReader)

def test_int(str, expected)
  ioke = IokeRuntime.get_runtime()
  result = ioke.evaluate_stream(StringReader.new(str))
  result.data.asJavaInteger.should == expected
end

def test_longer(str, expected = str)
  ioke = IokeRuntime.get_runtime()
  result = ioke.evaluate_stream(StringReader.new(str))
  result.data.asJavaString.should == expected
end

describe "parsing" do 
  describe "numbers" do 
    it "should be possible to parse a 0" do 
      test_int("0", 0)
    end

    it "should be possible to parse a 1" do 
      test_int("1", 1)
    end

    it "should be possible to parse a longer number" do 
      test_int("132342534", 132342534)
    end

    it "should be possible to parse a really long number" do 
      test_longer("112142342353453453453453453475434574675674564756896765786781121213200000")
    end
  end
end
