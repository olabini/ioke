
use("ispec")

describe(Hook,
  it("should have the correct kind",
    Hook should have kind("Hook")
  )

  describe("into",
    it("should return a new hook object connected to the argument object")
  )

  describe("into!",
    it("should add itself to the mimic chain of the first argument and bind it to the second object")
  )

  describe("hook!",
    it("should add a new observed object to the receiver")
  )

  describe("cellAdded",
    it("should have tests")
  )

  describe("cellRemoved",
    it("should have tests")
  )

  describe("cellChanged",
    it("should have tests")
  )

  describe("cellUndefined",
    it("should have tests")
  )

  describe("mimicked",
    it("should have tests")
  )

  describe("mimicAdded",
    it("should have tests")
  )

  describe("mimicRemoved",
    it("should have tests")
  )

  describe("mimicsChanged",
    it("should have tests")
  )
)
