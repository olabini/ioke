
use("ispec")

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
)
