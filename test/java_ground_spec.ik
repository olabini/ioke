
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
    it("should be possible to call a static method on the class",
      ioke:lang:test:StaticMethods simple asText should == "foo"
    )

    it("should be possible to call a static method on an instance of that class",
      x = ioke:lang:test:StaticMethods new
      x simple asText should == "foo"
    )

    it("should disambiguate between two method with the same arg count",
      ioke:lang:test:StaticMethods overloaded(true, 123) asText should == "overloaded(boolean, int)"
      ioke:lang:test:StaticMethods overloaded(true, 123.3) asText should == "overloaded(boolean, double)"
    )

    it("should invoke a method with no arguments correctly",
      ioke:lang:test:StaticMethods overloaded asText should == "overloaded()"
    )

    it("should coerce Text correctly to String",
      ioke:lang:test:StaticMethods overloaded("foo") asText should == "overloaded(String)"
    )

    it("should coerce Symbol correctly to String",
      ioke:lang:test:StaticMethods overloaded(:foo) asText should == "overloaded(String)"
    )

    it("should coerce Rational correctly to int",
      ioke:lang:test:StaticMethods overloaded(42) asText should == "overloaded(int)"
    )

    it("should coerce Decimal correctly to double",
      ioke:lang:test:StaticMethods overloaded(0.1) asText should == "overloaded(double)"
    )

    it("should coerce true correctly to boolean",
      ioke:lang:test:StaticMethods overloaded(true) asText should == "overloaded(boolean)"
    )

    it("should coerce false correctly to boolean",
      ioke:lang:test:StaticMethods overloaded(false) asText should == "overloaded(boolean)"
    )

    it("should coerce nil correctly to string",
      ioke:lang:test:StaticMethods overloaded(nil) asText should == "overloaded(null: String)"
    )

    it("should coerce something else correctly to Object",
      ioke:lang:test:StaticMethods overloaded(1..42) asText should == "overloaded(Object)"
    )

    it("should be possible to manually coerce into a short argument",
      ioke:lang:test:StaticMethods overloaded((short)102) asText should == "overloaded(short)"
      ioke:lang:test:StaticMethods overloaded((short)102, false) asText should == "overloaded(short, boolean)"
      ioke:lang:test:StaticMethods overloaded(123, (short)42) asText should == "overloaded(int, short)"
      ioke:lang:test:StaticMethods overloaded((short)123, (short)42) asText should == "overloaded(short, short)"
    )

    it("should be possible to manually coerce into an int argument",
      ioke:lang:test:StaticMethods overloaded((int)102) asText should == "overloaded(int)"
      ioke:lang:test:StaticMethods overloaded((int)102, 40.2) asText should == "overloaded(int, double)"
      ioke:lang:test:StaticMethods overloaded(false, (int)42) asText should == "overloaded(boolean, int)"
      ioke:lang:test:StaticMethods overloaded((int)123, (int)42) asText should == "overloaded(int, int)"
    )

    it("should be possible to manually coerce into a char argument",
      ioke:lang:test:StaticMethods overloaded((char)102) asText should == "overloaded(char)"
      ioke:lang:test:StaticMethods overloaded((char)102, false) asText should == "overloaded(char, boolean)"
      ioke:lang:test:StaticMethods overloaded(123, (char)42) asText should == "overloaded(int, char)"
      ioke:lang:test:StaticMethods overloaded((char)123, (char)42) asText should == "overloaded(char, char)"
    )

    it("should be possible to manually coerce into a long argument",
      ioke:lang:test:StaticMethods overloaded((long)102) asText should == "overloaded(long)"
      ioke:lang:test:StaticMethods overloaded((long)102, false) asText should == "overloaded(long, boolean)"
      ioke:lang:test:StaticMethods overloaded(123, (long)42) asText should == "overloaded(int, long)"
      ioke:lang:test:StaticMethods overloaded((long)123, (long)42) asText should == "overloaded(long, long)"
    )

    it("should be possible to manually coerce into a float argument",
      ioke:lang:test:StaticMethods overloaded((float)102) asText should == "overloaded(float)"
      ioke:lang:test:StaticMethods overloaded((float)102, false) asText should == "overloaded(float, boolean)"
      ioke:lang:test:StaticMethods overloaded(123, (float)42) asText should == "overloaded(int, float)"
      ioke:lang:test:StaticMethods overloaded((float)123, (float)42) asText should == "overloaded(float, float)"

      ioke:lang:test:StaticMethods overloaded((float)102.2) asText should == "overloaded(float)"
      ioke:lang:test:StaticMethods overloaded((float)102.3, false) asText should == "overloaded(float, boolean)"
      ioke:lang:test:StaticMethods overloaded(123, (float)42.4) asText should == "overloaded(int, float)"
      ioke:lang:test:StaticMethods overloaded((float)123.6, (float)42.5) asText should == "overloaded(float, float)"
    )

    it("should be possible to manually coerce into a double argument",
      ioke:lang:test:StaticMethods overloaded((double)102) asText should == "overloaded(double)"
      ioke:lang:test:StaticMethods overloaded((double)102, false) asText should == "overloaded(double, boolean)"
      ioke:lang:test:StaticMethods overloaded(123, (double)42) asText should == "overloaded(int, double)"
      ioke:lang:test:StaticMethods overloaded((double)123, (double)42) asText should == "overloaded(double, double)"

      ioke:lang:test:StaticMethods overloaded((double)102.2) asText should == "overloaded(double)"
      ioke:lang:test:StaticMethods overloaded((double)102.3, false) asText should == "overloaded(double, boolean)"
      ioke:lang:test:StaticMethods overloaded(123, (double)42.4) asText should == "overloaded(int, double)"
      ioke:lang:test:StaticMethods overloaded((double)123.6, (double)42.5) asText should == "overloaded(double, double)"
    )

    it("should be possible to manually coerce into a boolean argument",
      ioke:lang:test:StaticMethods overloaded((boolean)false) asText should == "overloaded(boolean)"
      ioke:lang:test:StaticMethods overloaded((boolean)false, 102) asText should == "overloaded(boolean, int)"
      ioke:lang:test:StaticMethods overloaded(123, (boolean)true) asText should == "overloaded(int, boolean)"
      ioke:lang:test:StaticMethods overloaded((boolean)true, (boolean)false) asText should == "overloaded(boolean, boolean)"
    )

    it("should be possible to manually coerce object arguments",
      ioke:lang:test:StaticMethods overloaded((Object)"foo") asText should == "overloaded(Object)"
      ioke:lang:test:StaticMethods overloaded((java:lang:Object)"foo") asText should == "overloaded(Object)"

      ioke:lang:test:StaticMethods overloaded((String)nil) asText should == "overloaded(null: String)"
      ioke:lang:test:StaticMethods overloaded((java:lang:String)nil) asText should == "overloaded(null: String)"

      ioke:lang:test:StaticMethods overloaded((Object)nil) asText should == "overloaded(null: Object)"
      ioke:lang:test:StaticMethods overloaded((java:lang:Object)nil) asText should == "overloaded(null: Object)"
    )

    it("should be possible to supply arguments by name")
    it("should add aliases for JavaBean style methods")
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

    it("should disambiguate between two method with the same arg count",
      i = ioke:lang:test:InstanceMethods new
      i overloaded(true, 123) asText should == "overloaded(boolean, int)"
      i overloaded(true, 123.3) asText should == "overloaded(boolean, double)"
    )

    it("should invoke a method with no arguments correctly",
      i = ioke:lang:test:InstanceMethods new
      i overloaded asText should == "overloaded()"
    )

    it("should coerce Text correctly to String",
      i = ioke:lang:test:InstanceMethods new
      i overloaded("foo") asText should == "overloaded(String)"
    )

    it("should coerce Symbol correctly to String",
      i = ioke:lang:test:InstanceMethods new
      i overloaded(:foo) asText should == "overloaded(String)"
    )

    it("should coerce Rational correctly to int",
      i = ioke:lang:test:InstanceMethods new
      i overloaded(42) asText should == "overloaded(int)"
    )

    it("should coerce Decimal correctly to double",
      i = ioke:lang:test:InstanceMethods new
      i overloaded(0.1) asText should == "overloaded(double)"
    )

    it("should coerce true correctly to boolean",
      i = ioke:lang:test:InstanceMethods new
      i overloaded(true) asText should == "overloaded(boolean)"
    )

    it("should coerce false correctly to boolean",
      i = ioke:lang:test:InstanceMethods new
      i overloaded(false) asText should == "overloaded(boolean)"
    )

    it("should coerce nil correctly to string",
      i = ioke:lang:test:InstanceMethods new
      i overloaded(nil) asText should == "overloaded(null: String)"
    )

    it("should coerce something else correctly to Object",
      i = ioke:lang:test:InstanceMethods new
      i overloaded(1..42) asText should == "overloaded(Object)"
    )

    it("should be possible to manually coerce into a short argument",
      i = ioke:lang:test:InstanceMethods new
      i overloaded((short)102) asText should == "overloaded(short)"
      i overloaded((short)102, false) asText should == "overloaded(short, boolean)"
      i overloaded(123, (short)42) asText should == "overloaded(int, short)"
      i overloaded((short)123, (short)42) asText should == "overloaded(short, short)"
    )

    it("should be possible to manually coerce into an int argument",
      i = ioke:lang:test:InstanceMethods new
      i overloaded((int)102) asText should == "overloaded(int)"
      i overloaded((int)102, 40.2) asText should == "overloaded(int, double)"
      i overloaded(false, (int)42) asText should == "overloaded(boolean, int)"
      i overloaded((int)123, (int)42) asText should == "overloaded(int, int)"
    )

    it("should be possible to manually coerce into a char argument",
      i = ioke:lang:test:InstanceMethods new
      i overloaded((char)102) asText should == "overloaded(char)"
      i overloaded((char)102, false) asText should == "overloaded(char, boolean)"
      i overloaded(123, (char)42) asText should == "overloaded(int, char)"
      i overloaded((char)123, (char)42) asText should == "overloaded(char, char)"
    )

    it("should be possible to manually coerce into a long argument",
      i = ioke:lang:test:InstanceMethods new
      i overloaded((long)102) asText should == "overloaded(long)"
      i overloaded((long)102, false) asText should == "overloaded(long, boolean)"
      i overloaded(123, (long)42) asText should == "overloaded(int, long)"
      i overloaded((long)123, (long)42) asText should == "overloaded(long, long)"
    )

    it("should be possible to manually coerce into a float argument",
      i = ioke:lang:test:InstanceMethods new
      i overloaded((float)102) asText should == "overloaded(float)"
      i overloaded((float)102, false) asText should == "overloaded(float, boolean)"
      i overloaded(123, (float)42) asText should == "overloaded(int, float)"
      i overloaded((float)123, (float)42) asText should == "overloaded(float, float)"

      i overloaded((float)102.2) asText should == "overloaded(float)"
      i overloaded((float)102.3, false) asText should == "overloaded(float, boolean)"
      i overloaded(123, (float)42.4) asText should == "overloaded(int, float)"
      i overloaded((float)123.6, (float)42.5) asText should == "overloaded(float, float)"
    )

    it("should be possible to manually coerce into a double argument",
      i = ioke:lang:test:InstanceMethods new
      i overloaded((double)102) asText should == "overloaded(double)"
      i overloaded((double)102, false) asText should == "overloaded(double, boolean)"
      i overloaded(123, (double)42) asText should == "overloaded(int, double)"
      i overloaded((double)123, (double)42) asText should == "overloaded(double, double)"

      i overloaded((double)102.2) asText should == "overloaded(double)"
      i overloaded((double)102.3, false) asText should == "overloaded(double, boolean)"
      i overloaded(123, (double)42.4) asText should == "overloaded(int, double)"
      i overloaded((double)123.6, (double)42.5) asText should == "overloaded(double, double)"
    )

    it("should be possible to manually coerce into a boolean argument",
      i = ioke:lang:test:InstanceMethods new
      i overloaded((boolean)false) asText should == "overloaded(boolean)"
      i overloaded((boolean)false, 102) asText should == "overloaded(boolean, int)"
      i overloaded(123, (boolean)true) asText should == "overloaded(int, boolean)"
      i overloaded((boolean)true, (boolean)false) asText should == "overloaded(boolean, boolean)"
    )

    it("should be possible to manually coerce object arguments",
      i = ioke:lang:test:InstanceMethods new
      i overloaded((Object)"foo") asText should == "overloaded(Object)"
      i overloaded((java:lang:Object)"foo") asText should == "overloaded(Object)"

      i overloaded((String)nil) asText should == "overloaded(null: String)"
      i overloaded((java:lang:String)nil) asText should == "overloaded(null: String)"

      i overloaded((Object)nil) asText should == "overloaded(null: Object)"
      i overloaded((java:lang:Object)nil) asText should == "overloaded(null: Object)"
    )

    it("should disambiguate between methods that take a Class and methods that take instance of that class, when searching for appropriate methods")
    it("should be possible to supply arguments by name")
    it("should add aliases for JavaBean style methods")
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

    it("should coerce Decimal correctly to double",
      ioke:lang:test:Constructors new(4242.42) getData asText should == "Constructors(double)"
    )      

    it("should coerce true correctly to boolean",
      ioke:lang:test:Constructors new(true) getData asText should == "Constructors(boolean)"
    )      

    it("should coerce false correctly to boolean",
      ioke:lang:test:Constructors new(false) getData asText should == "Constructors(boolean)"
    )      

    it("should coerce nil correctly to string",
      ioke:lang:test:Constructors new(nil) getData asText should == "Constructors(null: String)"
    )      

    it("should coerce something else correctly to Object",
      ioke:lang:test:Constructors new(1..40) getData asText should == "Constructors(Object)"
    )

    it("should be possible to manually coerce into a short argument",
      ioke:lang:test:Constructors new( (short) 4242 ) getData asText should == "Constructors(short)"
    )

    it("should be possible to manually coerce into an int argument",
      ioke:lang:test:Constructors new( (int) 4242 ) getData asText should == "Constructors(int)"
      ioke:lang:test:Constructors new((integer)4242) getData asText should == "Constructors(int)"
    )

    it("should be possible to manually coerce into a char argument",
      ioke:lang:test:Constructors new( (char) 4242 ) getData asText should == "Constructors(char)"
      ioke:lang:test:Constructors new((character)4242) getData asText should == "Constructors(char)"
    )

    it("should be possible to manually coerce into a long argument",
      ioke:lang:test:Constructors new( (long)4242 ) getData asText should == "Constructors(long)"
    )

    it("should be possible to manually coerce into a boolean argument",
      ioke:lang:test:Constructors new( (boolean)true ) getData asText should == "Constructors(boolean)"
    )

    it("should be possible to manually coerce into a float argument",
      ioke:lang:test:Constructors new( (float)4242 ) getData asText should == "Constructors(float)"
      ioke:lang:test:Constructors new( (float)4242.0 ) getData asText should == "Constructors(float)"
    )

    it("should be possible to manually coerce into a double argument",
      ioke:lang:test:Constructors new( (double)4242 ) getData asText should == "Constructors(double)"
      ioke:lang:test:Constructors new( (double)4242.1 ) getData asText should == "Constructors(double)"
    )

    it("should be possible to manually coerce object arguments",
      ioke:lang:test:Constructors new((Object)"foo") getData asText should == "Constructors(Object)"
      ioke:lang:test:Constructors new((java:lang:Object)"foo") getData asText should == "Constructors(Object)"

      ioke:lang:test:Constructors new((String)nil) getData asText should == "Constructors(null: String)"
      ioke:lang:test:Constructors new((java:lang:String)nil) getData asText should == "Constructors(null: String)"

      ioke:lang:test:Constructors new((Object)nil) getData asText should == "Constructors(null: Object)"
      ioke:lang:test:Constructors new((java:lang:Object)nil) getData asText should == "Constructors(null: Object)"
    )

    it("should be possible to supply arguments by name")
  )

  describe("implementing interfaces",
    it("should have tests")
  )

  describe("extending classes",
    it("should have tests")
  )
)
