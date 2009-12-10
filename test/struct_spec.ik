
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

  it("should create something that has the values given to it by a mix of positional and keyword arguments",
    X = Struct(:foo, :bar, :quux)
    x = X(42, quux: 55, bar: "blarg")
    x foo should == 42
    x quux should == 55
    x bar should == "blarg"
  )

  it("should handle activatable values correctly",
    X = Struct(:foo)
    x = X(method(error!("blah")))
    x cell(:foo) kind should == "DefaultMethod"
    fn(x foo) should signal(Condition Error)
  )

  it("should be possible to create a struct with nonstandard cell names",
    X = Struct(:"blarg fogus")
    x = X(42)
    x cell(:"blarg fogus") should == 42
  )

  it("should be possible to call a struct instance and get a new instance that is similar to this",
    X = Struct(:foo, :bar)
    x = X(42, 55)
    y = x(foo: 66)
    x foo should == 42
    x bar should == 55
    y foo should == 66
    y bar should == 55
  )

  it("should return something that is a sequence",
    X = Struct(:foo, :bar, :quux)
    x = X(42, 55, 66)
    x should mimic(Mixins Sequenced)
    x seq asList should == [:foo => 42, :bar => 55, :quux => 66]
    x bar = 6464
    x seq asList should == [:foo => 42, :bar => 6464, :quux => 66]
  )

  it("should return something that is enumerable",
    X = Struct(:foo, :bar, :quux)
    x = X(42, 55, 66)
    x should mimic(Mixins Enumerable)
    x asList should == [:foo => 42, :bar => 55, :quux => 66]
    x bar = 6464
    x asList should == [:foo => 42, :bar => 6464, :quux => 66]
  )

  describe("create",
    it("should return a new instance of the struct",
      X = Struct(:foo, :bar, :quux)
      x = X create
      x should mimic(X)
      x should not be(X)
    )

    it("should take positional arguments",
      X = Struct(:foo, :bar, :quux)
      x = X create(42, 55)
      x foo should == 42
      x bar should == 55
    )

    it("should take keyword arguments",
      X = Struct(foo:, bar:, quux:)
      x = X create(bar: 42, foo: 55)
      x bar should == 42
      x foo should == 55
    )
  )

  describe("attributeNames",
    it("should return all positional attribute names",
      X = Struct(:foo, :bar, :quux)
      X attributeNames should == [:foo, :bar, :quux]
      x = X(42, 55)
      x attributeNames should == [:foo, :bar, :quux]
    )

    it("should return all defaulted attribute names",
      X = Struct(foo: 42, bar: 55)
      X attributeNames should == [:foo, :bar]
      x = X(42, 55)
      x attributeNames should == [:foo, :bar]
    )

    it("should have all the defaulted attribute names after the positional attribute names",
      X = Struct(:foo, mama: "hoho", :bar, blux: 42, :quux)
      X attributeNames should == [:foo, :bar, :quux, :mama, :blux]
      x = X(42, 55)
      x attributeNames should == [:foo, :bar, :quux, :mama, :blux]
    )
  )

  describe("attributes",
    it("should return all the attributes with values as a dictionary",
      X = Struct(:foo, mama: "hoho", :bar, blux: 42, :quux)
      x = X(42, 55)
      x attributes should == {foo: 42, bar: 55, quux: nil, mama: "hoho", blux: 42}
    )
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
