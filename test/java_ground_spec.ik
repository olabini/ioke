
use("ispec")

describe("JavaGround",
  it("should have the correct kind",
    JavaGround kind should == "JavaGround"
  )

  it("should be a mimic of Origin",
    Origin should mimic(JavaGround)
  )

;   describe("java:lang:Class",
;     it("should have a kind of JavaOrigin",
;       JavaGround java:lang:Class kind should == "java:lang:Class"
;     )

;     it("should have a class of itself",
;       JavaGround java:lang:Class class should be same?(JavaGround java:lang:Class)
;     )
;   )

;   describe("primitiveJavaClass!",
;     it("should return the Java class for the string sent in",
;       px = JavaGround primitiveJavaClass!("java.util.HashMap")
;       px kind should == "java:util:HashMap"
;       px cell?(:new) should be true
;     )
;   )
)
