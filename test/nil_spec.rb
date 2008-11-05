include_class('ioke.lang.Runtime') { 'IokeRuntime' } unless defined?(IokeRuntime)

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

  describe "'or'" do 
    it "should evaluate it's argument" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string("x=41. nil or(x=42). x").data.as_java_integer.should == 42
    end

    it "should complain if no argument is given" do 
      ioke = IokeRuntime.get_runtime
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
end
