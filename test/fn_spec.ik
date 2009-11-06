
use("ispec")

describe(DefaultBehavior,
  describe("ʎ",
    it("should be possible to create a new LexicalBlock with it",
      ʎ call should be nil
    )

    it("should be possible to create a new LexicalBlock with it that returns a value",
      ʎ(42) call should == 42
    )
  )

  describe("fnx",
    it("should be possible to give it a documentation string",
      fnx("foo is bar", nil) documentation should == "foo is bar"
    )

    it("should return something that is activatable for empty list",
      fnx activatable should be true
    )

    it("should return something that is activatable for code",
      fnx("hello") activatable should be true
    )

    it("should return something that is activatable for code with arguments",
      fnx(x, y, x+y) activatable should be true
    )
  )

  describe("fn",
    it("should be possible to give it a documentation string",
      fn("foo is bar", nil) documentation should == "foo is bar"
    )

    it("should mimic LexicalBlock",
      result = fn("hello" println)
      result should have kind("LexicalBlock")
      result should not == LexicalBlock
    )

    it("should return nil when invoking 'call' on an empty block",
      fn call should be nil
    )

    it("should be possible to execute it by invoking 'call' on it",
      fn(1+1) call should == 2
      x = fn(42+4)
      x call
      x call should == 46
    )

    it("should have access to variables in the scope it was defined, in simple do",
      x = 26
      fn(x) call should == 26

      x = Origin mimic
      x do(
        y = 42
        z = fn(y+1) call)
      x z should == 43
    )

    it("should have access to variables in the scope it was defined, in more complicated do",
      x = Origin mimic
      x do(
        y = 42
        z = fn(y+2))
      x z call should == 44
    )

    it("should have access to variables in the scope it was defined, in more nested blocks",
      x = Origin mimic
      x do(
        y = 42
        z = fn(fn(y+3) call))
      x z call should == 45
    )

    it("should have access to variables in the scope it was defined, in method",
      x = Origin mimic
      x y = method(
        z = 42
        fn(z+5)
      )

      x y() call should == 47
    )

    it("should have access to variables in the scope it was defined, in method, getting self",
      x = Origin mimic
      x y = method(
        fn(self)
      )

      x y() call should == x
    )

    it("should take arguments",
      fn(x, x) call(42) should == 42
      fn(x, x+2) call(42) should == 44
      fn(x, y, x+y+2) call(3,7) should == 12
    )

    it("should complain when given the wrong number of arguments",
      fn(fn() call(42)) should signal(Condition Error Invocation TooManyArguments)
      fn(fn(x, x) call()) should signal(Condition Error Invocation TooFewArguments)
      fn(fn(x, x) call(12, 42)) should signal(Condition Error Invocation TooManyArguments)
    )

    it("should be able to update variables in the scope it was defined",
      x = Origin mimic
      x do(
        y = 42
        fn(y = 43) call
      )
      x y should == 43

      x = Origin mimic
      x do(
        y = 44
        zz = fn(y = 45)
      )
      x zz call
      x y should == 45
    )


    it("should create a new variable when assigning something that doesn't exist",
      fn(blarg = 42. blarg) call should == 42
      cell?(:blarg) should be false
    )

    it("should be possible to get the code for the block by calling 'code' on it",
      fn code should == "fn(nil)"
      fn(nil) code should == "fn(nil)"
      fn(1) code should == "fn(1)"
      fn(1 + 1) code should == "fn(1 +(1))"
      fn(x, x+x) code should == "fn(x, x +(x))"
      fn(x 12, x+x) code should == "fn(x 12, x +(x))"
      fn(x, x+x. x*x) code should == "fn(x, x +(x) .\nx *(x))"
      fn(x:, x+x. x*x) code should == "fn(x: nil, x +(x) .\nx *(x))"
      fn(x: 12, x+x. x*x) code should == "fn(x: 12, x +(x) .\nx *(x))"
      fn(x, +rest, x+x. x*x) code should == "fn(x, +rest, x +(x) .\nx *(x))"
      fn(x, +:rest, x+x. x*x) code should == "fn(x, +:rest, x +(x) .\nx *(x))"

      fnx code should == "fnx(nil)"
      fnx(nil) code should == "fnx(nil)"
      fnx(1) code should == "fnx(1)"
      fnx(1 + 1) code should == "fnx(1 +(1))"
      fnx(x, x+x) code should == "fnx(x, x +(x))"
      fnx(x 12, x+x) code should == "fnx(x 12, x +(x))"
      fnx(x, x+x. x*x) code should == "fnx(x, x +(x) .\nx *(x))"
      fnx(x:, x+x. x*x) code should == "fnx(x: nil, x +(x) .\nx *(x))"
      fnx(x: 12, x+x. x*x) code should == "fnx(x: 12, x +(x) .\nx *(x))"
      fnx(x, +rest, x+x. x*x) code should == "fnx(x, +rest, x +(x) .\nx *(x))"
      fnx(x, +:rest, x+x. x*x) code should == "fnx(x, +:rest, x +(x) .\nx *(x))"
    )

    it("should shadow reading of outer variables when getting arguments",
      x = 32
      fn(x, x) call(43) should == 43
      x should == 32
    )

    it("should shadow writing of outer variables when getting arguments",
      x = 32
      fn(x, x = 13. x) call(123) should == 13
      x should == 32
    )
  )
)

