include_class('ioke.lang.Runtime') { 'IokeRuntime' } unless defined?(IokeRuntime)

describe "true" do 
  describe "'false?'" do 
    it "should return false" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string("true false?").should == ioke.false
      ioke.evaluate_string("x = true. x false?").should == ioke.false
    end
  end

  describe "'true?'" do 
    it "should return true" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string("true true?").should == ioke.true
      ioke.evaluate_string("x = true. x true?").should == ioke.true
    end
  end

  describe "'not'" do 
    it "should return false" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string("true not").should == ioke.false
      ioke.evaluate_string("x = true. x not").should == ioke.false
    end
  end

  describe "'and'" do 
    it "should evaluate it's argument" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string("x=41. true and(x=42). x").data.as_java_integer.should == 42
    end

    it "should complain if no argument is given" do 
      ioke = IokeRuntime.get_runtime
      proc do 
        ioke.evaluate_string("true and()")
      end.should raise_error
    end

    it "should return the result of the argument" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string("true and(42)").data.as_java_integer.should == 42
    end

    it "should be available in infix" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string("true and 43").data.as_java_integer.should == 43
    end
  end

  describe "'or'" do 
    it "should not evaluate it's argument" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string("x=41. true or(x=42). x").data.as_java_integer.should == 41
    end

    it "should return true" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string("true or(42)").should == ioke.true
    end

    it "should be available in infix" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string("true or 43").should == ioke.true
    end
  end

  describe "'xor'" do 
    it "should evaluate it's argument" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string("x=41. true xor(x=42). x").data.as_java_integer.should == 42
    end

    it "should complain if no argument is given" do 
      ioke = IokeRuntime.get_runtime
      proc do 
        ioke.evaluate_string("true xor()")
      end.should raise_error
    end

    it "should return false if the argument is true" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string("true xor(true)").should == ioke.false
    end

    it "should return true if the argument is false" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string("true xor(false)").should == ioke.true
    end

    it "should return true if the argument is nil" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string("true xor(nil)").should == ioke.true
    end
    
    it "should be available in infix" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string("true xor 43").should == ioke.false
    end
  end

  describe "'nor'" do 
    it "should not evaluate it's argument" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string("x=41. true nor(x=42). x").data.as_java_integer.should == 41
    end

    it "should return false" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string("true nor(42)").should == ioke.false
    end

    it "should be available in infix" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string("true nor 43").should == ioke.false
    end
  end

  describe "'nand'" do 
    it "should evaluate it's argument" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string("x=41. true nand(x=42). x").data.as_java_integer.should == 42
    end

    it "should complain if no argument is given" do 
      ioke = IokeRuntime.get_runtime
      proc do 
        ioke.evaluate_string("true nand()")
      end.should raise_error
    end

    it "should return false if the argument evaluates to true" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string("true nand(42)").should == ioke.false
    end
    
    it "should return true if the argument evaluates to false" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string("true nand(false)").should == ioke.true
    end
    
    it "should return true if the argument evaluates to nil" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string("true nand(nil)").should == ioke.true
    end

    it "should be available in infix" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string("true nand 43").should == ioke.false
    end
  end
  
  describe "'ifTrue'" do 
    it "should execute it's argument" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string("x=41. true ifTrue(x=42). x").data.as_java_integer.should == 42
    end

    it "should return true" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string("true ifTrue(x=42)").should == ioke.true
    end
  end

  describe "'ifFalse'" do 
    it "should not execute it's argument" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string("x=41. true ifFalse(x=42). x").data.as_java_integer.should == 41
    end

    it "should return true" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string("true ifFalse(x=42)").should == ioke.true
    end
  end
end

describe "false" do 
  describe "'false?'" do 
    it "should return true" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string("false false?").should == ioke.true
      ioke.evaluate_string("x = false. x false?").should == ioke.true
    end
  end

  describe "'true?'" do 
    it "should return false" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string("false true?").should == ioke.false
      ioke.evaluate_string("x = false. x true?").should == ioke.false
    end
  end

  describe "'not'" do 
    it "should return true" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string("false not").should == ioke.true
      ioke.evaluate_string("x = false. x not").should == ioke.true
    end
  end

  describe "'and'" do 
    it "should not evaluate it's argument" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string("x=41. false and(x=42). x").data.as_java_integer.should == 41
    end

    it "should return false" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string("false and(42)").should == ioke.false
    end

    it "should be available in infix" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string("false and 43").should == ioke.false
    end
  end

  describe "'xor'" do 
    it "should evaluate it's argument" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string("x=41. false xor(x=42). x").data.as_java_integer.should == 42
    end

    it "should complain if no argument is given" do 
      ioke = IokeRuntime.get_runtime
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

  describe "'nand'" do 
    it "should not evaluate it's argument" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string("x=41. false nand(x=42). x").data.as_java_integer.should == 41
    end

    it "should return true" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string("false nand(42)").should == ioke.true
      ioke.evaluate_string("false nand(false)").should == ioke.true
      ioke.evaluate_string("false nand(nil)").should == ioke.true
      ioke.evaluate_string("false nand(true)").should == ioke.true
    end
    
    it "should be available in infix" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string("false nand 43").should == ioke.true
    end
  end

  describe "'or'" do 
    it "should evaluate it's argument" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string("x=41. false or(x=42). x").data.as_java_integer.should == 42
    end

    it "should complain if no argument is given" do 
      ioke = IokeRuntime.get_runtime
      proc do 
        ioke.evaluate_string("false or()")
      end.should raise_error
    end

    it "should return the result of the argument" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string("false or(42)").data.as_java_integer.should == 42
    end

    it "should be available in infix" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string("false or 43").data.as_java_integer.should == 43
    end
  end

  describe "'nor'" do 
    it "should evaluate it's argument" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string("x=41. false nor(x=42). x").data.as_java_integer.should == 42
    end

    it "should complain if no argument is given" do 
      ioke = IokeRuntime.get_runtime
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
  
  describe "'ifTrue'" do 
    it "should not execute it's argument" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string("x=41. false ifTrue(x=42). x").data.as_java_integer.should == 41
    end

    it "should return false" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string("false ifTrue(x=42)").should == ioke.false
    end
  end

  describe "'ifFalse'" do 
    it "should execute it's argument" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string("x=41. false ifFalse(x=42). x").data.as_java_integer.should == 42
    end

    it "should return false" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string("false ifFalse(x=42)").should == ioke.false
    end
  end
end
