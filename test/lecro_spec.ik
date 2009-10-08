
use("ispec")

describe(DefaultBehavior,
  describe("lecro",
    it("should return a lecro that returns nil when called with no arguments",
      lecro call should be nil
      lecro() call should be nil
    )

    it("should name itself after the slot it's assigned to if it has no name",
      x = lecro(nil)
      cell(:x) name should == "x"
    )

    it("should not change it's name if it already has a name",
      x = lecro(nil)
      y = cell(:x)
      cell(:y) name should == "x"
    )

    it("should know it's own name",
      (x = lecro(nil)) name should == "x"
    )

    it("should be activatable",
      lecro activatable should be true
    )
  )

  describe("lecrox",
    it("should return a lecro that returns nil when called with no arguments",
      lecrox call should be nil
      lecrox() call should be nil
    )

    it("should name itself after the slot it's assigned to if it has no name",
      x = lecrox(nil)
      cell(:x) name should == "x"
    )

    it("should not change it's name if it already has a name",
      x = lecrox(nil)
      y = cell(:x)
      cell(:y) name should == "x"
    )

    it("should know it's own name",
      (x = lecrox(nil)) name should == "x"
    )

    it("should not be activatable",
      lecrox activatable should be false
    )
  )
)

describe("LexicalMacro",
  it("should be possible to give it a documentation string",
    lecro("foo is bar", nil) documentation should == "foo is bar"
  )

  it("should signal a condition if activating the kind",
    fn(LexicalMacro) should signal(Condition Error Invocation NotActivatable)
  )

  it("should have 'call' defined inside the call to the macro",
    result = lecro(call) call
    result should have kind("Call")
  )

  it("should not evaluate it's arguments by default",
    x=42
    lecro(nil) call(x=13)
    x should == 42
  )

  it("should take any kinds of arguments",
    x = lecro(nil)
    x(13, 42, foo: 42*13) should be nil
  )

  it("should return the last value in the macro",
    x = lecro(nil. 42+13)
    x should == 55
  )

  it("should have access to variables in the scope it was defined, in simple do",
    x = 26
    lecro(x) call should == 26

    x = Origin mimic
    x do (
      y = 42
      z = lecro(y+1) call)
    x z should == 43
  )

  it("should have access to variables in the scope it was defined, in more complicated do",
    x = Origin mimic
    x do (
      y = 42
      z = lecro(y+2))
    x z should == 44
  )

  it("should have access to variables in the scope it was defined, in more nested blocks",
    x = Origin mimic
    x do (
      y = 42
      z = lecro(lecro(y+3) call))
    x z should == 45
  )

  it("should have access to variables in the scope it was defined, in method",
    x = Origin mimic
    x y = method(
      z = 42
      lecro(z+5)
    )

    x y() call should == 47
  )

  it("should have access to variables in the scope it was defined, in method, getting self",
    x = Origin mimic
    x y = method(
      lecro(self)
    )

    x y call should == x
  )

  it("should be able to update variables in the scope it was defined",
    x = Origin mimic
    x do(
      y = 42
      lecro(y = 43) call
    )
    x y should == 43

    x = Origin mimic
    x do(
      y = 44
      zz = lecro(y = 45)
    )
    x zz()
    x y should == 45
  )

  it("should create a new variable when assigning something that doesn't exist",
    lecro(lecro_blarg = 42. lecro_blarg) call should == 42
    cell?(:lecro_blarg) should be false
  )

  it("should be possible to get the code for the lecro by calling 'code' on it",
    lecro code should == "lecro(nil)"
    lecro(nil) code should == "lecro(nil)"
    lecro(1) code should == "lecro(1)"
    lecro(1 + 1) code should == "lecro(1 +(1))"

    lecrox code should == "lecrox(nil)"
    lecrox(nil) code should == "lecrox(nil)"
    lecrox(1) code should == "lecrox(1)"
    lecrox(1 + 1) code should == "lecrox(1 +(1))"
  )

  it("should have a outerScope cell that returns the outside scope this macro is executed in",
    lecro(
      lecro(
        [call evaluatedArguments, outerScope call evaluatedArguments])
      ) call(123, 321) call(42, 45) should == [[42,45], [123,321]]
  )
)
