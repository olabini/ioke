include_class('ioke.lang.Runtime') { 'IokeRuntime' } unless defined?(IokeRuntime)

import Java::java.io.StringReader unless defined?(StringReader)
import Java::java.io.PrintWriter unless defined?(PrintWriter)
import Java::java.io.StringWriter unless defined?(StringWriter)
import Java::java.io.InputStreamReader unless defined?(InputStreamReader)
import Java::java.lang.System unless defined?(System)

describe "Number" do 
  describe "Integer" do 
    it "should have the correct kind" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string('Number Integer kind == "Number Integer"').should == ioke.true
    end

    it "should mimic Rational" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string('Number Integer mimics?(Number Rational)').should == ioke.true
    end

    it "should be the kind of simple numbers" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string('0 kind == "Number Integer"').should == ioke.true
      ioke.evaluate_string('1 kind == "Number Integer"').should == ioke.true
      ioke.evaluate_string('255 kind == "Number Integer"').should == ioke.true
      ioke.evaluate_string('-1 kind == "Number Integer"').should == ioke.true
      ioke.evaluate_string('43534564356356456456 kind == "Number Integer"').should == ioke.true
      ioke.evaluate_string('0xFFF kind == "Number Integer"').should == ioke.true
    end
    
    describe "'%'" do 
      it "should return the number when taking the modulo of 0" do 
        ioke = IokeRuntime.get_runtime
        ioke.evaluate_string("0%0 == 0").should == ioke.true
        ioke.evaluate_string("13%0 == 13").should == ioke.true
        ioke.evaluate_string("-10%0 == -10").should == ioke.true
      end
      
      it "should return the regular modulus" do 
        ioke = IokeRuntime.get_runtime
        ioke.evaluate_string("13%4 == 1").should == ioke.true
        ioke.evaluate_string("4%13 == 4").should == ioke.true
        ioke.evaluate_string("1%2 == 1").should == ioke.true
      end 

      it "should return modulus for negative numbers" do 
        ioke = IokeRuntime.get_runtime
        ioke.evaluate_string("-13%4 == 3").should == ioke.true
        ioke.evaluate_string("-13%-4 == -1").should == ioke.true
        ioke.evaluate_string("13%-4 == -3").should == ioke.true
      end

      it "should convert its argument to a number if its not a number or a decimal" do 
        ioke = IokeRuntime.get_runtime()
        ioke.evaluate_string(<<CODE).data.as_java_integer.should == 1
x = Origin mimic
x asRational = method(3)
10 % x
CODE
      end

      it "should signal a condition if it isn't a number and can't be converted" do 
        sw = StringWriter.new(20)
        out = PrintWriter.new(sw)

        ioke = IokeRuntime.get_runtime(out, InputStreamReader.new(System.in), out)

        begin 
          ioke.evaluate_string('1 % Origin mimic').should == ioke.nil
          true.should be_false
        rescue NativeException => cfe
          cfe.cause.value.find_cell(nil, nil, "kind").data.text.should == "Condition Error Type IncorrectType"
        end
      end
    end
    
    describe "'times'" do 
      it "should not do anything for a negative number" do 
        ioke = IokeRuntime.get_runtime()
        ioke.evaluate_stream(StringReader.new("x = 0. (0-1) times(x++). x")).data.as_java_integer.should == 0
        ioke.evaluate_stream(StringReader.new("x = 0. (0-100) times(x++). x")).data.as_java_integer.should == 0
      end
      
      it "should not do anything for 0" do 
        ioke = IokeRuntime.get_runtime()
        ioke.evaluate_stream(StringReader.new("x = 0. 0 times(x++). x")).data.as_java_integer.should == 0
      end

      it "should execute the block one time for 1" do 
        ioke = IokeRuntime.get_runtime()
        ioke.evaluate_stream(StringReader.new("x = 0. 1 times(x++). x")).data.as_java_integer.should == 1
      end

      it "should execute the block the same number of times as the receiver" do 
        ioke = IokeRuntime.get_runtime()
        ioke.evaluate_stream(StringReader.new("x = 0. 12 times(x++). x")).data.as_java_integer.should == 12
        ioke.evaluate_stream(StringReader.new("x = 0. 343 times(x++). 343")).data.as_java_integer.should == 343
      end
    end

    describe "'&'" do 
      it "should bitwise and two powers of 8" do 
        ioke = IokeRuntime.get_runtime
        ioke.evaluate_string("(256&16) == 0").should == ioke.true
      end

      it "should bitwise and two zeroes" do 
        ioke = IokeRuntime.get_runtime
        ioke.evaluate_string("(0&0) == 0").should == ioke.true
      end

      it "should bitwise and other numbers" do 
        ioke = IokeRuntime.get_runtime
        ioke.evaluate_string("(2010&5) == 0").should == ioke.true
        ioke.evaluate_string("(65535&1) == 1").should == ioke.true
      end

      it "should bitwise and large numbers" do 
        ioke = IokeRuntime.get_runtime
        ioke.evaluate_string("(-1 & 2**64) == 18446744073709551616").should == ioke.true
      end

      it "should convert its argument to a number if its not a number or a decimal" do 
        ioke = IokeRuntime.get_runtime()
        ioke.evaluate_string(<<CODE).data.as_java_integer.should == 2
