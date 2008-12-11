
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
      dict at(:foo) should == nil
      dict at("bar") should == nil
      dict at(42) should == nil
    )

    it("should return nil if argument is over the size", 
      dict(bar: 42) at(:foo) should == nil
    )

    it("should an element if it's in the dict", 
      {foo: 123, 321 => "foo", "bax" => 42} at(:foo) should == 123
      {foo: 123, 321 => "foo", "bax" => 42} at(321) should == "foo"
      {foo: 123, 321 => "foo", "bax" => 42} at("bax") should == 42
    )
  )

  describe("[]", 
    it("should return nil if empty dict", 
      dict[:foo] should == nil
      dict["bar"] should == nil
      dict[42] should == nil
    )

    it("should return nil if argument is over the size", 
      dict(bar: 42)[:foo] should == nil
    )

    it("should an element if it's in the dict", 
      {foo: 123, 321 => "foo", "bax" => 42}[:foo] should == 123
      {foo: 123, 321 => "foo", "bax" => 42}[321] should == "foo"
      {foo: 123, 321 => "foo", "bax" => 42}["bax"] should == 42
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
  )
  
  describe("keys", 
    it("should return an empty set for an empty dict", 
      {} keys should == set()
    )

    it("should return the one key in an dict with one element", 
      {foo: 1} keys should == set(:foo)
      {1=>:foo} keys should == set(1)
      {"str" => :bar} keys should == set("str")
    )

    it("should return all the keys", 
      {foo: 1, bar: 2, 3 => :quux} keys should == set(:foo, :bar, 3)
    )
  )

  describe("each", 
    it("should not do anything for an empty dict", 
      x = 0
      {} each(. x++)
      x should == 0
    )
    
    it("should be possible to just give it a message chain, that will be invoked on each object", 
      Ground y = []
      Ground x = method(Ground y << self)
      {one: 1, two: 2, three: 3} each(x)
      y sort should == [:one => 1, :two => 2, :three => 3] sort

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
      cell?(:xxxx) should == false
      cell?(:blargus42) should == false

      x=14
      {one: 1, two: 2, three: 3} each(x, blarg=32)
      x should == 14
    )

    it("should be possible to give it an extra argument to get the index", 
      y = []
      {one: 1, two: 2, three: 3, four: 4} each(i, x, y << i)
      y should == [0,1,2,3]
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
)
