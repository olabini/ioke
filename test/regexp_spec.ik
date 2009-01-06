
use("ispec")

parse = method(str,
  Message fromText(str) code)

describe(Regexp,
  it("should have the correct kind",
    Regexp should have kind("Regexp")
  )

  it("should be the kind of literal regular expression patterns",
    #/foo/ should not == nil
    #/foo/ should have kind("Regexp")
    #/foo/ should mimic(Regexp)

    #/foo/xs should not == nil
    #/foo/xs should have kind("Regexp")
    #/foo/xs should mimic(Regexp)
  )

  describe(Regexp Match,
    it("should have the correct kind",
      Regexp Match should have kind("Regexp Match")
    )

    describe("target",
      it("should return the original string matched against",
        x = "foobar"
        #/oo/ match(x) target should be same(x)
      )
    )

    describe("names",
      it("should return an empty list for a pattern that doesn't have any named groups",
        #/foo/ match("foo") names should == []
        #/f(o)o/ match("foo") names should == []
      )
    
      it("should return a list of all the names, ordered from beginning parenthesis",
        #/({foo}bar)/ match("bar") names should == [:foo]
        #/({foo}bar)({quux}.)/ match("bar1") names should == [:foo, :quux]
        #/({foo}({bleg}.))({quux}.)/ match("ab") names should == [:foo, :bleg, :quux]
      )
    )

    describe("start",
      it("should return the start index of group zero, which is the whole group",
        (#/foo/ =~ "foobar") start should == 0
        (#/foo/ =~ "abcfoobar") start should == 3

        (#/foo/ =~ "foobar") start(0) should == 0
        (#/foo/ =~ "abcfoobar") start(0) should == 3
      )

      it("should return the start index of another group",
        (#/(..) (..) (..)/ =~ "fooab cd efbar") start(2) should == 6
      )

      it("should return the start index from the name of a named group",
        (#/({one}..) ({two}..) ({three}..)/ =~ "fooab cd efbar") start(:two) should == 6
      )

      it("should return -1 for a group that wasn't matched",
        (#/(..)((..))?/ =~ "ab") start(2) should == -1
        (#/({no}..)(({way}..))?/ =~ "ab") start(:way) should == -1

        (#/(..)((..))?/ =~ "ab") start(10) should == -1
        (#/({no}..)(({way}..))?/ =~ "ab") start(:blarg) should == -1
      )
    )

    describe("end",
      it("should return the end index of group zero, which is the whole group",
        (#/foo/ =~ "foobar") end should == 3
        (#/foo/ =~ "abcfoobar") end should == 6

        (#/foo/ =~ "foobar") end(0) should == 3
        (#/foo/ =~ "abcfoobar") end(0) should == 6
      )

      it("should return the end index of another group",
        (#/(..) (..) (..)/ =~ "fooab cd efbar") end(2) should == 8
      )

      it("should return the end index from the name of a named group",
        (#/({one}..) ({two}..) ({three}..)/ =~ "fooab cd efbar") end(:two) should == 8
      )

      it("should return -1 for a group that wasn't matched",
        (#/(..)((..))?/ =~ "ab") end(2) should == -1
        (#/({no}..)(({way}..))?/ =~ "ab") end(:way) should == -1

        (#/(..)((..))?/ =~ "ab") end(10) should == -1
        (#/({no}..)(({way}..))?/ =~ "ab") end(:blarg) should == -1
      )
    )

    describe("offset",
      it("should return the offset of group zero, which is the whole group",
        (#/foo/ =~ "foobar") offset should == (0 => 3)
        (#/foo/ =~ "abcfoobar") offset should == (3 => 6)

        (#/foo/ =~ "foobar") offset(0) should == (0 => 3)
        (#/foo/ =~ "abcfoobar") offset(0) should == (3 => 6)
      )

      it("should return the offset of another group",
        (#/(..) (..) (..)/ =~ "fooab cd efbar") offset(2) should == (6 => 8)
      )

      it("should return the offset from the name of a named group",
        (#/({one}..) ({two}..) ({three}..)/ =~ "fooab cd efbar") offset(:two) should == (6 => 8)
      )

      it("should return nil for a group that wasn't matched",
        (#/(..)((..))?/ =~ "ab") offset(2) should == nil
        (#/({no}..)(({way}..))?/ =~ "ab") offset(:way) should == nil

        (#/(..)((..))?/ =~ "ab") offset(10) should == nil
        (#/({no}..)(({way}..))?/ =~ "ab") offset(:blarg) should == nil
      )
    )

    describe("match",
      it("should return the fully matched text",
        (#/.. / =~ "foobar ") match should == "ar "
      )
    )

    describe("beforeMatch",
      it("should return the part before the string that matched",
        (#/.. / =~ "foobar ") beforeMatch should == "foob"
      )
    )

    describe("afterMatch",
      it("should return the part before the string that matched",
        (#/.. / =~ "foobar blargus") afterMatch should == "blargus"
      )
    )

    describe("asText",
      it("should return the fully matched text",
        (#/.. / =~ "foobar ") asText should == "ar "
      )
    )

    describe("length",
      it("should return the number of groups in the regexp, including the whole match",
        (#/foo/ =~ "foo") length should == 1
        (#/f(o)(o)/ =~ "foo") length should == 3
        (#/f(o)(o)(x)?/ =~ "foo") length should == 4
      )
    )

    describe("asList",
      it("should return the match itself",
        (#/foo/ =~ "foo") asList should == ["foo"]
      )

      it("should return all matches in the regexp",
        (#/f(.)(.)/ =~ "foo") asList should == ["foo", "o", "o"]
      )

      it("should return unmatched groups as nil",
        (#/f(.)(.)(.)?/ =~ "foo") asList should == ["foo", "o", "o", nil]
      )
    )

    describe("captures",
      it("should not return the match itself",
        (#/foo/ =~ "foo") captures should == []
      )

      it("should return all matches in the regexp",
        (#/f(.)(.)/ =~ "foo") captures should == ["o", "o"]
      )

      it("should return unmatched groups as nil",
        (#/f(.)(.)(.)?/ =~ "foo") captures should == ["o", "o", nil]
      )
    )
  )

  describe("pattern",
    it("should return a string containing the pattern used to create it",
      #/foo/ pattern should == "foo"
    )
  )

  describe("from",
    it("should create a new regular expression",
      Regexp from("foo") should == #/foo/
      Regexp from("foo bar") should == #/foo bar/
    )

    it("should take an optional argument for the flags",
      Regexp from("foo", "xs") should == #/foo/xs
      Regexp from("foo bar", "xs") should == #/foo bar/xs
    )
  )

  describe("=~",
    it("should return a true value when matching",
      (#/foo/ =~ "foo") true? should == true
      (#/fo{1,2}/ =~ "foo") true? should == true
      (#/foo/ =~ "x foo x") true? should == true
      (#/^foo$/ =~ "foo") true? should == true
      (#/^foo/ =~ "foo bar") true? should == true
      (#/ foo$/ =~ "bar foo") true? should == true
    )

    it("should return an instance of Regexp Match",
      (#/foo/ =~ "foo") kind should == "Regexp Match"
    )

    it("should return nil when not matching",
      (#/fo{3}/ =~ "foo") should == nil
      (#/fox/ =~ "x foo x") should == nil
      (#/^ foo$/ =~ "foo") should == nil
      (#/foo$/ =~ "foo bar") should == nil
      (#/^foo/ =~ "bar foo") should == nil
    )
  )

  describe("match",
    it("should return a true value when matching",
      (#/foo/ match("foo")) true? should == true
      (#/fo{1,2}/ match("foo")) true? should == true
      (#/foo/ match("x foo x")) true? should == true
      (#/^foo$/ match("foo")) true? should == true
      (#/^foo/ match("foo bar")) true? should == true
      (#/ foo$/ match("bar foo")) true? should == true
    )

    it("should return an instance of Regexp Match",
      #/foo/ match("foo") kind should == "Regexp Match"
    )

    it("should return nil when not matching",
      (#/fo{3}/ match("foo")) should == nil
      (#/fox/ match("x foo x")) should == nil
      (#/^ foo$/ match("foo")) should == nil
      (#/foo$/ match("foo bar")) should == nil
      (#/^foo/ match("bar foo")) should == nil
    )
  )

  describe("names",
    it("should return an empty list for a pattern that doesn't have any named groups",
      #/foo/ names should == []
      #/f(o)o/ names should == []
    )
    
    it("should return a list of all the names, ordered from beginning parenthesis",
      #/({foo}bar)/ names should == [:foo]
      #/({foo}bar)({quux}.)/ names should == [:foo, :quux]
      #/({foo}({bleg}.))({quux}.)/ names should == [:foo, :bleg, :quux]
    )
  )

  describe("===",
    it("should check for mimicness if receiver is Regexp",
      Regexp should === Regexp
      Regexp should === #//
      Regexp should === #/foo/
      Regexp should === #r[bar]mx
      Regexp should not === 123
      Regexp should not === "foo"
      Regexp should not === (#/foo/..#/bar/)
    )
    
    it("should check for match if receiver is not Regexp",
      #/foo/ should === "foo"
      #/fo{1,2}/ should === "foo"
      #/foo/ should === "x foo x"
      #/^foo$/ should === "foo"
      #/^foo/ should === "foo bar"
      #/ foo$/ should === "bar foo"

      #/foo/ should not === 123

      #/fo{3}/ should not === "foo"
      #/fox/ should not === "x foo x"
      #/^ foo$/ should not === "foo"
      #/foo$/ should not === "foo bar"
      #/^foo/ should not === "bar foo"
    )
  )

  describe("allMatches",
    it("should return a list of all matches",
      #/./ allMatches("abc") should == ["a","b","c"]
      #/o+/ allMatches("foo baroooooooo qoxuoooo") should == ["oo", "oooooooo", "o", "oooo"]
    )

    it("should return an empty list for no matches",
      #/foo/ allMatches("bar") should == []
    )
  )
  
  describe("inspect",
    it("should inspect correctly for a simple regexp",
      #/foo/ inspect should == "#/foo/"
      #/foo/x inspect should == "#/foo/x"
    )
  )

  describe("notice",
    it("should notice correctly for a simple regexp",
      #/foo/ notice should == "#/foo/"
      #/foo/x notice should == "#/foo/x"
    )
  )

  describe("quote",
    it("should return the same text if it doesn't contain any meta characters",
      Regexp quote("foobar") should == "foobar"
    )

    it("should quote metacharacters",
      Regexp quote("+?{}[]().* ") should == "\\+\\?\\{\\}\\[\\]\\(\\)\\.\\*\\ "
    )
  )

  describe("alternative syntax",
    it("should work for simple regexps",
      #r[foo] should == #/foo/
      #r[bar] should == #/bar/
    )

    it("should work with back slashes",
      #r[///] pattern should == "///"
    )

    it("should work for regexps with flags",
      #r[foo]x should == #/foo/x
    )
  )    

  describe("interpolation",
    it("should parse correctly with a simple number inside of it", 
      m = parse("#/foo \#{1} bar/")
      m should == "internal:compositeRegexp(\"foo \", 1, #/ bar/)"
    )

    it("should parse correctly with a complex expression", 
      m = parse("#/foo \#{29*5+foo bar} bar/")
      m should == "internal:compositeRegexp(\"foo \", 29 *(5) +(foo bar), #/ bar/)"
    )

    it("should parse correctly with interpolation at the beginning of the text", 
      m = parse("#/\#{1} bar/")
      m should == "internal:compositeRegexp(\"\", 1, #/ bar/)"
    )

    it("should parse correctly with interpolation at the end of the text", 
      m = parse("#/foo \#{1}/")
      m should == "internal:compositeRegexp(\"foo \", 1, #//)"
    )

    it("should parse correctly with more than one interpolation", 
      m = parse("#/foo \#{1} bar \#{2} quux \#{3}/")
      m should == "internal:compositeRegexp(\"foo \", 1, \" bar \", 2, \" quux \", 3, #//)"
    )

    it("should parse correctly with nested interpolations", 
      m = parse("#/foo \#{#/fux \#{32} bar/ bletch} bar/")
      m should == "internal:compositeRegexp(\"foo \", internal:compositeRegexp(\"fux \", 32, #/ bar/) bletch, #/ bar/)"
    )

    it("should add all the flags as the last argument",
      m = parse("#/foo \#{1} bar/mx")
      m should == "internal:compositeRegexp(\"foo \", 1, #/ bar/mx)"
    )      
  )
)
