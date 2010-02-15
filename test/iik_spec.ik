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
    
    it("should be false for an escaped paren inside of a string",
      IIk nested?(#["("]) should be false
    )
  )
)
