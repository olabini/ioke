
use("ispec")
use("icheck")

describe(ICheck,
  it("should have tests")
  it("mixes in itself and makes the property creators available")

  describe("forAll",
    it("should have tests")

    it("returns a newly created property")
    it("takes one code argument")
    it("will wrap the code argument in a lexical block")
    it("takes zero or more generator arguments")
    it("will add the generator argument names as arguments to the lexical block")
    it("executes the generator statements in the lexical context mainly, and with generator macros added to it")
    it("takes zero or more guard statements")
    it("uses the generators to create arguments to the block")
    it("will use the guards to reject the valeus that fails the guard")
    it("takes zero or more classifiers")

    it("works when creating a new valid property and testing it",
      Ground testCount = 0
      prop = ICheck forAll(
        Ground testCount++
        42 should == 42
      )

      Ground testCount should == 0
      prop check!

      Ground testCount should == 100

      prop check!(count: 42)

      Ground testCount should == 142
    )

    it("works when creating a new invalid property and testing it",
      Ground testCount = 0
      prop = ICheck forAll(
        Ground testCount++
        42 should == 43
      )

      Ground testCount should == 0
      failureHasBeenCaught? = false
      bind(rescue(ISpec Condition, fn(_, failureHasBeenCaught? = true)),
        prop check!)
      failureHasBeenCaught? should be true
      Ground testCount should == 1
    )
  )

  describe("forEvery",
    it("should have tests")
  )

  describe("Property",
    it("should have tests")
    describe("check!",
      it("takes an optional amount of tests to run")
      it("runs a property a hundred times by default")
      it("takes a flag whether it should print verbosely or not")
      it("returns a data structure with results from the run")
    )
   )

  describe("Classifiers",
    it("should have tests")
  )
  
  describe("Generators",
    it("should have tests")

    describe("int",
      it("should have tests")
    )

    describe("integer",
      it("should have tests")
    )

    describe("decimal",
      it("should have tests")
    )

    describe("ratio",
      it("should have tests")
    )

    describe("rational",
      it("should have tests")
    )

    describe("bool",
      it("should have tests")
    )

    describe("boolean",
      it("should have tests")
    )

    describe("kleene",
      it("should have tests")
    )

    describe("kleenean",
      it("should have tests")
    )

    describe("any",
      it("should have tests")
    )

    describe("oneOf",
      it("should have tests")
    )

    describe("oneOfFrequency",
      it("should have tests")
    )

    describe("nat",
      it("should have tests")
    )

    describe("natural",
      it("should have tests")
    )

    describe("..",
      it("should have tests")
    )

    describe("...",
      it("should have tests")
    )

    describe("list",
      it("should have tests")
    )

    describe("set",
      it("should have tests")
    )

    describe("dict",
      it("should have tests")
    )

    describe("=>",
      it("should have tests")
    )

    describe("text",
      it("should have tests")
    )

    describe("regexp",
      it("should have tests")
    )

    describe("()",
      it("should have tests")
    )

    describe("[]",
      it("should have tests")
    )

    describe("{}",
      it("should have tests")
    )

    describe("#{}",
      it("should have tests")
    )
  )
)
