include_class('ioke.lang.Runtime') { 'IokeRuntime' } unless defined?(IokeRuntime)

import Java::java.io.StringReader unless defined?(StringReader)
import Java::java.io.PrintWriter unless defined?(PrintWriter)
import Java::java.io.StringWriter unless defined?(StringWriter)
import Java::java.io.InputStreamReader unless defined?(InputStreamReader)
import Java::java.lang.System unless defined?(System)

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

  describe "'negation'" do 
    it "should return zero for zero" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string("0 negation").data.as_java_integer.should == 0
    end

    it "should return 1 for -1" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string("-1 negation").data.as_java_integer.should == 1
    end

    it "should return -1 for 1" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string("1 negation").data.as_java_integer.should == -1
    end

    it "should return a large positive number for a large negative number" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string("-353654645676451123345674 negation").data.as_java_string.should == "353654645676451123345674"
    end

    it "should return a large negative number for a large positive number" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string("353654645676451123345674 negation").data.as_java_string.should == "-353654645676451123345674"
    end
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
    it "should return 0 for the sum of 0 and 0" do 
      ioke = IokeRuntime.get_runtime()
      ioke.evaluate_stream(StringReader.new("0+0")).data.as_java_integer.should == 0
    end

    it "should return the sum of really large numbers" do 
      ioke = IokeRuntime.get_runtime()
      ioke.evaluate_stream(StringReader.new("234235345636345634567345675467+1")).data.as_java_string.should == "234235345636345634567345675468"
      ioke.evaluate_stream(StringReader.new("21342342342345345+778626453756754687567865785678")).data.as_java_string.should == "778626453756776029910208131023"
      ioke.evaluate_stream(StringReader.new("234234+63456345745676574567571345456345645675674567878567856785678657856568768")).data.
        as_java_string.should == "63456345745676574567571345456345645675674567878567856785678657856803002"
    end

    it "should return the sum of smaller numbers" do 
      ioke = IokeRuntime.get_runtime()
      ioke.evaluate_stream(StringReader.new("1+1")).data.as_java_integer.should == 2
      ioke.evaluate_stream(StringReader.new("10+1")).data.as_java_integer.should == 11
      ioke.evaluate_stream(StringReader.new("15+15")).data.as_java_integer.should == 30
      ioke.evaluate_stream(StringReader.new("16+15")).data.as_java_integer.should == 31
    end

    it "should return the sum of negative numbers" do 
      ioke = IokeRuntime.get_runtime()
      ioke.evaluate_stream(StringReader.new("1+(0-1)")).data.as_java_integer.should == 0
      ioke.evaluate_stream(StringReader.new("(0-1)+2")).data.as_java_integer.should == 1
      ioke.evaluate_stream(StringReader.new("(0-1)+(0-1)")).data.as_java_integer.should == -2
    end

    it "should return the number when 0 is the receiver" do 
      ioke = IokeRuntime.get_runtime()
      ioke.evaluate_stream(StringReader.new("0+1")).data.as_java_integer.should == 1
      ioke.evaluate_stream(StringReader.new("0+(0-1)")).data.as_java_integer.should == -1
      ioke.evaluate_stream(StringReader.new("0+124423")).data.as_java_integer.should == 124423
      ioke.evaluate_stream(StringReader.new("0+34545636745678657856786786785678")).data.as_java_string.should == "34545636745678657856786786785678"
    end

    it "should return the number when 0 is the argument" do 
      ioke = IokeRuntime.get_runtime()
      ioke.evaluate_stream(StringReader.new("1+0")).data.as_java_integer.should == 1
      ioke.evaluate_stream(StringReader.new("(0-1)+0")).data.as_java_integer.should == -1
      ioke.evaluate_stream(StringReader.new("124423+0")).data.as_java_integer.should == 124423
      ioke.evaluate_stream(StringReader.new("34545636745678657856786786785678+0")).data.as_java_string.should == "34545636745678657856786786785678"
    end

    # It should convert it's argument to number if it's not a number
  end

  describe "'*'" do 
    it "should multiply with 0" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string("1*0 == 0").should == ioke.true
      ioke.evaluate_string("34253453*0 == 0").should == ioke.true
      ioke.evaluate_string("-1*0 == 0").should == ioke.true
    end

    it "should return the same number when multiplying with 1" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string("1*1 == 1").should == ioke.true
      ioke.evaluate_string("34253453*1 == 34253453").should == ioke.true
      ioke.evaluate_string("-1*1 == -1").should == ioke.true
    end

    it "should return a really large number when multiplying large numbers" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string("2345346456745722*12213212323899088545 == 28644214249339912541248622627954490").should == ioke.true
    end

    it "should return a negative number when multiplying with one negative number" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string("-21*2 == -42").should == ioke.true
    end

    it "should return a positive number when multiplying with two negative numbers" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string("-21*-2 == 42").should == ioke.true
    end
  end

  describe "'**'" do 
    it "should return 1 for raising to 0" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string("1**0 == 1").should == ioke.true
    end

    it "should return the number when raising to 1" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string("2**1 == 2").should == ioke.true
    end

    it "should raise a number" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string("2**2 == 4").should == ioke.true
      ioke.evaluate_string("2**3 == 8").should == ioke.true
    end

    it "should raise a number to a large number" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string("2 ** 40 == 1099511627776").should == ioke.true
    end
  end
  
  describe "'/'" do 
    it "should cause a condition when dividing with 0" do 
      sw = StringWriter.new(20)
      out = PrintWriter.new(sw)

      ioke = IokeRuntime.get_runtime(out, InputStreamReader.new(System.in), out)

      begin 
        ioke.evaluate_string("10/0")
        true.should be_false
      rescue NativeException => cfe
        cfe.cause.value.find_cell(nil, nil, "kind").data.text.should == "Condition Error Arithmetic DivisionByZero"
      end
    end

    it "should divide simple numbers" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string("2/1 == 2").should == ioke.true
      ioke.evaluate_string("4/2 == 2").should == ioke.true
      ioke.evaluate_string("200/5 == 40").should == ioke.true
    end

    it "should shave off fractional parts when dividing uneven numbers" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string("8192/10 == 819").should == ioke.true
      ioke.evaluate_string("3/2 == 1").should == ioke.true
      ioke.evaluate_string("5/2 == 2").should == ioke.true
      ioke.evaluate_string("1/2 == 0").should == ioke.true
    end

    it "should divide negative numbers correctly" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string("-8192/10 == -820").should == ioke.true
    end

    it "should divide with a negative dividend correctly" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string("8192/-10 == -820").should == ioke.true
    end

    it "should divide a negative number with a negative dividend" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string("-8192/-10 == 819").should == ioke.true
    end
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
  end
  
  describe "'=='" do 
    it "should return true for the same number" do 
      ioke = IokeRuntime.get_runtime()
      ioke.evaluate_string("x = 1. x == x").should == ioke.true
      ioke.evaluate_string("x = 10. x == x").should == ioke.true
      ioke.evaluate_string("x = (0-20). x == x").should == ioke.true
    end

    it "should not return true for unequal numbers" do 
      ioke = IokeRuntime.get_runtime()
      ioke.evaluate_string("1 == 2").should == ioke.false
      ioke.evaluate_string("1 == 200000").should == ioke.false
      ioke.evaluate_string("1123223 == 65756756756").should == ioke.false
      ioke.evaluate_string("(0-1) == 2").should == ioke.false
    end
    
    it "should return true for the result of equal number calculations" do 
      ioke = IokeRuntime.get_runtime()
      ioke.evaluate_string("(1+1) == 2").should == ioke.true
      ioke.evaluate_string("(2+1) == (1+2)").should == ioke.true
    end
    
    it "should work correctly when comparing zeroes" do 
      ioke = IokeRuntime.get_runtime()
      ioke.evaluate_string("0 == 0").should == ioke.true
      ioke.evaluate_string("1 == 0").should == ioke.false
      ioke.evaluate_string("0 == 1").should == ioke.false
    end

    it "should work correctly when comparing negative numbers" do 
      ioke = IokeRuntime.get_runtime()
      ioke.evaluate_string("(0-19) == (0-19)").should == ioke.true
      ioke.evaluate_string("(0-19) == (0-20)").should == ioke.false
    end

    it "should work correctly when comparing large positive numbers" do 
      ioke = IokeRuntime.get_runtime()
      ioke.evaluate_string("123234534675676786789678985463456345 == 123234534675676786789678985463456345").should == ioke.true
      ioke.evaluate_string("8888856676776 == 8888856676776").should == ioke.true
    end
  end
  
  describe "'asText'" do 
    it "should return a representation of 0" do 
      ioke = IokeRuntime.get_runtime()
      ioke.evaluate_stream(StringReader.new("0 asText")).data.text.should == "0"
    end

    it "should return a representation of a small positive number" do 
      ioke = IokeRuntime.get_runtime()
      ioke.evaluate_stream(StringReader.new("1 asText")).data.text.should == "1"
      ioke.evaluate_stream(StringReader.new("12 asText")).data.text.should == "12"
      ioke.evaluate_stream(StringReader.new("9232423 asText")).data.text.should == "9232423"
    end
    
    it "should return a representation of a large positive number" do 
      ioke = IokeRuntime.get_runtime()
      ioke.evaluate_stream(StringReader.new("65535 asText")).data.text.should == "65535"
      ioke.evaluate_stream(StringReader.new("65536 asText")).data.text.should == "65536"
      ioke.evaluate_stream(StringReader.new("1235345341231298989793249879238543956783485384758333478526 asText")).data.text.should == "1235345341231298989793249879238543956783485384758333478526"
      ioke.evaluate_stream(StringReader.new("99999999999999999999999999 asText")).data.text.should == "99999999999999999999999999"
    end

    it "should return a representation of a negative number" do 
      ioke = IokeRuntime.get_runtime()
      ioke.evaluate_stream(StringReader.new("(0-65535) asText")).data.text.should == "-65535"
      ioke.evaluate_stream(StringReader.new("(0-65536) asText")).data.text.should == "-65536"
      ioke.evaluate_stream(StringReader.new("(0-1) asText")).data.text.should == "-1"
      ioke.evaluate_stream(StringReader.new("(0-645654) asText")).data.text.should == "-645654"
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
end
