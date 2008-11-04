include_class('ioke.lang.Runtime') { 'IokeRuntime' } unless defined?(IokeRuntime)

import Java::java.io.StringReader unless defined?(StringReader)

describe "Text" do 
  describe "'=='" do 
    it "should return true for the same text" do 
      ioke = IokeRuntime.get_runtime()
      ioke.evaluate_string("x = \"foo\". x == x").should == ioke.true
      ioke.evaluate_string("x = \"\". x == x").should == ioke.true
      ioke.evaluate_string("x = \"34tertsegdf\ndfgsdfgd\". x == x").should == ioke.true
    end

    it "should not return true for unequal texts" do 
      ioke = IokeRuntime.get_runtime()
      ioke.evaluate_string("\"foo\" == \"bar\"").should == ioke.false
      ioke.evaluate_string("\"foo\" == \"sdfsdgdfgsgf\nadsfgdsfgsdfgdfg\nsdfgdsfgsdfg\"").should == ioke.false
    end

    it "should return true for equal texts" do 
      ioke = IokeRuntime.get_runtime()
      ioke.evaluate_string("\"foo\" == \"foo\"").should == ioke.true
      ioke.evaluate_string("\"sdfsdgdfgsgf\nadsfgdsfgsdfgdfg\nsdfgdsfgsdfg\" == \"sdfsdgdfgsgf\nadsfgdsfgsdfgdfg\nsdfgdsfgsdfg\"").should == ioke.true
    end
    
    it "should work correctly when comparing empty text" do 
      ioke = IokeRuntime.get_runtime()
      ioke.evaluate_string("\"\" == \"\"").should == ioke.true
      ioke.evaluate_string("\"a\" == \"\"").should == ioke.false
      ioke.evaluate_string("\"\" == \"a\"").should == ioke.false
    end
  end

  describe "'!='" do 
    it "should return false for the same text" do 
      ioke = IokeRuntime.get_runtime()
      ioke.evaluate_string("x = \"foo\". x != x").should == ioke.false
      ioke.evaluate_string("x = \"\". x != x").should == ioke.false
      ioke.evaluate_string("x = \"34tertsegdf\ndfgsdfgd\". x != x").should == ioke.false
    end

    it "should return true for unequal texts" do 
      ioke = IokeRuntime.get_runtime()
      ioke.evaluate_string("\"foo\" != \"bar\"").should == ioke.true
      ioke.evaluate_string("\"foo\" != \"sdfsdgdfgsgf\nadsfgdsfgsdfgdfg\nsdfgdsfgsdfg\"").should == ioke.true
    end

    it "should return false for equal texts" do 
      ioke = IokeRuntime.get_runtime()
      ioke.evaluate_string("\"foo\" != \"foo\"").should == ioke.false
      ioke.evaluate_string("\"sdfsdgdfgsgf\nadsfgdsfgsdfgdfg\nsdfgdsfgsdfg\" != \"sdfsdgdfgsgf\nadsfgdsfgsdfgdfg\nsdfgdsfgsdfg\"").should == ioke.false
    end
    
    it "should work correctly when comparing empty text" do 
      ioke = IokeRuntime.get_runtime()
      ioke.evaluate_string("\"\" != \"\"").should == ioke.false
      ioke.evaluate_string("\"a\" != \"\"").should == ioke.true
      ioke.evaluate_string("\"\" != \"a\"").should == ioke.true
    end
  end
  
  describe "'[]'" do 
    it "should have tests"
  end
  
  describe "escapes" do 
    describe "\\b" do 
      it "should have tests"
    end

    describe "\\t" do 
      it "should have tests"
    end

    describe "\\n" do 
      it "should have tests"
    end

    describe "\\f" do 
      it "should have tests"
    end

    describe "\\r" do 
      it "should have tests"
    end

    describe "\\\"" do 
      it "should have tests"
    end

    describe "\\\\" do 
      it "should have tests"
    end

    describe "\\\\n" do 
      it "should have tests"
    end

    describe "unicode" do 
      it "should have tests"
    end

    describe "octal" do 
      it "should have tests"
    end
  end
end
