
use("ispec")

parse = method(str,
  Message fromText(str) code)

describe(Regexp,
  it("should have the correct kind",
    Regexp should have kind("Regexp")
  )

  it("should be the kind of literal regular expression patterns",
    #/foo/ should not be nil
    #/foo/ should have kind("Regexp")
    #/foo/ should mimic(Regexp)

    #/foo/xs should not be nil
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

      it("should validate type of receiver",
        Regexp Match should checkReceiverTypeOn(:target)
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

      it("should validate type of receiver",
        Regexp Match should checkReceiverTypeOn(:names)
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

      it("should validate type of receiver",
        Regexp Match should checkReceiverTypeOn(:start)
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

      it("should validate type of receiver",
        Regexp Match should checkReceiverTypeOn(:end)
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
        (#/(..)((..))?/ =~ "ab") offset(2) should be nil
        (#/({no}..)(({way}..))?/ =~ "ab") offset(:way) should be nil

        (#/(..)((..))?/ =~ "ab") offset(10) should be nil
        (#/({no}..)(({way}..))?/ =~ "ab") offset(:blarg) should be nil
      )

      it("should validate type of receiver",
        Regexp Match should checkReceiverTypeOn(:offset)
      )
    )

    describe("match",
      it("should return the fully matched text",
        (#/.. / =~ "foobar ") match should == "ar "
      )

      it("should validate type of receiver",
        Regexp Match should checkReceiverTypeOn(:match)
      )
    )

    describe("beforeMatch",
      it("should return the part before the string that matched",
        (#/.. / =~ "foobar ") beforeMatch should == "foob"
      )

      it("should validate type of receiver",
        Regexp Match should checkReceiverTypeOn(:beforeMatch)
      )
    )

    describe("afterMatch",
      it("should return the part before the string that matched",
        (#/.. / =~ "foobar blargus") afterMatch should == "blargus"
      )

      it("should validate type of receiver",
        Regexp Match should checkReceiverTypeOn(:afterMatch)
      )
    )

    describe("asText",
      it("should return the fully matched text",
        (#/.. / =~ "foobar ") asText should == "ar "
      )

      it("should validate type of receiver",
        Regexp Match should checkReceiverTypeOn(:asText)
      )
    )

    describe("length",
      it("should return the number of groups in the regexp, including the whole match",
        (#/foo/ =~ "foo") length should == 1
        (#/f(o)(o)/ =~ "foo") length should == 3
        (#/f(o)(o)(x)?/ =~ "foo") length should == 4
      )

      it("should validate type of receiver",
        Regexp Match should checkReceiverTypeOn(:length)
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

      it("should validate type of receiver",
        Regexp Match should checkReceiverTypeOn(:asList)
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

      it("should validate type of receiver",
        Regexp Match should checkReceiverTypeOn(:captures)
      )
    )

    describe("[]",
      it("should validate type of receiver",
        Regexp Match should checkReceiverTypeOn(:"[]", 1)
      )

      describe("number",
        it("should return the full match when given 0",
          (#/foo/ =~ "foo")[0] should == "foo"
          (#/..../ =~ "foo bbb")[0] should == "foo "
        )

        it("should return nil if given an index out of bounds",
          (#/foo/ =~ "foo")[1] should be nil
        )

        it("should return nil if given a group that didn't match",
          (#/f(.)(.)(.)?/ =~ "foo")[3] should be nil
        )

        it("should return the match at the index given",
          (#/f(..)(..)(..)?/ =~ "fabcdef")[1] should == "ab"
          (#/f(..)(..)(..)?/ =~ "fabcdef")[2] should == "cd"
        )

        it("should take a negative index to index from the end",
          (#/f(..)(..)(..)?/ =~ "fabcdef")[-1] should == "ef"
          (#/f(..)(..)(..)?/ =~ "fabcdef")[-2] should == "cd"
          (#/f(..)(..)(..)?/ =~ "fabcdef")[-3] should == "ab"
          (#/f(..)(..)(..)?/ =~ "fabcdef")[-4] should == "fabcdef"
        )
      )

      describe("range",
        it("should return all the matches indexed over",
          (#/f(..)(..)(..)(..)(..)/ =~ "xxfabcdefghijxx")[2..3] should == ["cd", "ef"]
          (#/f(..)(..)(..)(..)(..)/ =~ "xxfabcdefghijxx")[2...4] should == ["cd", "ef"]
        )

        it("should return nil for those that aren't matched",
          (#/f(..)(..)(..)?(xx)/ =~ "fabcdxx")[2..4] should == ["cd", nil, "xx"]
        )

        it("should allow negative indices",
          (#/f(..)(..)(..)(..)(..)/ =~ "xxfabcdefghijxx")[2..-2] should == ["cd", "ef", "gh"]
        )

        it("should allow indexing outside of length and don't do anything for that",
          (#/f(..)(..)/ =~ "xxfabcdxx")[1..10] should == ["ab", "cd"]
        )
      )

      describe("symbol",
        it("should return nil if given a name that isn't valid",
          (#/foo/ =~ "foo")[:foo] should be nil
        )

        it("should return nil if given a group that didn't match",
          (#/f(..)(..)({mux}..)?/ =~ "fabcd")[:mux] should be nil
        )

        it("should return the match at the symbol given",
          (#/f({mix}..)({max}..)({mux}..)?/ =~ "fabcdef")[:mix] should == "ab"
          (#/f({mix}..)({max}..)({mux}..)?/ =~ "fabcdef")["mix"] should == "ab"
          (#/f({mix}..)({max}..)({mux}..)?/ =~ "fabcdef")[:max] should == "cd"
          (#/f({mix}..)({max}..)({mux}..)?/ =~ "fabcdef")["max"] should == "cd"
          (#/f({mix}..)({max}..)({mux}..)?/ =~ "fabcdef")[:mux] should == "ef"
          (#/f({mix}..)({max}..)({mux}..)?/ =~ "fabcdef")["mux"] should == "ef"
        )
      )
    )

    describe("pass",
      it("should signal an error if calling a group that isn't defined",
        fn((#/foo/ =~ "foo") testingPassOnRegexp) should signal(Condition Error NoSuchCell)
      )

      it("should return the string matching a named group if it's matched",
        (#/foo({mux}..)bar/ =~ "fooQqbar") mux should == "Qq"
      )

      it("should return nil for a defined group that isn't matched",
        (#/foo({mux}..)?/ =~ "foob") mux should be nil
      )

      it("should validate type of receiver",
        Regexp Match should checkReceiverTypeOn(:pass)
      )
    )
  )

  describe("pattern",
    it("should return a string containing the pattern used to create it",
      #/foo/ pattern should == "foo"
    )

    it("should validate type of receiver",
      Regexp should checkReceiverTypeOn(:pattern)
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
      (#/foo/ =~ "foo") true? should be true
      (#/fo{1,2}/ =~ "foo") true? should be true
      (#/foo/ =~ "x foo x") true? should be true
      (#/^foo$/ =~ "foo") true? should be true
      (#/^foo/ =~ "foo bar") true? should be true
      (#/ foo$/ =~ "bar foo") true? should be true
    )

    it("should return an instance of Regexp Match",
      (#/foo/ =~ "foo") kind should == "Regexp Match"
    )

    it("should return nil when not matching",
      (#/fo{3}/ =~ "foo") should be nil
      (#/fox/ =~ "x foo x") should be nil
      (#/^ foo$/ =~ "foo") should be nil
      (#/foo$/ =~ "foo bar") should be nil
      (#/^foo/ =~ "bar foo") should be nil
    )

    it("should validate type of receiver",
      Regexp should checkReceiverTypeOn(:"=~", "foo")
    )
  )

  describe("match",
    it("should return a true value when matching",
      (#/foo/ match("foo")) true? should be true
      (#/fo{1,2}/ match("foo")) true? should be true
      (#/foo/ match("x foo x")) true? should be true
      (#/^foo$/ match("foo")) true? should be true
      (#/^foo/ match("foo bar")) true? should be true
      (#/ foo$/ match("bar foo")) true? should be true
    )

    it("should return an instance of Regexp Match",
      #/foo/ match("foo") kind should == "Regexp Match"
    )

    it("should return nil when not matching",
      (#/fo{3}/ match("foo")) should be nil
      (#/fox/ match("x foo x")) should be nil
      (#/^ foo$/ match("foo")) should be nil
      (#/foo$/ match("foo bar")) should be nil
      (#/^foo/ match("bar foo")) should be nil
    )

    it("should validate type of receiver",
      Regexp should checkReceiverTypeOn(:match, "foo")
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

    it("should validate type of receiver",
      Regexp should checkReceiverTypeOn(:names)
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

    it("should validate type of receiver",
      Regexp should checkReceiverTypeOn(:allMatches, "foo")
    )
  )
  
  describe("inspect",
    it("should inspect correctly for a simple regexp",
      #/foo/ inspect should == "#/foo/"
      #/foo/x inspect should == "#/foo/x"
    )

    it("should validate type of receiver",
      Regexp should checkReceiverTypeOn(:inspect)
    )
  )

  describe("notice",
    it("should notice correctly for a simple regexp",
      #/foo/ notice should == "#/foo/"
      #/foo/x notice should == "#/foo/x"
    )

    it("should validate type of receiver",
      Regexp should checkReceiverTypeOn(:notice)
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
  
  describe("escapes",
    describe("\\A",
      it("should match the beginning of the text",
        "foox" should match(#/\Afoo/)
        "xfoox" should not match(#/\Afoo/)
      )

      it("should not match the beginning of a line",
        "\nfoox" should not match(#/\Afoo/)
      )
    )

    describe("\\d",
      it("should match a number",
        "f1b" should match(#/\d/)
        "fib" should not match(#/\d/)
      )
    )

    describe("\\D",
      it("should match anything that is not a number",
        "142b3" should match(#/\D/)
        "123" should not match(#/\D/)
      )
    )

    describe("\\s",
      it("should match a whitespace",
        "f b" should match(#/\s/)
        "fib" should not match(#/\s/)
      )
    )

    describe("\\S",
      it("should match anything that is not a whitespace",
        "  f  " should match(#/\S/)
        "   " should not match(#/\S/)
      )
    )

    describe("\\w",
      it("should match a word character",
        "f" should match(#/\w/)
        " f " should match(#/\w/)
        " 1 " should match(#/\w/)
        "  . !!!" should not match(#/\w/)
      )
    )

    describe("\\W",
      it("should match anything that is not a word character",
        "123 " should match(#/\W/)
        " abc" should match(#/\W/)
        "abc" should not match(#/\W/)
      )
    )

    describe("\\b",
      it("should match a word boundary",
        "foo bar" should match(#/\bbar/)
        "foo bar" should match(#/\bfoo/)
        "foobar" should not match(#/\bbar/)
      )
    )

    describe("\\B",
      it("should match anything that is not a word boundary",
        "foobar" should match(#/\Bbar/)
        "foo bar" should not match(#/\Bbar/)
      )
    )

    describe("\\<",
      it("should match beginning of a word",
        "foo bar" should match(#/\<bar/)
        "foo bar" should match(#/\<foo/)
        "foobar" should not match(#/\<bar/)
        "foo bar" should not match(#/foo\</)
      )
    )

    describe("\\>",
      it("should match end of a word",
        "foo bar" should match(#/foo\>/)
        "foo bar" should match(#/bar\>/)
        "foobar" should not match(#/\>bar/)
        "foo bar" should not match(#/\>foo/)
      )
    )

    describe("\\z",
      it("should match the end of the text",
        "foo" should match(#/foo\z/)
        "foo\nfoo" should match(#/foo\z/)
      )

      it("should not match the end of a line",
        "foo\nbar" should not match(#/foo\z/)
      )

      it("should not match the end of a line before the end of the text",
        "foo\n" should not match(#/foo\z/)
      )
    )

    describe("\\Z",
      it("should match the end of the text",
        "foo" should match(#/foo\Z/)
        "foo\nfoo" should match(#/foo\Z/)
      )

      it("should match the end of a line before the end of the text",
        "foo\n" should match(#/foo\Z/)
      )

      it("should not match the end of a line",
        "foo\nbar" should not match(#/foo\Z/)
      )
    )

    describe("\\G",
      it("should match the beginning of the text for a new match",
        "foo" should match(#/\Gfoo/)
      )
    )

    describe("\\p",
      it("should match a specific unicode block or category",
        "FoF" should match(#/\p{Ll}/)
        "FOF" should not match(#/\p{Ll}/)
      )
    )

    describe("\\P",
      it("should match anything that isn't a specific uncode block or category",
        "oooooFooooo" should match(#/\P{Ll}/)
        "ooooofooooo" should not match(#/\P{Ll}/)
      )
    )

    describe("\\{",
      it("should match literally",
        "foo{" should match(#/\{/)
        "foo" should not match(#/\{/)
      )
    )

    describe("\\}",
      it("should match literally",
        "foo}" should match(#/\}/)
        "foo" should not match(#/\}/)
      )
    )

    describe("\\.",
      it("should match literally",
        "foo." should match(#/\./)
        "foo" should not match(#/\./)
      )
    )

    describe("\\[",
      it("should match literally",
        "foo[" should match(#/\[/)
        "foo" should not match(#/\[/)
      )
    )

    describe("]",
      it("should match literally",
        "foo]" should match(#/]/)
        "foo" should not match(#/]/)
      )
    )

    describe("\\^",
      it("should match literally",
        "foo^" should match(#/\^/)
        "foo" should not match(#/\^/)
      )
    )

    describe("\\$",
      it("should match literally",
        "foo$" should match(#/\$/)
        "foo" should not match(#/\$/)
      )
    )

    describe("\\*",
      it("should match literally",
        "foo*" should match(#/\*/)
        "foo" should not match(#/\*/)
      )
    )

    describe("\\+",
      it("should match literally",
        "foo+" should match(#/\+/)
        "foo" should not match(#/\+/)
      )
    )

    describe("\\?",
      it("should match literally",
        "foo?" should match(#/\?/)
        "foo" should not match(#/\?/)
      )
    )

    describe("\\(",
      it("should match literally",
        "foo(" should match(#/\(/)
        "foo" should not match(#/\(/)
      )
    )

    describe("\\)",
      it("should match literally",
        "foo)" should match(#/\)/)
        "foo" should not match(#/\)/)
      )
    )

    describe("\\|",
      it("should match literally",
        "foo|" should match(#/\|/)
        "foo" should not match(#/\|/)
      )
    )

    describe("\\/",
      it("should match literally",
        "foo/" should match(#/\//)
        "foo" should not match(#/\//)
      )
    )
  )

  describe("flags",
    it("should have tests")
  )
)
