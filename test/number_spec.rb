include_class('ioke.lang.Runtime') { 'IokeRuntime' } unless defined?(IokeRuntime)

import Java::java.io.StringReader unless defined?(StringReader)
import Java::java.io.PrintWriter unless defined?(PrintWriter)
import Java::java.io.StringWriter unless defined?(StringWriter)
import Java::java.io.InputStreamReader unless defined?(InputStreamReader)
import Java::java.lang.System unless defined?(System)

describe "Number" do 
  describe "Decimal" do 
    it "should have the correct kind" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string('Number Decimal kind == "Number Decimal"').should == ioke.true
    end

    it "should mimic Real" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string('Number Decimal mimics?(Number Real)').should == ioke.true
    end

    it "should be the kind of simple decimal numbers" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string('0.0 kind == "Number Decimal"').should == ioke.true
      ioke.evaluate_string('1.0 kind == "Number Decimal"').should == ioke.true
      ioke.evaluate_string('424345.255 kind == "Number Decimal"').should == ioke.true
      ioke.evaluate_string('-1.0 kind == "Number Decimal"').should == ioke.true
      ioke.evaluate_string('435345643563.56456456 kind == "Number Decimal"').should == ioke.true
      ioke.evaluate_string('10e6 kind == "Number Decimal"').should == ioke.true
    end

    describe "'=='" do 
      it "should return true for the same number" do 
        ioke = IokeRuntime.get_runtime()
        ioke.evaluate_string("x = 1.0. x == x").should == ioke.true
        ioke.evaluate_string("x = 10.0. x == x").should == ioke.true
        ioke.evaluate_string("x = -20.0. x == x").should == ioke.true
      end

      it "should not return true for unequal numbers" do 
        ioke = IokeRuntime.get_runtime()
        ioke.evaluate_string("1.1 == 2.0").should == ioke.false
        ioke.evaluate_string("1.2 == 200000.0").should == ioke.false
        ioke.evaluate_string("1123223.3233223 == 65756756756.0").should == ioke.false
        ioke.evaluate_string("-1.0 == 2.0").should == ioke.false
      end
      
      it "should return true for the result of equal number calculations" do 
        ioke = IokeRuntime.get_runtime()
        ioke.evaluate_string("(1.0+1.0) == 2.0").should == ioke.true
        ioke.evaluate_string("(2.1+1.0) == (1.1+2.0)").should == ioke.true
      end

      it "should work correctly when comparing zeroes" do 
        ioke = IokeRuntime.get_runtime()
        ioke.evaluate_string("0.0 == 0.0").should == ioke.true
        ioke.evaluate_string("1.0 == 0.0").should == ioke.false
        ioke.evaluate_string("0.0 == 1.0").should == ioke.false
      end

      it "should work correctly when comparing negative numbers" do 
        ioke = IokeRuntime.get_runtime()
        ioke.evaluate_string("(0.0-19.1) == (0.0-19.1)").should == ioke.true
        ioke.evaluate_string("(0.0-19.0) == (0.0-20.1)").should == ioke.false
      end

      it "should work correctly when comparing large positive numbers" do 
        ioke = IokeRuntime.get_runtime()
        ioke.evaluate_string("123234534675676786789678985463456345.234234 == 123234534675676786789678985463456345.234234").should == ioke.true
        ioke.evaluate_string("8888856676776.0101 == 8888856676776.0101").should == ioke.true
      end

      it "should convert its argument to a decimal if it is a rational" do 
        ioke = IokeRuntime.get_runtime()
        ioke.evaluate_string("2.0 == 2").should == ioke.true
        ioke.evaluate_string("2.1 == 2").should == ioke.false
      end

      it "should return false for comparisons against unrelated objects" do 
        ioke = IokeRuntime.get_runtime()
        ioke.evaluate_string("2.1 == \"foo\"").should == ioke.false
        ioke.evaluate_string("2.1 == :blarg").should == ioke.false
      end
    end
    
    describe "'<=>'" do 
      it "should return 0 for the same number" do 
        ioke = IokeRuntime.get_runtime()
        ioke.evaluate_string(("0.0<=>0.0")).data.as_java_integer.should == 0
        ioke.evaluate_string(("1.0<=>1.0")).data.as_java_integer.should == 0
        ioke.evaluate_string(("10.0<=>10.0")).data.as_java_integer.should == 0
        ioke.evaluate_string(("12413423523452345345345.0<=>12413423523452345345345.0")).data.as_java_integer.should == 0
        ioke.evaluate_string(("(0.0-1.0)<=>(0.0-1.0)")).data.as_java_integer.should == 0
        ioke.evaluate_string(("1.2<=>1.2")).data.as_java_integer.should == 0
      end

      it "should return 1 when the left number is larger than the right" do 
        ioke = IokeRuntime.get_runtime()
        ioke.evaluate_string(("1.0<=>0.0")).data.as_java_integer.should == 1
        ioke.evaluate_string(("2.0<=>1.0")).data.as_java_integer.should == 1
        ioke.evaluate_string(("10.0<=>9.0")).data.as_java_integer.should == 1
        ioke.evaluate_string(("12413423523452345345345.0<=>12413423523452345345344.0")).data.as_java_integer.should == 1
        ioke.evaluate_string(("0.0<=>(0.0-1.0)")).data.as_java_integer.should == 1
        ioke.evaluate_string(("1.0<=>(0.0-1.0)")).data.as_java_integer.should == 1
        ioke.evaluate_string(("0.001<=>0.0009")).data.as_java_integer.should == 1
        ioke.evaluate_string(("0.2<=>0.1")).data.as_java_integer.should == 1
      end

      it "should return -1 when the left number is smaller than the right" do 
        ioke = IokeRuntime.get_runtime()
        ioke.evaluate_string(("0.0<=>1.0")).data.as_java_integer.should == -1
        ioke.evaluate_string(("1.0<=>2.0")).data.as_java_integer.should == -1
        ioke.evaluate_string(("9.0<=>10.0")).data.as_java_integer.should == -1
        ioke.evaluate_string(("12413423523452345345343.0<=>12413423523452345345344.0")).data.as_java_integer.should == -1
        ioke.evaluate_string(("(0.0-1.0)<=>0.0")).data.as_java_integer.should == -1
        ioke.evaluate_string(("(0.0-1.0)<=>1.0")).data.as_java_integer.should == -1
        ioke.evaluate_string(("0.0009<=>0.001")).data.as_java_integer.should == -1
        ioke.evaluate_string(("0.1<=>0.2")).data.as_java_integer.should == -1
      end

      it "should convert argument to a decimal if the argument is a rational" do 
        ioke = IokeRuntime.get_runtime()
        ioke.evaluate_string("1.0<=>1").data.as_java_integer.should == 0
        ioke.evaluate_string("1.1<=>1").data.as_java_integer.should == 1
        ioke.evaluate_string("0.9<=>1").data.as_java_integer.should == -1
      end

      it "should convert its argument to a decimal if its not a rational or a decimal" do 
        ioke = IokeRuntime.get_runtime()
        ioke.evaluate_string(<<CODE).data.as_java_integer.should == 0
