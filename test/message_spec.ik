
use("ispec")

describe(Message, 
  it("should have the correct kind", 
    Message should have kind("Message")
  )

  it("should mimic Enumerable", 
    Message should mimic(Mixins Enumerable)
  )

  describe("OperatorTable",
    describe("withOperator",
      it("should temporarily add a new operator to the table, but then remove it",
        Message OperatorTable withOperator("+++++", 42,
          Message OperatorTable operators[:"+++++"] should == 42
        )
        
        Message OperatorTable operators[:"+++++"] should be nil
      )

      it("should reassign the associativity of an existing operator",
        Message OperatorTable withOperator("+", 42,
          Message OperatorTable operators[:"+"] should == 42
        )

        Message OperatorTable operators[:"+"] should == 3
      )
    )

    describe("withTrinaryOperator",
      it("should temporarily add a new trinary operator to the table, but then remove it",
        Message OperatorTable withTrinaryOperator("+++++", 42,
          Message OperatorTable trinaryOperators[:"+++++"] should == 42
        )
        
        Message OperatorTable trinaryOperators[:"+++++"] should be nil
      )

      it("should reassign the associativity of an existing operator",
        Message OperatorTable withTrinaryOperator("+=", 42,
          Message OperatorTable trinaryOperators[:"+="] should == 42
        )

        Message OperatorTable trinaryOperators[:"+="] should == 2
      )
    )

    describe("withInvertedOperator",
      it("should temporarily add a new inverted operator to the table, but then remove it",
        Message OperatorTable withInvertedOperator(":-:", 42,
          Message OperatorTable invertedOperators[:":-:"] should == 42
        )
        
        Message OperatorTable invertedOperators[:":-:"] should be nil
      )

      it("should reassign the associativity of an existing operator",
        Message OperatorTable withInvertedOperator("::", 42,
          Message OperatorTable invertedOperators[:"::"] should == 42
        )

        Message OperatorTable invertedOperators[:"::"] should == 12
      )
    )
  )

  describe("code", 
    it("should return a text representation of itself", 
      Message fromText("foo") code should == "foo"
    )

    it("should return a text representation of itself with arguments", 
      Message fromText("foo(123, 321)") code should == "foo(123, 321)"
    )

    it("should return empty parenthesis for the empty message", 
      Message fromText("()") code should == "()"
    )

    it("should include the next pointer if any exists", 
      Message fromText("foo bar") code should == "foo bar"
    )

    it("should validate type of receiver",
      Message should checkReceiverTypeOn(:code)
    )
  )

  describe("name", 
    it("should return the name of something simple", 
      Message fromText("foo") name should == :foo
    )

    it("should return an empty name", 
      Message fromText("()") name should == :""
    )

    it("should return a name with a question mark", 
      Message fromText("blarg?") name should == :"blarg?"
    )

    it("should validate type of receiver",
      Message should checkReceiverTypeOn(:name)
    )
  )

  describe("name=", 
    it("should validate type of receiver",
      Message should checkReceiverTypeOn(:"name=", "foo")
    )
  )

  describe("next", 
    it("should return nil if there is no next", 
      Message fromText("foo") next should be nil
    )

    it("should return the next pointer", 
      Message fromText("foo bar") next name should == :bar
      Message fromText("foo(123, 321) bar") next name should == :bar
    )

    it("should validate type of receiver",
      Message should checkReceiverTypeOn(:next)
    )
  )

  describe("prev", 
    it("should return nil if there is no next", 
      Message fromText("foo") prev should be nil
    )

    it("should return the prev pointer", 
      Message fromText("foo bar") next prev name should == :foo
      Message fromText("foo(123, 321) bar") next prev name should == :foo
    )

    it("should validate type of receiver",
      Message should checkReceiverTypeOn(:next)
    )
  )

  describe("prev=",
    it("should validate type of receiver",
      Message should checkReceiverTypeOn(:"prev=", "foo")
    )
  )
  
  describe("keyword?", 
    it("should return true for a message that ends with a colon", 
      Message fromText("foo:") keyword? should be true
      Message fromText("bar::::") keyword? should be true
    )

    it("should return false for something simple", 
      Message fromText("foo") keyword? should be false
    )

    it("should return false for the empty message", 
      Message fromText("()") keyword? should be false
    )

    it("should validate type of receiver",
      Message should checkReceiverTypeOn(:keyword?)
    )
  )

  describe("symbol?", 
    it("should return true for a message that starts with a colon", 
      Message fromText(":foo") symbol? should be true
      Message fromText("::::bar") symbol? should be true
    )

    it("should return false for something simple", 
      Message fromText("foo") symbol? should be false
    )

    it("should return false for the empty message", 
      Message fromText("()") symbol? should be false
    )

    it("should validate type of receiver",
      Message should checkReceiverTypeOn(:symbol?)
    )
  )

  describe("from",
    it("should return the things inside unevaluated",
      Message from(+(200)) name should == :"+"
      Message from(abc foo bar quux lux) name should == :abc
    )
  )

  describe("wrap",
    it("should return something with a name of cachedResult",
      Message wrap(42) name should == :cachedResult
    )

    it("should evaluate its argument",
      Message wrap(Ground flurg = 444)
      flurg should == 444
    )

    it("should return a message",
      Message wrap(42) should have kind("Message")
    )

    it("should return something that when evaluated yields the value sent to the wrap method",
      x = 55
      m = Message wrap(x)
      m evaluateOn(Ground, Ground) should be same(x)
    )
  )
  
  describe("sendTo", 
    it("should be possible to create a message from text, with arguments and send that to a number", 
      Message fromText("+(200)") sendTo(20) should == 220
    )
    
    it("should possible to send a simple message that is not predefined", 
      Ground f = method(self asText)
      Message fromText("f") sendTo(42) should == "42"
    )
    
    it("should only send one message and not follow the next pointer", 
      Message fromText("+(200) +(10) -(5)") sendTo(20) should == 220
    )
  )

  describe("evaluateOn", 
    it("should be possible to create a message from text, with arguments and send that to a number", 
      Message fromText("+(200)") evaluateOn(20) should == 220
    )
    
    it("should possible to send a simple message that is not predefined", 
      Ground f = method(self asText)
      Message fromText("f") evaluateOn(42) should == "42"
    )
    
    it("should evaluate the full message chain", 
      Message fromText("+(200) +(10) -(5)") evaluateOn(20) should == 225
    )
  )

  describe("fromText",  
    it("should return a message from the text", 
      Message fromText("foo") name should == :foo
      Message fromText("foo bar") next name should == :bar
    )
  )

  describe("next=",
    it("should set the next pointer",
      msg = Message fromText("foo bar")
      val = msg cell(:next)
      msg next = nil
      msg next should be nil
      (msg cell(:next) == cell(:val)) should be true
    )

    it("should validate type of argument",
      fn(Message next = []) should signal(Condition Error Type IncorrectType)
    )

    it("should validate type of receiver",
      Message should checkReceiverTypeOn(:"next=", 'foo)
    )
  )

  describe("prev=",
    it("should set the prev pointer",
      msg = Message fromText("foo bar")
      val = msg next cell(:prev)
      msg next prev = nil
      msg next prev should be nil
      (msg next cell(:prev) == cell(:val)) should be true
    )

    it("should validate type of argument",
      fn(Message prev = []) should signal(Condition Error Type IncorrectType)
    )

    it("should validate type of receiver",
      Message should checkReceiverTypeOn(:"prev=", 'foo)
    )
  )
  
  describe("terminator?",
    it("should be true when it is a '.' message",
      msg = Message fromText(".")
      msg name should == :"."
      msg terminator? should be true
    )

    it("should not be true when it is not a '.' message",
      msg = Message fromText("foo bar")
      msg terminator? should be false
      msg next terminator? should be false
    )

    it("should validate type of receiver",
      Message should checkReceiverTypeOn(:"terminator?")
    )
  )

  describe("<<",
    it("should add an argument at the end of the message argument list",
      msg = '(foo(x))
      msg << '(blarg mux)
      msg code should == "foo(x, blarg mux)"
    )
    
    it("should return the original message",
      msg = '(foo(x))
      (msg << '(blarg mux)) should be same(msg)
    )
  )

  describe(">>",
    it("should add an argument at the beginning of the message argument list",
      msg = '(foo(x))
      msg >> '(blarg mux)
      msg code should == "foo(blarg mux, x)"
    )

    it("should return the original message",
      msg = '(foo(x))
      (msg >> '(blarg mux)) should be same(msg)
    )
  )

  describe("->",
    it("should change the next pointer of the receiver to the argument",
      one = 'foo
      two = 'bar

      one -> two
      one next should be same(two)
    )

    it("should change the prev pointer of the argument to the receiver",
      one = 'foo
      two = 'bar

      one -> two
      two prev should be same(one)
    )

    it("should return the argument message",
      one = 'foo
      ('bar -> one) should be same(one)
    )

    it("should accept nil as an argument, and set the next pointer to nil in that case",
      x = '(foo bar)

      x -> nil
      x next should be nil
    )

    it("should validate type of argument",
      fn('foo -> []) should signal(Condition Error Type IncorrectType)
    )

    it("should validate type of receiver",
      Message should checkReceiverTypeOn(:"->", 'foo)
    )
  )

  describe("each",
    it("should always execute for itself", 
      Ground x = 0
      'foo each(. Ground x++)
      Ground x should == 1
    )

    it("should execute once for each message in the chain",
      result = []
      '(foo bar quux) each(m, result << m name)
      result should == [:foo, :bar, :quux]
    )
    
    it("should be possible to just give it a message chain, that will be invoked on each object", 
      Ground y = []
      Ground xs = method(y << self name)
      '(foo bar quux) each(xs)
      y should == [:foo, :bar, :quux]

      x = 0
      '(foo bar quux) each(nil. x++)
      x should == 3
    )
    
    it("should be possible to give it an argument name, and code", 
      y = []
      '(foo bar quux) each(x, y << x name)
      y should == [:foo, :bar, :quux]
    )

    it("should return the object", 
      y = '(foo bar quux)
      (y each(x, x)) should be same(y)
    )
    
    it("should establish a lexical context when invoking the methods. this context will be the same for all invocations.", 
      '(foo bar quux) each(x_list, blarg=32)
      cell?(:x_list) should be false
      cell?(:blarg) should be false

      x=14
      '(foo bar quux) each(x, blarg=32)
      x should == 14
    )

    it("should be possible to give it an extra argument to get the index", 
      y = []
      '(foo bar baz quux) each(i, x, y << [i, x name])
      y should == [[0, :foo], [1, :bar], [2, :baz], [3, :quux]]
    )

    it("should validate type of receiver",
      Message should checkReceiverTypeOn(:each)
    )
  )

  describe("walk",
    it("should always execute for itself", 
      Ground x = 0
      'foo(bar) walk(. Ground x++)
      Ground x should == 2
    )

    it("should execute once for each message and each argument in the chain",
      result = []
      '(foo(bar) quux(bar)) walk(m, result << m name)
      result should == [:foo, :bar, :quux, :bar]
    )
    
    it("should be possible to just give it a message chain, and it will be invoked on each object recursively", 
      Ground y = []
      Ground xs = method(y << self name)
      '(foo bar(quux)) walk(xs)
      y should == [:foo, :bar, :quux]

      x = 0
      '(foo bar(quux)) walk(nil. x++)
      x should == 3
    )
    
    it("should be possible to give it an argument name, and code", 
      y = []
      '(foo bar(quux)) walk(x, y << x name)
      y should == [:foo, :bar, :quux]
    )

    it("should return the object", 
      y = '(foo bar(quux))
      (y walk(x, x)) should be same(y)
    )
    
    it("should establish a lexical context when invoking the methods. this context will be the same for all invocations.", 
      '(foo bar(quux)) walk(x_list, blarg=32)
      cell?(:x_list) should be false
      cell?(:blarg) should be false

      x=14
      '(foo bar quux) walk(x, blarg=32)
      x should == 14
    )

    it("should validate type of receiver",
      Message should checkReceiverTypeOn(:walk)
    )
  )
)
