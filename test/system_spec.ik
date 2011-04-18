
use("ispec")

describe(System,
  it("should have the correct kind",
    System should have kind("System")
  )

  describe("hostName",
    it("returns something that is a non-empty Text",
      System hostName should mimic(Text)
      System hostName should not be empty
    )
  )
)
