
use("ispec")

describe(IO, 
  it("should have the correct kind", 
    IO should have kind("IO")
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
