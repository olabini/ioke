
use("ispec")

describe("IokeGround",
  it("should have the correct kind",
    IokeGround kind should == "IokeGround"
  )

  it("should mimic Base",
    (IokeGround mimics[1] == Base) should be true
  )

  it("should mimic DefaultBehavior",
    (IokeGround mimics[0] == DefaultBehavior) should be true
  )
)

describe("Ground",
  it("should mimic IokeGround",
    Ground should mimic(IokeGround)
  )

  onlyWhen(System feature?(:java),
    it("should mimic JavaGround",
      Ground should mimic(JavaGround)
  ))
)