x = Origin mimic
x asDecimal = method(42.0)
42.0 <=> x
CODE
      end
      
      it "should return nil if it can't be converted and there is no way of comparing" do 
        ioke = IokeRuntime.get_runtime()
        ioke.evaluate_string('1.0 <=> Origin mimic').should == ioke.nil
      end
    end

    describe "'-'" do 
      it "should return 0.0 for the difference between 0.0 and 0.0" do 
        ioke = IokeRuntime.get_runtime()
        ioke.evaluate_string("0.0-0.0").data.as_java_string.should == "0.0"
      end
      
      it "should return the difference between really large numbers" do 
        ioke = IokeRuntime.get_runtime()
        ioke.evaluate_string("123435334645674745675675757.1-123435334645674745675675756.1").data.as_java_string.should == "1.0"
        ioke.evaluate_string(("123435334645674745675675757.2-1.1")).data.as_java_string.should == "123435334645674745675675756.1"
        ioke.evaluate_string(("123435334645674745675675757.0-24334534544345345345345.0")).data.as_java_string.should == "123411000111130400330330412.0"
      end
      
      it "should return the difference between smaller numbers" do 
        ioke = IokeRuntime.get_runtime()
        ioke.evaluate_string(("1.0-1.0")).data.as_java_string.should == "0.0"
        ioke.evaluate_string(("0.0-1.0")).data.as_java_string.should == "-1.0"
        ioke.evaluate_string(("2.0-1.0")).data.as_java_string.should == "1.0"
        ioke.evaluate_string(("10.0-5.0")).data.as_java_string.should == "5.0"
        ioke.evaluate_string(("234.0-30.0")).data.as_java_string.should == "204.0"
        ioke.evaluate_string(("30.0-35.0")).data.as_java_string.should == "-5.0"
      end
      
      it "should return the difference between negative numbers" do 
        ioke = IokeRuntime.get_runtime()
        ioke.evaluate_string(("(0.0-1.0)-1.0")).data.as_java_string.should == "-2.0"
        ioke.evaluate_string(("(0.0-1.0)-5.0")).data.as_java_string.should == "-6.0"
        ioke.evaluate_string(("(0.0-1.0)-(0.0-5.0)")).data.as_java_string.should == "4.0"
        ioke.evaluate_string(("(0.0-10.0)-5.0")).data.as_java_string.should == "-15.0"
        ioke.evaluate_string("(0.0-10.0)-(0.0-5.0)").data.as_java_string.should == "-5.0"
        ioke.evaluate_string("(0.0-2545345345346547456756.0)-(0.0-2545345345346547456755.0)").data.as_java_string.should == "-1.0"
      end

      it "should return the number when 0 is the argument" do 
        ioke = IokeRuntime.get_runtime()
        ioke.evaluate_string("(0.0-1.0)-0.0").data.as_java_string.should == "-1.0"
        ioke.evaluate_string("10.0-0.0").data.as_java_string.should == "10.0"
        ioke.evaluate_string("1325234534634564564576367.0-0.0").data.as_java_string.should == "1325234534634564564576367.0"
      end

      it "should convert its argument to a decimal if its not a decimal" do 
        ioke = IokeRuntime.get_runtime()
        ioke.evaluate_string("1.6-1").data.as_java_string.should == "0.6"
        ioke.evaluate_string("3.2-2").data.as_java_string.should == "1.2"
      end

      it "should convert its argument to a decimal with asDecimal if its not a decimal and not a rational" do 
        ioke = IokeRuntime.get_runtime()
        ioke.evaluate_string(<<CODE).data.as_java_string.should == "1.4"
