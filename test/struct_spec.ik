
use("ispec")

describe("Struct",
  it("should be a lexical block",
    Struct should mimic(LexicalBlock)
  )

  it("should return a new object when called with arguments",
    x = Struct(:foo)
    x should not be(Origin)
    x should not be(LexicalBlock)
    x should not be nil
    x should not be true
    x should not be false
    x should not be(Struct)
  )

  it("should return something that mimics Struct",
    Struct(:foo) should mimic(Struct)
  )

  it("should return something that is a lexical block",
    Struct(:foo) should mimic(LexicalBlock)
  )

  it("should take keyword arguments to give the default values",
    Struct(:foo, bar: 42)
  )

  it("should return something that when called will return a new struct object that mimics the original creator",
    X = Struct(:foo)
    x = X(42)
    x should mimic(X)
    x should mimic(Struct)
  )

  it("should return something that can be called with regular arguments",
    X = Struct(:foo)
    X(42)
  )

  it("should return something that can be called with keyword arguments",
    X = Struct(:foo)
    X(foo: 42)
  )

  it("should create something that has the default values provided when creating the struct",
    X = Struct(:foo, bar: 42)
    X(15) bar should == 42
  )

  it("should create something that has the values given to it by positional arguments",
    X = Struct(:foo, :bar, :quux)
    x = X(42, 55, "blarg")
    x foo should == 42
    x bar should == 55
    x quux should == "blarg"
  )

  it("should create something that has the values given to it by keyword arguments",
    X = Struct(:foo, :bar, :quux)
    x = X(bar: 42, quux: 55, foo: "blarg")
    x bar should == 42
    x quux should == 55
    x foo should == "blarg"
  )

  it("should create something that has the values given to it by a mix of positional and keyword arguments")
  it("should handle activatable values correctly")
  it("should be possible to create a struct with nonstandard cell names")
  it("should be possible to call a struct instance and get a new instance that is similar to this")
  it("should return something that is a sequence")
  it("should return something that is enumerable")

  describe("create",
    it("should return a new instance of the struct")
    it("should take positional arguments")
    it("should take keyword arguments")
  )

  describe("attributeNames",
    it("should have tests")
  )

  describe("attributes",
    it("should have tests")
  )

  describe("valuesAt",
    it("should have tests")
  )

  describe("[]",
    it("should have tests")
  )

  describe("[]=",
    it("should have tests")
  )

  describe("==",
    it("should defer equality to the defined attributes")
  )

  describe("hash",
    it("should defer hashing to the defined attributes")
  )

  describe("asText",
    it("should return a text representation based on the attributes")
  )

  describe("inspect",
    it("should return an inspect representation based on the attributes")
  )

  describe("notice",
    it("should return a notice representation based on the attributes")
  )
)
