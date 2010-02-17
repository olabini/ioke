use("ispec")
use("builtin/iik")

describe(IIk,
  describe("nested?",
    it("should be false given an empty message",
      IIk nested?("") should be false
    )
    
    it("should be true for a unfinished double quoted string",
      IIk nested?(#["foo]) should be true
    )    
    
    it("should be false for a simple message",
      IIk nested?("foo") should be false
    )
    
    it("should be false for a finished string",
      IIk nested?(#["foo"]) should be false
    )
    
    it("should be true for a finished string followed by an unfinished string",
      IIk nested?(#["foo" "bar]) should be true
    )
    
    it("should be false for a finished string containing an escaped quote",
      IIk nested?(#["fo\\"o"]) should be false
    )
    
    it("should be false for a finished string containing something else that is quoted",
      IIk nested?(#["fo\\ro"]) should be false
    )
    
    it("should be false for a finished string containing an escaped escape at the end",
      IIk nested?(#["fo\\\\"]) should be false
    )
    
    it("should be true for a message with an unclosed parenthesis",
      IIk nested?("foo(") should be true
    )
    
    it("should be true for a message with an unclosed parenthesis followed by something",
      IIk nested?("foo( bar quux") should be true
    )

    it("should be false for a string with a single parenthesized message",
      IIk nested?("foo(bar)") should be false
    )
    
    it("should be false for an obvious syntax error in parenthesis nesting",
      IIk nested?("foo())") should be false
    )
    
    it("should be false for an paren inside of a string",
      IIk nested?(#["("]) should be false
    )
    
    it("should be true for a message with an unclosed square bracket",
      IIk nested?("[") should be true
    )
    
    it("should be true for a message followed by an unclosed square bracket",
      IIk nested?("foo [") should be true
    )
    
    it("should be true for a message with an unclosed square bracket followed by something",
      IIk nested?("foo [ bar quux") should be true
    )
    
    it("should be false for a string with a single square bracketed message",
      IIk nested?("foo [bar]") should be false
    )
    
    it("should be false for an obvious syntax error in square bracket nesting",
      IIk nested?("foo []]") should be false
    )
    
    it("should be false for a square bracket inside of a string",
      IIk nested?(#["["]) should be false
    )
    
    it("should return false for a square bracket enclosed in alternate Text syntax",
      IIk nested?("#[[]") should be false
    )
    
    it("should return false for an empty, lonesome hash",
      IIk nested?("#") should be false
    )
    
    it("should return false for a string with alt text syntax with escape in it",
      IIk nested?("#[foo bar \\]bax]") should be false
    )
    
    it("should be false for a finished alt text containing something else that is quoted",
      IIk nested?("#[fo\\ro]") should be false
    )
    
    it("should return false for a string with alt text syntax ending in an escaped escape",
      IIk nested?("#[foo bar \\\\]") should be false
    )
    
    it("should return true for a string with alt text syntax without a closing bracket",
      IIk nested?("#[foo bar") should be true    
    )
    
    it("should return true for a string with alt text syntax with an open string character",
      IIk nested?("#[foo bar\"") should be true
    )
    
    it("should be true for a message with an unclosed curly bracket",
      IIk nested?("{") should be true
    )
    
    it("should be true for a message followed by an unclosed curly bracket",
      IIk nested?("foo {") should be true
    )
    
    it("should be true for a message with an unclosed curly bracket followed by something",
      IIk nested?("foo { bar quux") should be true
    )
    
    it("should be false for a string with a single curly bracketed message",
      IIk nested?("foo {bar}") should be false
    )
    
    it("should be false for an obvious syntax error in curly bracket nesting",
      IIk nested?("foo {}}") should be false
    )
    
    it("should be false for a curly bracket inside of a string",
      IIk nested?(#["{"]) should be false
    )
    
    it("should return false for a curly bracket enclosed in alternate Text syntax",
      IIk nested?("#[{]") should be false
    )
    
    it("should return false for a quote inside of a regexp literal",
      IIk nested?("#/\"/") should be false 
    )
    
    it("should return false for an opening paren inside of a regexp literal",
      IIk nested?("#/(/") should be false 
    )
    
    it("should return false for a closing paren inside of a regexp literal",
      IIk nested?("#/)/") should be false 
    )
    
    it("should return false for an opening square bracket inside of a regexp literal",
      IIk nested?("#/[/") should be false 
    )
    
    it("should return false for a closing square bracket inside of a regexp literal",
      IIk nested?("#/]/") should be false 
    )
    
    it("should return false for an opening curly bracket inside of a regexp literal",
      IIk nested?("#/{/") should be false 
    )
    
    it("should return false for a closing curly bracket inside of a regexp literal",
      IIk nested?("#/}/") should be false 
    )
    
    it("should return true for a simple opened regexp literal",
      IIk nested?("#/") should be true
    )
    
    it("should be true for an opened regexp literal as part of a longer message",
      IIk nested?("foo bar(#/baz\"qux\"") should be true
    )
    
    it("should false for a regexp with an escaped ending character",
      IIk nested?("#/foo\\/bar#/") should be false
    )
    
    it("should be false for a regexp containing something else that is quoted",
      IIk nested?("#/fo\\so/") should be false
    )
    
    it("should return false for a quote inside of a alt regexp literal",
      IIk nested?("#r[\"]") should be false 
    )
    
    it("should return false for an opening paren inside of an alt regexp literal",
      IIk nested?("#r[(]") should be false 
    )
    
    it("should return false for a closing paren inside of an alt regexp literal",
      IIk nested?("#r[)]") should be false 
    )
    
    it("should return false for an opening square bracket inside of an alt regexp literal",
      IIk nested?("#r[[]") should be false 
    )
    
    it("should return false for an opening curly bracket inside of an alt regexp literal",
      IIk nested?("#r[{]") should be false 
    )
    
    it("should return false for a closing curly bracket inside of an alt regexp literal",
      IIk nested?("#r[}]") should be false 
    )
    
    it("should return true for a simple opened alt regexp literal",
      IIk nested?("#r[") should be true
    )
    
    it("should be true for an opened alt regexp literal as part of a longer message",
      IIk nested?("foo bar(#r[baz\"qux\"") should be true
    )
    
    it("should false for an alt regexp with an escaped ending character",
      IIk nested?("#r[foo\\]bar#]") should be false
    )
    
    it("should be false for an alt regexp containing something else that is quoted",
      IIk nested?("#r[fo\\so]") should be false
    )
    
    it("should be false for an alt regexp containing a regular regexp literal",
      IIk nested?("#r[#/foo]") should be false
    )

    it("should report the nesting of an interpolated text element that is closed correctly",
      IIk nested?("\"foo \#{blah}\"") should be false
    )

    it("should report the nesting of an interpolated text element as 2",
      IIk nested?("\"foo \#{blah") should be true
    )

    it("should report the nesting of an interpolated text element with more nesting inside of it",
      IIk nested?("\"foo \#{blah([1,2,3") should be true
    )

    it("should report the nesting of an interpolated text element with even more nesting inside of it",
      IIk nested?("\"foo \#{blah([1,2,3, {") should be true
    )

    it("should report the nesting of an escaped interpolation correctly",
      IIk nested?("\"foo \\\#{\"") should be false
    )

    it("should report the nesting of an interpolated text element inside of an interpolated text element correctly",
      IIk nested?("\"foo \#{\"blah \#{foo(") should be true
    )

    it("should report the nesting of an interpolated alt text element that is closed correctly",
      IIk nested?("#[foo \#{blah}]") should be false
    )

    it("should report the nesting of an interpolated alt text element as 2",
      IIk nested?("#[foo \#{blah") should be true
    )

    it("should report the nesting of an interpolated alt text element with more nesting inside of it",
      IIk nested?("#[foo \#{blah([1,2,3") should be true
    )

    it("should report the nesting of an interpolated alt text element with even more nesting inside of it",
      IIk nested?("#[foo \#{blah([1,2,3, {") should be true
    )

    it("should report the nesting of an escaped interpolation in alt text correctly",
      IIk nested?("#[foo \\\#{]") should be false
    )

    it("should report the nesting of an interpolated alt text element inside of an interpolated alt text element correctly",
      IIk nested?("#[foo \#{#[blah \#{foo(") should be true
    )

    it("should report the nesting of an interpolated regexp element that is closed correctly",
      IIk nested?("#/foo \#{blah}/") should be false
    )

    it("should report the nesting of an interpolated regexp element as 2",
      IIk nested?("#/foo \#{blah") should be true
    )

    it("should report the nesting of an interpolated regexp element with more nesting inside of it",
      IIk nested?("#/foo \#{blah([1,2,3") should be true
    )

    it("should report the nesting of an interpolated regexp element with even more nesting inside of it",
      IIk nested?("#/foo \#{blah([1,2,3, {") should be true
    )

    it("should report the nesting of an escaped interpolation in regexp correctly",
      IIk nested?("#/foo \\\#{/") should be false
    )

    it("should report the nesting of an interpolated regexp element inside of an interpolated regexp element correctly",
      IIk nested?("#/foo \#{#/blah \#{foo(") should be true
    )

    it("should report the nesting of an interpolated alt regexp element that is closed correctly",
      IIk nested?("#r[foo \#{blah}]") should be false
    )

    it("should report the nesting of an interpolated alt regexp element as 2",
      IIk nested?("#r[foo \#{blah") should be true
    )

    it("should report the nesting of an interpolated alt regexp element with more nesting inside of it",
      IIk nested?("#r[foo \#{blah([1,2,3") should be true
    )

    it("should report the nesting of an interpolated alt regexp element with even more nesting inside of it",
      IIk nested?("#r[foo \#{blah([1,2,3, {") should be true
    )

    it("should report the nesting of an escaped interpolation in alt regexp correctly",
      IIk nested?("#r[foo \\\#{]") should be false
    )

    it("should report the nesting of an interpolated alt regexp element inside of an interpolated alt regexp element correctly",
      IIk nested?("#r[foo \#{#r[blah \#{foo(") should be true
    )
  )

  describe("nesting",
    it("should be false given an empty message",
      IIk nesting("") should == 0
    )
    
    it("should be true for a unfinished double quoted string",
      IIk nesting(#["foo]) should == 1
    )    
    
    it("should be false for a simple message",
      IIk nesting("foo") should == 0
    )
    
    it("should be false for a finished string",
      IIk nesting(#["foo"]) should == 0
    )
    
    it("should be true for a finished string followed by an unfinished string",
      IIk nesting(#["foo" "bar]) should == 1
    )
    
    it("should be false for a finished string containing an escaped quote",
      IIk nesting(#["fo\\"o"]) should == 0
    )
    
    it("should be false for a finished string containing something else that is quoted",
      IIk nesting(#["fo\\ro"]) should == 0
    )
    
    it("should be false for a finished string containing an escaped escape at the end",
      IIk nesting(#["fo\\\\"]) should == 0
    )
    
    it("should be true for a message with an unclosed parenthesis",
      IIk nesting("foo(") should == 1
    )
    
    it("should be true for a message with an unclosed parenthesis followed by something",
      IIk nesting("foo( bar quux") should == 1
    )
    
    it("should be false for a string with a single parenthesized message",
      IIk nesting("foo(bar)") should == 0
    )
    
    it("should be false for an obvious syntax error in parenthesis nesting",
      IIk nesting("foo())") should == 0
    )
    
    it("should be false for an paren inside of a string",
      IIk nesting(#["("]) should == 0
    )
    
    it("should be true for a message with an unclosed square bracket",
      IIk nesting("[") should == 1
    )
    
    it("should be true for a message followed by an unclosed square bracket",
      IIk nesting("foo [") should == 1
    )
    
    it("should be true for a message with an unclosed square bracket followed by something",
      IIk nesting("foo [ bar quux") should == 1
    )
    
    it("should be false for a string with a single square bracketed message",
      IIk nesting("foo [bar]") should == 0
    )
    
    it("should be false for an obvious syntax error in square bracket nesting",
      IIk nesting("foo []]") should == 0
    )
    
    it("should be false for a square bracket inside of a string",
      IIk nesting(#["["]) should == 0
    )
    
    it("should return false for a square bracket enclosed in alternate Text syntax",
      IIk nesting("#[[]") should == 0
    )
    
    it("should return false for an empty, lonesome hash",
      IIk nesting("#") should == 0
    )
    
    it("should return false for a string with alt text syntax with escape in it",
      IIk nesting("#[foo bar \\]bax]") should == 0
    )
    
    it("should be false for a finished alt text containing something else that is quoted",
      IIk nesting("#[fo\\ro]") should == 0
    )
    
    it("should return false for a string with alt text syntax ending in an escaped escape",
      IIk nesting("#[foo bar \\\\]") should == 0
    )
    
    it("should return true for a string with alt text syntax without a closing bracket",
      IIk nesting("#[foo bar") should == 1 
    )
    
    it("should return true for a string with alt text syntax with an open string character",
      IIk nesting("#[foo bar\"") should == 1
    )
    
    it("should be true for a message with an unclosed curly bracket",
      IIk nesting("{") should == 1
    )
    
    it("should be true for a message followed by an unclosed curly bracket",
      IIk nesting("foo {") should == 1
    )
    
    it("should be true for a message with an unclosed curly bracket followed by something",
      IIk nesting("foo { bar quux") should == 1
    )
    
    it("should be false for a string with a single curly bracketed message",
      IIk nesting("foo {bar}") should == 0
    )
    
    it("should be false for an obvious syntax error in curly bracket nesting",
      IIk nesting("foo {}}") should == 0
    )
    
    it("should be false for a curly bracket inside of a string",
      IIk nesting(#["{"]) should == 0
    )
    
    it("should return false for a curly bracket enclosed in alternate Text syntax",
      IIk nesting("#[{]") should == 0
    )
    
    it("should return false for a quote inside of a regexp literal",
      IIk nesting("#/\"/") should == 0 
    )
    
    it("should return false for an opening paren inside of a regexp literal",
      IIk nesting("#/(/") should == 0 
    )
    
    it("should return false for a closing paren inside of a regexp literal",
      IIk nesting("#/)/") should == 0 
    )
    
    it("should return false for an opening square bracket inside of a regexp literal",
      IIk nesting("#/[/") should == 0 
    )
    
    it("should return false for a closing square bracket inside of a regexp literal",
      IIk nesting("#/]/") should == 0 
    )
    
    it("should return false for an opening curly bracket inside of a regexp literal",
      IIk nesting("#/{/") should == 0 
    )
    
    it("should return false for a closing curly bracket inside of a regexp literal",
      IIk nesting("#/}/") should == 0 
    )
    
    it("should return true for a simple opened regexp literal",
      IIk nesting("#/") should == 1
    )
    
    it("should be true for an opened regexp literal as part of a longer message",
      IIk nesting("foo bar(#/baz\"qux\"") should == 2
    )
    
    it("should false for a regexp with an escaped ending character",
      IIk nesting("#/foo\\/bar#/") should == 0
    )
    
    it("should be false for a regexp containing something else that is quoted",
      IIk nesting("#/fo\\so/") should == 0
    )
    
    it("should return false for a quote inside of a alt regexp literal",
      IIk nesting("#r[\"]") should == 0 
    )
    
    it("should return false for an opening paren inside of an alt regexp literal",
      IIk nesting("#r[(]") should == 0 
    )
    
    it("should return false for a closing paren inside of an alt regexp literal",
      IIk nesting("#r[)]") should == 0 
    )
    
    it("should return false for an opening square bracket inside of an alt regexp literal",
      IIk nesting("#r[[]") should == 0 
    )
    
    it("should return false for an opening curly bracket inside of an alt regexp literal",
      IIk nesting("#r[{]") should == 0 
    )
    
    it("should return false for a closing curly bracket inside of an alt regexp literal",
      IIk nesting("#r[}]") should == 0 
    )
    
    it("should return true for a simple opened alt regexp literal",
      IIk nesting("#r[") should == 1
    )
    
    it("should be true for an opened alt regexp literal as part of a longer message",
      IIk nesting("foo bar(#r[baz\"qux\"") should == 2
    )
    
    it("should false for an alt regexp with an escaped ending character",
      IIk nesting("#r[foo\\]bar#]") should == 0
    )
    
    it("should be false for an alt regexp containing something else that is quoted",
      IIk nesting("#r[fo\\so]") should == 0
    )
    
    it("should be false for an alt regexp containing a regular regexp literal",
      IIk nesting("#r[#/foo]") should == 0
    )

    it("should report the nesting of an interpolated text element that is closed correctly",
      IIk nesting("\"foo \#{blah}\"") should == 0
    )

    it("should report the nesting of an interpolated text element as 2",
      IIk nesting("\"foo \#{blah") should == 2
    )

    it("should report the nesting of an interpolated text element with more nesting inside of it",
      IIk nesting("\"foo \#{blah([1,2,3") should == 4
    )

    it("should report the nesting of an interpolated text element with even more nesting inside of it",
      IIk nesting("\"foo \#{blah([1,2,3, {") should == 5
    )

    it("should report the nesting of an escaped interpolation correctly",
      IIk nesting("\"foo \\\#{\"") should == 0
    )

    it("should report the nesting of an interpolated text element inside of an interpolated text element correctly",
      IIk nesting("\"foo \#{\"blah \#{foo(") should == 5
    )

    it("should report the nesting of an interpolated alt text element that is closed correctly",
      IIk nesting("#[foo \#{blah}]") should == 0
    )

    it("should report the nesting of an interpolated alt text element as 2",
      IIk nesting("#[foo \#{blah") should == 2
    )

    it("should report the nesting of an interpolated alt text element with more nesting inside of it",
      IIk nesting("#[foo \#{blah([1,2,3") should == 4
    )

    it("should report the nesting of an interpolated alt text element with even more nesting inside of it",
      IIk nesting("#[foo \#{blah([1,2,3, {") should == 5
    )

    it("should report the nesting of an escaped interpolation in alt text correctly",
      IIk nesting("#[foo \\\#{]") should == 0
    )

    it("should report the nesting of an interpolated alt text element inside of an interpolated alt text element correctly",
      IIk nesting("#[foo \#{#[blah \#{foo(") should == 5
    )

    it("should report the nesting of an interpolated regexp element that is closed correctly",
      IIk nesting("#/foo \#{blah}/") should == 0
    )

    it("should report the nesting of an interpolated regexp element as 2",
      IIk nesting("#/foo \#{blah") should == 2
    )

    it("should report the nesting of an interpolated regexp element with more nesting inside of it",
      IIk nesting("#/foo \#{blah([1,2,3") should == 4
    )

    it("should report the nesting of an interpolated regexp element with even more nesting inside of it",
      IIk nesting("#/foo \#{blah([1,2,3, {") should == 5
    )

    it("should report the nesting of an escaped interpolation in regexp correctly",
      IIk nesting("#/foo \\\#{/") should == 0
    )

    it("should report the nesting of an interpolated regexp element inside of an interpolated regexp element correctly",
      IIk nesting("#/foo \#{#/blah \#{foo(") should == 5
    )

    it("should report the nesting of an interpolated alt regexp element that is closed correctly",
      IIk nesting("#r[foo \#{blah}]") should == 0
    )

    it("should report the nesting of an interpolated alt regexp element as 2",
      IIk nesting("#r[foo \#{blah") should == 2
    )

    it("should report the nesting of an interpolated alt regexp element with more nesting inside of it",
      IIk nesting("#r[foo \#{blah([1,2,3") should == 4
    )

    it("should report the nesting of an interpolated alt regexp element with even more nesting inside of it",
      IIk nesting("#r[foo \#{blah([1,2,3, {") should == 5
    )

    it("should report the nesting of an escaped interpolation in alt regexp correctly",
      IIk nesting("#r[foo \\\#{]") should == 0
    )

    it("should report the nesting of an interpolated alt regexp element inside of an interpolated alt regexp element correctly",
      IIk nesting("#r[foo \#{#r[blah \#{foo(") should == 5
    )
  )
)
