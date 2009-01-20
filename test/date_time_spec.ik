
use("ispec")

describe(DateTime,
  it("should have the correct kind",
    DateTime should have kind("DateTime")
  )

  describe("-",
    it("should validate type of argument",
      fn(DateTime - 4) should signal(Condition Error Type IncorrectType)
    )

    it("should validate type of receiver",
      DateTime should checkReceiverTypeOn(:"-", DateTime now)
    )
  )

  describe("inspect",
    it("should validate type of receiver",
      DateTime should checkReceiverTypeOn(:inspect)
    )
  )

  describe("notice",
    it("should validate type of receiver",
      DateTime should checkReceiverTypeOn(:notice)
    )
  )
)
