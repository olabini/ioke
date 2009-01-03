
use("ispec")

describe("Message", 
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
  )

  describe("next", 
    it("should return nil if there is no next", 
      Message fromText("foo") next should == nil
    )

    it("should return the next pointer", 
      Message fromText("foo bar") next name should == :bar
      Message fromText("foo(123, 321) bar") next name should == :bar
    )
  )

  describe("prev", 
    it("should return nil if there is no next", 
      Message fromText("foo") prev should == nil
    )

    it("should return the prev pointer", 
      Message fromText("foo bar") next prev name should == :foo
      Message fromText("foo(123, 321) bar") next prev name should == :foo
    )
  )
  
  describe("keyword?", 
    it("should return true for a message that )s with a colon", 
      Message fromText("foo:") keyword? should == true
      Message fromText("bar::::") keyword? should == true
    )

    it("should return false for something simple", 
      Message fromText("foo") keyword? should == false
    )

    it("should return false for the empty message", 
      Message fromText("()") keyword? should == false
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
      msg next should == nil
      (msg cell(:next) == cell(:val)) should == true
    )
  )

  describe("prev=",
    it("should set the prev pointer",
      msg = Message fromText("foo bar")
      val = msg next cell(:prev)
      msg next prev = nil
      msg next prev should == nil
      (msg next cell(:prev) == cell(:val)) should == true
    )
  )
  
  describe("terminator?",
    it("should be true when it is a '.' message",
      msg = Message fromText(".")
      msg name should == :"."
      msg terminator? should == true
    )

    it("should not be true when it is not a '.' message",
      msg = Message fromText("foo bar")
      msg terminator? should == false
      msg next terminator? should == false
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
      x next should == nil
    )
  )
)
