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

describe "Number" do 
  it "should mimic Comparing" do 
    ioke = IokeRuntime.get_runtime()
    ioke.number.get_mimics.should include(ioke.mixins.find_cell(nil, nil, "Comparing"))
  end

  describe "'<=>'" do 
    it "should return 0 for the same number" do 
      ioke = IokeRuntime.get_runtime()
      ioke.evaluate_stream(StringReader.new("0<=>0")).data.as_java_integer.should == 0
      ioke.evaluate_stream(StringReader.new("1<=>1")).data.as_java_integer.should == 0
      ioke.evaluate_stream(StringReader.new("10<=>10")).data.as_java_integer.should == 0
      ioke.evaluate_stream(StringReader.new("12413423523452345345345<=>12413423523452345345345")).data.as_java_integer.should == 0
      ioke.evaluate_stream(StringReader.new("(0-1)<=>(0-1)")).data.as_java_integer.should == 0
    end

    it "should return 1 when the left number is larger than the right" do 
      ioke = IokeRuntime.get_runtime()
      ioke.evaluate_stream(StringReader.new("1<=>0")).data.as_java_integer.should == 1
      ioke.evaluate_stream(StringReader.new("2<=>1")).data.as_java_integer.should == 1
      ioke.evaluate_stream(StringReader.new("10<=>9")).data.as_java_integer.should == 1
      ioke.evaluate_stream(StringReader.new("12413423523452345345345<=>12413423523452345345344")).data.as_java_integer.should == 1
      ioke.evaluate_stream(StringReader.new("0<=>(0-1)")).data.as_java_integer.should == 1
      ioke.evaluate_stream(StringReader.new("1<=>(0-1)")).data.as_java_integer.should == 1
    end

    it "should return -1 when the left number is smaller than the right" do 
      ioke = IokeRuntime.get_runtime()
      ioke.evaluate_stream(StringReader.new("0<=>1")).data.as_java_integer.should == -1
      ioke.evaluate_stream(StringReader.new("1<=>2")).data.as_java_integer.should == -1
      ioke.evaluate_stream(StringReader.new("9<=>10")).data.as_java_integer.should == -1
      ioke.evaluate_stream(StringReader.new("12413423523452345345343<=>12413423523452345345344")).data.as_java_integer.should == -1
      ioke.evaluate_stream(StringReader.new("(0-1)<=>0")).data.as_java_integer.should == -1
      ioke.evaluate_stream(StringReader.new("(0-1)<=>1")).data.as_java_integer.should == -1
    end

    # It should convert it's argument to number if it's not a number
  end

  describe "'-'" do 
    it "should return 0 for the difference between 0 and 0" do 
      ioke = IokeRuntime.get_runtime()
      ioke.evaluate_stream(StringReader.new("0-0")).data.as_java_integer.should == 0
    end
    
    it "should return the difference between really large numbers" do 
      ioke = IokeRuntime.get_runtime()
      ioke.evaluate_stream(StringReader.new("123435334645674745675675757-123435334645674745675675756")).data.as_java_integer.should == 1
      ioke.evaluate_stream(StringReader.new("123435334645674745675675757-1")).data.as_java_string.should == "123435334645674745675675756"
      ioke.evaluate_stream(StringReader.new("123435334645674745675675757-24334534544345345345345")).data.as_java_string.should == "123411000111130400330330412"
    end
    
    it "should return the difference between smaller numbers" do 
      ioke = IokeRuntime.get_runtime()
      ioke.evaluate_stream(StringReader.new("1-1")).data.as_java_integer.should == 0
      ioke.evaluate_stream(StringReader.new("0-1")).data.as_java_integer.should == -1
      ioke.evaluate_stream(StringReader.new("2-1")).data.as_java_integer.should == 1
      ioke.evaluate_stream(StringReader.new("10-5")).data.as_java_integer.should == 5
      ioke.evaluate_stream(StringReader.new("234-30")).data.as_java_integer.should == 204
      ioke.evaluate_stream(StringReader.new("30-35")).data.as_java_integer.should == -5
    end
    
    it "should return the difference between negative numbers" do 
      ioke = IokeRuntime.get_runtime()
      ioke.evaluate_stream(StringReader.new("(0-1)-1")).data.as_java_integer.should == -2
      ioke.evaluate_stream(StringReader.new("(0-1)-5")).data.as_java_integer.should == -6
      ioke.evaluate_stream(StringReader.new("(0-1)-(0-5)")).data.as_java_integer.should == 4
      ioke.evaluate_stream(StringReader.new("(0-10)-5")).data.as_java_integer.should == -15
      ioke.evaluate_stream(StringReader.new("(0-10)-(0-5)")).data.as_java_integer.should == -5
      ioke.evaluate_stream(StringReader.new("(0-2545345345346547456756)-(0-2545345345346547456755)")).data.as_java_integer.should == -1
    end

    it "should return the number when 0 is the argument" do 
      ioke = IokeRuntime.get_runtime()
      ioke.evaluate_stream(StringReader.new("(0-1)-0")).data.as_java_integer.should == -1
      ioke.evaluate_stream(StringReader.new("10-0")).data.as_java_integer.should == 10
      ioke.evaluate_stream(StringReader.new("1325234534634564564576367-0")).data.as_java_string.should == "1325234534634564564576367"
    end
    
    # It should convert it's argument to number if it's not a number
  end

  describe "'+'" do 
    it "should return 0 for the sum of 0 and 0"
    it "should return the sum of really large numbers"
    it "should return the sum of smaller numbers"
    it "should return the sum of negative numbers"
    it "should return the number when 0 is the receiver"
    it "should return the number when 0 is the argument"

    # It should convert it's argument to number if it's not a number
  end
  
  describe "'asText'" do 
    it "should return a representation of 0"
    it "should return a representation of a small positive number"
    it "should return a representation of a large positive number"
    it "should return a representation of a negative number"
  end

  describe "'succ'" do 
    it "should return the successor of 0"
    it "should return the successor of a small positive number"
    it "should return the successor of a large positive number"
    it "should return the successor of a negative number"
  end

  describe "'times'" do 
    it "should not do anything for a negative number"
    it "should not do anything for 0"
    it "should execute the block one time for 1"
    it "should execute the block the same number of times as the receiver"
  end
end
