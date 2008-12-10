
use("ispec")

describe(DateTime,
  it("should have the correct kind",
    DateTime should have kind("DateTime")
  )
)
