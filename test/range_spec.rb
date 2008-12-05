include_class('ioke.lang.Runtime') { 'IokeRuntime' } unless defined?(IokeRuntime)

describe "DefaultBehavior" do 
  describe "'..'" do 
    it "should create a range from 0 to 0" do 
      ioke = IokeRuntime.get_runtime

      result = ioke.evaluate_string("0..0")
      result.find_cell(nil, nil, "kind").data.text.should == "Range"
      ioke.evaluate_string("(0..0) from").data.as_java_integer.should == 0
      ioke.evaluate_string("(0..0) to").data.as_java_integer.should == 0
    end

    it "should create a range from 0 to 1" do 
      ioke = IokeRuntime.get_runtime

      result = ioke.evaluate_string("0..1")
      result.find_cell(nil, nil, "kind").data.text.should == "Range"
      ioke.evaluate_string("(0..1) from").data.as_java_integer.should == 0
      ioke.evaluate_string("(0..1) to").data.as_java_integer.should == 1
    end

    it "should create a range from 0 to -1" do 
      ioke = IokeRuntime.get_runtime

      result = ioke.evaluate_string("0..-1")
      result.find_cell(nil, nil, "kind").data.text.should == "Range"
      ioke.evaluate_string("(0..-1) from").data.as_java_integer.should == 0
      ioke.evaluate_string("(0..-1) to").data.as_java_integer.should == -1
    end

    it "should create a range from other numbers" do 
      ioke = IokeRuntime.get_runtime

      result = ioke.evaluate_string("23..-342")
      result.find_cell(nil, nil, "kind").data.text.should == "Range"
      ioke.evaluate_string("(23..-342) from").data.as_java_integer.should == 23
      ioke.evaluate_string("(23..-342) to").data.as_java_integer.should == -342
    end

    it "should create an inclusive range" do 
      ioke = IokeRuntime.get_runtime

      ioke.evaluate_string("(0..0) inclusive?").should == ioke.true
    end
  end

  describe "'...'" do 
    it "should create a range from 0 to 0" do 
      ioke = IokeRuntime.get_runtime

      result = ioke.evaluate_string("0...0")
      result.find_cell(nil, nil, "kind").data.text.should == "Range"
      ioke.evaluate_string("(0...0) from").data.as_java_integer.should == 0
      ioke.evaluate_string("(0...0) to").data.as_java_integer.should == 0
    end

    it "should create a range from 0 to 1" do 
      ioke = IokeRuntime.get_runtime

      result = ioke.evaluate_string("0...1")
      result.find_cell(nil, nil, "kind").data.text.should == "Range"
      ioke.evaluate_string("(0...1) from").data.as_java_integer.should == 0
      ioke.evaluate_string("(0...1) to").data.as_java_integer.should == 1
    end

    it "should create a range from 0 to -1" do 
      ioke = IokeRuntime.get_runtime

      result = ioke.evaluate_string("0...-1")
      result.find_cell(nil, nil, "kind").data.text.should == "Range"
      ioke.evaluate_string("(0...-1) from").data.as_java_integer.should == 0
      ioke.evaluate_string("(0...-1) to").data.as_java_integer.should == -1
    end

    it "should create a range from other numbers" do 
      ioke = IokeRuntime.get_runtime

      result = ioke.evaluate_string("23...-342")
      result.find_cell(nil, nil, "kind").data.text.should == "Range"
      ioke.evaluate_string("(23...-342) from").data.as_java_integer.should == 23
      ioke.evaluate_string("(23...-342) to").data.as_java_integer.should == -342
    end

    it "should create an inclusive range" do 
      ioke = IokeRuntime.get_runtime

      ioke.evaluate_string("(0...0) inclusive?").should == ioke.false
    end
  end
end

describe "Range" do 
  describe "'from'" do 
    it "should return the from part of the range" do 
      ioke = IokeRuntime.get_runtime

      ioke.evaluate_string("(13..0) from").data.as_java_integer.should == 13
      ioke.evaluate_string("(-42..0) from").data.as_java_integer.should == -42
      ioke.evaluate_string("(0..0) from").data.as_java_integer.should == 0

      ioke.evaluate_string("(13...0) from").data.as_java_integer.should == 13
      ioke.evaluate_string("(-42...0) from").data.as_java_integer.should == -42
      ioke.evaluate_string("(0...0) from").data.as_java_integer.should == 0
    end
  end

  describe "'it'" do 
    it "should return the to part of the range" do 
      ioke = IokeRuntime.get_runtime

      ioke.evaluate_string("(0..13) to").data.as_java_integer.should == 13
      ioke.evaluate_string("(0..-42) to").data.as_java_integer.should == -42
      ioke.evaluate_string("(0..0) to").data.as_java_integer.should == 0

      ioke.evaluate_string("(0...13) to").data.as_java_integer.should == 13
      ioke.evaluate_string("(0...-42) to").data.as_java_integer.should == -42
      ioke.evaluate_string("(0...0) to").data.as_java_integer.should == 0
    end
  end

  describe "'inclusive?'" do 
    it "should return true for an inclusive range" do 
      ioke = IokeRuntime.get_runtime

      ioke.evaluate_string("(0..13) inclusive?").should == ioke.true
    end

    it "should return false for an exclusive range" do 
      ioke = IokeRuntime.get_runtime

      ioke.evaluate_string("(0...13) inclusive?").should == ioke.false
    end
  end

  describe "'exclusive?'" do 
    it "should return false for an inclusive range" do 
      ioke = IokeRuntime.get_runtime

      ioke.evaluate_string("(0..13) exclusive?").should == ioke.false
    end

    it "should return true for an exclusive range" do 
      ioke = IokeRuntime.get_runtime

      ioke.evaluate_string("(0...13) exclusive?").should == ioke.true
    end
  end
  
  describe "'==='" do 
    it "should match something inside the range" do 
      ioke = IokeRuntime.get_runtime

      ioke.evaluate_string("(1..5) === 1").should == ioke.true
      ioke.evaluate_string("(1..5) === 2").should == ioke.true
      ioke.evaluate_string("(1..5) === 3").should == ioke.true
      ioke.evaluate_string("(1..5) === 4").should == ioke.true
      ioke.evaluate_string("(1..5) === 5").should == ioke.true
      ioke.evaluate_string("(1..5) === 1.5").should == ioke.true
      ioke.evaluate_string("(1..5) === 4.9999").should == ioke.true
      ioke.evaluate_string("(1...5) === 4.9999").should == ioke.true
      ioke.evaluate_string("(1..5) === 4/3").should == ioke.true
    end

    it "should not match something outside the range" do 
      ioke = IokeRuntime.get_runtime

      ioke.evaluate_string("(1..5) === 0").should == ioke.false
      ioke.evaluate_string("(1...5) === 5").should == ioke.false
      ioke.evaluate_string("(1..5) === 0.5").should == ioke.false
      ioke.evaluate_string("(1..5) === 5.000001").should == ioke.false
      ioke.evaluate_string("(1...5) === 5.0").should == ioke.false
      ioke.evaluate_string("(1..5) === 1/3").should == ioke.false

      ioke.evaluate_string("(1..5) === :foo").should == ioke.false
    end
  end
end
