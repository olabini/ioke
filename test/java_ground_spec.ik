
use("ispec")

describe("JavaGround",
  it("should have the correct kind",
    JavaGround kind should == "JavaGround"
  )

  it("should be one of Origin's mimics",
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
      px class:name should == "java:util:HashMap"
      px cell?(:new) should be true
    )
  )

  describe("import",
    it("should simply import a named class with an argument",
      cell?(:AbstractMap) should be false
      import(java:util:AbstractMap)
      cell?(:AbstractMap) should be true
      import(java:util:AbstractMap)
      cell?(:AbstractMap) should be true
    )

    it("should work as an operator when importing single classes",
      cell?(:AbstractSet) should be false
      import java:util:AbstractSet
      cell?(:AbstractSet) should be true
      import java:util:AbstractSet
      cell?(:AbstractSet) should be true
    )

    it("shouldn't overwrite or shadow an existing cell",
      foo = Origin mimic
      foo bar = 123
      foo2 = foo mimic
      foo2 import(bar: java:util:HashMap)
      foo bar should == 123
      foo2 bar should == 123

      foo import(bar: java:util:LinkedList)
      foo bar should == 123
    )

    it("should allow renaming by using hash arguments",
      cell?(:TestOfImportingNaming1) should be false
      cell?(:TestOfImportingNaming2) should be false
      cell?(:TestOfImportingNaming3) should be false

      import(TestOfImportingNaming1: java:util:HashMap, TestOfImportingNaming2: java:util:ArrayList)
      import TestOfImportingNaming3: java:util:HashMap

      cell?(:TestOfImportingNaming1) should be true
      cell?(:TestOfImportingNaming2) should be true
      cell?(:TestOfImportingNaming3) should be true
    )

    it("should allow importing of more than one entity from the same package",
      cell?(:ListResourceBundle) should be false
      cell?(:SimpleTimeZone) should be false
      cell?(:GregorianCalendar) should be false

      import(:java:util, :ListResourceBundle, :SimpleTimeZone, :GregorianCalendar)

      cell?(:ListResourceBundle) should be true
      cell?(:SimpleTimeZone) should be true
      cell?(:GregorianCalendar) should be true
    )
  )

  describe("use of jar-files",
    it("should have tests")
  )
)

