
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

  describe("import",
    it("should have tests")
  )
)

describe("Java Objects",
  describe("==",
    it("should call java.lang.Object#equals")
  )

  describe("same?",
    it("should use Java ==")
  )

  describe("inner classes",
    it("should have tests")
  )

  describe("fields",
    it("should have tests")
  )

  describe("construction",
    it("should be possible to create a new instance of a Java class",
      px = JavaGround primitiveJavaClass!("java.util.HashMap")
      val = px new
      val should mimic(px)
    )
  )

  describe("static methods",
    it("should be possible to call a static method on the class")
    it("should be possible to call a static method on an instance of that class")
    it("should disambiguate between two method with the same arg count")
    it("should invoke a method with no arguments correctly")
    it("should coerce Text correctly to String")
    it("should coerce Symbol correctly to String")
    it("should coerce Rational correctly to int")
    it("should coerce Decimal correctly to float")
    it("should coerce true correctly to boolean")
    it("should coerce false correctly to boolean")      
    it("should coerce nil correctly to string")      
    it("should coerce something else correctly to Object")
    it("should sort them in most specific order before choosing")
    it("should not wrap the result value")
    it("should be possible to manually coerce into a short argument")
    it("should be possible to manually coerce into an int argument")
    it("should be possible to manually coerce into a char argument")
    it("should be possible to manually coerce into a long argument")
    it("should be possible to manually coerce into a float argument")
    it("should be possible to manually coerce into a double argument")
    it("should be possible to supply arguments by name")
    it("should always return nil instead of null")
  )

  describe("methods",
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

    it("should disambiguate between two method with the same arg count")
    it("should invoke a method with no arguments correctly")
    it("should coerce Text correctly to String")
    it("should coerce Symbol correctly to String")
    it("should coerce Rational correctly to int")
    it("should coerce Decimal correctly to float")
    it("should coerce true correctly to boolean")
    it("should coerce false correctly to boolean")      
    it("should coerce nil correctly to string")      
    it("should coerce something else correctly to Object")
    it("should sort them in most specific order before choosing")
    it("should not wrap the result value")
    it("should be possible to manually coerce into a short argument")
    it("should be possible to manually coerce into an int argument")
    it("should be possible to manually coerce into a char argument")
    it("should be possible to manually coerce into a long argument")
    it("should be possible to manually coerce into a float argument")
    it("should be possible to manually coerce into a double argument")
    it("should disambiguate between methods that take a Class and methods that take instance of that class, when searching for appropriate methods")
    it("should be possible to supply arguments by name")
    it("should always return nil instead of null")
  )

  describe("constructors",
    it("should disambiguate between two constructors with the same arg count",
      ll = java:util:ArrayList new(10)
      ll size asRational should == 0

      val = java:util:ArrayList new
      val add("foo")
      val add("bar")

      ll = java:util:ArrayList new(val)
      ll size asRational should == 2
    )

    it("should invoke an empty constructor correctly",
      ioke:lang:test:Constructors new getData asText should == "Constructors()"
    )

    it("should coerce Text correctly to String",
      ioke:lang:test:Constructors new("foo") getData asText should == "Constructors(String)"
    )      

    it("should coerce Symbol correctly to String",
      ioke:lang:test:Constructors new(:foo) getData asText should == "Constructors(String)"
    )      

    it("should coerce Rational correctly to int",
      ioke:lang:test:Constructors new(4242) getData asText should == "Constructors(int)"
    )      

    it("should coerce Decimal correctly to float",
      ioke:lang:test:Constructors new(4242.42) getData asText should == "Constructors(float)"
    )      

    it("should coerce true correctly to boolean",
      ioke:lang:test:Constructors new(true) getData asText should == "Constructors(boolean)"
    )      

    it("should coerce false correctly to boolean",
      ioke:lang:test:Constructors new(false) getData asText should == "Constructors(boolean)"
    )      

    it("should coerce nil correctly to string",
      ioke:lang:test:Constructors new(nil) getData asText should == "Constructors(null: Object)"
    )      

    it("should coerce something else correctly to Object",
      ioke:lang:test:Constructors new(1..40) getData asText should == "Constructors(Object)"
    )
    
    it("should sort them in most specific order before choosing")
    it("should be possible to manually coerce into a short argument")
    it("should be possible to manually coerce into an int argument")
    it("should be possible to manually coerce into a char argument")
    it("should be possible to manually coerce into a long argument")
    it("should be possible to manually coerce into a float argument")
    it("should be possible to manually coerce into a double argument")
    
    it("should be possible to supply arguments by name")
  )

  describe("implementing interfaces",
    it("should have tests")
  )

  describe("extending classes",
    it("should have tests")
  )
)