describe(LexicalBlock,
  describe("->",
    it("should take a block and return a new one that combines them",
      x = fn(a, a + 10)
      y = fn(a, a * 5)
      (x -> y) call(32) should == 210
    )
  )

  describe("<-",
    it("should take a block and return a new one that combines them",
      x = fn(a, a + 10)
      y = fn(a, a * 5)
      (x <- y) call(32) should == 170
    )
  )

  describe("&",
    it("should take a block and return a new one that combines them using boolean logic",
      x = fn(a, a > 5)
      y = fn(a, a < 10)
      res = x & y
      res call(0) should be false
      res call(1) should be false
      res call(2) should be false
      res call(3) should be false
      res call(4) should be false
      res call(5) should be false
      res call(6) should be true
      res call(7) should be true
      res call(8) should be true
      res call(9) should be true
      res call(10) should be false
      res call(11) should be false
      res call(12) should be false
    )
  )

  describe("|",
    it("should take a block and return a new one that combines them using boolean logic",
      x = fn(a, a < 5)
      y = fn(a, a > 10)
      res = x | y
      res call(0) should be true
      res call(1) should be true
      res call(2) should be true
      res call(3) should be true
      res call(4) should be true
      res call(5) should be false
      res call(6) should be false
      res call(7) should be false
      res call(8) should be false
      res call(9) should be false
      res call(10) should be false
      res call(11) should be true
      res call(12) should be true
    )
  )

  describe("complement",
    it("should return a new block that is the complement of the original one",
      x = fn(a, a < 5)
      res = x complement
      res call(0) should be false
      res call(4) should be false
      res call(5) should be true
      res call(6) should be true
      res call(7) should be true
      res call(8) should be true
    )
  )

  describe("iterate",
    it("should return a sequence",
      fn() iterate should mimic(Sequence)
    )

    it("should be possible to define a sequence of fibonacci",
      fibseq = fn(a, b, [b, a + b]) iterate(0, 1) mapped(first)
      fibseq next should == 0
      fibseq next should == 1
      fibseq next should == 1
      fibseq next should == 2
      fibseq next should == 3
      fibseq next should == 5
      fibseq next should == 8
      fibseq next should == 13
      fibseq next should == 21
      fibseq next should == 34
      fibseq next should == 55
      fibseq next should == 89
      fibseq next should == 144
      fibseq next should == 233
    )
  )

  it("should report arity failures with regular arguments",
    noargs = fnx(nil)
    onearg = fnx(x, nil)
    twoargs = fnx(x, y, nil)

    fn(noargs(1)) should signal(Condition Error Invocation TooManyArguments)
    fn(onearg) should signal(Condition Error Invocation TooFewArguments)
    fn(onearg()) should signal(Condition Error Invocation TooFewArguments)
    fn(onearg(1, 2)) should signal(Condition Error Invocation TooManyArguments)
    fn(twoargs) should signal(Condition Error Invocation TooFewArguments)
    fn(twoargs()) should signal(Condition Error Invocation TooFewArguments)
    fn(twoargs(1)) should signal(Condition Error Invocation TooFewArguments)
    fn(twoargs(1,2,3)) should signal(Condition Error Invocation TooManyArguments)
  )

  it("should execute a non-activatable block if given arguments",
    x = fn(x, x+42+4)
    x(10) should == 56
  )

  it("should report arity failures with optional arguments",
    oneopt       = fnx(x 1, nil)
    twoopt       = fnx(x 1, y 2, nil)

    fn(oneopt(1,2)) should signal(Condition Error Invocation TooManyArguments)
    fn(twoopt(1,2,3)) should signal(Condition Error Invocation TooManyArguments)
  )

  it("should report arity failures with regular and optional arguments",
    oneopt       = fnx(y, x 1, nil)
    twoopt       = fnx(z, x 1, y 2, nil)
    oneopttworeg = fnx(z, q, x 1, nil)
    twoopttworeg = fnx(z, q, x 1, y 2, nil)

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
    fn(oneopttworeg(1,2,3,4,5)) should signal(Condition Error Invocation TooManyArguments)
  )

  it("should report mismatched arguments when trying to define optional arguments before regular ones",
    fn(fn(x 1, y, nil)) should signal(Condition Error Invocation ArgumentWithoutDefaultValue)
  )

  it("should be possible to give it one optional argument with simple data",
    fn(x 42, x) call should == 42
    fn(x 42, x) call(43) should == 43
  )

  it("should be possible to give it one optional argument and one regular argument with simple data",
    first = fnx(x, y 42, x)
    second = fnx(x, y 42, y)

    first(10) should == 10
    second(10) should == 42

    first(10, 13) should == 10
    second(10, 13) should == 13
  )

  it("should be possible to give it one regular argument and one optional argument that refers to the first one",
    first = fnx(x, y x + 42, y)

    first(10) should == 52
    first(10, 33) should == 33
  )

  it("should be possible to give it two optional arguments where the second refers to the first one",
    first  = fnx(x 13, y x + 42, x)
    second = fnx(x 13, y x + 42, y)

    first should == 13
    first(10) should == 10
    first(10, 444) should == 10

    second should == 55
    second(10) should == 52
    second(10, 444) should == 444
  )

  it("should be possible to have more complicated expression as default value",
    first  = fnx(x 13, y "foo".(x + 42)-1, y)

    first should == 54
    first(12) should == 53
    first(12, 52) should == 52
  )

  it("should be possible to define a block with a keyword argument",
    fn(x:, x)
  )

  it("should give nil as default value to keyword argument",
    first = fnx(x:, x)

    first should be nil
    first() should be nil
  )

  it("should be possible to call with keyword argument",
    first = fnx(x:, x)

    first(x: 12) should == 12
  )

  it("should be possible to give a keyword argument a default value",
    first = fnx(x: 42, x)

    first should == 42
    first(x: 12) should == 12
  )

  it("should be possible to give more than one keyword argument in any order",
    first = fnx(x:, y:, x)
    second = fnx(x:, y:, y)

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
    first = fnx(z, x:, x)
    second = fnx(z, x:, z)
    third = fnx(x:, z,  x)
    fourth = fnx(x:, z,  z)

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
    first = fnx(z, x:, x)
    second = fnx(z, x:, z)
    third = fnx(x:, z,  x)
    fourth = fnx(x:, z,  z)

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
    m1 = fnx(x, y 12, z:, x)
    m2 = fnx(x, y 12, z:, y)
    m3 = fnx(x, y 12, z:, z)
    m4 = fnx(x, z:, y 12, x)
    m5 = fnx(x, z:, y 12, y)
    m6 = fnx(x, z:, y 12, z)
    m7 = fnx(z:, x, y 12, x)
    m8 = fnx(z:, x, y 12, y)
    m9 = fnx(z:, x, y 12, z)

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
    m1 = fnx(x, y: x+2, y)
    m2 = fnx(x 13, y: x+2, y)

    m1(55) should == 57
    m2 should == 15
    m2(55) should == 57

    m1(55, y: 111) should == 111
    m2(y: 111) should == 111
    m2(55, y: 111) should == 111
    m2(y: 111, 55) should == 111
  )

  it("should raise an error when providing a keyword argument that haven't been defined",
    m1 = fnx(x, x)
    m2 = fnx(x 13, x)
    m3 = fnx(x: 42, x)

    fn(m1(1, foo: 13)) should signal(Condition Error Invocation MismatchedKeywords)
    fn(m2(foo: 13)) should signal(Condition Error Invocation MismatchedKeywords)
    fn(m3(foo: 13)) should signal(Condition Error Invocation MismatchedKeywords)
  )

  it("should be possible to get a list of keyword arguments",
    fn keywords should == []
    fn(a, a) keywords should == []
    fn(a 1, a) keywords should == []
    fn(a, b, a) keywords should == []
    fn(a:, a) keywords should == [:a]
    fn(x, a:, a) keywords should == [:a]
    fn(x, a:, y, a) keywords should == [:a]
    fn(x, a:, y, b: 123, a) keywords should == [:a, :b]
    fn(x, a:, y, b: 123, foo: "foo", a) keywords should == [:a, :b, :foo]
  )

  it("should be possible to use a keyword arguments value as a default value for a regular argument",
    m1 = fnx(x:, y x+2, y)
    m2 = fnx(y x+2, x:, y)

    m1(x: 14) should == 16
    m1(13, x: 14) should == 13
    m1(x: 14, 42) should == 42
    m2(x: 14, 44) should == 44

    fn(m2(x:15)) should signal(Condition Error NoSuchCell)
  )

  describe("argumentNames",
    it("should return an empty list for a simple fn",
      fn argumentNames should == []
    )

    it("should return an the argument names as symbols for a block",
      fn(x, x) argumentNames should == [:x]
      fn(x, y 12, x) argumentNames should == [:x, :y]
      fn(x, y: 12, x) argumentNames should == [:x]
      fn(y: 12, x, x) argumentNames should == [:x]
    )
  )

  describe("rest (+)",
    it("should to give any length of arguments to a rest-only argument",
      restm = fnx(+rest, rest)
      restm should == []
      restm(1) should == [1]
      restm(nil, nil, nil) should == [nil, nil, nil]
      restm(12+1, 13+2, 14+5) should == [13, 15, 19]
    )

    it("should to give both rest and regular arguments",
      rest2 = fnx(a, b, +rest, [a, b, rest])
      rest2(1,2) should == [1,2,[]]
      rest2(1,2,3) should == [1,2,[3]]
      rest2(1,2,3,4,5+2) should == [1,2,[3,4,7]]
    )

    it("should to give both rest, optional and regular arguments",
      rest3 = fnx(a, b, c 13, d 14, +rest, [a, b, c, d, rest])
      rest3(1,2) should == [1,2,13,14,[]]
      rest3(1,2,33) should == [1,2,33,14,[]]
      rest3(1,2,33,15) should == [1,2,33,15,[]]
      rest3(1,2,33,15,2+2,2+3,2+5) should == [1,2,33,15,[4,5,7]]
    )

    it("should to be possible to give keyword arguments to a block with a rest argument too",
      rest4 = fnx(a, b, boo: 12, +rest, [a, b, boo, rest])
      rest4(1,2) should == [1,2,12,[]]
      rest4(1,2,3,4) should == [1,2,12,[3,4]]
      rest4(1,2,3+4) should == [1,2,12,[7]]
      rest4(boo: 444, 1,2,3+4) should == [1,2,444,[3+4]]
      rest4(1, boo: 444, 2, 3+4) should == [1,2,444,[3+4]]
      rest4(1, 2, boo: 444, 3+4) should == [1,2,444,[3+4]]
      rest4(1, 2, 3+4, boo: 444) should == [1,2,444,[3+4]]
    )

    it("should be possible to splat out arguments from a list into a block with regular, optional and rest arguments",
      norest = fnx(a, b, [a,b])
      rests  = fnx(+rest, rest)
      rests2 = fnx(a, b, +rest, [a, b, rest])

      rests([1,2,3,4]) should == [[1,2,3,4]]
      rests(*[1,2,3,4]) should == [1,2,3,4]
      x = [1,2,3,4]. rests(*x) should == [1,2,3,4]

      rests2(*[1,2,3,4]) should == [1,2,[3,4]]
      rests2(*[1,2]) should == [1,2,[]]
      norest(*[1,2]) should == [1,2]
    )
  )

  describe("keyword rest (+:)",
    it("should be possible to give any keyword argument to something with a keyword rest",
      krest = fnx(+:rest, rest)
      krest should == {}
      krest(foo: 1) should == {foo: 1}
      krest(foo: nil, bar: nil, quux: nil) should == {foo:, bar:, quux:}
      krest(one: 12+1, two: 13+2, three: 14+5) should == {one: 13, two: 15, three: 19}
    )

    it("should be possible to combine with regular argument, rest arguments and optional arguments",
      oneeach = fnx(a, b, c 12, d 15, +rest, +:krest, [a, b, c, d, rest, krest])
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
      oneeach = fnx(a, b, c 12, d 15, +rest, +:krest, [a, b, c, d, rest, krest])

      oneeach(1,2,*{foo: 123, bar: 333}) should == [1,2,12,15,[],{foo: 123, bar: 333}]
      x = {foo: 123, bar: 333}. oneeach(1,2,*x) should == [1,2,12,15,[],{foo: 123, bar: 333}]

      oneeach(1,2,*[18,19,20,21,22], *{foo: 123, bar: 333}) should == [1,2,18,19,[20, 21, 22],{foo: 123, bar: 333}]
    )
  )
)
