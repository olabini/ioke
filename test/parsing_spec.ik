
use("ispec")

parse = method(str,
  Message fromText(str) code)

describe("parsing",  
  it("should ignore a first line that starts with #!",  
    m = parse("#!/foo/bar 123\nfoo")
    m should == "foo"
  )
  
  it("should parse an empty string into a terminator message",  
    m = parse("")
    m should == ".\n"
  )

  it("should parse a string with only spaces into a terminator message",  
    m = parse("  ")
    m should == ".\n"
  )
  
  describe("terminators",  
    it("should parse a newline as a terminator",  
      m = parse("\n")
      m should == ".\n"
    )

    it("should parse two newlines as one terminator",  
      m = parse("\n\n")
      m should == ".\n"
    )

    it("should parse a period as a terminator",  
      m = parse(".")
      m should == ".\n"
    )

    it("should parse one period and one newline as one terminator",  
      m = parse(".\n")
      m should == ".\n"
    )

    it("should parse one newline and one period as one terminator",  
      m = parse("\n.")
      m should == ".\n"
    )

    it("should parse one newline and one period and one newline as one terminator",  
      m = parse("\n.\n")
      m should == ".\n"
    )
    
    it("should not parse a line ending with a slash as a terminator",  
      m = parse("foo\\\nbar")
      m should == "foo bar"
    )

    it("should not parse a line ending with a slash and spaces around it as a terminator",  
      m = parse("foo    \\\n    bar")
      m should == "foo bar"
    )
  )

  describe("strings",  
    it("should parse a string containing newlines",  
      m = parse("\"foo\nbar\"")
      m should == "\"foo\nbar\""
    )

    describe("escapes",  
      it("should parse a newline as nothing if preceeded with a slash",  
        "foo\
bar" should == "foobar"
      )
    )
  )
  
  describe("parens without preceeding message",  
    it("should be translated into identity message",  
      m = parse("(1)")
      m should == "(1)"
    )
  )
  
  describe("square brackets",  
    it("should be parsed correctly in regular message passing syntax",  
      m = parse("[]()")
      m should == "[]"
    )

    it("should be parsed correctly in regular message passing syntax with arguments",  
      m = parse("[](123)")
      m should == "[](123)"
    )

    it("should be parsed correctly in regular message passing syntax with arguments and receiver",  
      m = parse("foo bar(1) [](123)")
      m should == "foo bar(1) [](123)"
    )
    
    it("should be parsed correctly when empty",  
      m = parse("[]")
      m should == "[]"
    )

    it("should be parsed correctly when empty with spaces",  
      m = parse("[   ]")
      m should == "[]"
    )
    
    it("should be parsed correctly with argument",  
      m = parse("[1]")
      m should == "[](1)"
    )

    it("should be parsed correctly with argument and spaces",  
      m = parse("[   1   ]")
      m should == "[](1)"
    )
    
    it("should be parsed correctly with arguments",  
      m = parse("[1, 2]")
      m should == "[](1, 2)"
    )

    it("should be parsed correctly with terminators inside",  
      m = parse("[1, \nfoo(24)]")
      m should == "[](1, foo(24))"
    )

    it("should be parsed correctly directly after an identifier",  
      m = parse("foo[1, 2]")
      m should == "foo [](1, 2)"
    )

    it("should be parsed correctly with a space directly after an identifier",  
      m = parse("foo [1, 2]")
      m should == "foo [](1, 2)"
    )

    it("should be parsed correctly inside a function application",  
      m = parse("foo([1, 2])")
      m should == "foo([](1, 2))"
    )

    it("should not parse correctly when mismatched",
      fn(parse("foo([1, 2)]")) should signal(Condition Error JavaException)
    )

    it("should not parse correctly when missing end",  
      fn(parse("[1, 2")) should signal(Condition Error JavaException)
    )
  )
  
  describe("curly brackets",  
    it("should be parsed correctly in regular message passing syntax",  
      m = parse("{}()")
      m should == "{}"
    )

    it("should be parsed correctly in regular message passing syntax with arguments",  
      m = parse("{}(123)")
      m should == "{}(123)"
    )

    it("should be parsed correctly in regular message passing syntax with arguments and receiver",  
      m = parse("foo bar(1) {}(123)")
      m should == "foo bar(1) {}(123)"
    )
    
    it("should be parsed correctly when empty",  
      m = parse("{}")
      m should == "{}"
    )

    it("should be parsed correctly when empty with spaces",  
      m = parse("{     }")
      m should == "{}"
    )
    
    it("should be parsed correctly with argument",  
      m = parse("{1}")
      m should == "{}(1)"
    )

    it("should be parsed correctly with argument and spaces",  
      m = parse("{ 1     }")
      m should == "{}(1)"
    )
    
    it("should be parsed correctly with arguments",  
      m = parse("{1, 2}")
      m should == "{}(1, 2)"
    )

    it("should be parsed correctly with terminators inside",  
      m = parse("{1, \nfoo(24)}")
      m should == "{}(1, foo(24))"
    )

    it("should be parsed correctly directly after an identifier",  
      m = parse("foo{1, 2}")
      m should == "foo {}(1, 2)"
    )

    it("should be parsed correctly with a space directly after an identifier",  
      m = parse("foo {1, 2}")
      m should == "foo {}(1, 2)"
    )

    it("should be parsed correctly inside a function application",  
      m = parse("foo({1, 2})")
      m should == "foo({}(1, 2))"
    )

    it("should not parse correctly when mismatched",  
      fn(parse("foo({1, 2)}")) should signal(Condition Error JavaException)
    )

    it("should not parse correctly when missing end",  
      fn(parse("{1, 2")) should signal(Condition Error JavaException)
    )
  )

  describe("identifiers",  
    it("should be allowed to begin with colon",  
      m = parse(":foo")
      m should == ":foo"
    )

;     it("should be allowed to begin with two colons",  
;       m = parse("::foo")
;       m should == "::foo"
;     )

    it("should be allowed to only be a colon",  
      m = parse(":")
      m should == ":"
    )

    it("should be allowed to end with colon",  
      m = parse("foo:")
      m should == "foo:"
    )

    it("should be allowed to have a colon in the middle",  
      m = parse("foo:bar")
      m should == "foo:bar"
    )

    it("should be allowed to have more than one colon in the middle", 
      m = parse("foo::bar")
      m should == "foo::bar"

      m = parse("f:o:o:b:a:r")
      m should == "f:o:o:b:a:r"
    )
  )

  describe("shuffling",
    it("should shuffle a ` without arguments",
      Message fromText("`foo") code should == "`(foo)"
      Message fromText("`42") code should == "`(42)"
      Message fromText("`") code should == "`"
    )

    it("should shuffle a : without arguments",
      Message fromText(":\"42\"") code should == ":(\"42\")"
      Message fromText(": \"42\" 43") code should == ":(\"42\") 43"
    )

    it("should shuffle a ' without arguments",
      Message fromText("'foo") code should == "'(foo)"
      Message fromText("'42") code should == "'(42)"
      Message fromText("'") code should == "'"
    )

    it("should not shuffle a ` with arguments",
      Message fromText("`(foo bar) quux") code should == "`(foo bar) quux"
    )

    it("should not shuffle a : with arguments",
      Message fromText(":(foo)") code should == ":(foo)"
    )

    it("should not shuffle a ' with arguments",
      Message fromText("'(foo bar) quux") code should == "'(foo bar) quux"
    )

    it("should shuffle the arguments to an inverted operator around",
      Message fromText("foo bar quux :: blarg mux") code should == "blarg mux ::(foo bar quux)"
    )
  )

  describe("strange characters",
    it("should handle japanese characters correctly",
      キャンディ! = "Candy!"
      キャンディ! should == "Candy!"
    )
  )
)
