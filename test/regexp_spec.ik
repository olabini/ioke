
use("ispec")

describe(Regexp,
  it("should have the correct kind",
    Regexp should have kind("Regexp")
  )
)
