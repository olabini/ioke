
use("ispec")

describe("Dict", 
  it("should have the correct kind", 
    Dict should have kind("Dict")
  )

  it("should be possible to mimic", 
    x = Dict mimic
    x should mimic(Dict)
    x should have kind("Dict")
    x should not be same(Dict)
  )
  
  it("should mimic Enumerable", 
    Dict should mimic(Mixins Enumerable)
  )

  describe("key?",
    it("should return false if there is no such key",
      {} key?(:foo) should be false
      {fox: 123} key?(:foo) should be false
      {"foo" => 123} key?(:foo) should be false
    )

    it("should return true if the key is there",
      {foo: 123} key?(:foo) should be true
    )

    it("should validate type of receiver",
      Dict should checkReceiverTypeOn(:key?, :foo)
    )
  )
  
  describe("==", 
    it("should return false when sent an argument that is not a dict", 
      {} should not == 1
      {1=>2} should not == 1
      {1=>2,2=>3,3=>4} should not == "foo"
      {} should not == fn({})
    )
    
    it("should return true for two empty dicts", 
      x = {}.
      x should == x
      {} should == {}
    )
    
    it("should return true for two empty dicts where one has a new cell", 
        x = {}
        y = {}
        x blarg = 12
        x should == y
    )
    
    it("should return false when the two dicts have a key element of different types", 
      {1=>2} should not == {"1"=>2}
      {1=>2, 2=>3, 3=>4} should not == {"1"=>2, "2"=>3, "3"=>4}
    )

    it("should return false when the two dicts have different size", 
      {1} should not == {}
      {1} should not == {1,2,3}
    )
    
    it("should return true if the elements in the dict are the same", 
      {1} should == {1=>nil}
      {1=>"str"} should == {1=>"str"}
      {"1"=>123} should == {"1"=>123}
      {1,2,3,4,5,6,7} should == {1,2,3,4,5,6,7}
    )

    it("should return true if the elements in the dict are the same but in different order", 
      {1,2,3,4,5,6,7} should == {3,4,5,6,7,1,2,3}
    )
  )

  describe("addKeysAndValues", 
    it("should add the keys and values provided to the dict", 
      {} addKeysAndValues([:foo, :bar, :x], [32, 111, 4]) should == {foo: 32, bar: 111, x: 4}
    )

    it("should only add as many as there are keys", 
      {} addKeysAndValues([:foo, :bar, :x], [32, 111, 4, 10, 42]) should == {foo: 32, bar: 111, x: 4}
    )

    it("should return the dict", 
      v = {}. v addKeysAndValues([], []) should == v
    )
  )
  
  describe("at", 
    it("should return nil if empty dict", 
      dict at(:foo) should be nil
      dict at("bar") should be nil
      dict at(42) should be nil
    )

    it("should return nil if argument is over the size", 
      dict(bar: 42) at(:foo) should be nil
    )

    it("should an element if it's in the dict", 
      {foo: 123, 321 => "foo", "bax" => 42} at(:foo) should == 123
      {foo: 123, 321 => "foo", "bax" => 42} at(321) should == "foo"
      {foo: 123, 321 => "foo", "bax" => 42} at("bax") should == 42
    )

    it("should validate type of receiver",
      Dict should checkReceiverTypeOn(:at, :foo)
    )
  )
  
  describe("merge",
    it("should return an equal dict if given an empty dict",
      {foo: "bar"} merge({}) should == {foo: "bar"}
    )

    it("should return a new dict that contains both of the keys and values",
      {foo: "bar"} merge({qux: 42}) should == {foo: "bar", qux: 42}
    )

    it("should return a new dict that has overwritten the values with the same key",
      {foo: "bar", qux: 16} merge({qux: 42}) should == {foo: "bar", qux: 42}
    )

    it("should take zero or more pairs and add them to the returned dict",
      {foo: "bar", qux: 16} merge(:qux => 42) should == {foo: "bar", qux: 42}
      {foo: "bar", qux: 16} merge(:qux => 42, {abc: 15}) should == {foo: "bar", qux: 42, abc: 15}
      {foo: "bar", qux: 16} merge({abc: 15}, :qux => 42) should == {foo: "bar", qux: 42, abc: 15}
    )

    it("should take zero or more keyword arguments and add them to the returned dict",
      {foo: "bar", qux: 16} merge(qux: 42) should == {foo: "bar", qux: 42}
      {foo: "bar", qux: 16} merge(qux: 42, {abc: 15}) should == {foo: "bar", qux: 42, abc: 15}
      {foo: "bar", qux: 16} merge({abc: 15}, qux: 42) should == {foo: "bar", qux: 42, abc: 15}
    )

    it("should validate type of receiver",
      Dict should checkReceiverTypeOn(:merge, {})
    )
  )

  describe("withDefault",
    it("should return a new mimic",
      x = {}
      x withDefault(1) should not be same(x)
      {foo: 13} withDefault(42)[:foo] should == 13
    )
    
    it("should set the default value for that mimic",
      x = {} withDefault(42)
      x[:blarg] should == 42
      x should == {}
    )

    it("should validate type of receiver",
      Dict should checkReceiverTypeOn(:withDefault, 42)
    )
  )

  describe("[]", 
    it("should return nil if empty dict", 
      dict[:foo] should be nil
      dict["bar"] should be nil
      dict[42] should be nil
    )

    it("should return nil if argument is over the size", 
      dict(bar: 42)[:foo] should be nil
    )

    it("should an element if it's in the dict", 
      {foo: 123, 321 => "foo", "bax" => 42}[:foo] should == 123
      {foo: 123, 321 => "foo", "bax" => 42}[321] should == "foo"
      {foo: 123, 321 => "foo", "bax" => 42}["bax"] should == 42
    )

    it("should validate type of receiver",
      Dict should checkReceiverTypeOn(:"[]", :foo)
    )
  )
  
  describe("[]=", 
    it("should add an element to an empty dict", 
      x = {}. x[:foo] = :bar. x should == {foo: :bar}
      x = {42 => 32}. x[:foo] = :bar. x should == {42 => 32, foo: :bar}
    )

    it("should overwrite an existing element", 
      x = {foo: 6666}. x[:foo] = :bar. x should == {foo: :bar}
      x = {foo: 6666, 42 => 32}. x[:foo] = :bar. x should == {42 => 32, foo: :bar}
    )
    
    it("should return the value set", 
      ({foo: 6666}[42] = :bar) should == :bar
    )

    it("should validate type of receiver",
      Dict should checkReceiverTypeOn(:"[]=", :foo, :bar)
    )
  )
  
  describe("keys", 
    it("should return an empty set for an empty dict", 
      {} keys should == set()
    )

    it("should return the one key in an dict with one element", 
      {foo: 1} keys should == set(:foo)
      {1 => :foo} keys should == set(1)
      {"str" => :bar} keys should == set("str")
    )

    it("should return all the keys", 
      {foo: 1, bar: 2, 3 => :quux} keys should == set(:foo, :bar, 3)
    )

    it("should validate type of receiver",
      Dict should checkReceiverTypeOn(:keys)
    )
  )

  describe("each", 
    it("should not do anything for an empty dict", 
      x = 0
      {} each(. x++)
      x should == 0
    )
    
    it("should be possible to just give it a message chain, that will be invoked on each object", 
      d = {one: 1, two: 2, three: 3}
      Pair y = []
      Pair x = method(y << self)
      d each(x)

      Pair y sort should == [:one => 1, :two => 2, :three => 3] sort

      x = 0
      {one: 1, two: 2, three: 3} each(nil. x++)
      x should == 3
    )
    
    it("should be possible to give it an argument name, and code", 
        y = []
        {one: 1, two: 2, three: 3} each(x, y << x)
        y sort should == [:one => 1, :two => 2, :three => 3] sort
    )

    it("should return the object", 
        y = {one: 1, two: 2, three: 3}
        (y each(x, x)) should == y
    )
    
    it("should establish a lexical context when invoking the methods. this context will be the same for all invocations.", 
      {one: 1, two: 2, three: 3} each(xxxx, blargus42=32)
      cell?(:xxxx) should be false
      cell?(:blargus42) should be false

      x=14
      {one: 1, two: 2, three: 3} each(x, blarg=32)
      x should == 14
    )

    it("should be possible to give it an extra argument to get the index", 
      y = []
      {one: 1, two: 2, three: 3, four: 4} each(i, x, y << i)
      y should == [0,1,2,3]
    )

    it("should validate type of receiver",
      Dict should checkReceiverTypeOn(:each, "foo")
    )
  )


  describe("?|",
    it("should just return itself if not empty",
      dict(foo: 1) ?|(x/0) should == dict(foo: 1)
      dict(foo: 1,bar: 2,quux: 3) ?|(x/0) should == dict(foo: 1,bar: 2,quux: 3)
      x = dict(foo: 1,bar: 3)
      x ?|(blarg) should be same(x)
    )

    it("should return the result of evaluating the code if empty",
      dict ?|(42) should == 42
      dict ?|([1,2,3]) should == [1,2,3]
    )
  )

  describe("?&",
    it("should just return itself if empty",
      (dict ?& 42) should == dict
      (dict ?& [1,2,3]) should == dict
    )

    it("should return the result of evaluating the code if non-empty",
      dict(foo: 1) ?&(10) should == 10
      dict(foo: 1,bar: 2,quux: 3) ?&(20) should == 20
      x = dict(foo: 1,bar: 3)
      x ?&([1,2,3]) should == [1,2,3]
    )
  )
)