x = Origin mimic
x asRational = method(3)
10 & x
CODE
      end

      it "should signal a condition if it isn't a number and can't be converted" do 
        sw = StringWriter.new(20)
        out = PrintWriter.new(sw)

        ioke = IokeRuntime.get_runtime(out, InputStreamReader.new(System.in), out)

        begin 
          ioke.evaluate_string('1 & Origin mimic').should == ioke.nil
          true.should be_false
        rescue NativeException => cfe
          cfe.cause.value.find_cell(nil, nil, "kind").data.text.should == "Condition Error Type IncorrectType"
        end
      end
    end

    describe "'|'" do 
      it "should bitwise or two zeroes" do 
        ioke = IokeRuntime.get_runtime
        ioke.evaluate_string("(0|0) == 0").should == ioke.true
      end

      it "should bitwise or other numbers" do 
        ioke = IokeRuntime.get_runtime
        ioke.evaluate_string("(1|0) == 1").should == ioke.true
        ioke.evaluate_string("(5|4) == 5").should == ioke.true
        ioke.evaluate_string("(5|6) == 7").should == ioke.true
        ioke.evaluate_string("(248|4096) == 4344").should == ioke.true
      end
      
      it "should bitwise or negative and large numbers" do 
        ioke = IokeRuntime.get_runtime
        ioke.evaluate_string("(-1|2**64) == -1").should == ioke.true
      end

      it "should convert its argument to a number if its not a number or a decimal" do 
        ioke = IokeRuntime.get_runtime()
        ioke.evaluate_string(<<CODE).data.as_java_integer.should == 11
x = Origin mimic
x asRational = method(3)
10 | x
CODE
      end

      it "should signal a condition if it isn't a number and can't be converted" do 
        sw = StringWriter.new(20)
        out = PrintWriter.new(sw)

        ioke = IokeRuntime.get_runtime(out, InputStreamReader.new(System.in), out)

        begin 
          ioke.evaluate_string('1 | Origin mimic').should == ioke.nil
          true.should be_false
        rescue NativeException => cfe
          cfe.cause.value.find_cell(nil, nil, "kind").data.text.should == "Condition Error Type IncorrectType"
        end
      end
    end
    
    describe "'^'" do 
      it "should xor zeroes" do 
        ioke = IokeRuntime.get_runtime
        ioke.evaluate_string("(0^0) == 0").should == ioke.true
      end
      
      it "should xor regular numbers" do 
        ioke = IokeRuntime.get_runtime
        ioke.evaluate_string("(1^0) == 1").should == ioke.true
        ioke.evaluate_string("(1^1) == 0").should == ioke.true
        ioke.evaluate_string("(0^1) == 1").should == ioke.true
        ioke.evaluate_string("(3^5) == 6").should == ioke.true
        ioke.evaluate_string("(-2^-255) == 255").should == ioke.true
      end
      
      it "should xor large numbers" do 
        ioke = IokeRuntime.get_runtime
        ioke.evaluate_string("(-1 ^ 2**64) == -18446744073709551617").should == ioke.true
      end

      it "should convert its argument to a number if its not a number or a decimal" do 
        ioke = IokeRuntime.get_runtime()
        ioke.evaluate_string(<<CODE).data.as_java_integer.should == 9
