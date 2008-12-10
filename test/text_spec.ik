
use("ispec")

parse = method(str,
  Message fromText(str) code)

describe("Text", 
  describe("==", 
    it("should return true for the same text", 
      x = "foo". x should == x
      x = "". x should == x
      x = "34tertsegdf\ndfgsdfgd". x should == x
    )

    it("should not return true for unequal texts", 
      "foo" should not == "bar"
      "foo" should not == "sdfsdgdfgsgf\nadsfgdsfgsdfgdfg\nsdfgdsfgsdfg"
    )

    it("should return true for equal texts", 
      "foo" should == "foo"
      "sdfsdgdfgsgf\nadsfgdsfgsdfgdfg\nsdfgdsfgsdfg" should == "sdfsdgdfgsgf\nadsfgdsfgsdfgdfg\nsdfgdsfgsdfg"
    )
    
    it("should work correctly when comparing empty text", 
      "" should == ""
      "a" should not == ""
      "" should not == "a"
    )
  )

  describe("!=", 
    it("should return false for the same text", 
      x = "foo". (x != x) should == false
      x = "". (x != x) should == false
      x = "34tertsegdf\ndfgsdfgd". (x != x) should == false
    )

    it("should return true for unequal texts", 
      ("foo" != "bar") should == true
      ("foo" != "sdfsdgdfgsgf\nadsfgdsfgsdfgdfg\nsdfgdsfgsdfg") should == true
    )

    it("should return false for equal texts", 
      ("foo" != "foo") should == false
      ("sdfsdgdfgsgf\nadsfgdsfgsdfgdfg\nsdfgdsfgsdfg" != "sdfsdgdfgsgf\nadsfgdsfgsdfgdfg\nsdfgdsfgsdfg") should == false
    )
    
    it("should work correctly when comparing empty text", 
      ("" != "") should == false
      ("a" != "") should == true
      ("" != "a") should == true
    )
  )

  describe("empty?", 
    it("should return true for an empty text", 
      "" empty? should == true
    )

    it("should not return true for a non-empty text", 
      "a b c" empty? should == false
    )

    it("should not return true for a text with only spaces", 
      " " empty? should == false
      "  " empty? should == false
    )

    it("should not return true for a text with only a newline", 
      "\n" empty? should == false
    )
  )
  
  describe("[number]", 
    it("should return nil if empty text", 
      ""[0] should == nil
      ""[10] should == nil
      ""[(0-1)] should == nil
    )

    it("should return nil if argument is over the size", 
      "abc"[10] should == nil
    )

    it("should return from the front if the argument is zero or positive", 
      "abcd"[0] should == 97
      "abcd"[1] should == 98
      "abcd"[2] should == 99
      "abcd"[3] should == 100
    )

    it("should return from the back if the argument is negative", 

      "abcd"[-1] should == 100
      "abcd"[-2] should == 99
      "abcd"[-3] should == 98
      "abcd"[-4] should == 97
    )
  )

  describe("[range]", 
    it("should return an empty text for any range given to an empty text", 
      ""[0..0]    should == ""
      ""[0...0]   should == ""
      ""[0..-1]   should == ""
      ""[0...-1]  should == ""
      ""[10..20]  should == ""
      ""[10...20] should == ""
      ""[-1..20]  should == ""
    )
    
    it("should return an equal text for 0..-1", 
      ""[0..-1] should == ""
      "foo bar"[0..-1] should == "foo bar"
      "f"[0..-1] should == "f"
    )

    it("should return all except the first element for 1..-1", 
      "foo bar"[1..-1] should == "oo bar"
      "x"[1..-1] should == ""
      "xxxxxxxx"[1..-1] should == "xxxxxxx"
    )

    it("should return all except for the first and last for 1...-1", 
      "fa"[1...-1] should == ""
      "foobar"[1...-1] should == "ooba"
      "xxxxxxxxxxxxxxx"[1...-1] should == "xxxxxxxxxxxxx"
    )

    it("should return an text with the first element for 0..0", 
      "f"[0..0] should == "f"
      "foobar"[0..0] should == "f"
    )

    it("should return an empty text for 0...0", 
      ""[0...0] should == ""
      "f"[0...0] should == ""
      "foobar"[0...0] should == ""
    )

    it("should return a slice from a larger text", 
      "123456789"[3..5] should == "456"
    )

    it("should return a correct slice for an exclusive range", 
      "123456789"[3...6] should == "456"
    )

    it("should return a correct slice for a slice that ends in a negative index", 
      "1234567891011"[3..-3] should == "45678910"
    )

    it("should return a correct slice for an exclusive slice that ends in a negative index", 
      "1234567891011"[3...-3] should == "4567891"
    )

    it("should return all elements up to the end of the slice, if the end argument is way out there", 
      "1234567891011"[5..3443343] should == "67891011"
      "1234567891011"[5...3443343] should == "67891011"
    )

    it("should return an empty array for a totally messed up indexing", 
      "1234567891011"[-1..3] should == ""
      "1234567891011"[-1..7557] should == ""
      "1234567891011"[5..4] should == ""
      "1234567891011"[-1...3] should == ""
      "1234567891011"[-1...7557] should == ""
      "1234567891011"[5...4] should == ""
    )
  )
  
  describe("interpolation", 
    it("should parse correctly with a simple number inside of it", 
      m = parse("\"foo \#{1} bar\"")
      m should == "internal:concatenateText(\"foo \", 1, \" bar\")"
    )

    it("should parse correctly with a complex expression", 
      m = parse("\"foo \#{29*5+foo bar} bar\"")
      m should == "internal:concatenateText(\"foo \", 29 *(5) +(foo bar), \" bar\")"
    )

    it("should parse correctly with interpolation at the beginning of the text", 
      m = parse("\"\#{1} bar\"")
      m should == "internal:concatenateText(\"\", 1, \" bar\")"
    )

    it("should parse correctly with interpolation at the end of the text", 
      m = parse("\"foo \#{1}\"")
      m should == "internal:concatenateText(\"foo \", 1, \"\")"
    )

    it("should parse correctly with more than one interpolation", 
      m = parse("\"foo \#{1} bar \#{2} quux \#{3}\"")
      m should == "internal:concatenateText(\"foo \", 1, \" bar \", 2, \" quux \", 3, \"\")"
    )

    it("should parse correctly with nested interpolations", 
      m = parse("\"foo \#{\"fux \#{32} bar\" bletch} bar\"")
      m should == "internal:concatenateText(\"foo \", internal:concatenateText(\"fux \", 32, \" bar\") bletch, \" bar\")"
    )
  )

  describe("format", 
    it("should create a text when no % is specified", 
      "abc foo bar quux \n men men" format() should == "abc foo bar quux \n men men"
    )

    it("should handle a % followed by a non-specifier", 
      "abc foo% bar quux \n men men" format() should == "abc foo% bar quux \n men men"
      "abc foo 10% bar quux \n men men" format() should == "abc foo 10% bar quux \n men men"
      "abc foo 10%, bar quux \n men men" format() should == "abc foo 10%, bar quux \n men men"
      "abc foo %01 bar quux \n men men" format() should == "abc foo %01 bar quux \n men men"
      "abc foo %* bar quux \n men men" format() should == "abc foo %* bar quux \n men men"
      "abc foo %-10 bar quux \n men men" format() should == "abc foo %-10 bar quux \n men men"
    )

    it("should handle a % followed by a newline", 
"foo%
" format should == "foo%\n"
    )
    
    it("should handle a % followed by end of string", 
      "abc%" format() should == "abc%"
    )

    it("should handle a % at beginning of string", 
      "% abc" format() should == "% abc"
    )
    
    it("should insert a text with only a %s", 
      "%s" format("bar") should == "bar"
      "%s" format("") should == ""
      "%s" format("\n") should == "\n"
    )

    it("should insert a text with %s inside of stuff", 
      "foo bar %s dfgdfg" format("bar") should == "foo bar bar dfgdfg"
      "foo bar %s dfgdfg" format("flurg") should == "foo bar flurg dfgdfg"
    )

    it("should insert two texts with two %s inside of stuff", 
      "foo bar %s dfgdfg%sabc" format("bar", "mums") should == "foo bar bar dfgdfgmumsabc"
    )

    it("should call asText when inserting %s", 
      x = Origin mimic
      x asText = "blurg"
      "foo %s bar" format(x) should == "foo blurg bar"
    )

    it("should right adjust when given %s with a number", 
      "%10s" format("bar") should == "       bar"
      "a%10sb" format("bar") should == "a       barb"
    )

    it("should left adjust when given %s with a negative number", 
      "%-10s" format("bar") should == "bar       "
      "a%-10sb" format("bar") should == "abar       b"
    )

    it("should overflow when giving right adjustment but the string is too long", 
      "%2s" format("barfly") should == "barfly"
      "a%2sb" format("barfly") should == "abarflyb"
    )
    
    it("should overflow when giving left adjustment but the string is too long", 
      "%-2s" format("barfly") should == "barfly"
      "a%-2sb" format("barfly") should == "abarflyb"
    )
    
    it("should not print anything for an empty list, with %[ and %]", 
      "foo %[bar %]quux" format([]) should == "foo quux"
    )
    
    it("should iterate over an element when using %[ and %]", 
      "foo %[%s - %]quux" format(["one", "two", "three"]) should == "foo one - two - three - quux"
      "%[%s - %]" format(["one", "two", "three"]) should == "one - two - three - "
    )

    it("should iterate over an element with each when using %[ and %]", 
      CustomEnumerable = Origin mimic
      CustomEnumerable mimic!(Mixins Enumerable)
      CustomEnumerable each = macro(
        ; Assume only one argument  
        first = call arguments first
        first evaluateOn(call ground, "3first")
        first evaluateOn(call ground, "1second")
        first evaluateOn(call ground, "2third"))

      "ah: %[%s-%] mama" format(CustomEnumerable) should == "ah: 3first-1second-2third- mama"
      "%[%s%]" format(CustomEnumerable) should == "3first1second2third"
    )

    it("should splat all inner elements when using %*[ and %]", 
      "foo %*[%s = %s - %]quux" format([["one", "1", "ignored"], ["two", "2", "ignored"], ["three", "3", "ignored"]]) should == "foo one = 1 - two = 2 - three = 3 - quux"
      "%*[%s=%s%]" format([["one", "1", "ignored"], ["two", "2", "ignored"], ["three", "3", "ignored"]]) should == "one=1two=2three=3"
    )
  )
  
  describe("escapes", 
    describe("\\b", 
      it("should be replaced when it's the only thing in the text", 
        "\b" should == "\b"
      )

      it("should be replaced when it's at the start of the text", 
        "\b " should == "\b "
        "\barfoo" should == "\barfoo"
      )

      it("should be replaced when it's at the end of the text", 
        " \b" should == " \b"
        "arfoo\b" should == "arfoo\b"
      )

      it("should be replaced when it's in the middle of the text", 
        " \b " should == " \b "
        "ar\bfoo" should == "ar\bfoo"
      )

      it("should be replaced when there are several in a string", 
        "\b \b adsf\bgtr\brsergfg\b\b\bfert\b" should == "\b \b adsf\bgtr\brsergfg\b\b\bfert\b"
      )
    )

    describe("\\t", 
      it("should be replaced when it's the only thing in the text", 
        "\t" should == "\t"
      )

      it("should be replaced when it's at the start of the text", 
        "\t " should == "\t "
        "\tarfoo" should == "\tarfoo"
      )

      it("should be replaced when it's at the end of the text", 
        " \t" should == " \t"
        "arfoo\t" should == "arfoo\t"
      )

      it("should be replaced when it's in the middle of the text", 
        " \t " should == " \t "
        "ar\tfoo" should == "ar\tfoo"
      )

      it("should be replaced when there are several in a string", 
        "\t \t adsf\tgtr\trsergfg\t\t\tfert\t" should == "\t \t adsf\tgtr\trsergfg\t\t\tfert\t"
      )
    )

    describe("\\n", 
      it("should be replaced when it's the only thing in the text", 
        "\n" should == "\n"
      )

      it("should be replaced when it's at the start of the text", 
        "\n " should == "\n "
        "\narfoo" should == "\narfoo"
      )

      it("should be replaced when it's at the end of the text", 
        " \n" should == " \n"
        "arfoo\n" should == "arfoo\n"
      )

      it("should be replaced when it's in the middle of the text", 
        " \n " should == " \n "
        "ar\nfoo" should == "ar\nfoo"
      )

      it("should be replaced when there are several in a string", 
        "\n \n adsf\ngtr\nrsergfg\n\n\nfert\n" should == "\n \n adsf\ngtr\nrsergfg\n\n\nfert\n"
      )
    )

    describe("\\f", 
      it("should be replaced when it's the only thing in the text", 
        "\f" should == "\f"
      )

      it("should be replaced when it's at the start of the text", 
        "\f " should == "\f "
        "\farfoo" should == "\farfoo"
      )

      it("should be replaced when it's at the end of the text", 
        " \f" should == " \f"
        "arfoo\f" should == "arfoo\f"
      )

      it("should be replaced when it's in the middle of the text", 
        " \f " should == " \f "
        "ar\ffoo" should == "ar\ffoo"
      )

      it("should be replaced when there are several in a string", 
        "\f \f adsf\fgtr\frsergfg\f\f\ffert\f" should == "\f \f adsf\fgtr\frsergfg\f\f\ffert\f"
      )
    )

    describe("\\r", 
      it("should be replaced when it's the only thing in the text", 
        "\r" should == "\r"
      )

      it("should be replaced when it's at the start of the text", 
        "\r " should == "\r "
        "\rarfoo" should == "\rarfoo"
      )

      it("should be replaced when it's at the end of the text", 
        " \r" should == " \r"
        "arfoo\r" should == "arfoo\r"
      )

      it("should be replaced when it's in the middle of the text", 
        " \r " should == " \r "
        "ar\rfoo" should == "ar\rfoo"
      )

      it("should be replaced when there are several in a string", 
        "\r \r adsf\rgtr\rrsergfg\r\r\rfert\r" should == "\r \r adsf\rgtr\rrsergfg\r\r\rfert\r"
      )
    )

    describe("\"", 
      it("should be replaced when it's the only thing in the text", 
        "\"" should == "\""
      )

      it("should be replaced when it's at the start of the text", 
        "\" " should == "\" "
        "\"arfoo" should == "\"arfoo"
      )

      it("should be replaced when it's at the end of the text", 
        " \"" should == " \""
        "arfoo\"" should == "arfoo\""
      )

      it("should be replaced when it's in the middle of the text", 
        " \" " should == " \" "
        "ar\"foo" should == "ar\"foo"
      )

      it("should be replaced when there are several in a string", 
        "\" \" adsf\"gtr\"rsergfg\"\"\"fert\"" should == "\" \" adsf\"gtr\"rsergfg\"\"\"fert\""
      )
    )

    describe("\\#", 
      it("should be replaced when it's the only thing in the text", 
        "\#" should == "\#"
      )

      it("should be replaced when it's at the start of the text", 
        "\# " should == "\# "
        "\#arfoo" should == "\#arfoo"
      )

      it("should be replaced when it's at the end of the text", 
        " \#" should == " \#"
        "arfoo\#" should == "arfoo\#"
      )

      it("should be replaced when it's in the middle of the text", 
        " \# " should == " \# "
        "ar\#foo" should == "ar\#foo"
      )

      it("should be replaced when there are several in a string", 
        "\# \# adsf\#gtr\#rsergfg\#\#\#fert\#" should == "\# \# adsf\#gtr\#rsergfg\#\#\#fert\#"
      )
    )

    describe("\\\\", 
      it("should be replaced when it's the only thing in the text", 
        "\\" should == "\\"
      )

      it("should be replaced when it's at the start of the text", 
        "\\ " should == "\\ "
        "\\arfoo" should == "\\arfoo"
      )

      it("should be replaced when it's at the end of the text", 
        " \\" should == " \\"
        "arfoo\\" should == "arfoo\\"
      )

      it("should be replaced when it's in the middle of the text", 
        " \\ " should == " \\ "
        "ar\\foo" should == "ar\\foo"
      )

      it("should be replaced when there are several in a string", 
        "\\ \\ adsf\\gtr\\rsergfg\\\\\\fert\\" should == "\\ \\ adsf\\gtr\\rsergfg\\\\\\fert\\"
      )
    )

    describe("\\\\n", 
      it("should be replaced when it's the only thing in the text", 
        "\
" should == ""
      )

      it("should be replaced when it's at the start of the text", 
        "\
 " should == " "
        "\
arfoo" should == "arfoo"
      )

      it("should be replaced when it's at the end of the text", 
        " \
" should == " "
        "arfoo\
" should == "arfoo"
      )

      it("should be replaced when it's in the middle of the text", 
        " \
 " should == "  "
        "ar\
foo" should == "arfoo"
      )

      it("should be replaced when there are several in a string", 
        "\
 \
 adsf\
gtr\
rsergfg\
\
\
fert\
" should == "  adsfgtrrsergfgfert"
      )
    )

    describe("unicode", 
      it("should replace any unicode letter in a string with only it", 
        "\uAAAA" length should == 1
        "\uAAAA"[0] should == 0xAAAA
      )

      it("should replace a unicode letter at the beginning of a string", 
        "\u000a foo bar x"[0] should == 0xA
        "\u000a foo bar x"[1..-1] should == " foo bar x"
      )

      it("should replace a unicode letter at the end of a string", 
        "blarg ucrg ma\u3332"[-1] should == 0x3332
        "blarg ucrg ma\u3332"[0..-2] should == "blarg ucrg ma"
      )
    )

    describe("octal", 
;       it("should replace any octal letter in a string with only it", 
;         (0..255) each(number,
;           "#{number.to_s(8)}" length should == 1
;           "#{number.to_s(8)}"[0] should == number
;         )
;       )

;       it("should replace a octal letter at the beginning of a string", 
;         (0..255) each(number,
;           "#{number.to_s(8)} foo bar x"[0] should == number
;           "#{number.to_s(8)} foo bar x"[1..-1] should == " foo bar x"
;         )
;       )

;       it("should replace a octal letter at the end of a string", 
;         (0..255) each(number,
;           "blarg xxx\\#{number.to_s(8)}"[-1] should == number
;           "blarg xxx\\#{number.to_s(8)}"[0..-2] should == "blarg xxx"
;         )
;       )
      
      it("should handle an octal letter of one letter", 
        "blarg \0xxx"[6] should == 0
        "blarg \1xxx"[6] should == 1
        "blarg \2xxx"[6] should == 2
        "blarg \3xxx"[6] should == 3
        "blarg \4xxx"[6] should == 4
        "blarg \5xxx"[6] should == 5
        "blarg \6xxx"[6] should == 6
        "blarg \7xxx"[6] should == 7
      )

      it("should handle an octal letter of two letters", 
        "blarg \00xxx"[6] should == 0
        "blarg \01xxx"[6] should == 1
        "blarg \02xxx"[6] should == 2
        "blarg \03xxx"[6] should == 3
        "blarg \04xxx"[6] should == 4
        "blarg \05xxx"[6] should == 5
        "blarg \06xxx"[6] should == 6
        "blarg \07xxx"[6] should == 7
        "blarg \34xxx"[6] should == 28
        "blarg \12xxx"[6] should == 10
      )
    )
  )
)
