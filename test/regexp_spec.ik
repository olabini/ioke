
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

  describe("inspect",
    it("should have tests")
  )

  describe("notice",
    it("should have tests")
  )
)