x = Origin mimic
x asRational = method(3)
10 ^ x
CODE
      end

      it "should signal a condition if it isn't a number and can't be converted" do 
        sw = StringWriter.new(20)
        out = PrintWriter.new(sw)

        ioke = IokeRuntime.get_runtime(out, InputStreamReader.new(System.in), out)

        begin 
          ioke.evaluate_string('1 ^ Origin mimic').should == ioke.nil
          true.should be_false
        rescue NativeException => cfe
          cfe.cause.value.find_cell(nil, nil, "kind").data.text.should == "Condition Error Type IncorrectType"
        end
      end
    end

    describe "'>>'" do 
      it "returns self shifted the given amount of bits to the right" do
        ioke = IokeRuntime.get_runtime
        ioke.evaluate_string("7 >> 1 == 3").should == ioke.true
        ioke.evaluate_string("4095 >> 3 == 511").should == ioke.true
        ioke.evaluate_string("9245278 >> 1 == 4622639").should == ioke.true
      end

      it "performs a left-shift if given a negative value" do
        ioke = IokeRuntime.get_runtime
        ioke.evaluate_string("7 >> -1 == 7 << 1").should == ioke.true
        ioke.evaluate_string("4095 >> -3 == 4095 << 3").should == ioke.true
      end
      
      it "performs a right-shift if given a negative value as receiver" do
        ioke = IokeRuntime.get_runtime
        ioke.evaluate_string("-7 >> 1 == -4").should == ioke.true
        ioke.evaluate_string("-4095 >> 3 == -512").should == ioke.true
      end

      it "should convert its argument to a number if its not a number or a decimal" do 
        ioke = IokeRuntime.get_runtime()
        ioke.evaluate_string(<<CODE).data.as_java_integer.should == 3
x = Origin mimic
x asRational = method(1)
7 >> x
CODE
      end

      it "should signal a condition if it isn't a number and can't be converted" do 
        sw = StringWriter.new(20)
        out = PrintWriter.new(sw)

        ioke = IokeRuntime.get_runtime(out, InputStreamReader.new(System.in), out)

        begin 
          ioke.evaluate_string('1 >> Origin mimic').should == ioke.nil
          true.should be_false
        rescue NativeException => cfe
          cfe.cause.value.find_cell(nil, nil, "kind").data.text.should == "Condition Error Type IncorrectType"
        end
      end
    end

    describe "'<< '" do 
      it "returns self shifted the given amount of bits to the left" do 
        ioke = IokeRuntime.get_runtime
        ioke.evaluate_string("7<<2 == 28").should == ioke.true
        ioke.evaluate_string("9<<4 == 144").should == ioke.true
      end
      
      it "performs a right shift if given a negative value" do 
        ioke = IokeRuntime.get_runtime
        ioke.evaluate_string("7<<-2 == 7>>2").should == ioke.true
        ioke.evaluate_string("9<<-4 == 9>>4").should == ioke.true
      end
      
      it "should left shift a large number" do 
        ioke = IokeRuntime.get_runtime
        ioke.evaluate_string("6<<255 == 347376267711948586270712955026063723559809953996921692118372752023739388919808").should == ioke.true
      end

      it "should convert its argument to a number if its not a number or a decimal" do 
        ioke = IokeRuntime.get_runtime()
        ioke.evaluate_string(<<CODE).data.as_java_integer.should == 28
