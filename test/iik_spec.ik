use("ispec")
use("../src/builtin/iik")

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
    
    ; it("should return false for an opening square bracket inside of a regexp literal",
    ;   IIk nested?("#/[/") should be false 
    ; )
    ; 
    ; it("should return false for a closing square bracket inside of a regexp literal",
    ;   IIk nested?("#/]/") should be false 
    ; )
    ; 
    ; it("should return false for an opening curly bracket inside of a regexp literal",
    ;   IIk nested?("#/{/") should be false 
    ; )
    ; 
    ; it("should return false for a closing curly bracket inside of a regexp literal",
    ;   IIk nested?("#/}/") should be false 
    ; )
    ; 
    ; it("should return true for a simple opened regexp literal",
    ;   IIk nested?("#/") should be true
    ; )
    ; 
    ; it("should be true for an opened regexp literal as part of a longer message",
    ;   IIk nested?("foo bar(#/baz\"qux\"") should be true
    ; )
    ; 
    ; it("should false for a regexp with an escaped ending character",
    ;   IIk nested?("#/foo\\/bar#/") should be false
    ; )
    ; 
    ; it("should be false for a regexp containing something else that is quoted",
    ;   IIk nested?("#/fo\\so/") should be false
    ; )
  )
)
