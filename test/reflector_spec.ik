
use("ispec")

describe(Reflector,
  it("should have the correct kind",
    Reflector should have kind("Reflector")
  )

  describe("other:documentation",
    it("should fetch an objects documentation",
      obj = Origin mimic

      Reflector other:documentation(obj) should be nil

      obj documentation = "foo bar"

      Reflector other:documentation(obj) should == "foo bar"

      obj removeAllMimics!

      Reflector other:documentation(obj) should == "foo bar"
    )
  )

  describe("other:documentation=",
    it("should set the documentation on an object",
      obj = Origin mimic
      Reflector other:documentation(obj) = "flux"
      obj documentation should == "flux"

      obj removeAllMimics!

      Reflector other:documentation(obj) should == "flux"
    )
  )

  describe("other:mimics",
    it("should have tests")
  )

  describe("other:is?",
    it("should have tests")
  )

  describe("other:uniqueHexId",
    it("should have tests")
  )

  describe("other:same?",
    it("should have tests")
  )

  describe("other:send",
    it("should have tests")
  )

  describe("other:kind?",
    it("should have tests")
  )

  describe("other:become!",
    it("should have tests")
  )

  describe("other:frozen?",
    it("should have tests")
  )

  describe("other:freeze!",
    it("should have tests")
  )

  describe("other:thaw!",
    it("should have tests")
  )

  describe("other:mimics?",
    it("should have tests")
  )

  describe("other:mimic",
    it("should have tests")
  )

  describe("other:mimic!",
    it("should have tests")
  )

  describe("other:appendMimic!",
    it("should have tests")
  )

  describe("other:prependMimic!",
    it("should have tests")
  )

  describe("other:removeMimics!",
    it("should have tests")
  )

  describe("other:removeAllMimics!",
    it("should have tests")
  )

  describe("other:cell",
    it("should have tests")
  )

  describe("other:cell=",
    it("should have tests")
  )

  describe("other:cell?",
    it("should have tests")
  )

  describe("other:cellNames",
    it("should have tests")
  )

  describe("other:cells",
    it("should have tests")
  )

  describe("other:cellOwner",
    it("should have tests")
  )

  describe("other:cellOwner?",
    it("should have tests")
  )

  describe("other:removeCell!",
    it("should have tests")
  )

  describe("other:undefineCell!",
    it("should have tests")
  )
)
