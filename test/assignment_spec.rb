include_class('ioke.lang.Runtime') { 'IokeRuntime' } unless defined?(IokeRuntime)
include_class('ioke.lang.Text') unless defined?(Text)

import Java::java.io.StringReader unless defined?(StringReader)
import Java::java.io.PrintWriter unless defined?(PrintWriter)
import Java::java.io.StringWriter unless defined?(StringWriter)
import Java::java.io.InputStreamReader unless defined?(InputStreamReader)
import Java::java.lang.System unless defined?(System)

describe "DefaultBehavior" do 
  describe "'+='" do 
    it "should call + and then assign the result of this call to the same name" do 
      ioke = IokeRuntime.get_runtime()
      ioke.evaluate_string("x = 1. x += 2. x == 3").should == ioke.true
      ioke.evaluate_string("x = 42. x += -1. x == 41").should == ioke.true
    end
    
    it "should work with a place" do 
      ioke = IokeRuntime.get_runtime()
      ioke.evaluate_string("x = [1]. x[0] += 2. x[0] == 3").should == ioke.true
    end
  end

  describe "'-='" do 
    it "should call - and then assign the result of this call to the same name" do 
      ioke = IokeRuntime.get_runtime()
      ioke.evaluate_string("x = 2. x -= 1. x == 1").should == ioke.true
      ioke.evaluate_string("x = 42. x -= -1. x == 43").should == ioke.true
    end

    it "should work with a place" do 
      ioke = IokeRuntime.get_runtime()
      ioke.evaluate_string("x = [42]. x[0] -= 2. x[0] == 40").should == ioke.true
    end
  end

  describe "'/='" do 
    it "should call / and then assign the result of this call to the same name" do 
      ioke = IokeRuntime.get_runtime()
      ioke.evaluate_string("x = 12. x /= 2. x == 6").should == ioke.true
      ioke.evaluate_string("x = 150. x /= -2. x == -75").should == ioke.true
    end

    it "should work with a place" do 
      ioke = IokeRuntime.get_runtime()
      ioke.evaluate_string("x = [42]. x[0] /= 2. x[0] == 21").should == ioke.true
    end
  end

  describe "'*='" do 
    it "should call * and then assign the result of this call to the same name" do 
      ioke = IokeRuntime.get_runtime()
      ioke.evaluate_string("x = 12. x *= 2. x == 24").should == ioke.true
      ioke.evaluate_string("x = 150. x *= -2. x == -300").should == ioke.true
    end

    it "should work with a place" do 
      ioke = IokeRuntime.get_runtime()
      ioke.evaluate_string("x = [42]. x[0] *= 2. x[0] == 84").should == ioke.true
    end
  end

  describe "'**='" do 
    it "should call ** and then assign the result of this call to the same name" do 
      ioke = IokeRuntime.get_runtime()
      ioke.evaluate_string("x = 2. x **= 3. x == 8").should == ioke.true
      ioke.evaluate_string("x = 2. x **= 40. x == 1099511627776").should == ioke.true
    end

    it "should work with a place" do 
      ioke = IokeRuntime.get_runtime()
      ioke.evaluate_string("x = [3]. x[0] **= 2. x[0] == 9").should == ioke.true
    end
  end

  describe "'%='" do 
    it "should call % and then assign the result of this call to the same name" do 
      ioke = IokeRuntime.get_runtime()
      ioke.evaluate_string("x = 12. x %= 5. x == 2").should == ioke.true
      ioke.evaluate_string("x = 13. x %= 4. x == 1").should == ioke.true
    end

    it "should work with a place" do 
      ioke = IokeRuntime.get_runtime()
      ioke.evaluate_string("x = [42]. x[0] %= 4. x[0] == 2").should == ioke.true
    end
  end

  describe "'&='" do 
    it "should call & and then assign the result of this call to the same name" do 
      ioke = IokeRuntime.get_runtime()
      ioke.evaluate_string("x = 65535. x &= 1. x == 1").should == ioke.true
      ioke.evaluate_string("x = 8. x &= 8. x == 8").should == ioke.true
    end

    it "should work with a place" do 
      ioke = IokeRuntime.get_runtime()
      ioke.evaluate_string("x = [65535]. x[0] &= 1. x[0] == 1").should == ioke.true
    end
  end

  describe "'&&='" do 
    it "should not assign a cell if it doesn't exist" do 
      ioke = IokeRuntime.get_runtime()
      ioke.evaluate_string("x &&= 42. cell?(:x)").should == ioke.false
    end

    it "should not assign a cell if it is nil" do 
      ioke = IokeRuntime.get_runtime()
      ioke.evaluate_string("x = nil. x &&= 42. x == nil").should == ioke.true
    end

    it "should not assign a cell if it is false" do 
      ioke = IokeRuntime.get_runtime()
      ioke.evaluate_string("x = false. x &&= 42. x == false").should == ioke.true
    end

    it "should assign a cell that exist" do 
      ioke = IokeRuntime.get_runtime()
      ioke.evaluate_string("x = 43. x &&= 42. x == 42").should == ioke.true
    end

    it "should work with a place" do 
      ioke = IokeRuntime.get_runtime()
      ioke.evaluate_string("x = [1, 3]. x[1] &&= 42.     x == [1, 42]").should == ioke.true
      ioke.evaluate_string("x = [2, 3]. x[2] &&= 42.     x == [2, 3]").should == ioke.true
      ioke.evaluate_string("x = [3, nil]. x[1] &&= 42.   x == [3, nil]").should == ioke.true
      ioke.evaluate_string("x = [4, false]. x[1] &&= 42. x == [4, false]").should == ioke.true
    end
  end

  describe "'|='" do 
    it "should call | and then assign the result of this call to the same name" do 
      ioke = IokeRuntime.get_runtime()
      ioke.evaluate_string("x = 5. x |= 6. x == 7").should == ioke.true
      ioke.evaluate_string("x = 5. x |= 4. x == 5").should == ioke.true
    end

    it "should work with a place" do 
      ioke = IokeRuntime.get_runtime()
      ioke.evaluate_string("x = [5]. x[0] |= 6. x[0] == 7").should == ioke.true
    end
  end

  describe "'||='" do 
    it "should assign a cell if it doesn't exist" do 
      ioke = IokeRuntime.get_runtime()
      ioke.evaluate_string("x ||= 42. x == 42").should == ioke.true
    end

    it "should assign a cell if it is nil" do 
      ioke = IokeRuntime.get_runtime()
      ioke.evaluate_string("x = nil. x ||= 42. x == 42").should == ioke.true
    end

    it "should assign a cell if it is false" do 
      ioke = IokeRuntime.get_runtime()
      ioke.evaluate_string("x = false. x ||= 42. x == 42").should == ioke.true
    end

    it "should not assign a cell that exist" do 
      ioke = IokeRuntime.get_runtime()
      ioke.evaluate_string("x = 43. x ||= 42. x == 43").should == ioke.true
    end

    it "should work with a place" do 
      ioke = IokeRuntime.get_runtime()
      ioke.evaluate_string("x = [1, 3]. x[1] ||= 42.     x == [1, 3]").should == ioke.true
      ioke.evaluate_string("x = [2, 3]. x[2] ||= 42.     x == [2, 3, 42]").should == ioke.true
      ioke.evaluate_string("x = [3, nil]. x[1] ||= 42.   x == [3, 42]").should == ioke.true
      ioke.evaluate_string("x = [4, false]. x[1] ||= 42. x == [4, 42]").should == ioke.true
    end
  end

  describe "'^='" do 
    it "should call ^ and then assign the result of this call to the same name" do 
      ioke = IokeRuntime.get_runtime()
      ioke.evaluate_string("x = 3. x ^= 5. x == 6").should == ioke.true
      ioke.evaluate_string("x = -2. x ^= -255. x == 255").should == ioke.true
    end

    it "should work with a place" do 
      ioke = IokeRuntime.get_runtime()
      ioke.evaluate_string("x = [3]. x[0] ^= 5. x[0] == 6").should == ioke.true
    end
  end

  describe "'<<='" do 
    it "should call << and then assign the result of this call to the same name" do 
      ioke = IokeRuntime.get_runtime()
      ioke.evaluate_string("x = 7. x <<= 2. x == 28").should == ioke.true
      ioke.evaluate_string("x = 9. x <<= 4. x == 144").should == ioke.true
    end

    it "should work with a place" do 
      ioke = IokeRuntime.get_runtime()
      ioke.evaluate_string("x = [9]. x[0] <<= 4. x[0] == 144").should == ioke.true
    end
  end

  describe "'>>='" do 
    it "should call >> and then assign the result of this call to the same name" do 
      ioke = IokeRuntime.get_runtime()
      ioke.evaluate_string("x = 7. x >>= 1. x == 3").should == ioke.true
      ioke.evaluate_string("x = 4095. x >>= 3. x == 511").should == ioke.true
    end

    it "should work with a place" do 
      ioke = IokeRuntime.get_runtime()
      ioke.evaluate_string("x = [7]. x[0] >>= 1. x[0] == 3").should == ioke.true
    end
  end
end
