
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
)