describe("Java Objects",
  describe("==",
    it("should call java.lang.Object#equals",
      x = ioke:lang:test:EqualsTest new
      y = ioke:lang:test:EqualsTest new
      
      x should == y

      x theProperty = "oh noes"

      x should not == y
      
      y theProperty = "oh noes"

      x should == y
    )
  )

  describe("same?",
    it("should use Java ==",
      x = java:lang:Object new
      y = java:lang:Object new
      x same?(y) should be false
      x same?(x) should be true
      z = x
      x same?(z) should be true
    )
  )

  describe("inner classes",
    it("should be possible to create a new instance of one",
      obj = ioke:lang:test:TestInner$TheInner new
      obj foo asText should == "an inner class"
    )

    it("should be possible to import one",
      import ioke:lang:test:TestInner$TheInner
      TestInner$TheInner new should not be nil
    )
  )

  describe("static fields",
    describe("public",
      describe("final",
        it("should handle a simple String field",
          i = ioke:lang:test:StaticFields
          i field:publicStringFieldFinal asText should == "test1StringFinal"
        )

        it("should not have a setter for the String field",
          i = ioke:lang:test:StaticFields
          i cell?("field:publicStringField=") should be true
          i cell?("field:publicStringFieldFinal=") should be false
        )

        it("should not have a setter for the Object field",
          i = ioke:lang:test:StaticFields
          i cell?("field:publicObjectField=") should be true
          i cell?("field:publicObjectFieldFinal=") should be false
        )

        it("should handle a simple int field",
          i = ioke:lang:test:StaticFields
          i field:publicIntFieldFinal asRational should == 42
        )

        it("should not have a setter for the int field",
          i = ioke:lang:test:StaticFields
          i cell?("field:publicIntField=") should be true
          i cell?("field:publicIntFieldFinal=") should be false
        )

        it("should handle a simple short field",
          i = ioke:lang:test:StaticFields
          i field:publicShortFieldFinal asRational should == 13
        )

        it("should not have a setter for the short field",
          i = ioke:lang:test:StaticFields
          i cell?("field:publicShortField=") should be true
          i cell?("field:publicShortFieldFinal=") should be false
        )

        it("should handle a simple long field",
          i = ioke:lang:test:StaticFields
          i field:publicLongFieldFinal asRational should == 13243435
        )

        it("should not have a setter for the long field",
          i = ioke:lang:test:StaticFields
          i cell?("field:publicLongField=") should be true
          i cell?("field:publicLongFieldFinal=") should be false
        )

        it("should handle a simple char field",
          i = ioke:lang:test:StaticFields
          i field:publicCharFieldFinal asRational should == 44
        )

        it("should not have a setter for the char field",
          i = ioke:lang:test:StaticFields
          i cell?("field:publicCharField=") should be true
          i cell?("field:publicCharFieldFinal=") should be false
        )

        it("should handle a simple float field",
          i = ioke:lang:test:StaticFields
          i field:publicFloatFieldFinal asDecimal should be close(434.2)
        )

        it("should not have a setter for the float field",
          i = ioke:lang:test:StaticFields
          i cell?("field:publicFloatField=") should be true
          i cell?("field:publicFloatFieldFinal=") should be false
        )

        it("should handle a simple double field",
          i = ioke:lang:test:StaticFields
          i field:publicDoubleFieldFinal asDecimal should be close(3432435.22)
        )

        it("should not have a setter for the double field",
          i = ioke:lang:test:StaticFields
          i cell?("field:publicDoubleField=") should be true
          i cell?("field:publicDoubleFieldFinal=") should be false
        )

        it("should handle a simple boolean field",
          i = ioke:lang:test:StaticFields
          i field:publicBooleanFieldFinal should be true
        )

        it("should not have a setter for the boolean field",
          i = ioke:lang:test:StaticFields
          i cell?("field:publicBooleanField=") should be true
          i cell?("field:publicBooleanFieldFinal=") should be false
        )
      )

      it("should handle a simple String field",
        i = ioke:lang:test:StaticFields
        i field:publicStringField should be nil
        i field:publicStringField = "blargus"
        i get_publicStringField asText should == "blargus"
      )

      it("should handle a simple Object field",
        i = ioke:lang:test:StaticFields
        i field:publicObjectField should be nil
        i field:publicObjectField = (1..5)
        i get_publicObjectField should == (1..5)
      )

      it("should handle a simple int field",
        i = ioke:lang:test:StaticFields
        i field:publicIntField asRational should == 0
        i field:publicIntField = 42
        i get_publicIntField asRational should == 42
      )

      it("should handle a simple short field",
        i = ioke:lang:test:StaticFields
        i field:publicShortField asRational should == 0
        i field:publicShortField = 12
        i get_publicShortField asRational should == 12
      )

      it("should handle a simple long field",
        i = ioke:lang:test:StaticFields
        i field:publicLongField asRational should == 0
        i field:publicLongField = 127
        i get_publicLongField asRational should == 127
      )

      it("should handle a simple char field",
        i = ioke:lang:test:StaticFields
        i field:publicCharField asRational should == 0
        i field:publicCharField = 10
        i get_publicCharField asRational should == 10
      )

      it("should handle a simple float field",
        i = ioke:lang:test:StaticFields
        i field:publicFloatField asDecimal should == 0.0
        i field:publicFloatField = 10.3
        i get_publicFloatField asDecimal should be close(10.3)
      )

      it("should handle a simple double field",
        i = ioke:lang:test:StaticFields
        i field:publicDoubleField asDecimal should == 0.0
        i field:publicDoubleField = 5335.234
        i get_publicDoubleField asDecimal should be close(5335.234)
      )

      it("should handle a simple boolean field",
        i = ioke:lang:test:StaticFields
        i field:publicBooleanField should be false
        i field:publicBooleanField = true
        i get_publicBooleanField should be true
      )
    )

    describe("protected",
      describe("final",
        it("should handle a simple String field",
          i = ioke:lang:test:StaticFields
          i field:protectedStringFieldFinal asText should == "test1StringFinal"
        )

        it("should not have a setter for the String field",
          i = ioke:lang:test:StaticFields
          i cell?("field:protectedStringField=") should be true
          i cell?("field:protectedStringFieldFinal=") should be false
        )

        it("should not have a setter for the Object field",
          i = ioke:lang:test:StaticFields
          i cell?("field:protectedObjectField=") should be true
          i cell?("field:protectedObjectFieldFinal=") should be false
        )

        it("should handle a simple int field",
          i = ioke:lang:test:StaticFields
          i field:protectedIntFieldFinal asRational should == 42
        )

        it("should not have a setter for the int field",
          i = ioke:lang:test:StaticFields
          i cell?("field:protectedIntField=") should be true
          i cell?("field:protectedIntFieldFinal=") should be false
        )

        it("should handle a simple short field",
          i = ioke:lang:test:StaticFields
          i field:protectedShortFieldFinal asRational should == 13
        )

        it("should not have a setter for the short field",
          i = ioke:lang:test:StaticFields
          i cell?("field:protectedShortField=") should be true
          i cell?("field:protectedShortFieldFinal=") should be false
        )

        it("should handle a simple long field",
          i = ioke:lang:test:StaticFields
          i field:protectedLongFieldFinal asRational should == 13243435
        )

        it("should not have a setter for the long field",
          i = ioke:lang:test:StaticFields
          i cell?("field:protectedLongField=") should be true
          i cell?("field:protectedLongFieldFinal=") should be false
        )

        it("should handle a simple char field",
          i = ioke:lang:test:StaticFields
          i field:protectedCharFieldFinal asRational should == 44
        )

        it("should not have a setter for the char field",
          i = ioke:lang:test:StaticFields
          i cell?("field:protectedCharField=") should be true
          i cell?("field:protectedCharFieldFinal=") should be false
        )

        it("should handle a simple float field",
          i = ioke:lang:test:StaticFields
          i field:protectedFloatFieldFinal asDecimal should be close(434.2)
        )

        it("should not have a setter for the float field",
          i = ioke:lang:test:StaticFields
          i cell?("field:protectedFloatField=") should be true
          i cell?("field:protectedFloatFieldFinal=") should be false
        )

        it("should handle a simple double field",
          i = ioke:lang:test:StaticFields
          i field:protectedDoubleFieldFinal asDecimal should be close(3432435.22)
        )

        it("should not have a setter for the double field",
          i = ioke:lang:test:StaticFields
          i cell?("field:protectedDoubleField=") should be true
          i cell?("field:protectedDoubleFieldFinal=") should be false
        )

        it("should handle a simple boolean field",
          i = ioke:lang:test:StaticFields
          i field:protectedBooleanFieldFinal should be true
        )

        it("should not have a setter for the boolean field",
          i = ioke:lang:test:StaticFields
          i cell?("field:protectedBooleanField=") should be true
          i cell?("field:protectedBooleanFieldFinal=") should be false
        )
      )

      it("should handle a simple String field",
        i = ioke:lang:test:StaticFields
        i field:protectedStringField should be nil
        i field:protectedStringField = "blargus"
        i get_protectedStringField asText should == "blargus"
      )

      it("should handle a simple Object field",
        i = ioke:lang:test:StaticFields
        i field:protectedObjectField should be nil
        i field:protectedObjectField = (1..5)
        i get_protectedObjectField should == (1..5)
      )

      it("should handle a simple int field",
        i = ioke:lang:test:StaticFields
        i field:protectedIntField asRational should == 0
        i field:protectedIntField = 42
        i get_protectedIntField asRational should == 42
      )

      it("should handle a simple short field",
        i = ioke:lang:test:StaticFields
        i field:protectedShortField asRational should == 0
        i field:protectedShortField = 12
        i get_protectedShortField asRational should == 12
      )

      it("should handle a simple long field",
        i = ioke:lang:test:StaticFields
        i field:protectedLongField asRational should == 0
        i field:protectedLongField = 127
        i get_protectedLongField asRational should == 127
      )

      it("should handle a simple char field",
        i = ioke:lang:test:StaticFields
        i field:protectedCharField asRational should == 0
        i field:protectedCharField = 10
        i get_protectedCharField asRational should == 10
      )

      it("should handle a simple float field",
        i = ioke:lang:test:StaticFields
        i field:protectedFloatField asDecimal should == 0.0
        i field:protectedFloatField = 10.3
        i get_protectedFloatField asDecimal should be close(10.3)
      )

      it("should handle a simple double field",
        i = ioke:lang:test:StaticFields
        i field:protectedDoubleField asDecimal should == 0.0
        i field:protectedDoubleField = 5335.234
        i get_protectedDoubleField asDecimal should be close(5335.234)
      )

      it("should handle a simple boolean field",
        i = ioke:lang:test:StaticFields
        i field:protectedBooleanField should be false
        i field:protectedBooleanField = true
        i get_protectedBooleanField should be true
      )
    )

    describe("packagePrivate",
      describe("final",
        it("should handle a simple String field",
          i = ioke:lang:test:StaticFields
          i field:packagePrivateStringFieldFinal asText should == "test1StringFinal"
        )

        it("should not have a setter for the String field",
          i = ioke:lang:test:StaticFields
          i cell?("field:packagePrivateStringField=") should be true
          i cell?("field:packagePrivateStringFieldFinal=") should be false
        )

        it("should not have a setter for the Object field",
          i = ioke:lang:test:StaticFields
          i cell?("field:packagePrivateObjectField=") should be true
          i cell?("field:packagePrivateObjectFieldFinal=") should be false
        )

        it("should handle a simple int field",
          i = ioke:lang:test:StaticFields
          i field:packagePrivateIntFieldFinal asRational should == 42
        )

        it("should not have a setter for the int field",
          i = ioke:lang:test:StaticFields
          i cell?("field:packagePrivateIntField=") should be true
          i cell?("field:packagePrivateIntFieldFinal=") should be false
        )

        it("should handle a simple short field",
          i = ioke:lang:test:StaticFields
          i field:packagePrivateShortFieldFinal asRational should == 13
        )

        it("should not have a setter for the short field",
          i = ioke:lang:test:StaticFields
          i cell?("field:packagePrivateShortField=") should be true
          i cell?("field:packagePrivateShortFieldFinal=") should be false
        )

        it("should handle a simple long field",
          i = ioke:lang:test:StaticFields
          i field:packagePrivateLongFieldFinal asRational should == 13243435
        )

        it("should not have a setter for the long field",
          i = ioke:lang:test:StaticFields
          i cell?("field:packagePrivateLongField=") should be true
          i cell?("field:packagePrivateLongFieldFinal=") should be false
        )

        it("should handle a simple char field",
          i = ioke:lang:test:StaticFields
          i field:packagePrivateCharFieldFinal asRational should == 44
        )

        it("should not have a setter for the char field",
          i = ioke:lang:test:StaticFields
          i cell?("field:packagePrivateCharField=") should be true
          i cell?("field:packagePrivateCharFieldFinal=") should be false
        )

        it("should handle a simple float field",
          i = ioke:lang:test:StaticFields
          i field:packagePrivateFloatFieldFinal asDecimal should be close(434.2)
        )

        it("should not have a setter for the float field",
          i = ioke:lang:test:StaticFields
          i cell?("field:packagePrivateFloatField=") should be true
          i cell?("field:packagePrivateFloatFieldFinal=") should be false
        )

        it("should handle a simple double field",
          i = ioke:lang:test:StaticFields
          i field:packagePrivateDoubleFieldFinal asDecimal should be close(3432435.22)
        )

        it("should not have a setter for the double field",
          i = ioke:lang:test:StaticFields
          i cell?("field:packagePrivateDoubleField=") should be true
          i cell?("field:packagePrivateDoubleFieldFinal=") should be false
        )

        it("should handle a simple boolean field",
          i = ioke:lang:test:StaticFields
          i field:packagePrivateBooleanFieldFinal should be true
        )

        it("should not have a setter for the boolean field",
          i = ioke:lang:test:StaticFields
          i cell?("field:packagePrivateBooleanField=") should be true
          i cell?("field:packagePrivateBooleanFieldFinal=") should be false
        )
      )

      it("should handle a simple String field",
        i = ioke:lang:test:StaticFields
        i field:packagePrivateStringField should be nil
        i field:packagePrivateStringField = "blargus"
        i get_packagePrivateStringField asText should == "blargus"
      )

      it("should handle a simple Object field",
        i = ioke:lang:test:StaticFields
        i field:packagePrivateObjectField should be nil
        i field:packagePrivateObjectField = (1..5)
        i get_packagePrivateObjectField should == (1..5)
      )

      it("should handle a simple int field",
        i = ioke:lang:test:StaticFields
        i field:packagePrivateIntField asRational should == 0
        i field:packagePrivateIntField = 42
        i get_packagePrivateIntField asRational should == 42
      )

      it("should handle a simple short field",
        i = ioke:lang:test:StaticFields
        i field:packagePrivateShortField asRational should == 0
        i field:packagePrivateShortField = 12
        i get_packagePrivateShortField asRational should == 12
      )

      it("should handle a simple long field",
        i = ioke:lang:test:StaticFields
        i field:packagePrivateLongField asRational should == 0
        i field:packagePrivateLongField = 127
        i get_packagePrivateLongField asRational should == 127
      )

      it("should handle a simple char field",
        i = ioke:lang:test:StaticFields
        i field:packagePrivateCharField asRational should == 0
        i field:packagePrivateCharField = 10
        i get_packagePrivateCharField asRational should == 10
      )

      it("should handle a simple float field",
        i = ioke:lang:test:StaticFields
        i field:packagePrivateFloatField asDecimal should == 0.0
        i field:packagePrivateFloatField = 10.3
        i get_packagePrivateFloatField asDecimal should be close(10.3)
      )

      it("should handle a simple double field",
        i = ioke:lang:test:StaticFields
        i field:packagePrivateDoubleField asDecimal should == 0.0
        i field:packagePrivateDoubleField = 5335.234
        i get_packagePrivateDoubleField asDecimal should be close(5335.234)
      )

      it("should handle a simple boolean field",
        i = ioke:lang:test:StaticFields
        i field:packagePrivateBooleanField should be false
        i field:packagePrivateBooleanField = true
        i get_packagePrivateBooleanField should be true
      )
    )


    describe("private",
      describe("final",
        it("should handle a simple String field",
          i = ioke:lang:test:StaticFields
          i field:privateStringFieldFinal asText should == "test1StringFinal"
        )

        it("should not have a setter for the String field",
          i = ioke:lang:test:StaticFields
          i cell?("field:privateStringField=") should be true
          i cell?("field:privateStringFieldFinal=") should be false
        )

        it("should not have a setter for the Object field",
          i = ioke:lang:test:StaticFields
          i cell?("field:privateObjectField=") should be true
          i cell?("field:privateObjectFieldFinal=") should be false
        )

        it("should handle a simple int field",
          i = ioke:lang:test:StaticFields
          i field:privateIntFieldFinal asRational should == 42
        )

        it("should not have a setter for the int field",
          i = ioke:lang:test:StaticFields
          i cell?("field:privateIntField=") should be true
          i cell?("field:privateIntFieldFinal=") should be false
        )

        it("should handle a simple short field",
          i = ioke:lang:test:StaticFields
          i field:privateShortFieldFinal asRational should == 13
        )

        it("should not have a setter for the short field",
          i = ioke:lang:test:StaticFields
          i cell?("field:privateShortField=") should be true
          i cell?("field:privateShortFieldFinal=") should be false
        )

        it("should handle a simple long field",
          i = ioke:lang:test:StaticFields
          i field:privateLongFieldFinal asRational should == 13243435
        )

        it("should not have a setter for the long field",
          i = ioke:lang:test:StaticFields
          i cell?("field:privateLongField=") should be true
          i cell?("field:privateLongFieldFinal=") should be false
        )

        it("should handle a simple char field",
          i = ioke:lang:test:StaticFields
          i field:privateCharFieldFinal asRational should == 44
        )

        it("should not have a setter for the char field",
          i = ioke:lang:test:StaticFields
          i cell?("field:privateCharField=") should be true
          i cell?("field:privateCharFieldFinal=") should be false
        )

        it("should handle a simple float field",
          i = ioke:lang:test:StaticFields
          i field:privateFloatFieldFinal asDecimal should be close(434.2)
        )

        it("should not have a setter for the float field",
          i = ioke:lang:test:StaticFields
          i cell?("field:privateFloatField=") should be true
          i cell?("field:privateFloatFieldFinal=") should be false
        )

        it("should handle a simple double field",
          i = ioke:lang:test:StaticFields
          i field:privateDoubleFieldFinal asDecimal should be close(3432435.22)
        )

        it("should not have a setter for the double field",
          i = ioke:lang:test:StaticFields
          i cell?("field:privateDoubleField=") should be true
          i cell?("field:privateDoubleFieldFinal=") should be false
        )

        it("should handle a simple boolean field",
          i = ioke:lang:test:StaticFields
          i field:privateBooleanFieldFinal should be true
        )

        it("should not have a setter for the boolean field",
          i = ioke:lang:test:StaticFields
          i cell?("field:privateBooleanField=") should be true
          i cell?("field:privateBooleanFieldFinal=") should be false
        )
      )

      it("should handle a simple String field",
        i = ioke:lang:test:StaticFields
        i field:privateStringField should be nil
        i field:privateStringField = "blargus"
        i get_privateStringField asText should == "blargus"
      )

      it("should handle a simple Object field",
        i = ioke:lang:test:StaticFields
        i field:privateObjectField should be nil
        i field:privateObjectField = (1..5)
        i get_privateObjectField should == (1..5)
      )

      it("should handle a simple int field",
        i = ioke:lang:test:StaticFields
        i field:privateIntField asRational should == 0
        i field:privateIntField = 42
        i get_privateIntField asRational should == 42
      )

      it("should handle a simple short field",
        i = ioke:lang:test:StaticFields
        i field:privateShortField asRational should == 0
        i field:privateShortField = 12
        i get_privateShortField asRational should == 12
      )

      it("should handle a simple long field",
        i = ioke:lang:test:StaticFields
        i field:privateLongField asRational should == 0
        i field:privateLongField = 127
        i get_privateLongField asRational should == 127
      )

      it("should handle a simple char field",
        i = ioke:lang:test:StaticFields
        i field:privateCharField asRational should == 0
        i field:privateCharField = 10
        i get_privateCharField asRational should == 10
      )

      it("should handle a simple float field",
        i = ioke:lang:test:StaticFields
        i field:privateFloatField asDecimal should == 0.0
        i field:privateFloatField = 10.3
        i get_privateFloatField asDecimal should be close(10.3)
      )

      it("should handle a simple double field",
        i = ioke:lang:test:StaticFields
        i field:privateDoubleField asDecimal should == 0.0
        i field:privateDoubleField = 5335.234
        i get_privateDoubleField asDecimal should be close(5335.234)
      )

      it("should handle a simple boolean field",
        i = ioke:lang:test:StaticFields
        i field:privateBooleanField should be false
        i field:privateBooleanField = true
        i get_privateBooleanField should be true
      )
    )
  )

  describe("fields",
    describe("public",
      describe("final",
        it("should handle a simple String field",
          i = ioke:lang:test:InstanceFields new
          i field:publicStringFieldFinal asText should == "test1StringFinal"
        )

        it("should not have a setter for the String field",
          i = ioke:lang:test:InstanceFields new
          i cell?("field:publicStringField=") should be true
          i cell?("field:publicStringFieldFinal=") should be false
        )

        it("should not have a setter for the Object field",
          i = ioke:lang:test:InstanceFields new
          i cell?("field:publicObjectField=") should be true
          i cell?("field:publicObjectFieldFinal=") should be false
        )

        it("should handle a simple int field",
          i = ioke:lang:test:InstanceFields new
          i field:publicIntFieldFinal asRational should == 42
        )

        it("should not have a setter for the int field",
          i = ioke:lang:test:InstanceFields new
          i cell?("field:publicIntField=") should be true
          i cell?("field:publicIntFieldFinal=") should be false
        )

        it("should handle a simple short field",
          i = ioke:lang:test:InstanceFields new
          i field:publicShortFieldFinal asRational should == 13
        )

        it("should not have a setter for the short field",
          i = ioke:lang:test:InstanceFields new
          i cell?("field:publicShortField=") should be true
          i cell?("field:publicShortFieldFinal=") should be false
        )

        it("should handle a simple long field",
          i = ioke:lang:test:InstanceFields new
          i field:publicLongFieldFinal asRational should == 13243435
        )

        it("should not have a setter for the long field",
          i = ioke:lang:test:InstanceFields new
          i cell?("field:publicLongField=") should be true
          i cell?("field:publicLongFieldFinal=") should be false
        )

        it("should handle a simple char field",
          i = ioke:lang:test:InstanceFields new
          i field:publicCharFieldFinal asRational should == 44
        )

        it("should not have a setter for the char field",
          i = ioke:lang:test:InstanceFields new
          i cell?("field:publicCharField=") should be true
          i cell?("field:publicCharFieldFinal=") should be false
        )

        it("should handle a simple float field",
          i = ioke:lang:test:InstanceFields new
          i field:publicFloatFieldFinal asDecimal should be close(434.2)
        )

        it("should not have a setter for the float field",
          i = ioke:lang:test:InstanceFields new
          i cell?("field:publicFloatField=") should be true
          i cell?("field:publicFloatFieldFinal=") should be false
        )

        it("should handle a simple double field",
          i = ioke:lang:test:InstanceFields new
          i field:publicDoubleFieldFinal asDecimal should be close(3432435.22)
        )

        it("should not have a setter for the double field",
          i = ioke:lang:test:InstanceFields new
          i cell?("field:publicDoubleField=") should be true
          i cell?("field:publicDoubleFieldFinal=") should be false
        )

        it("should handle a simple boolean field",
          i = ioke:lang:test:InstanceFields new
          i field:publicBooleanFieldFinal should be true
        )

        it("should not have a setter for the boolean field",
          i = ioke:lang:test:InstanceFields new
          i cell?("field:publicBooleanField=") should be true
          i cell?("field:publicBooleanFieldFinal=") should be false
        )
      )

      it("should handle a simple String field",
        i = ioke:lang:test:InstanceFields new
        i field:publicStringField should be nil
        i field:publicStringField = "blargus"
        i get_publicStringField asText should == "blargus"
      )

      it("should handle a simple Object field",
        i = ioke:lang:test:InstanceFields new
        i field:publicObjectField should be nil
        i field:publicObjectField = (1..5)
        i get_publicObjectField should == (1..5)
      )

      it("should handle a simple int field",
        i = ioke:lang:test:InstanceFields new
        i field:publicIntField asRational should == 0
        i field:publicIntField = 42
        i get_publicIntField asRational should == 42
      )

      it("should handle a simple short field",
        i = ioke:lang:test:InstanceFields new
        i field:publicShortField asRational should == 0
        i field:publicShortField = 12
        i get_publicShortField asRational should == 12
      )

      it("should handle a simple long field",
        i = ioke:lang:test:InstanceFields new
        i field:publicLongField asRational should == 0
        i field:publicLongField = 127
        i get_publicLongField asRational should == 127
      )

      it("should handle a simple char field",
        i = ioke:lang:test:InstanceFields new
        i field:publicCharField asRational should == 0
        i field:publicCharField = 10
        i get_publicCharField asRational should == 10
      )

      it("should handle a simple float field",
        i = ioke:lang:test:InstanceFields new
        i field:publicFloatField asDecimal should == 0.0
        i field:publicFloatField = 10.3
        i get_publicFloatField asDecimal should be close(10.3)
      )

      it("should handle a simple double field",
        i = ioke:lang:test:InstanceFields new
        i field:publicDoubleField asDecimal should == 0.0
        i field:publicDoubleField = 5335.234
        i get_publicDoubleField asDecimal should be close(5335.234)
      )

      it("should handle a simple boolean field",
        i = ioke:lang:test:InstanceFields new
        i field:publicBooleanField should be false
        i field:publicBooleanField = true
        i get_publicBooleanField should be true
      )
    )

    describe("protected",
      describe("final",
        it("should handle a simple String field",
          i = ioke:lang:test:InstanceFields new
          i field:protectedStringFieldFinal asText should == "test1StringFinal"
        )

        it("should not have a setter for the String field",
          i = ioke:lang:test:InstanceFields new
          i cell?("field:protectedStringField=") should be true
          i cell?("field:protectedStringFieldFinal=") should be false
        )

        it("should not have a setter for the Object field",
          i = ioke:lang:test:InstanceFields new
          i cell?("field:protectedObjectField=") should be true
          i cell?("field:protectedObjectFieldFinal=") should be false
        )

        it("should handle a simple int field",
          i = ioke:lang:test:InstanceFields new
          i field:protectedIntFieldFinal asRational should == 42
        )

        it("should not have a setter for the int field",
          i = ioke:lang:test:InstanceFields new
          i cell?("field:protectedIntField=") should be true
          i cell?("field:protectedIntFieldFinal=") should be false
        )

        it("should handle a simple short field",
          i = ioke:lang:test:InstanceFields new
          i field:protectedShortFieldFinal asRational should == 13
        )

        it("should not have a setter for the short field",
          i = ioke:lang:test:InstanceFields new
          i cell?("field:protectedShortField=") should be true
          i cell?("field:protectedShortFieldFinal=") should be false
        )

        it("should handle a simple long field",
          i = ioke:lang:test:InstanceFields new
          i field:protectedLongFieldFinal asRational should == 13243435
        )

        it("should not have a setter for the long field",
          i = ioke:lang:test:InstanceFields new
          i cell?("field:protectedLongField=") should be true
          i cell?("field:protectedLongFieldFinal=") should be false
        )

        it("should handle a simple char field",
          i = ioke:lang:test:InstanceFields new
          i field:protectedCharFieldFinal asRational should == 44
        )

        it("should not have a setter for the char field",
          i = ioke:lang:test:InstanceFields new
          i cell?("field:protectedCharField=") should be true
          i cell?("field:protectedCharFieldFinal=") should be false
        )

        it("should handle a simple float field",
          i = ioke:lang:test:InstanceFields new
          i field:protectedFloatFieldFinal asDecimal should be close(434.2)
        )

        it("should not have a setter for the float field",
          i = ioke:lang:test:InstanceFields new
          i cell?("field:protectedFloatField=") should be true
          i cell?("field:protectedFloatFieldFinal=") should be false
        )

        it("should handle a simple double field",
          i = ioke:lang:test:InstanceFields new
          i field:protectedDoubleFieldFinal asDecimal should be close(3432435.22)
        )

        it("should not have a setter for the double field",
          i = ioke:lang:test:InstanceFields new
          i cell?("field:protectedDoubleField=") should be true
          i cell?("field:protectedDoubleFieldFinal=") should be false
        )

        it("should handle a simple boolean field",
          i = ioke:lang:test:InstanceFields new
          i field:protectedBooleanFieldFinal should be true
        )

        it("should not have a setter for the boolean field",
          i = ioke:lang:test:InstanceFields new
          i cell?("field:protectedBooleanField=") should be true
          i cell?("field:protectedBooleanFieldFinal=") should be false
        )
      )

      it("should handle a simple String field",
        i = ioke:lang:test:InstanceFields new
        i field:protectedStringField should be nil
        i field:protectedStringField = "blargus"
        i get_protectedStringField asText should == "blargus"
      )

      it("should handle a simple Object field",
        i = ioke:lang:test:InstanceFields new
        i field:protectedObjectField should be nil
        i field:protectedObjectField = (1..5)
        i get_protectedObjectField should == (1..5)
      )

      it("should handle a simple int field",
        i = ioke:lang:test:InstanceFields new
        i field:protectedIntField asRational should == 0
        i field:protectedIntField = 42
        i get_protectedIntField asRational should == 42
      )

      it("should handle a simple short field",
        i = ioke:lang:test:InstanceFields new
        i field:protectedShortField asRational should == 0
        i field:protectedShortField = 12
        i get_protectedShortField asRational should == 12
      )

      it("should handle a simple long field",
        i = ioke:lang:test:InstanceFields new
        i field:protectedLongField asRational should == 0
        i field:protectedLongField = 127
        i get_protectedLongField asRational should == 127
      )

      it("should handle a simple char field",
        i = ioke:lang:test:InstanceFields new
        i field:protectedCharField asRational should == 0
        i field:protectedCharField = 10
        i get_protectedCharField asRational should == 10
      )

      it("should handle a simple float field",
        i = ioke:lang:test:InstanceFields new
        i field:protectedFloatField asDecimal should == 0.0
        i field:protectedFloatField = 10.3
        i get_protectedFloatField asDecimal should be close(10.3)
      )

      it("should handle a simple double field",
        i = ioke:lang:test:InstanceFields new
        i field:protectedDoubleField asDecimal should == 0.0
        i field:protectedDoubleField = 5335.234
        i get_protectedDoubleField asDecimal should be close(5335.234)
      )

      it("should handle a simple boolean field",
        i = ioke:lang:test:InstanceFields new
        i field:protectedBooleanField should be false
        i field:protectedBooleanField = true
        i get_protectedBooleanField should be true
      )
    )

    describe("packagePrivate",
      describe("final",
        it("should handle a simple String field",
          i = ioke:lang:test:InstanceFields new
          i field:packagePrivateStringFieldFinal asText should == "test1StringFinal"
        )

        it("should not have a setter for the String field",
          i = ioke:lang:test:InstanceFields new
          i cell?("field:packagePrivateStringField=") should be true
          i cell?("field:packagePrivateStringFieldFinal=") should be false
        )

        it("should not have a setter for the Object field",
          i = ioke:lang:test:InstanceFields new
          i cell?("field:packagePrivateObjectField=") should be true
          i cell?("field:packagePrivateObjectFieldFinal=") should be false
        )

        it("should handle a simple int field",
          i = ioke:lang:test:InstanceFields new
          i field:packagePrivateIntFieldFinal asRational should == 42
        )

        it("should not have a setter for the int field",
          i = ioke:lang:test:InstanceFields new
          i cell?("field:packagePrivateIntField=") should be true
          i cell?("field:packagePrivateIntFieldFinal=") should be false
        )

        it("should handle a simple short field",
          i = ioke:lang:test:InstanceFields new
          i field:packagePrivateShortFieldFinal asRational should == 13
        )

        it("should not have a setter for the short field",
          i = ioke:lang:test:InstanceFields new
          i cell?("field:packagePrivateShortField=") should be true
          i cell?("field:packagePrivateShortFieldFinal=") should be false
        )

        it("should handle a simple long field",
          i = ioke:lang:test:InstanceFields new
          i field:packagePrivateLongFieldFinal asRational should == 13243435
        )

        it("should not have a setter for the long field",
          i = ioke:lang:test:InstanceFields new
          i cell?("field:packagePrivateLongField=") should be true
          i cell?("field:packagePrivateLongFieldFinal=") should be false
        )

        it("should handle a simple char field",
          i = ioke:lang:test:InstanceFields new
          i field:packagePrivateCharFieldFinal asRational should == 44
        )

        it("should not have a setter for the char field",
          i = ioke:lang:test:InstanceFields new
          i cell?("field:packagePrivateCharField=") should be true
          i cell?("field:packagePrivateCharFieldFinal=") should be false
        )

        it("should handle a simple float field",
          i = ioke:lang:test:InstanceFields new
          i field:packagePrivateFloatFieldFinal asDecimal should be close(434.2)
        )

        it("should not have a setter for the float field",
          i = ioke:lang:test:InstanceFields new
          i cell?("field:packagePrivateFloatField=") should be true
          i cell?("field:packagePrivateFloatFieldFinal=") should be false
        )

        it("should handle a simple double field",
          i = ioke:lang:test:InstanceFields new
          i field:packagePrivateDoubleFieldFinal asDecimal should be close(3432435.22)
        )

        it("should not have a setter for the double field",
          i = ioke:lang:test:InstanceFields new
          i cell?("field:packagePrivateDoubleField=") should be true
          i cell?("field:packagePrivateDoubleFieldFinal=") should be false
        )

        it("should handle a simple boolean field",
          i = ioke:lang:test:InstanceFields new
          i field:packagePrivateBooleanFieldFinal should be true
        )

        it("should not have a setter for the boolean field",
          i = ioke:lang:test:InstanceFields new
          i cell?("field:packagePrivateBooleanField=") should be true
          i cell?("field:packagePrivateBooleanFieldFinal=") should be false
        )
      )

      it("should handle a simple String field",
        i = ioke:lang:test:InstanceFields new
        i field:packagePrivateStringField should be nil
        i field:packagePrivateStringField = "blargus"
        i get_packagePrivateStringField asText should == "blargus"
      )

      it("should handle a simple Object field",
        i = ioke:lang:test:InstanceFields new
        i field:packagePrivateObjectField should be nil
        i field:packagePrivateObjectField = (1..5)
        i get_packagePrivateObjectField should == (1..5)
      )

      it("should handle a simple int field",
        i = ioke:lang:test:InstanceFields new
        i field:packagePrivateIntField asRational should == 0
        i field:packagePrivateIntField = 42
        i get_packagePrivateIntField asRational should == 42
      )

      it("should handle a simple short field",
        i = ioke:lang:test:InstanceFields new
        i field:packagePrivateShortField asRational should == 0
        i field:packagePrivateShortField = 12
        i get_packagePrivateShortField asRational should == 12
      )

      it("should handle a simple long field",
        i = ioke:lang:test:InstanceFields new
        i field:packagePrivateLongField asRational should == 0
        i field:packagePrivateLongField = 127
        i get_packagePrivateLongField asRational should == 127
      )

      it("should handle a simple char field",
        i = ioke:lang:test:InstanceFields new
        i field:packagePrivateCharField asRational should == 0
        i field:packagePrivateCharField = 10
        i get_packagePrivateCharField asRational should == 10
      )

      it("should handle a simple float field",
        i = ioke:lang:test:InstanceFields new
        i field:packagePrivateFloatField asDecimal should == 0.0
        i field:packagePrivateFloatField = 10.3
        i get_packagePrivateFloatField asDecimal should be close(10.3)
      )

      it("should handle a simple double field",
        i = ioke:lang:test:InstanceFields new
        i field:packagePrivateDoubleField asDecimal should == 0.0
        i field:packagePrivateDoubleField = 5335.234
        i get_packagePrivateDoubleField asDecimal should be close(5335.234)
      )

      it("should handle a simple boolean field",
        i = ioke:lang:test:InstanceFields new
        i field:packagePrivateBooleanField should be false
        i field:packagePrivateBooleanField = true
        i get_packagePrivateBooleanField should be true
      )
    )


    describe("private",
      describe("final",
        it("should handle a simple String field",
          i = ioke:lang:test:InstanceFields new
          i field:privateStringFieldFinal asText should == "test1StringFinal"
        )

        it("should not have a setter for the String field",
          i = ioke:lang:test:InstanceFields new
          i cell?("field:privateStringField=") should be true
          i cell?("field:privateStringFieldFinal=") should be false
        )

        it("should not have a setter for the Object field",
          i = ioke:lang:test:InstanceFields new
          i cell?("field:privateObjectField=") should be true
          i cell?("field:privateObjectFieldFinal=") should be false
        )

        it("should handle a simple int field",
          i = ioke:lang:test:InstanceFields new
          i field:privateIntFieldFinal asRational should == 42
        )

        it("should not have a setter for the int field",
          i = ioke:lang:test:InstanceFields new
          i cell?("field:privateIntField=") should be true
          i cell?("field:privateIntFieldFinal=") should be false
        )

        it("should handle a simple short field",
          i = ioke:lang:test:InstanceFields new
          i field:privateShortFieldFinal asRational should == 13
        )

        it("should not have a setter for the short field",
          i = ioke:lang:test:InstanceFields new
          i cell?("field:privateShortField=") should be true
          i cell?("field:privateShortFieldFinal=") should be false
        )

        it("should handle a simple long field",
          i = ioke:lang:test:InstanceFields new
          i field:privateLongFieldFinal asRational should == 13243435
        )

        it("should not have a setter for the long field",
          i = ioke:lang:test:InstanceFields new
          i cell?("field:privateLongField=") should be true
          i cell?("field:privateLongFieldFinal=") should be false
        )

        it("should handle a simple char field",
          i = ioke:lang:test:InstanceFields new
          i field:privateCharFieldFinal asRational should == 44
        )

        it("should not have a setter for the char field",
          i = ioke:lang:test:InstanceFields new
          i cell?("field:privateCharField=") should be true
          i cell?("field:privateCharFieldFinal=") should be false
        )

        it("should handle a simple float field",
          i = ioke:lang:test:InstanceFields new
          i field:privateFloatFieldFinal asDecimal should be close(434.2)
        )

        it("should not have a setter for the float field",
          i = ioke:lang:test:InstanceFields new
          i cell?("field:privateFloatField=") should be true
          i cell?("field:privateFloatFieldFinal=") should be false
        )

        it("should handle a simple double field",
          i = ioke:lang:test:InstanceFields new
          i field:privateDoubleFieldFinal asDecimal should be close(3432435.22)
        )

        it("should not have a setter for the double field",
          i = ioke:lang:test:InstanceFields new
          i cell?("field:privateDoubleField=") should be true
          i cell?("field:privateDoubleFieldFinal=") should be false
        )

        it("should handle a simple boolean field",
          i = ioke:lang:test:InstanceFields new
          i field:privateBooleanFieldFinal should be true
        )

        it("should not have a setter for the boolean field",
          i = ioke:lang:test:InstanceFields new
          i cell?("field:privateBooleanField=") should be true
          i cell?("field:privateBooleanFieldFinal=") should be false
        )
      )

      it("should handle a simple String field",
        i = ioke:lang:test:InstanceFields new
        i field:privateStringField should be nil
        i field:privateStringField = "blargus"
        i get_privateStringField asText should == "blargus"
      )

      it("should handle a simple Object field",
        i = ioke:lang:test:InstanceFields new
        i field:privateObjectField should be nil
        i field:privateObjectField = (1..5)
        i get_privateObjectField should == (1..5)
      )

      it("should handle a simple int field",
        i = ioke:lang:test:InstanceFields new
        i field:privateIntField asRational should == 0
        i field:privateIntField = 42
        i get_privateIntField asRational should == 42
      )

      it("should handle a simple short field",
        i = ioke:lang:test:InstanceFields new
        i field:privateShortField asRational should == 0
        i field:privateShortField = 12
        i get_privateShortField asRational should == 12
      )

      it("should handle a simple long field",
        i = ioke:lang:test:InstanceFields new
        i field:privateLongField asRational should == 0
        i field:privateLongField = 127
        i get_privateLongField asRational should == 127
      )

      it("should handle a simple char field",
        i = ioke:lang:test:InstanceFields new
        i field:privateCharField asRational should == 0
        i field:privateCharField = 10
        i get_privateCharField asRational should == 10
      )

      it("should handle a simple float field",
        i = ioke:lang:test:InstanceFields new
        i field:privateFloatField asDecimal should == 0.0
        i field:privateFloatField = 10.3
        i get_privateFloatField asDecimal should be close(10.3)
      )

      it("should handle a simple double field",
        i = ioke:lang:test:InstanceFields new
        i field:privateDoubleField asDecimal should == 0.0
        i field:privateDoubleField = 5335.234
        i get_privateDoubleField asDecimal should be close(5335.234)
      )

      it("should handle a simple boolean field",
        i = ioke:lang:test:InstanceFields new
        i field:privateBooleanField should be false
        i field:privateBooleanField = true
        i get_privateBooleanField should be true
      )
    )
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

;     it("should be possible to supply arguments by name")

    it("should add an alias for a name beginning in get, taking no arguments",
      val = ioke:lang:test:StaticJavaBean
      val getFooValue asText should == "foo"
      val fooValue asText should == "foo"
    )

    it("should add an alias for a name beginning with set, taking one argument",
      val = ioke:lang:test:StaticJavaBean
      val setQuuxValue("blax")
      val getQuuxValue asText should == "blax"
      val quuxValue = "blux"
      val getQuuxValue asText should == "blux"
    )

    it("should add an alias for a name beginning with is, taking no arguments",
      val = ioke:lang:test:StaticJavaBean
      val isBarValue() should be true
      val barValue? should be true
      val setBarValue(false)
      val isBarValue() should be false
      val barValue? should be false
    )
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

    it("should disambiguate between methods that take a Class and methods that take instance of that class, when searching for appropriate methods",
      i = java:util:ArrayList new
      i add("foo")
      i add("bar")
      
      ;; this test might look weird. the reason is that ArrayList doesn't implement its own toString.
      ;; that implementation is in a super class. the problem is that the Class#toString method will be found
      ;; first, so this will cause an invocation problem currently. that shouldn't happen.
      ;; instead, a Java lookup like this should actually totally ignore methods implemented for classes when
      ;; the instance in question is not a class. ok, that explanation sucks. someone redo it good?
      i toString asText should == "[foo, bar]"

      java:util:ArrayList class:toString asText should == "class java.util.ArrayList"
      java:util:ArrayList new class:toString asText should == "class java.util.ArrayList"
    )

;     it("should be possible to supply arguments by name")

    it("should add an alias for a name beginning in get, taking no arguments",
      val = ioke:lang:test:JavaBean new("foo", false)
      val getFooValue asText should == "foo"
      val fooValue asText should == "foo"
    )

    it("should add an alias for a name beginning with set, taking one argument",
      val = ioke:lang:test:JavaBean new("foo", false)
      val setFooValue("blax")
      val getFooValue asText should == "blax"
      val fooValue = "blux"
      val getFooValue asText should == "blux"
    )

    it("should add an alias for a name beginning with is, taking no arguments",
      val = ioke:lang:test:JavaBean new("foo", true)
      val isBarValue() should be true
      val barValue? should be true
      val setBarValue(false)
      val isBarValue() should be false
      val barValue? should be false
    )
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

;     it("should be possible to supply arguments by name")
  )

  describe("working with arrays",
    it("should have tests")
  )
)