describe(DefaultBehavior, 
  ; These methods will NOT create Pair instances, instead it's cheating - just like keyword arguments
  ; At some point these methods should also take keyword arguments, interchangably with pairs.
  describe("dict", 
    it("should create a new empty dict when given no arguments", 
      x = dict
      x should be kind("Dict")
      x should not be same(Dict)
      x should mimic(Dict)

      x = dict()
      x should be kind("Dict")
      x should not be same(Dict)
      x should mimic(Dict)
    )
    
    it("should create a new dict with the evaluated arguments", 
      result = dict(1 => 2, "abc" => 3+42, :foo => 123, :bar => "x")
      result asList length should == 4
    )
    
    it("should create a new dict with keyword arguments", 
      result = dict(abc: 2, foo: 3+42, bar: 123, quux: "x")
      result asList length should == 4
    )

    it("should take arguments that are not keyword or pairs and add nil as value for them", 
      dict(123, "foo", 13+2, :bar) should == dict(123=>nil, "foo"=>nil, 15=>nil, :bar => nil)
    )

    it("should take keyword arguments without a next pointer and add nil as value for them", 
      dict(foo:, bar:, quux:) should == dict(:foo => nil, :bar => nil, :quux => nil)
    )
  )
  
  describe("{}", 
    it("should create a new empty dict when given no arguments", 
      x = {}
      x should be kind("Dict")
      x should not be same(Dict)
      x should mimic(Dict)
    )
    
    it("should create a new dict with the evaluated arguments", 
      result = {1 => 2, "abc" => 3+42, :foo => 123, :bar => "x"}
      result asList length should == 4
    )

    it("should create a new dict with keyword arguments", 
      result = {abc: 2, foo: 3+42, bar: 123, quux: "x"}
      result asList length should == 4
    )

    it("should take arguments that are not keyword or pairs and add nil as value for them", 
      {123, "foo", 13+2, :bar} should == {123=>nil, "foo"=>nil, 15=>nil, :bar => nil}
    )

    it("should take keyword arguments without a next pointer and add nil as value for them", 
      {foo:, bar:, quux:} should == {:foo => nil, :bar => nil, :quux => nil} 
    )
  )

  describe("size",
    it("should be 0 for an empty dict",
      dict size should == 0)
    
    it("should be the number of pairs in dict",
      dict(a: 1, b: 2) size should == 2)
  )
      
)
