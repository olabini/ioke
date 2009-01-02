
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

  describe("pattern",
    it("should return a string containing the pattern used to create it",
      #/foo/ pattern should == "foo"
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

    it("should return nil when not matching",
      (#/fo{3}/ =~ "foo") should == nil
      (#/fox/ =~ "x foo x") should == nil
      (#/^ foo$/ =~ "foo") should == nil
      (#/foo$/ =~ "foo bar") should == nil
      (#/^foo/ =~ "bar foo") should == nil
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
