
use("ispec")

describe(IO,
  it("should have the correct kind",
    IO should have kind("IO")
  )

  describe("println",
    it("should validate type of receiver",
      IO should checkReceiverTypeOn(:println, "foo")
    )
  )

  describe("print",
    it("should validate type of receiver",
      IO should checkReceiverTypeOn(:print, "foo")
    )
  )

  describe("read",
    it("should validate type of receiver",
      IO should checkReceiverTypeOn(:read)
    )
  )
)

describe(System,
  describe("out",
    it("should be an IO object",
      System out should have kind("IO")
    )
  )

  describe("err",
    it("should be an IO object",
      System err should have kind("IO")
    )
  )

  describe("in",
    it("should be an IO object",
      System in should have kind("IO")
    )
  )
)
