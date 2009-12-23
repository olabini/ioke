
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
      X attributeNames sort should == [:foo, :bar] sort
      x = X(42, 55)
      x attributeNames sort should == [:foo, :bar] sort
    )

    it("should have all the defaulted attribute names after the positional attribute names",
      X = Struct(:foo, mama: "hoho", :bar, blux: 42, :quux)
      X attributeNames[0..2] should == [:foo, :bar, :quux]
      X attributeNames[3..-1] sort should == [:blux, :mama]
      x = X(42, 55)
      x attributeNames[0..2] should == [:foo, :bar, :quux]
      x attributeNames[3..-1] sort should == [:blux, :mama]
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
    it("should return an empty array when given no arguments",
      X = Struct(:foo, :bar, :quux)
      x = X(42, 55)
      x valuesAt should == []
      x valuesAt() should == []
    )

    it("should use positional arguments zero-indexed",
      X = Struct(:foo, :bar, :quux)
      x = X(42, 55)
      x valuesAt(2, 0) should == [nil, 42]
    )

    it("should return an array with a specified positional attribute",
      X = Struct(:foo, :bar, :quux)
      x = X(42, 55)
      x valuesAt(1) should == [55]
    )

    it("should return an array with a specified keyword attribute",
      X = Struct(:foo, :bar, :quux)
      x = X(42, 55)
      x valuesAt(:bar) should == [55]

      Y = Struct(foo: 42, bar: 5555, six: 'seven)
      y = Y(bar: 32)
      y valuesAt(:six) should == ['seven]
    )

    it("should return an array with all the elements specified by position",
      X = Struct(:foo, :bar, :quux)
      x = X(42, 55)
      x valuesAt(1, 1, 1, 0, 1, 0) should == [55, 55, 55, 42, 55, 42]
    )

    it("should return an array with all the elements specified by keyword",
      Y = Struct(foo: 42, bar: 5555, six: 'seven)
      y = Y(bar: 32)
      y valuesAt(:six, :bar, :foo, :six) should == ['seven, 32, 42, 'seven]
    )

    it("should be possible to mix positional and keyword arguments",
      X = Struct(:foo, :bar, :quux)
      x = X(42, 55)
      x valuesAt(1, :foo, 1, 0, :bar, 0) should == [55, 42, 55, 42, 55, 42]
    )
  )

  describe("[]",
    it("should take a positional zero-indexed argument",
      X = Struct(:foo, :bar, :quux)
      x = X(42, 55)
      x[0] should == 42
      x[1] should == 55
      x[2] should be nil
    )

    it("should take a keyword argument",
      X = Struct(:foo, :bar, :quux)
      x = X(42, 55)
      x[:foo] should == 42
      x[:bar] should == 55
      x[:quux] should be nil
    )
  )

  describe("[]=",
    it("should take a positional zero-indexed argument",
      X = Struct(:foo, :bar, :quux)
      x = X(42, 55)
      x[0] = 15345
      x[1] = 444
      x[2] = 11133
      x foo should == 15345
      x bar should == 444
      x quux should == 11133
    )

    it("should take a keyword argument",
      X = Struct(:foo, :bar, :quux)
      x = X(42, 55)
      x[:foo] = 15345
      x[:bar] = 444
      x[:quux] = 11133
      x foo should == 15345
      x bar should == 444
      x quux should == 11133
    )
  )

  describe("==",
    it("should defer equality to the defined attributes",
      X = Struct(:foo, :bar, :quux)
      x = X(42, 55)
      x2 = X(42, 55)

      x should == x2

      x foo = 43
      x should not == x2

      x foo = 42
      x bar = 56
      x should not == x2

      x bar = 55
      x quux = "blurg"
      x should not == x2

      x quux = nil
      x should == x2
    )

    it("should work when given base as argument",
      (Struct(:x) create(42) == Base) should be false
    )

    it("should work when given basebehavior as argument",
      (Struct(:x) create(42) == DefaultBehavior BaseBehavior) should be false
    )
  )

  describe("hash",
    it("should defer hashing to the defined attributes",
      X = Struct(:foo, :bar, :quux)
      x = X(42, 55)
      x2 = X(42, 55)

      x hash should == x2 hash

      x foo = 43
      x hash should not == x2 hash

      x foo = 42
      x bar = 56
      x hash should not == x2 hash

      x bar = 55
      x quux = "blurg"
      x hash should not == x2 hash

      x quux = nil
      x hash should == x2 hash
    )
  )

  describe("asText",
    it("should return the attribute names for a Struct",
      X = Struct(:foo, :bar, :quux)
      X asText should == "Struct(foo, bar, quux)"
    )

    it("should return a text representation based on the attributes",
      X = Struct(:foo, :bar, :quux)
      x = X(42, 55)
      x asText should == "(foo: 42, bar: 55, quux: nil)"
      x quux = "blarg"
      x asText should == "(foo: 42, bar: 55, quux: blarg)"
    )
  )

  describe("inspect",
    it("should return the attribute names for a Struct",
      X = Struct(:foo, :bar, :quux)
      X inspect should == "Struct(foo, bar, quux)"
    )

    it("should return an inspect representation based on the attributes",
      X = Struct(:foo, :bar, :quux)
      x = X(method("blarg"), 55)
      x inspect should == "(foo: foo:method(\"blarg\"), bar: 55, quux: nil)"
      x foo = ["blarg"]
      x bar = ["blurg"]
      x quux = ["blerg"]
      x inspect should == "(foo: [\"blarg\"], bar: [\"blurg\"], quux: [\"blerg\"])"
    )
  )

  describe("notice",
    it("should return the attribute names for a Struct",
      X = Struct(:foo, :bar, :quux)
      X notice should == "Struct(foo, bar, quux)"

    )
    it("should return a notice representation based on the attributes",
      X = Struct(:foo, :bar, :quux)
      x = X(method("blarg"), 55)
      x notice should == "(foo: foo:method(...), bar: 55, quux: nil)"
      x foo = ["blarg"]
      x bar = ["blurg"]
      x quux = ["blerg"]
      x notice should == "(foo: [\"blarg\"], bar: [\"blurg\"], quux: [\"blerg\"])"
    )
  )
)
