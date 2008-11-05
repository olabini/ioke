include_class('ioke.lang.Runtime') { 'IokeRuntime' } unless defined?(IokeRuntime)

describe "Call" do 
  describe "'ground'" do 
    it "should return the surrounding context of the call" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string("x = macro(call ground). == x").should == ioke.true
    end
  end

  describe "'message'" do 
    it "should return the message used to invoke this call" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string("x = macro(call message). x name").data.text.should == "x"
    end
  end

  describe "'argAt'" do 
    it "should evaluate and return the argument at the specific place" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string("x = macro(call argAt(0)). x(23+44)").data.as_java_integer.should == 67
    end

    it "should raise an error if no arg at the index specified was available" do 
      ioke = IokeRuntime.get_runtime
      proc do 
        ioke.evaluate_string("x = macro(call argAt(0)). x")
      end.should raise_error
    end
  end

  describe "'arguments'" do 
    it "should return all arguments in a list, unevaluated" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string("x = macro(call arguments). x(foo bar, x rrr)[0] name").data.text.should == "foo"
      ioke.evaluate_string("x = macro(call arguments). x(foo bar, x rrr)[1] name").data.text.should == "x"
    end
  end

  describe "'evaluatedArguments'" do 
    it "should return a list of all the evaluated arguments" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string("x = macro(call evaluatedArguments). x(13+55, 18+18, 3-2)[0]").data.as_java_integer.should == 68
      ioke.evaluate_string("x = macro(call evaluatedArguments). x(13+55, 18+18, 3-2)[1]").data.as_java_integer.should == 36
      ioke.evaluate_string("x = macro(call evaluatedArguments). x(13+55, 18+18, 3-2)[2]").data.as_java_integer.should == 1
    end
  end

  describe "'resendToMethod'" do 
    it "it should resend the thing with the same arguments" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string("x = macro(call resendToMethod(:f)). f = method(a, b, c, [a, b, c]). w = 13. x(1+w, w+w, w+3+w)[0]").data.as_java_integer.should == 14
      ioke.evaluate_string("x = macro(call resendToMethod(:f)). f = method(a, b, c, [a, b, c]). w = 13. x(1+w, w+w, w+3+w)[1]").data.as_java_integer.should == 26
      ioke.evaluate_string("x = macro(call resendToMethod(:f)). f = method(a, b, c, [a, b, c]). w = 13. x(1+w, w+w, w+3+w)[2]").data.as_java_integer.should == 29
    end
  end
end
