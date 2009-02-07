
use("ispec")

describe("JavaGround",
  it("should have the correct kind",
    JavaGround kind should == "JavaGround"
  )

  it("should be a mimic of Origin",
    Origin should mimic(JavaGround)
  )

  describe("java:lang:Class",
    it("should have a kind of JavaOrigin",
      JavaGround java:lang:Class kind should == "java:lang:Class"
    )

    it("should have a class of itself",
      JavaGround java:lang:Class getClass should be same?(JavaGround java:lang:Class)
    )
  )

  describe("primitiveJavaClass!",
    it("should return the Java class for the string sent in",
      px = JavaGround primitiveJavaClass!("java.util.HashMap")
      px kind should == "java:lang:Class"
      px name should == "java:util:HashMap"
      px cell?(:new) should be true
    )
  )

  describe("construction",
    it("should be possible to create a new instance of a Java class",
      px = JavaGround primitiveJavaClass!("java.util.HashMap")
      val = px new
      val should mimic(px)
    )
  )

  describe("calling static methods",
    it("should have tests")
  )

  describe("calling method with arguments",
    it("should be possible to give one arguments",
      ll = java:util:ArrayList new
      ll size asRational should == 0
      ll add("foo")
      ll size asRational should == 1
      ll add("foo")
      ll size asRational should == 2
    )

    it("should be possible to give two arguments",
      hm = java:util:HashMap new
      hm size asRational should == 0
      hm put("foo", "bar")
      hm size asRational should == 1
      hm put("foo", "quux")
      hm size asRational should == 1
    )

    describe("conversion protocol",
      it("should not transform argument when parameter type is object - except for nil")
      it("should always coerce nil into null")
      it("should coerce a Text to a String argument")
      it("should never coerce the return value")
    )
  )

  describe("calling constructors with arguments",
    it("should disambiguate between two constructors with the same arg count",
      ll = java:util:ArrayList new(10)
      ll size asRational should == 0

      val = java:util:ArrayList new
      val add("foo")
      val add("bar")

      ll = java:util:ArrayList new(val)
      ll size asRational should == 2
    )
  )
)
