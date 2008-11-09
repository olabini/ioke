include_class('ioke.lang.Runtime') { 'IokeRuntime' } unless defined?(IokeRuntime)

import Java::java.io.StringReader unless defined?(StringReader)

def parse(str)
  ioke = IokeRuntime.get_runtime()
  ioke.parse_stream(StringReader.new(str))
end

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
  
  describe "'[number]'" do 
    it "should return nil if empty text" do 
      ioke = IokeRuntime.get_runtime

      ioke.evaluate_string("\"\"[0]").should == ioke.nil
      ioke.evaluate_string("\"\"[10]").should == ioke.nil
      ioke.evaluate_string("\"\"[(0-1)]").should == ioke.nil
    end

    it "should return nil if argument is over the size" do 
      ioke = IokeRuntime.get_runtime

      ioke.evaluate_string("\"abc\"[10]").should == ioke.nil
    end

    it "should return from the front if the argument is zero or positive" do 
      ioke = IokeRuntime.get_runtime

      ioke.evaluate_string("\"abcd\"[0]").data.as_java_integer.should == 97
      ioke.evaluate_string("\"abcd\"[1]").data.as_java_integer.should == 98
      ioke.evaluate_string("\"abcd\"[2]").data.as_java_integer.should == 99
      ioke.evaluate_string("\"abcd\"[3]").data.as_java_integer.should == 100
    end

    it "should return from the back if the argument is negative" do 
      ioke = IokeRuntime.get_runtime

      ioke.evaluate_string("\"abcd\"[-1]").data.as_java_integer.should == 100
      ioke.evaluate_string("\"abcd\"[-2]").data.as_java_integer.should == 99
      ioke.evaluate_string("\"abcd\"[-3]").data.as_java_integer.should == 98
      ioke.evaluate_string("\"abcd\"[-4]").data.as_java_integer.should == 97
    end
  end

  describe "'[range]'" do 
    it "should return an empty text for any range given to an empty text" do 
      ioke = IokeRuntime.get_runtime

      ioke.evaluate_string('""[0..0]    == ""').should == ioke.true
      ioke.evaluate_string('""[0...0]   == ""').should == ioke.true
      ioke.evaluate_string('""[0..-1]   == ""').should == ioke.true
      ioke.evaluate_string('""[0...-1]  == ""').should == ioke.true
      ioke.evaluate_string('""[10..20]  == ""').should == ioke.true
      ioke.evaluate_string('""[10...20] == ""').should == ioke.true
      ioke.evaluate_string('""[-1..20]  == ""').should == ioke.true
    end
    
    it "should return an equal text for 0..-1" do 
      ioke = IokeRuntime.get_runtime

      ioke.evaluate_string('""[0..-1] == ""').should == ioke.true
      ioke.evaluate_string('"foo bar"[0..-1] == "foo bar"').should == ioke.true
      ioke.evaluate_string('"f"[0..-1] == "f"').should == ioke.true
    end

    it "should return all except the first element for 1..-1" do 
      ioke = IokeRuntime.get_runtime

      ioke.evaluate_string('"foo bar"[1..-1] == "oo bar"').should == ioke.true
      ioke.evaluate_string('"x"[1..-1] == ""').should == ioke.true
      ioke.evaluate_string('"xxxxxxxx"[1..-1] == "xxxxxxx"').should == ioke.true
    end

    it "should return all except for the first and last for 1...-1" do 
      ioke = IokeRuntime.get_runtime

      ioke.evaluate_string('"fa"[1...-1] == ""').should == ioke.true
      ioke.evaluate_string('"foobar"[1...-1] == "ooba"').should == ioke.true
      ioke.evaluate_string('"xxxxxxxxxxxxxxx"[1...-1] == "xxxxxxxxxxxxx"').should == ioke.true
    end

    it "should return an text with the first element for 0..0" do 
      ioke = IokeRuntime.get_runtime

      ioke.evaluate_string('"f"[0..0] == "f"').should == ioke.true
      ioke.evaluate_string('"foobar"[0..0] == "f"').should == ioke.true
    end

    it "should return an empty text for 0...0" do 
      ioke = IokeRuntime.get_runtime

      ioke.evaluate_string('""[0...0] == ""').should == ioke.true
      ioke.evaluate_string('"f"[0...0] == ""').should == ioke.true
      ioke.evaluate_string('"foobar"[0...0] == ""').should == ioke.true
    end

    it "should return a slice from a larger text" do 
      ioke = IokeRuntime.get_runtime

      ioke.evaluate_string('"123456789"[3..5] == "456"').should == ioke.true
    end

    it "should return a correct slice for an exclusive range" do 
      ioke = IokeRuntime.get_runtime

      ioke.evaluate_string('"123456789"[3...6] == "456"').should == ioke.true
    end

    it "should return a correct slice for a slice that ends in a negative index" do 
      ioke = IokeRuntime.get_runtime

      ioke.evaluate_string('"1234567891011"[3..-3] == "45678910"').should == ioke.true
    end

    it "should return a correct slice for an exclusive slice that ends in a negative index" do 
      ioke = IokeRuntime.get_runtime

      ioke.evaluate_string('"1234567891011"[3...-3] == "4567891"').should == ioke.true
    end

    it "should return all elements up to the end of the slice, if the end argument is way out there" do 
      ioke = IokeRuntime.get_runtime

      ioke.evaluate_string('"1234567891011"[5..3443343] == "67891011"').should == ioke.true
      ioke.evaluate_string('"1234567891011"[5...3443343] == "67891011"').should == ioke.true
    end

    it "should return an empty array for a totally messed up indexing" do 
      ioke = IokeRuntime.get_runtime

      ioke.evaluate_string('"1234567891011"[-1..3] == ""').should == ioke.true
      ioke.evaluate_string('"1234567891011"[-1..7557] == ""').should == ioke.true
      ioke.evaluate_string('"1234567891011"[5..4] == ""').should == ioke.true
      ioke.evaluate_string('"1234567891011"[-1...3] == ""').should == ioke.true
      ioke.evaluate_string('"1234567891011"[-1...7557] == ""').should == ioke.true
      ioke.evaluate_string('"1234567891011"[5...4] == ""').should == ioke.true
    end
  end
  
  describe "interpolation" do 
    it "should parse correctly with a simple number inside of it" do 
      m = parse('"foo #{1} bar"').to_string
      m.should == 'internal:concatenateText("foo ", 1, " bar")'
    end

    it "should parse correctly with a complex expression" do 
      m = parse('"foo #{29*5+foo bar} bar"').to_string
      m.should == 'internal:concatenateText("foo ", 29 *(5) +(foo bar), " bar")'
    end

    it "should parse correctly with interpolation at the beginning of the text" do 
      m = parse('"#{1} bar"').to_string
      m.should == 'internal:concatenateText("", 1, " bar")'
    end

    it "should parse correctly with interpolation at the end of the text" do 
      m = parse('"foo #{1}"').to_string
      m.should == 'internal:concatenateText("foo ", 1, "")'
    end

    it "should parse correctly with more than one interpolation" do 
      m = parse('"foo #{1} bar #{2} quux #{3}"').to_string
      m.should == 'internal:concatenateText("foo ", 1, " bar ", 2, " quux ", 3, "")'
    end

    it "should parse correctly with nested interpolations" do 
      m = parse('"foo #{"fux #{32} bar" bletch} bar"').to_string
      m.should == 'internal:concatenateText("foo ", internal:concatenateText("fux ", 32, " bar") bletch, " bar")'
    end
  end
  
  describe "escapes" do 
    describe "text escape", :shared => true do 
      it "should be replaced when it's the only thing in the text" do 
        ioke = IokeRuntime.get_runtime
        ioke.evaluate_string('"' + @replace + '"').data.text.should == "#{@expect}"
      end

      it "should be replaced when it's at the start of the text" do 
        ioke = IokeRuntime.get_runtime
        ioke.evaluate_string('"' + @replace + ' "').data.text.should == "#{@expect} "
        ioke.evaluate_string('"' + @replace + 'arfoo"').data.text.should == "#{@expect}arfoo"
      end

      it "should be replaced when it's at the end of the text" do 
        ioke = IokeRuntime.get_runtime
        ioke.evaluate_string('" ' + @replace + '"').data.text.should == " #{@expect}"
        ioke.evaluate_string('"arfoo' + @replace + '"').data.text.should == "arfoo#{@expect}"
      end

      it "should be replaced when it's in the middle of the text" do 
        ioke = IokeRuntime.get_runtime
        ioke.evaluate_string('" ' + @replace + ' "').data.text.should == " #{@expect} "
        ioke.evaluate_string('"ar' + @replace + 'foo"').data.text.should == "ar#{@expect}foo"
      end

      it "should be replaced when there are several in a string" do 
        ioke = IokeRuntime.get_runtime
        ioke.evaluate_string('"' + @replace + ' ' + @replace + ' adsf' + @replace + 'gtr' + @replace + 'rsergfg' + @replace + '' + @replace + '' + @replace + 'fert' + @replace + '"').data.text.should == "#{@expect} #{@expect} adsf#{@expect}gtr#{@expect}rsergfg#{@expect}#{@expect}#{@expect}fert#{@expect}"
      end
    end
    
    describe "\\b" do 
      before :each do 
        @replace = '\b'
        @expect = "\b"
      end

      it_should_behave_like "text escape"
    end

    describe "\\t" do 
      before :each do 
        @replace = '\t'
        @expect = "\t"
      end

      it_should_behave_like "text escape"
    end

    describe "\\n" do 
      before :each do 
        @replace = '\n'
        @expect = "\n"
      end

      it_should_behave_like "text escape"
    end

    describe "\\f" do 
      before :each do 
        @replace = '\f'
        @expect = "\f"
      end

      it_should_behave_like "text escape"
    end

    describe "\\r" do 
      before :each do 
        @replace = '\r'
        @expect = "\r"
      end

      it_should_behave_like "text escape"
    end

    describe "\\\"" do 
      before :each do 
        @replace = '\"'
        @expect = '"'
      end

      it_should_behave_like "text escape"
    end

    describe "\\#" do 
      before :each do 
        @replace = '\#'
        @expect = '#'
      end

      it_should_behave_like "text escape"
    end

    describe "\\\\" do 
      before :each do 
        @replace = '\\\\'
        @expect = '\\'
      end

      it_should_behave_like "text escape"
    end

    describe "\\\\n" do 
      before :each do 
        @replace = "\\\n"
        @expect = ''
      end

      it_should_behave_like "text escape"
    end

    describe "unicode" do 
      it "should replace any unicode letter in a string with only it" do 
        ioke = IokeRuntime.get_runtime
        ioke.evaluate_string('"\uAAAA" length').data.as_java_integer.should == 1
        ioke.evaluate_string('"\uAAAA"[0]').data.as_java_integer.should == 0xAAAA
      end

      it "should replace a unicode letter at the beginning of a string" do 
        ioke = IokeRuntime.get_runtime
        ioke.evaluate_string('"\u000a foo bar x"[0]').data.as_java_integer.should == 0xA
        ioke.evaluate_string('"\u000a foo bar x"[1..-1]').data.text.should == " foo bar x"
      end

      it "should replace a unicode letter at the end of a string" do 
        ioke = IokeRuntime.get_runtime
        ioke.evaluate_string('"blarg ucrg ma\u3332"[-1]').data.as_java_integer.should == 0x3332
        ioke.evaluate_string('"blarg ucrg ma\u3332"[0..-2]').data.text.should == "blarg ucrg ma"
      end
    end

    describe "octal" do 
      it "should replace any octal letter in a string with only it" do 
        ioke = IokeRuntime.get_runtime
        (0..255).each do |number|
          ioke.evaluate_string("\"\\#{number.to_s(8)}\" length").data.as_java_integer.should == 1
          ioke.evaluate_string("\"\\#{number.to_s(8)}\"[0]").data.as_java_integer.should == number
        end
      end

      it "should replace a octal letter at the beginning of a string" do 
        ioke = IokeRuntime.get_runtime
        (0..255).each do |number|
          ioke.evaluate_string("\"\\#{number.to_s(8)} foo bar x\"[0]").data.as_java_integer.should == number
          ioke.evaluate_string("\"\\#{number.to_s(8)} foo bar x\"[1..-1]").data.text.should == " foo bar x"
        end
      end

      it "should replace a octal letter at the end of a string" do 
        ioke = IokeRuntime.get_runtime
        (0..255).each do |number|
          ioke.evaluate_string("\"blarg xxx\\#{number.to_s(8)}\"[-1]").data.as_java_integer.should == number
          ioke.evaluate_string("\"blarg xxx\\#{number.to_s(8)}\"[0..-2]").data.text.should == "blarg xxx"
        end
      end
      
      it "should handle an octal letter of one letter" do 
        ioke = IokeRuntime.get_runtime
        ioke.evaluate_string('"blarg \0xxx"[6]').data.as_java_integer.should == 0
        ioke.evaluate_string('"blarg \1xxx"[6]').data.as_java_integer.should == 1
        ioke.evaluate_string('"blarg \2xxx"[6]').data.as_java_integer.should == 2
        ioke.evaluate_string('"blarg \3xxx"[6]').data.as_java_integer.should == 3
        ioke.evaluate_string('"blarg \4xxx"[6]').data.as_java_integer.should == 4
        ioke.evaluate_string('"blarg \5xxx"[6]').data.as_java_integer.should == 5
        ioke.evaluate_string('"blarg \6xxx"[6]').data.as_java_integer.should == 6
        ioke.evaluate_string('"blarg \7xxx"[6]').data.as_java_integer.should == 7
      end

      it "should handle an octal letter of two letters" do 
        ioke = IokeRuntime.get_runtime
        ioke.evaluate_string('"blarg \00xxx"[6]').data.as_java_integer.should == 0
        ioke.evaluate_string('"blarg \01xxx"[6]').data.as_java_integer.should == 1
        ioke.evaluate_string('"blarg \02xxx"[6]').data.as_java_integer.should == 2
        ioke.evaluate_string('"blarg \03xxx"[6]').data.as_java_integer.should == 3
        ioke.evaluate_string('"blarg \04xxx"[6]').data.as_java_integer.should == 4
        ioke.evaluate_string('"blarg \05xxx"[6]').data.as_java_integer.should == 5
        ioke.evaluate_string('"blarg \06xxx"[6]').data.as_java_integer.should == 6
        ioke.evaluate_string('"blarg \07xxx"[6]').data.as_java_integer.should == 7
        ioke.evaluate_string('"blarg \34xxx"[6]').data.as_java_integer.should == 28
        ioke.evaluate_string('"blarg \12xxx"[6]').data.as_java_integer.should == 10
      end
    end
  end
end
