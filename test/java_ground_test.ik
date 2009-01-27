
use("ispec")

describe("JavaGround",
  it("should have the correct kind",
    JavaGround kind should == "JavaGround"
  )

  it("should be a mimic of Origin",
    Origin should mimic(JavaGround)
  )
)