x = Origin mimic
x asDecimal = method(42.0)
43.4 - x
CODE
      end

      it "should signal a condition if it isn't a number and can't be converted" do 
        sw = StringWriter.new(20)
        out = PrintWriter.new(sw)

        ioke = IokeRuntime.get_runtime(out, InputStreamReader.new(System.in), out)

        begin 
          ioke.evaluate_string('1.0 - Origin mimic').should == ioke.nil
          true.should be_false
        rescue NativeException => cfe
          cfe.cause.value.find_cell(nil, nil, "kind").data.text.should == "Condition Error Type IncorrectType"
        end
      end
    end

    describe "'+'" do 
      it "should return 0.0 for the sum of 0.0 and 0.0" do 
        ioke = IokeRuntime.get_runtime()
        ioke.evaluate_string(("0.0+0.0")).data.as_java_string.should == "0.0"
      end

      it "should return the sum of really large numbers" do 
        ioke = IokeRuntime.get_runtime()
        ioke.evaluate_string(("234235345636345634567345675467.1+1.2")).data.as_java_string.should == "234235345636345634567345675468.3"
        ioke.evaluate_string(("21342342342345345.0+778626453756754687567865785678.1")).data.as_java_string.should == "778626453756776029910208131023.1"
        ioke.evaluate_string(("234234.0+63456345745676574567571345456345645675674567878567856785678657856568768.0")).data.
          as_java_string.should == "63456345745676574567571345456345645675674567878567856785678657856803002.0"
      end

      it "should return the sum of smaller numbers" do 
        ioke = IokeRuntime.get_runtime()
        ioke.evaluate_string(("1.0+1.1")).data.as_java_string.should == "2.1"
        ioke.evaluate_string(("10.0+1.0")).data.as_java_string.should == "11.0"
        ioke.evaluate_string(("15.5+15.0")).data.as_java_string.should == "30.5"
        ioke.evaluate_string(("16.0+15.0")).data.as_java_string.should == "31.0"
      end

      it "should return the sum of negative numbers" do 
        ioke = IokeRuntime.get_runtime()
        ioke.evaluate_string(("1.0+(0.0-1.0)")).data.as_java_string.should == "0.0"
        ioke.evaluate_string(("(0.0-1.0)+2.0")).data.as_java_string.should == "1.0"
        ioke.evaluate_string(("(0.0-1.0)+(0.0-1.0)")).data.as_java_string.should == "-2.0"
      end

      it "should return the number when 0.0 is the receiver" do 
        ioke = IokeRuntime.get_runtime()
        ioke.evaluate_string(("0.0+1.0")).data.as_java_string.should == "1.0"
        ioke.evaluate_string(("0.0+(0.0-1.0)")).data.as_java_string.should == "-1.0"
        ioke.evaluate_string(("0.0+124423.0")).data.as_java_string.should == "124423.0"
        ioke.evaluate_string(("0.0+34545636745678657856786786785678.1")).data.as_java_string.should == "34545636745678657856786786785678.1"
      end

      it "should return the number when 0.0 is the argument" do 
        ioke = IokeRuntime.get_runtime()
        ioke.evaluate_string(("1.3+0.0")).data.as_java_string.should == "1.3"
        ioke.evaluate_string(("(0.0-1.0)+0.0")).data.as_java_string.should == "-1.0"
        ioke.evaluate_string(("124423.0+0.0")).data.as_java_string.should == "124423.0"
        ioke.evaluate_string(("34545636745678657856786786785678.0+0.0")).data.as_java_string.should == "34545636745678657856786786785678.0"
      end

      it "should convert its argument to a decimal if its not a decimal" do 
        ioke = IokeRuntime.get_runtime()
        ioke.evaluate_string("0.6+1").data.as_java_string.should == "1.6"
        ioke.evaluate_string("1.2+3").data.as_java_string.should == "4.2"
      end

      it "should convert its argument to a decimal with asDecimal if its not a decimal and not a rational" do 
        ioke = IokeRuntime.get_runtime()
        ioke.evaluate_string(<<CODE).data.as_java_string.should == "42.2"