x = Origin mimic
x asRational = method(2)
7 << x
CODE
      end

      it "should signal a condition if it isn't a number and can't be converted" do 
        sw = StringWriter.new(20)
        out = PrintWriter.new(sw)

        ioke = IokeRuntime.get_runtime(out, InputStreamReader.new(System.in), out)

        begin 
          ioke.evaluate_string('1 << Origin mimic').should == ioke.nil
          true.should be_false
        rescue NativeException => cfe
          cfe.cause.value.find_cell(nil, nil, "kind").data.text.should == "Condition Error Type IncorrectType"
        end
      end
    end

    describe "'succ'" do 
      it "should return the successor of 0" do 
        ioke = IokeRuntime.get_runtime()
        ioke.evaluate_stream(StringReader.new("0 succ")).data.as_java_integer.should == 1
      end

      it "should return the successor of a small positive number" do 
        ioke = IokeRuntime.get_runtime()
        ioke.evaluate_stream(StringReader.new("1 succ")).data.as_java_integer.should == 2
        ioke.evaluate_stream(StringReader.new("12 succ")).data.as_java_integer.should == 13
        ioke.evaluate_stream(StringReader.new("41 succ")).data.as_java_integer.should == 42
        ioke.evaluate_stream(StringReader.new("99 succ")).data.as_java_integer.should == 100
      end

      it "should return the successor of a large positive number" do 
        ioke = IokeRuntime.get_runtime()
        ioke.evaluate_stream(StringReader.new("465467257434567 succ")).data.as_java_string.should == "465467257434568"
        ioke.evaluate_stream(StringReader.new("5999999999999999999 succ")).data.as_java_string.should == "6000000000000000000"
        ioke.evaluate_stream(StringReader.new("65535 succ")).data.as_java_string.should == "65536"
        ioke.evaluate_stream(StringReader.new("34565464575678567876852464563575468678567835678456865785678 succ")).data.as_java_string.should == "34565464575678567876852464563575468678567835678456865785679"
      end

      it "should return the successor of a negative number" do 
        ioke = IokeRuntime.get_runtime()
        ioke.evaluate_stream(StringReader.new("(0-1) succ")).data.as_java_integer.should == 0
        ioke.evaluate_stream(StringReader.new("(0-2) succ")).data.as_java_integer.should == -1
        ioke.evaluate_stream(StringReader.new("(0-10) succ")).data.as_java_integer.should == -9
        ioke.evaluate_stream(StringReader.new("(0-23534634654367) succ")).data.as_java_string.should == "-23534634654366"
      end
    end

    describe "'pred'" do 
      it "should return the predecessor of 0" do 
        ioke = IokeRuntime.get_runtime()
        ioke.evaluate_stream(StringReader.new("0 pred")).data.as_java_integer.should == -1
      end

      it "should return the predecessor of a small positive number" do 
        ioke = IokeRuntime.get_runtime()
        ioke.evaluate_stream(StringReader.new("1 pred")).data.as_java_integer.should == 0
        ioke.evaluate_stream(StringReader.new("2 pred")).data.as_java_integer.should == 1
        ioke.evaluate_stream(StringReader.new("12 pred")).data.as_java_integer.should == 11
        ioke.evaluate_stream(StringReader.new("41 pred")).data.as_java_integer.should == 40
        ioke.evaluate_stream(StringReader.new("99 pred")).data.as_java_integer.should == 98
      end

      it "should return the predecessor of a large positive number" do 
        ioke = IokeRuntime.get_runtime()
        ioke.evaluate_stream(StringReader.new("465467257434567 pred")).data.as_java_string.should == "465467257434566"
        ioke.evaluate_stream(StringReader.new("6000000000000000000 pred")).data.as_java_string.should == "5999999999999999999"
        ioke.evaluate_stream(StringReader.new("65536 pred")).data.as_java_string.should == "65535"
        ioke.evaluate_stream(StringReader.new("34565464575678567876852464563575468678567835678456865785678 pred")).data.as_java_string.should == "34565464575678567876852464563575468678567835678456865785677"
      end

      it "should return the predecessor of a negative number" do 
        ioke = IokeRuntime.get_runtime()
        ioke.evaluate_stream(StringReader.new("(0-1) pred")).data.as_java_integer.should == -2
        ioke.evaluate_stream(StringReader.new("(0-2) pred")).data.as_java_integer.should == -3
        ioke.evaluate_stream(StringReader.new("(0-10) pred")).data.as_java_integer.should == -11
        ioke.evaluate_stream(StringReader.new("(0-23534634654367) pred")).data.as_java_string.should == "-23534634654368"
      end
    end
  end

  describe "Ratio" do 
    it "should have the correct kind" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string('Number Ratio kind == "Number Ratio"').should == ioke.true
    end

    it "should mimic Rational" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string('Number Ratio mimics?(Number Rational)').should == ioke.true
    end
  end
end
