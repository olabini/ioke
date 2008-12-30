
use("ispec")

describe(DefaultBehavior,
  describe("internal:concatenateText", 
    it("should combine several strings", 
      internal:concatenateText("foo", "bar", "flux") should == "foobarflux"

      x = "str"
      internal:concatenateText("foo", x, "flux") should == "foostrflux"
    )

    it("should combine strings with the text representation of other stuff", 
      internal:concatenateText("foo", 123, "flux") should == "foo123flux"
      internal:concatenateText([1,2,3], "foo") should == "[1, 2, 3]foo"
    )
  )
  
  describe("internal:createText", 
    it("should be possible to invoke from Ioke with a regular String", 
      internal:createText("foo") should == "foo"
    )
  )

  describe("same?", 
    it("should return false for different objects", 
      Origin mimic should not be same(Origin mimic)
    )

    it("should return true for the same objects", 
      x = Origin mimic
      x should be same(x)
    )
  )
  
  describe("uniqueHexId", 
    it("should return different ids for different objects", 
      Origin mimic uniqueHexId should not == Origin mimic uniqueHexId
    )

    it("should return the same id for the same object", 
      x = Origin mimic
      x uniqueHexId should == x uniqueHexId
    )
  )
  
  describe("in?", 
    it("should call 'include?' on the argument with itself as argument", 
      x = Origin mimic
      x include? = method(arg, [arg, 42])
      y = Origin mimic
      y in?(x) should == [y, 42]
    )
    
    it("should return true if the object is in a list", 
      1 in?([1,2,3]) should == true
    )

    it("should return false if the object is not in a list", 
      1 in?([2, 3, 4]) should == false
    )
  )
  
  describe("derive", 
    it("should be able to derive from Origin", 
      result = Origin derive
      result should have kind("Origin")
      result should not be same(Origin)
    )

    it("should be able to derive from Ground", 
      result = Ground derive
      result should have kind("Ground")
      result should not be same(Ground)
    )

    it("should be able to derive from Text", 
      result = Text derive
      result should have kind("Text")
      result should not be same(Text)
    )
  )
  
  describe("break", 
    it("should have nil as value by default", 
      loop(break) should == nil
    )

    it("should take a return value", 
      loop(break(42)) should == 42
    )
  )
  
  describe("return", 
    it("should have nil as value by default", 
      method(return) call should == nil
    )

    it("should take a return value", 
      method(return(42)) call should == 42
    )
  )
  
  describe("until", 
    it("should not do anything if initial argument is true", 
      x = 42
      until(true, x = 43)
      x should == 42
    )
    
    it("should loop until the argument becomes true", 
      x=42
      until(x == 45, x++)
      x should == 45
    )
    
    it("should return the last statement value", 
      x=42
      until(x==43, x++. "blurg") should == "blurg"
    )
    
    it("should be interrupted by break", 
      x=42
      until(x==50, x++. if(x==45, break))
      x should == 45
    )
    
    it("should be continued by continue", 
      count=0
      x=42
      until(x==50, count++. if(x==45, x = 47. continue). x++.)
      x should == 50
      count should == 7
    )

    it("should return nil if no arguments provided", 
      until() should == nil
    )
  )

  describe("while", 
    it("should not do anything if initial argument is false", 
      x = 42
      while(false, x=43)
      x should == 42
    )
    
    it("should loop until the argument becomes false", 
      x = 42
      while(x<45, x++)
      x should == 45
    )
    
    it("should return the last statement value", 
      x=42
      while(x<43, x++. "blurg") should == "blurg"
    )
    
    it("should be interrupted by break", 
      x=42
      while(x<50, x++. if(x==45, break))
      x should == 45
    )

    it("should be continued by continue", 
      count=0. x=42. while(x<50, count++. if(x==45, x = 47. continue). x++.)
      x should == 50
      count should == 7
    )
    
    it("should return nil if no arguments provided", 
      while() should == nil
    )
  )
  
  describe("loop", 
    it("should loop until interrupted by break", 
      x=42
      loop(x++. if(x==45, break))
      x should == 45
    )
  )

  describe("if", 
    it("should evaluate it's first element once", 
      x=42
      if(x++)
      x should == 43
    )
    
    it("should return it's second argument if the first element evaluates to true", 
      if(true, 42, 43) should == 42
    )

    it("should return it's third argument if the first element evaluates to false", 
      if(false, 42, 43) should == 43
    )
    
    it("should return the result of evaluating the first argument if there are no more arguments", 
      if(44) should == 44
    )
    
    it("should return the result of evaluating the first argument if it is false and there are only two arguments", 
      if(false) should == false
      if(nil) should == nil
    )
    
    it("should assign the test result to the variable it", 
      if(42, it) should == 42
      if(nil, 42, it) should == nil
      if(false, 42, it) should == false
      if("str", 42, it) should == 42
    )

    it("should have a lexical context for the it variable", 
      if(42, fn(it)) call should == 42
    )

    it("should be possible to nest it variables lexically", 
      if(42, [it, if(13, [it, if(nil, 44, it), it])]) should == [42, [13, nil, 13]]
    )
  )

  describe("unless", 
    it("should evaluate it's first element once", 
      x=42
      unless(x++)
      x should == 43
    )
    
    it("should return it's second argument if the first element evaluates to false", 
      unless(false, 42, 43) should == 42
    )

    it("should return it's third argument if the first element evaluates to true", 
      unless(true, 42, 43) should == 43
    )
    
    it("should return the result of evaluating the first argument if there are no more arguments", 
      unless(44) should == 44
)
    
    it("should return the result of evaluating the first argument if it is true and there are only two arguments", 
      unless(true, 13) should == true
    )
    
    it("should assign the test result to the variable it", 
      unless(42, nil, it) should == 42
      unless(nil, it, 42) should == nil
      unless(false, it, 42) should == false
      unless("str", it, 42) should == 42
    )

    it("should have a lexical context for the it variable", 
      unless(42, nil, fn(it)) call should == 42
    )

    it("should be possible to nest it variables lexically", 
      unless(42, nil, [it, unless(13, nil, [it, unless(nil, it, 44), it])]) should == [42, [13, nil, 13]]
    )
  )
 
  describe("asText", 
    it("should call toString and return the text from that", 
      Origin mimic asText should match(#/^#<Origin:[0-9A-F]+>$/)
    )
  )

  describe("do", 
    it("should execute a piece of code inside an object", 
      x = Origin mimic
      x do(
        y = 42
        z = "str"
      )
      cell?(:y) should == false
      x y should == 42
      x z should == "str"
    )
  )
  
  describe("nil?", 
    it("should return true for nil", 
      nil nil? should == true
    )

    it("should return false for false", 
      false nil? should == false
    )
    
    it("should return false for true", 
      true nil? should == false
    )
    
    it("should return false for a Number", 
      123 nil? should == false
    )
    
    it("should return false for a Text", 
      "flurg" nil? should == false
    )
  )

  describe("true?", 
    it("should return false for nil", 
      nil true? should == false
    )

    it("should return false for false", 
      false true? should == false
    )
    
    it("should return true for true", 
      true true? should == true
    )
    
    it("should return true for a Number", 
      123 true? should == true
    )
    
    it("should return true for a Text", 
      "flurg" true? should == true
    )
  )

  describe("false?", 
    it("should return true for nil", 
      nil false? should == true
    )

    it("should return true for false", 
      false false? should == true
    )
    
    it("should return false for true", 
      true false? should == false
    )
    
    it("should return false for a Number", 
      123 false? should == false
    )
    
    it("should return false for a Text", 
      "flurg" false? should == false
    )
  )

  describe("mimics", 
    it("should return an empty list for DefaultBehavior", 
      DefaultBehavior mimics should == [ISpec ExtendedDefaultBehavior]
    )

    it("should return a list with Origin for a simple mimic", 
      Origin mimic mimics should == [Origin]
    )

    it("should return a list with all mimics", 
      X = Origin mimic
      Y = Origin mimic
      Z = Origin mimic
      y = Y mimic
      y mimic!(X)
      y mimic!(Z)
      y mimics should == [Y, X, Z]
    )
  )

  describe("removeAllMimics!", 
    it("should return the object", 
      x = Origin mimic
      x uniqueHexId = DefaultBehavior cell(:uniqueHexId)
      x removeAllMimics! uniqueHexId should == x uniqueHexId
    )

    it("should remove all mimics", 
      x = Origin mimic
      x mimic!(Text)
      x mimics = DefaultBehavior cell(:mimics)
      x removeAllMimics! mimics should == []
    )
  )

  describe("removeMimic!", 
    it("should not remove something it doesn't mimic", 
      Origin mimic removeMimic!("foo") mimics should == [Origin]
    )

    it("should return the object", 
      x = Origin mimic
      x removeMimic!(1) should == x
    )
    
    it("should remove any mimic it has", 
      x = Origin mimic
      x mimics = DefaultBehavior cell(:mimics)
      x removeMimic!(Origin)
      x mimics should == []
    )

    it("should not remove any other mimic", 
      x = Origin mimic
      y = Origin mimic
      x mimic!(y)
      x removeMimic!(y)
      x mimics should == [Origin]
    )
  )
  
  
  describe("prependMimic!", 
    it("should add a new mimic to the list of mimics", 
      f = Origin mimic
      g = Origin mimic
      f prependMimic!(g)
      f mimics length should == 2
      f mimics[1] should == Origin
      f mimics[0] should == g
    )

    it("should not add a mimic that's already in the list", 
      f = Origin mimic
      f prependMimic!(Origin)
      f prependMimic!(Origin)
      f prependMimic!(Origin)
      f prependMimic!(Origin)
      f mimics length should == 1
    )

    it("should not be able to mimic nil", 
      fn(Origin mimic prependMimic!(nil)) should signal(Condition Error CantMimicOddball)
    )
    
    it("should not be able to mimic true", 
      fn(Origin mimic prependMimic!(true)) should signal(Condition Error CantMimicOddball)
    )
    
    it("should not be able to mimic false", 
      fn(Origin mimic prependMimic!(false)) should signal(Condition Error CantMimicOddball)
    )
    
    it("should not be able to mimic symbols", 
      fn(Origin mimic prependMimic!(:foo)) should signal(Condition Error CantMimicOddball)
    )
    
    it("should return the receiving object", 
      f = Origin mimic
      f prependMimic!(Origin) should == f
    )
  )
  
  describe("kind?", 
    it("should return false if the kind doesn't match", 
      Text kind?("nil") should == false
      Text kind?("Number") should == false
      "" kind?("nil") should == false
      "" kind?("Number") should == false
      "" kind?("System") should == false
    )

    it("should return true if the current object has the kind", 
      Text kind?("Text") should == true
    )
    
    it("should return true if the main mimic has the kind", 
      "" kind?("Text") should == true
      "" kind?("DefaultBehavior") should == true
      "" kind?("Base") should == true
      "" kind?("Ground") should == true
      "" kind?("Origin") should == true
    )

    it("should return true if another mimic has the kind", 
      123 kind?("Mixins Comparing") should == true
    )

    it("should handle a cycle of mimics correctly", 
      f = Origin mimic. f mimic!(f). f kind?("Origin") should == true
      f = Origin mimic. Origin mimic!(f). f kind?("Origin") should == true
      f = Origin mimic. Origin mimic!(f). f kind?("DefaultBehavior") should == true
    )
  )
  
  describe("mimics?", 
    it("should return false if the object doesn't mimic the argument", 
      f = Origin mimic. Origin mimics?(f) should == false
      f = Origin mimic. DefaultBehavior mimics?(f) should == false
      f = Origin mimic. 12 mimics?(f) should == false
      f = Origin mimic. f mimics?(12) should == false
    )
    
    it("should return true if the object is the same as the argument", 
      f = Origin mimic. f mimics?(f) should == true
      Origin mimics?(Origin) should == true
    )

    it("should return true if any of the mimics are the argument", 
      x = Origin mimic. y = x mimic. z = y mimic. z mimics?(Origin) should == true
      x = Origin mimic. y = x mimic. z = y mimic. z mimics?(x) should == true
      x = Origin mimic. y = x mimic. z = y mimic. z mimics?(y) should == true
      x = Origin mimic. y = x mimic. z = y mimic. z mimics?(z) should == true
      f = Origin mimic. Origin mimic!(f). x = Origin mimic. y = x mimic. z = y mimic. z mimics?(f) should == true
    )
    
    it("should handle a cycle of mimics correctly", 
      x = Origin mimic. y = x mimic. z = y mimic. Origin mimic!(z). z mimics?(Number) should == false
      x = Origin mimic. y = x mimic. z = y mimic. Origin mimic!(z). z mimics?(Origin) should == true
      x = Origin mimic. y = x mimic. z = y mimic. Origin mimic!(z). z mimics?(Base) should == true
      x = Origin mimic. x mimic!(x). x mimics?(Origin) should == true
    )
  )

  describe("is?", 
    it("should return false if the object doesn't mimic the argument", 
      f = Origin mimic. Origin is?(f) should == false
      f = Origin mimic. DefaultBehavior is?(f) should == false
      f = Origin mimic. 12 is?(f) should == false
      f = Origin mimic. f is?(12) should == false
    )
    
    it("should return true if the object is the same as the argument", 
      f = Origin mimic. f is?(f) should == true
      Origin is?(Origin) should == true
    )

    it("should return true if any of the mimics are the argument", 
      x = Origin mimic. y = x mimic. z = y mimic. z is?(Origin) should == true
      x = Origin mimic. y = x mimic. z = y mimic. z is?(x) should == true
      x = Origin mimic. y = x mimic. z = y mimic. z is?(y) should == true
      x = Origin mimic. y = x mimic. z = y mimic. z is?(z) should == true
      f = Origin mimic. Origin mimic!(f). x = Origin mimic. y = x mimic. z = y mimic. z is?(f) should == true
    )
    
    it("should handle a cycle of mimics correctly", 
      x = Origin mimic. y = x mimic. z = y mimic. Origin mimic!(z). z is?(Number) should == false
      x = Origin mimic. y = x mimic. z = y mimic. Origin mimic!(z). z is?(Origin) should == true
      x = Origin mimic. y = x mimic. z = y mimic. Origin mimic!(z). z is?(Base) should == true
      x = Origin mimic. x mimic!(x). x is?(Origin) should == true
    )
  )
  
  describe("mimic!", 
    it("should add a new mimic to the list of mimics", 
      f = Origin mimic. g = Origin mimic. f mimic!(g)
      f mimics length should == 2
      f mimics[0] should == Origin
      f mimics[1] should == g
    )

    it("should not add a mimic that's already in the list", 
      f = Origin mimic
      f mimic!(Origin)
      f mimic!(Origin)
      f mimic!(Origin)
      f mimic!(Origin)
      f mimics length should == 1
    )

    it("should not be able to mimic nil", 
      fn(Origin mimic mimic!(nil)) should signal(Condition Error CantMimicOddball)
    )
    
    it("should not be able to mimic true", 
      fn(Origin mimic mimic!(true)) should signal(Condition Error CantMimicOddball)
    )
    
    it("should not be able to mimic false", 
      fn(Origin mimic mimic!(false)) should signal(Condition Error CantMimicOddball)
    )
    
    it("should not be able to mimic symbols", 
      fn(Origin mimic mimic!(:foo)) should signal(Condition Error CantMimicOddball)
    )
    
    it("should return the receiving object", 
      f = Origin mimic
      f mimic!(Origin) should == f
    )
  )
  
  describe("with", 
    it("should just mimic an object if no arguments given", 
      Origin with cellNames should == []
    )

    it("should set the given keywords as cells", 
      Origin with(foo: 13) cellNames should == [:foo]
      Origin with(foo: 13) cells should == {foo: 13}
      Origin with(foo: 13, bar: 14) cellNames should == [:foo, :bar]
      Origin with(foo: 13, bar: 14) cells should == {foo: 13, bar: 14}
    )
  )

  describe("!", 
    it("should return the result of calling not on the object", 
      x = Origin mimic
      x not = method(53)
      !x should == 53

      x = Origin mimic
      x not = method(33)
      !x should == 33
    )
  )

  describe("not", 
    it("should return nil for a number", 
      123 not should == nil
    )

    it("should return nil for a text", 
      "foo" not should == nil
    )
  )

  describe("and", 
    it("should evaluate it's argument", 
      x=41
      13 and(x=42)
      x should == 42
    )

    it("should return the result of the argument", 
      5353 and(42) should == 42
    )

    it("should be available in infix", 
      ("flurg" and 43) should == 43
    )
  )

  describe("&&", 
    it("should evaluate it's argument", 
      x=41
      13 &&(x=42)
      x should == 42
    )

    it("should return the result of the argument", 
      5353 &&(42) should == 42
    )

    it("should be available in infix", 
      ("flurg" && 43) should == 43
    )
  )
  
  describe("or", 
    it("should not evaluate it's argument", 
      x=41
      123 or(x=42)
      x should == 41
    )

    it("should return the receiver", 
      "murg" or(42) should == "murg"
    )

    it("should be available in infix", 
      (444 or 43) should == 444
    )
  )

  describe("||", 
    it("should not evaluate it's argument", 
      x=41
      123 ||(x=42)
      x should == 41
    )

    it("should return the receiver", 
      "murg" ||(42) should == "murg"
    )

    it("should be available in infix", 
      (444 || 43) should == 444
    )
  )
  
  describe("xor", 
    it("should evaluate it's argument", 
      x=41
      30 xor(x=42)
      x should == 42
    )

    it("should return false if the argument is true", 
      (30 xor(true)) should == false
    )

    it("should return true if the argument is false", 
      (30 xor(false)) should == true
    )

    it("should return true if the argument is nil", 
      (30 xor(nil)) should == true
    )
    
    it("should be available in infix", 
      (30 xor 43) should == false
    )
  )

  describe("nor", 
    it("should not evaluate it's argument", 
      x=41
      30 nor(x=42)
      x should == 41
    )

    it("should return false", 
      30 nor(42) should == false
    )

    it("should be available in infix", 
      (30 nor 43) should == false
    )
  )

  describe("nand", 
    it("should evaluate it's argument", 
      x=41
      30 nand(x=42)
      x should == 42
    )

    it("should return false if the argument evaluates to true", 
      (30 nand(42)) should == false
    )
    
    it("should return true if the argument evaluates to false", 
      (30 nand(false)) should == true
    )
    
    it("should return true if the argument evaluates to nil", 
      (30 nand(nil)) should == true
    )

    it("should be available in infix", 
      (30 nand 43) should == false
    )
  )
  
  describe("genSym", 
    it("should generate a new thing every time called", 
      genSym should not == genSym
    )

    it("should generate a symbol", 
      genSym should have kind("Symbol")
    )
  )
  
  describe("message", 
    it("should return a new message", 
      message("foo") should have kind("Message")
    )
    
    it("should take a text argument", 
      message("foo") name should == :foo
    )

    it("should take a symbol argument", 
      message(:foo) name should == :foo
    )
  )

  describe("become!",
    it("should not be possible to have nil become something",
      fn(nil become!(42)) should signal(Condition Error CantMimicOddball)
    )

    it("should not be possible to have true become something",
      fn(true become!(42)) should signal(Condition Error CantMimicOddball)
    )

    it("should not be possible to have false become something",
      fn(false become!(42)) should signal(Condition Error CantMimicOddball)
    )

    it("should be possible to have a number become something else",
      x = Origin mimic
      y = 321

      y become!(x)

      y should have kind("Origin")
      y should not == 321
    )

    it("should be possible to have something become a number",
      x = Origin mimic
      y = 42

      x become!(y)

      x should have kind("Number")
      x should == 42
    )

    it("should be possible to have a text become something else",
      x = Origin mimic
      y = "foobar"

      y become!(x)

      y should have kind("Origin")
      y should not == "foobar"
    )

    it("should be possible to have something become a text",
      x = Origin mimic
      y = "foobar"

      x become!(y)

      x should have kind("Text")
      x should == "foobar"
    )

    it("should return the receiver",
      x = Origin mimic
      y = Origin mimic

      x become!(y) should be same(y)
    )

    it("should modify the reciever to have the same documentation",
      x = Origin mimic
      y = Origin mimic
      x documentation = "foo"
      y documentation = "quux"

      x become!(y)

      x documentation should == "quux"
    )

    it("should give both objects the same uniqueHexId",
      x = Origin mimic
      y = Origin mimic

      x uniqueHexId should not == y uniqueHexId
      y uniqueHexId should not == x uniqueHexId

      x become!(y)
      
      x uniqueHexId should == y uniqueHexId
      y uniqueHexId should == x uniqueHexId
    )

    it("should give objects that are the same",
      x = Origin mimic
      y = Origin mimic
      x should not be same(y)
      y should not be same(x)

      x become!(y)
      
      x should be same(y)
      y should be same(x)
    )
    
    it("should give objects that mimic each other",
      x = Origin mimic
      y = Origin mimic

      x become!(y)
      
      x should be mimic(y)
      y should be mimic(x)
    )
    
    it("should give objects that when modified will change each other",
      x = Origin mimic
      y = Origin mimic

      x become!(y)

      x z = 42
      y z should == 42

      y q = 35
      x q should == 35

      b = Origin mimic
      x mimic!(b)

      y should have mimic(b)
    )
  )

  describe("frozen?",
    it("should return false on something that isn't frozen",
      x = Origin mimic
      x should not be frozen
      
      x freeze!

      x should be frozen
    )
  )

  describe("freeze!",
    it("should be possible to call several times without effect",
      x = Origin mimic
      x freeze!
      x freeze!
    )

    it("should not be possible to modify a frozen object",
      x = Origin mimic
      x existing = 43
      x freeze!

      ;; create new cell
      fn(x y = 42) should signal(Condition Error ModifyOnFrozen)

      ;; modify existing
      fn(x existing = 42) should signal(Condition Error ModifyOnFrozen)

      ;; add new mimic
      fn(x mimic!(Origin mimic)) should signal(Condition Error ModifyOnFrozen)
      fn(x prependMimic!(Origin mimic)) should signal(Condition Error ModifyOnFrozen)

      ;; remove mimic
      fn(x removeMimic!(Origin)) should signal(Condition Error ModifyOnFrozen)

      ;; remove all mimics
      fn(x removeAllMimics!) should signal(Condition Error ModifyOnFrozen)

      ;; set documentation
      fn(x documentation = "blarg") should signal(Condition Error ModifyOnFrozen)

      ;; become something else
      fn(x become!(42)) should signal(Condition Error ModifyOnFrozen)
    )

    it("should be copied when becoming",
      x = Origin mimic
      y = Origin mimic
      x freeze!

      y become!(x)
      
      y should be frozen
    )
  )

  describe("thaw!",
    it("should be possible to call several times without effect",
      x = Origin mimic
      x freeze!

      x thaw!
      x thaw!
    )

    it("should unfreeze an object",
      x = Origin mimic
      x freeze!

      x thaw!

      x should not be frozen
    )
  )
)