x = Origin mimic
x asDecimal = method(41.1)
1.1 + x
CODE
      end
      
      it "should signal a condition if it isn't a decimal and can't be converted" do 
        sw = StringWriter.new(20)
        out = PrintWriter.new(sw)

        ioke = IokeRuntime.get_runtime(out, InputStreamReader.new(System.in), out)

        begin 
          ioke.evaluate_string('1.0 + Origin mimic').should == ioke.nil
          true.should be_false
        rescue NativeException => cfe
          cfe.cause.value.find_cell(nil, nil, "kind").data.text.should == "Condition Error Type IncorrectType"
        end
      end
    end
    
    
    describe "'*'" do 
      it "should multiply with 0.0" do 
        ioke = IokeRuntime.get_runtime
        ioke.evaluate_string("1.0*0.0 == 0.0").should == ioke.true
        ioke.evaluate_string("34253453.0*0.0 == 0.0").should == ioke.true
        ioke.evaluate_string("-1.0*0.0 == 0.0").should == ioke.true
      end

      it "should return the same number when multiplying with 1.0" do 
        ioke = IokeRuntime.get_runtime
        ioke.evaluate_string("1.0*1.0 == 1.0").should == ioke.true
        ioke.evaluate_string("34253453.1*1.0 == 34253453.1").should == ioke.true
        ioke.evaluate_string("-1.0*1.0 == -1.0").should == ioke.true
      end

      it "should return a really large number when multiplying large numbers" do 
        ioke = IokeRuntime.get_runtime
        ioke.evaluate_string("2345346456745722.0*12213212323899088545.0 == 28644214249339912541248622627954490.0").should == ioke.true
      end

      it "should return a negative number when multiplying with one negative number" do 
        ioke = IokeRuntime.get_runtime
        ioke.evaluate_string("-21.0*2.0 == -42.0").should == ioke.true
      end

      it "should return a positive number when multiplying with two negative numbers" do 
        ioke = IokeRuntime.get_runtime
        ioke.evaluate_string("-21.0*-2.0 == 42.0").should == ioke.true
      end

      it "should convert its argument to a decimal if its not a decimal" do 
        ioke = IokeRuntime.get_runtime()
        ioke.evaluate_string("0.6*2").data.as_java_string.should == "1.2"
        ioke.evaluate_string("1.2*3").data.as_java_string.should == "3.6"
      end

      it "should convert its argument to a decimal with asDecimal if its not a decimal and not a rational" do 
        ioke = IokeRuntime.get_runtime()
        ioke.evaluate_string(<<CODE).data.as_java_string.should == "42.4"
