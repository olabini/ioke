
use("ispec")

describe(DefaultBehavior,
  describe("method",
    it("should return a method that returns nil when called with no arguments",
      method call should be nil
      method() call should be nil
    )
    
    it("should name itself after the slot it's assigned to if it has no name",
      (x = method(nil)) name should == "x"
    )
    
    it("should not change it's name if it already has a name",
      x = method(nil)
      y = cell("x")
      cell("y") name should == "x"
    )
    
    it("should know it's own name",
      (x = method(nil)) name should == "x"
    )
  )
)    

describe("Method",
  it("should signal a condition if activating the kind",
    fn(Method) should signal(Condition Error Invocation NotActivatable)
  )
)

describe("NativeMethod",
  it("should signal a condition if activating the kind",
    fn(NativeMethod) should signal(Condition Error Invocation NotActivatable)
  )
)

describe("DefaultMethod",
  it("should be possible to give it a documentation string", 
    method("foo is bar", nil) documentation should == "foo is bar"
  )

  it("should be possible to use identity inside of it",
    method(identity) call kind should == "Locals"
  )

  it("should signal a condition if activating the kind",
    fn(DefaultMethod) should signal(Condition Error Invocation NotActivatable)
  )
  
  it("should report arity failures with regular arguments", 
    noargs = method(nil)
    onearg = method(x, nil)
    twoargs = method(x, y, nil)

    fn(noargs(1)) should signal(Condition Error Invocation TooManyArguments)
    fn(onearg) should signal(Condition Error Invocation TooFewArguments)
    fn(onearg()) should signal(Condition Error Invocation TooFewArguments)
    fn(onearg(1, 2)) should signal(Condition Error Invocation TooManyArguments)
    fn(twoargs) should signal(Condition Error Invocation TooFewArguments)
    fn(twoargs()) should signal(Condition Error Invocation TooFewArguments)
    fn(twoargs(1)) should signal(Condition Error Invocation TooFewArguments)
    fn(twoargs(1, 2, 3)) should signal(Condition Error Invocation TooManyArguments)
  )

  it("should report arity failures with optional arguments", 
    oneopt       = method(x 1, nil)
    twoopt       = method(x 1, y 2, nil)

    fn(oneopt(1, 2)) should signal(Condition Error Invocation TooManyArguments)
    fn(twoopt(1, 2, 3)) should signal(Condition Error Invocation TooManyArguments)
  )

  it("should report arity failures with regular and optional arguments", 
    oneopt       = method(y, x 1, nil)
    twoopt       = method(z, x 1, y 2, nil)
    oneopttworeg = method(z, q, x 1, nil)
    twoopttworeg = method(z, q, x 1, y 2, nil)

    fn(oneopt) should signal(Condition Error Invocation TooFewArguments)
    fn(oneopt()) should signal(Condition Error Invocation TooFewArguments)
    fn(oneopt(1,2,3)) should signal(Condition Error Invocation TooManyArguments)
    fn(twoopt) should signal(Condition Error Invocation TooFewArguments)
    fn(twoopt()) should signal(Condition Error Invocation TooFewArguments)
    fn(twoopt(1,2,3,4)) should signal(Condition Error Invocation TooManyArguments)
    fn(oneopttworeg) should signal(Condition Error Invocation TooFewArguments)
    fn(oneopttworeg()) should signal(Condition Error Invocation TooFewArguments)
    fn(oneopttworeg(1)) should signal(Condition Error Invocation TooFewArguments)
    fn(oneopttworeg(1,2,3,4)) should signal(Condition Error Invocation TooManyArguments)
    fn(twoopttworeg(1,2,3,4,5)) should signal(Condition Error Invocation TooManyArguments)
  )
  
  it("should report mismatched arguments when trying to define optional arguments before regular ones", 
    fn(method(x 1, y, nil)) should signal(Condition Error Invocation ArgumentWithoutDefaultValue)
  )
    
  it("should be possible to give it one optional argument with simple data", 
    m = method(x 42, x)
    m should == 42
    m(43) should == 43
  )

  it("should be possible to give it one optional argument and one regular argument with simple data", 
    first = method(x, y 42, x)
    second = method(x, y 42, y)

    first(10) should == 10
    second(10) should == 42

    first(10, 13) should == 10
    second(10, 13) should == 13
  )
  
  it("should be possible to give it one regular argument and one optional argument that refers to the first one", 
    first = method(x, y x + 42, y)

    first(10) should == 52
    first(10, 33) should == 33
  )
  
  it("should be possible to give it two optional arguments where the second refers to the first one", 
    first  = method(x 13, y x + 42, x)
    second = method(x 13, y x + 42, y)

    first should == 13
    first(10) should == 10
    first(10, 444) should == 10

    second should == 55
    second(10) should == 52
    second(10, 444) should == 444
  )
  
  it("should be possible to have more complicated expression as default value", 
    first = method(x 13, y "foo". (x + 42)-1, y)

    first should == 54
    first(12) should == 53
    first(12, 52) should == 52
  )
  
  it("should be possible to define a method with a keyword argument", 
    method(x:, x)
  )

  it("should give nil as default value to keyword argument", 
    first = method(x:, x)
    
    first should be nil
    first() should be nil
  )

  it("should be possible to call with keyword argument", 
    first = method(x:, x)
    first(x: 12) should == 12
  )

  it("should be possible to give a keyword argument a default value", 
    first = method(x: 42, x)
    
    first should == 42
    first(x: 12) should == 12
  )

  it("should be possible to give more than one keyword argument in any order", 
    first = method(x:, y:, x)
    second = method(x:, y:, y)
    
    first should be nil
    second should be nil

    first(x: 42) should == 42
    second(x: 42) should be nil

    first(x: 42,y: 33) should == 42
    second(x: 42, y: 33) should == 33

    first(y: 42,x: 33) should == 33
    second(y: 42, x: 33) should == 42
  )

  it("should be possible to have both keyword argument and regular argument and give keyword argument before regular argument", 
    first = method(z, x:, x)
    second = method(z, x:, z)
    third = method(x:, z,  x)
    fourth = method(x:, z,  z)
    
    second(12) should == 12
    fourth(13) should == 13

    first(12) should be nil
    third(13) should be nil

    second(x: 321, 12) should == 12
    fourth(x: 321, 13) should == 13

    first(x: 333, 12) should == 333
    third(x: 343, 13) should == 343
  )

  it("should be possible to have both keyword argument and regular argument and give keyword argument after regular argument", 
    first = method(z, x:, x)
    second = method(z, x:, z)
    third = method(x:, z,  x)
    fourth = method(x:, z,  z)
    
    second(12) should == 12
    fourth(13) should == 13

    first(12) should be nil
    third(13) should be nil

    second(12, x: 321) should == 12
    fourth(13, x: 321) should == 13

    first(12, x: 333) should == 333
    third(13, x: 343) should == 343
  )
  
  it("should be possible to have both keyword argument and optional argument and intersperse keyword arguments", 
    m1 = method(x, y 12, z:, x)
    m2 = method(x, y 12, z:, y)
    m3 = method(x, y 12, z:, z)
    m4 = method(x, z:, y 12, x)
    m5 = method(x, z:, y 12, y)
    m6 = method(x, z:, y 12, z)
    m7 = method(z:, x, y 12, x)
    m8 = method(z:, x, y 12, y)
    m9 = method(z:, x, y 12, z)

    m1(42) should == 42
    m2(42) should == 12
    m3(42) should be nil
    m4(42) should == 42
    m5(42) should == 12
    m6(42) should be nil
    m7(42) should == 42
    m8(42) should == 12
    m9(42) should be nil

    m1(42, 13) should == 42
    m2(42, 13) should == 13
    m3(42, 13) should be nil
    m4(42, 13) should == 42
    m5(42, 13) should == 13
    m6(42, 13) should be nil
    m7(42, 13) should == 42
    m8(42, 13) should == 13
    m9(42, 13) should be nil

    m1(z: 1, 42) should == 42
    m2(z: 1, 42) should == 12
    m3(z: 1, 42) should == 1
    m4(z: 1, 42) should == 42
    m5(z: 1, 42) should == 12
    m6(z: 1, 42) should == 1
    m7(z: 1, 42) should == 42
    m8(z: 1, 42) should == 12
    m9(z: 1, 42) should == 1

    m1(z: 1, 42, 14) should == 42
    m2(z: 1, 42, 14) should == 14
    m3(z: 1, 42, 14) should == 1
    m4(z: 1, 42, 14) should == 42
    m5(z: 1, 42, 14) should == 14
    m6(z: 1, 42, 14) should == 1
    m7(z: 1, 42, 14) should == 42
    m8(z: 1, 42, 14) should == 14
    m9(z: 1, 42, 14) should == 1

    m1(42, z: 1, 14) should == 42
    m2(42, z: 1, 14) should == 14
    m3(42, z: 1, 14) should == 1
    m4(42, z: 1, 14) should == 42
    m5(42, z: 1, 14) should == 14
    m6(42, z: 1, 14) should == 1
    m7(42, z: 1, 14) should == 42
    m8(42, z: 1, 14) should == 14
    m9(42, z: 1, 14) should == 1

    m1(42, 14, z: 1) should == 42
    m2(42, 14, z: 1) should == 14
    m3(42, 14, z: 1) should == 1
    m4(42, 14, z: 1) should == 42
    m5(42, 14, z: 1) should == 14
    m6(42, 14, z: 1) should == 1
    m7(42, 14, z: 1) should == 42
    m8(42, 14, z: 1) should == 14
    m9(42, 14, z: 1) should == 1
  )
  
  it("should be possible to have keyword arguments use as default values things defined before it in the argument list", 
    m1 = method(x, y: x+2, y)
    m2 = method(x 13, y: x+2, y)

    m1(55) should == 57
    m2 should == 15
    m2(55) should == 57
    
    m1(55, y: 111) should == 111
    m2(y: 111) should == 111
    m2(55, y: 111) should == 111
    m2(y: 111, 55) should == 111
  )

  it("should raise an error when providing a keyword argument that haven't been defined", 
    m1 = method(x, x)
    m2 = method(x 13, x)
    m3 = method(x: 42, x)

    fn(m1(1, foo: 13)) should signal(Condition Error Invocation MismatchedKeywords)
    fn(m2(foo: 13)) should signal(Condition Error Invocation MismatchedKeywords)
    fn(m3(foo: 13)) should signal(Condition Error Invocation MismatchedKeywords)
  )

  it("should be possible to get a list of keyword arguments", 
    method keywords should == []
    method(a, a) keywords should == []
    method(a 1, a) keywords should == []
    method(a, b, a) keywords should == []
    method(a:, a) keywords should == [:a]
    method(x, a:, a) keywords should == [:a]
    method(x, a:, y, a) keywords should == [:a]
    method(x, a:, y, b: 123, a) keywords should == [:a, :b]
    method(x, a:, y, b: 123, foo: "foo", a) keywords should == [:a, :b, :foo]
    method should checkReceiverTypeOn(:keywords)
  )

  it("should be possible to use a keyword arguments value as a default value for a regular argument", 
    m1 = method(x:, y x+2, y)
    m2 = method(y x+2, x:, y)

    m1(x: 14) should == 16
    m1(13, x: 14) should == 13
    m1(x: 14, 42) should == 42
    m2(x: 14, 44) should == 44

    fn(m2(x:15)) should signal(Condition Error NoSuchCell)
  )
  
  it("should have @ return the receiving object inside of a method", 
    obj = Origin mimic
    obj atSign = method(@)
    obj2 = obj mimic
    obj atSign should == obj
    obj2 atSign should == obj2
  )

  it("should have @@ return the executing method inside of a method", 
    obj = Origin mimic
    obj atAtSign = method(@@)
    obj2 = obj mimic
    obj atAtSign should == obj cell(:atAtSign)
    obj2 atAtSign should == obj2 cell(:atAtSign)
  )

  it("should have 'self' return the receiving object inside of a method", 
    obj = Origin mimic
    obj selfMethod = method(self)
    obj2 = obj mimic

    obj selfMethod should == obj
    obj2 selfMethod should == obj2
  )
  
  describe("rest (+)", 
    it("should to give any length of arguments to a rest-only argument", 
      restm = method(+rest, rest)
      restm should == []
      restm(1) should == [1]
      restm(nil, nil, nil) should == [nil, nil, nil]
      restm(12+1, 13+2, 14+5) should == [13, 15, 19]
    )

    it("should to give both rest and regular arguments", 
      rest2 = method(a, b, +rest, [a, b, rest])
      rest2(1,2) should == [1,2,[]]
      rest2(1,2,3) should == [1,2,[3]]
      rest2(1,2,3,4,5+2) should == [1,2,[3,4,7]]
    )

    it("should to give both rest, optional and regular arguments", 
      rest3 = method(a, b, c 13, d 14, +rest, [a, b, c, d, rest])
      rest3(1,2) should == [1,2,13,14,[]]
      rest3(1,2,33) should == [1,2,33,14,[]]
      rest3(1,2,33,15) should == [1,2,33,15,[]]
      rest3(1,2,33,15,2+2,2+3,2+5) should == [1,2,33,15,[4,5,7]]
    )

    it("should to be possible to give keyword arguments to a method with a rest argument too", 
      rest4 = method(a, b, boo: 12, +rest, [a, b, boo, rest])
      rest4(1,2) should == [1,2,12,[]]
      rest4(1,2,3,4) should == [1,2,12,[3,4]]
      rest4(1,2,3+4) should == [1,2,12,[7]]
      rest4(boo: 444, 1,2,3+4) should == [1,2,444,[3+4]]
      rest4(1, boo: 444, 2, 3+4) should == [1,2,444,[3+4]]
      rest4(1, 2, boo: 444, 3+4) should == [1,2,444,[3+4]]
      rest4(1, 2, 3+4, boo: 444) should == [1,2,444,[3+4]]
    )

    it("should be possible to splat out arguments from a list into a method with regular, optional and rest arguments", 
      norest = method(a, b, [a,b])
      rests  = method(+rest, rest)
      rests2 = method(a, b, +rest, [a, b, rest])

      rests([1,2,3,4]) should == [[1,2,3,4]]
      rests(*[1,2,3,4]) should == [1,2,3,4]
      x = [1,2,3,4]. rests(*x) should == [1,2,3,4]

      rests2(*[1,2,3,4]) should == [1,2,[3,4]]
      rests2(*[1,2]) should == [1,2,[]]
      norest(*[1,2]) should == [1,2]
    )

    describe("message",
      it("should validate type of receiver",
        method should checkReceiverTypeOn(:message)
      )
    )

    describe("argumentsCode",
      it("should validate type of receiver",
        method should checkReceiverTypeOn(:argumentsCode)
      )
    )

    describe("formattedCode",
      it("should validate type of receiver",
        method should checkReceiverTypeOn(:formattedCode)
      )
    )
  )
  
  describe("keyword rest (+:)", 
    it("should be possible to give any keyword argument to something with a keyword rest", 
      krest = method(+:rest, rest)
      krest should == {}
      krest(foo: 1) should == {foo: 1}
      krest(foo: nil, bar: nil, quux: nil) should == {foo:, bar:, quux:}
      krest(one: 12+1, two: 13+2, three: 14+5) should == {one: 13, two: 15, three: 19}
    )

    it("should be possible to combine with regular argument, rest arguments and optional arguments", 
      oneeach = method(a, b, c 12, d 15, +rest, +:krest, [a, b, c, d, rest, krest])
      oneeach(1,2) should == [1,2,12,15,[],{}]
      oneeach(1,2,3) should == [1,2,3,15,[],{}]
      oneeach(f: 111, 1,2) should == [1,2,12,15,[],{f: 111}]
      oneeach(1, f: 111, 2) should == [1,2,12,15,[],{f: 111}]
      oneeach(1, 2, f: 111) should == [1,2,12,15,[],{f: 111}]
      oneeach(1, 2, 44, f: 111) should == [1,2,44,15,[],{f: 111}]
      oneeach(1, 2, 44, 10, f: 111) should == [1,2,44,10,[],{f: 111}]
      oneeach(1, 2, 44, 10, 12, 13, f: 111) should == [1,2,44,10,[12, 13],{f: 111}]
      oneeach(1, x: 1111111, 2, 44, 10, 12, 13, f: 111) should == [1,2,44,10,[12, 13],{f: 111, x: 1111111}]
    )
    
    it("should be possible to splat out keyword arguments", 
      oneeach = method(a, b, c 12, d 15, +rest, +:krest, [a, b, c, d, rest, krest])

      oneeach(1,2,*{foo: 123, bar: 333}) should == [1,2,12,15,[],{foo: 123, bar: 333}]
      x = {foo: 123, bar: 333}. oneeach(1,2,*x) should == [1,2,12,15,[],{foo: 123, bar: 333}]

      oneeach(1,2,*[18,19,20,21,22], *{foo: 123, bar: 333}) should == [1,2,18,19,[20, 21, 22],{foo: 123, bar: 333}]
    )
  )
  
  it("should be possible to get the code for the method by calling 'code' on it", 
    method code should == "method(nil)"
    method(nil) code should == "method(nil)"
    method(1) code should == "method(1)"
    method(1 + 1) code should == "method(1 +(1))"
    method(x, x+x) code should == "method(x, x +(x))"
    method(x 12, x+x) code should == "method(x 12, x +(x))"
    method(x, x+x. x*x) code should == "method(x, x +(x) .\nx *(x))"
    method(x:, x+x. x*x) code should == "method(x: nil, x +(x) .\nx *(x))"
    method(x: 12, x+x. x*x) code should == "method(x: 12, x +(x) .\nx *(x))"
    method(x, +rest, x+x. x*x) code should == "method(x, +rest, x +(x) .\nx *(x))"
    method(x, +:rest, x+x. x*x) code should == "method(x, +:rest, x +(x) .\nx *(x))"
  )
  
  it("should be possible to return from it prematurely, with return", 
    Ground x = 42
    m = method(if(true, return(:bar)). Ground x = 24)
    m() should == :bar 
    x should == 42
  )
  
  it("should return even from inside of a lexical block", 
    x = method(block, block call)
    y = method(
      x(fn(return(42)))
      43)
    y should == 42
  )
)
