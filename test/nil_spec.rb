include_class('ioke.lang.Runtime') { 'IokeRuntime' } unless defined?(IokeRuntime)

import Java::java.io.StringReader unless defined?(StringReader)
import Java::java.io.PrintWriter unless defined?(PrintWriter)
import Java::java.io.StringWriter unless defined?(StringWriter)
import Java::java.io.InputStreamReader unless defined?(InputStreamReader)
import Java::java.lang.System unless defined?(System)

describe "nil" do 
  describe "'nil?'" do 
    it "should return true" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string("nil nil?").should == ioke.true
      ioke.evaluate_string("x = nil. x nil?").should == ioke.true
    end
  end

  describe "'false?'" do 
    it "should return true" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string("nil false?").should == ioke.true
      ioke.evaluate_string("x = nil. x false?").should == ioke.true
    end
  end

  describe "'true?'" do 
    it "should return false" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string("nil true?").should == ioke.false
      ioke.evaluate_string("x = nil. x true?").should == ioke.false
    end
  end

  describe "'not'" do 
    it "should return true" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string("nil not").should == ioke.true
      ioke.evaluate_string("x = nil. x not").should == ioke.true
    end
  end

  describe "'and'" do 
    it "should not evaluate it's argument" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string("x=41. nil and(x=42). x").data.as_java_integer.should == 41
    end

    it "should return nil" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string("nil and(42)").should == ioke.nil
    end

    it "should be available in infix" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string("nil and 43").should == ioke.nil
    end
  end

  describe "'&&'" do 
    it "should not evaluate it's argument" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string("x=41. nil &&(x=42). x").data.as_java_integer.should == 41
    end

    it "should return nil" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string("nil &&(42)").should == ioke.nil
    end

    it "should be available in infix" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string("nil && 43").should == ioke.nil
    end
  end
  
  describe "'or'" do 
    it "should evaluate it's argument" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string("x=41. nil or(x=42). x").data.as_java_integer.should == 42
    end

    it "should complain if no argument is given" do 
      sw = StringWriter.new(20)
      out = PrintWriter.new(sw)

      ioke = IokeRuntime.get_runtime(out, InputStreamReader.new(System.in), out)
      proc do 
        ioke.evaluate_string("nil or()")
      end.should raise_error
    end

    it "should return the result of the argument" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string("nil or(42)").data.as_java_integer.should == 42
    end

    it "should be available in infix" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string("nil or 43").data.as_java_integer.should == 43
    end
  end
  
  describe "'||'" do 
    it "should evaluate it's argument" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string("x=41. nil ||(x=42). x").data.as_java_integer.should == 42
    end

    it "should complain if no argument is given" do 
      sw = StringWriter.new(20)
      out = PrintWriter.new(sw)

      ioke = IokeRuntime.get_runtime(out, InputStreamReader.new(System.in), out)
      proc do 
        ioke.evaluate_string("nil ||()")
      end.should raise_error
    end

    it "should return the result of the argument" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string("nil ||(42)").data.as_java_integer.should == 42
    end

    it "should be available in infix" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string("nil || 43").data.as_java_integer.should == 43
    end
  end
  
  describe "'xor'" do 
    it "should evaluate it's argument" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string("x=41. false xor(x=42). x").data.as_java_integer.should == 42
    end

    it "should complain if no argument is given" do 
      sw = StringWriter.new(20)
      out = PrintWriter.new(sw)

      ioke = IokeRuntime.get_runtime(out, InputStreamReader.new(System.in), out)
      proc do 
        ioke.evaluate_string("false xor()")
      end.should raise_error
    end

    it "should return true if the argument is true" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string("false xor(true)").should == ioke.true
    end

    it "should return false if the argument is false" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string("false xor(false)").should == ioke.false
    end

    it "should return false if the argument is nil" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string("false xor(nil)").should == ioke.false
    end
    
    it "should be available in infix" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string("false xor 43").should == ioke.true
    end
  end

  describe "'nor'" do 
    it "should evaluate it's argument" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string("x=41. false nor(x=42). x").data.as_java_integer.should == 42
    end

    it "should complain if no argument is given" do 
      sw = StringWriter.new(20)
      out = PrintWriter.new(sw)

      ioke = IokeRuntime.get_runtime(out, InputStreamReader.new(System.in), out)
      proc do 
        ioke.evaluate_string("false nor()")
      end.should raise_error
    end

    it "should return false if the argument is true" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string("false nor(42)").should == ioke.false
    end

    it "should return false if the argument is false" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string("false nor(false)").should == ioke.true
    end

    it "should return false if the argument is nil" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string("false nor(nil)").should == ioke.true
    end

    it "should be available in infix" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string("false nor 43").should == ioke.false
    end
  end

  describe "'nand'" do 
    it "should not evaluate it's argument" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string("x=41. nil nand(x=42). x").data.as_java_integer.should == 41
    end

    it "should return true" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string("nil nand(42)").should == ioke.true
      ioke.evaluate_string("nil nand(false)").should == ioke.true
      ioke.evaluate_string("nil nand(nil)").should == ioke.true
      ioke.evaluate_string("nil nand(true)").should == ioke.true
    end
    
    it "should be available in infix" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string("nil nand 43").should == ioke.true
    end
  end
end