x = Origin mimic
x asDecimal = method(21.2)
2.0 * x
CODE
      end
      
      it "should signal a condition if it isn't a decimal and can't be converted" do 
        sw = StringWriter.new(20)
        out = PrintWriter.new(sw)

        ioke = IokeRuntime.get_runtime(out, InputStreamReader.new(System.in), out)

        begin 
          ioke.evaluate_string('1.0 * Origin mimic').should == ioke.nil
          true.should be_false
        rescue NativeException => cfe
          cfe.cause.value.find_cell(nil, nil, "kind").data.text.should == "Condition Error Type IncorrectType"
        end
      end
    end
    
    describe "'/'" do 
      it "should cause a condition when dividing with 0.0" do 
        sw = StringWriter.new(20)
        out = PrintWriter.new(sw)

        ioke = IokeRuntime.get_runtime(out, InputStreamReader.new(System.in), out)

        begin 
          ioke.evaluate_string("10.0/0.0")
          true.should be_false
        rescue NativeException => cfe
          cfe.cause.value.find_cell(nil, nil, "kind").data.text.should == "Condition Error Arithmetic DivisionByZero"
        end
      end

      it "should divide simple numbers" do 
        ioke = IokeRuntime.get_runtime
        ioke.evaluate_string("2.0/1.0 == 2.0").should == ioke.true
        ioke.evaluate_string("4.2/2.0 == 2.1").should == ioke.true
        ioke.evaluate_string("200.0/5.0 == 40.0").should == ioke.true
      end

      it "should divide negative numbers correctly" do 
        ioke = IokeRuntime.get_runtime
        ioke.evaluate_string("-8200.0/10.0 == -820.0").should == ioke.true
      end

      it "should divide with a negative dividend correctly" do 
        ioke = IokeRuntime.get_runtime
        ioke.evaluate_string("8200.0/-10.0 == -820.0").should == ioke.true
      end

      it "should divide a negative number with a negative dividend" do 
        ioke = IokeRuntime.get_runtime
        ioke.evaluate_string("-8200.0/-10.0 == 820.0").should == ioke.true
      end

      it "should convert its argument to a decimal if its not a decimal" do 
        ioke = IokeRuntime.get_runtime()
        ioke.evaluate_string("0.5/5").data.as_java_string.should == "0.1"
        ioke.evaluate_string("3.4/2").data.as_java_string.should == "1.7"
      end
      
      it "should convert its argument to a decimal with asDecimal if its not a decimal and not a rational" do 
        ioke = IokeRuntime.get_runtime()
        ioke.evaluate_string(<<CODE).data.as_java_string.should == "21.4"
x = Origin mimic
x asDecimal = method(2.0)
42.8 / x
CODE
      end

      it "should signal a condition if it isn't a decimal and can't be converted" do 
        sw = StringWriter.new(20)
        out = PrintWriter.new(sw)

        ioke = IokeRuntime.get_runtime(out, InputStreamReader.new(System.in), out)

        begin 
          ioke.evaluate_string('1.0 / Origin mimic').should == ioke.nil
          true.should be_false
        rescue NativeException => cfe
          cfe.cause.value.find_cell(nil, nil, "kind").data.text.should == "Condition Error Type IncorrectType"
        end
      end
    end
  end
  
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
