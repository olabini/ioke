
use("ispec")
use("icheck")

describe(ICheck,
  it("mixes in itself and makes the property creators available")

  describe("forAll",
    it("returns a newly created property",
      prop = ICheck forAll(1 should == 1)
      prop should mimic(ICheck Property)
      prop should not be(ICheck Property)
    )

    it("takes one code argument",
      ICheck forAll(1 should == 1)
    )

    it("will wrap the code argument in a lexical block",
      thisVariableShouldBeVisibleInsideTheBlock = 25
      prop = ICheck forAll(
        thisVariableShouldBeVisibleInsideTheBlock should == 25
        thisVariableShouldNotBeVisibleOutsideOfThisLexicalBlock = 42
      )
      prop check!
                      cell?(:thisVariableShouldNotBeVisibleOutsideOfThisLexicalBlock) should be false
      ICheck          cell?(:thisVariableShouldNotBeVisibleOutsideOfThisLexicalBlock) should be false
      ICheck Property cell?(:thisVariableShouldNotBeVisibleOutsideOfThisLexicalBlock) should be false
      prop            cell?(:thisVariableShouldNotBeVisibleOutsideOfThisLexicalBlock) should be false
    )

    it("takes zero or more generator arguments",
      ICheck forAll(integer x,
        42 should == 42) check!

      ICheck forAll(integer x, integer y,
        42 should == 42) check!

      ICheck forAll(integer x, integer y, integer z,
        42 should == 42) check!
    )

    it("will add the generator argument names as arguments to the lexical block",
      ICheck forAll(integer x,
        (x + x) should == (x*2)) check!

      ICheck forAll(integer thisNameIsNotReallyVisibleOutsideEither,
        thisNameIsNotReallyVisibleOutsideEither should mimic(Number Rational)
        ) check!
      cell?(:thisNameIsNotReallyVisibleOutsideEither) should be false
    )

    it("will use a specific generator and call that to get values to the block",
      ICheck Generators basicSetOfCreatedValues = fnx([42, 55, 12, 42425, 7756] seq)
      allValuesGiven = []
      ICheck forAll(basicSetOfCreatedValues blarg,
        allValuesGiven << blarg) check!(count: 5)
      allValuesGiven should == [42, 55, 12, 42425, 7756]
    )

    it("executes the generator statements in the lexical context mainly, and with generator macros added to it",
      ICheck Generators anotherSetOfCreatedValues = fnx(inp, Origin with(next: inp + 42))
      bladiBlaTest = 55
      ICheck forAll(anotherSetOfCreatedValues(bladiBlaTest) x,
        x should == 97) check!(count: 1)
    )

    it("takes zero or more guard statements",
      ICheck forAll(integer x, where x > 40,
        nil) check!(count: 1)
    )

    it("should allow a guard statement with keyword syntax too",
      ICheck forAll(integer x, where: x > 40,
        nil) check!(count: 1)
    )

    it("will use the guards to reject the values that fails the guard",
      ICheck Generators testData = fnx((1..100) seq)
      allValuesGiven = []
      ICheck forAll(testData x, where x > 40,
        allValuesGiven << x) check!(count: 60)
      allValuesGiven should == (41..100) asList
    )

    it("executes the guards in the lexical scope of where it was created",
      outsideVal = [] 
      ICheck forAll(integer x, where . outsideVal << 42. true,
        true) check!(count: 2)
      outsideVal should == [42, 42]
    )

    it("takes zero or more classifiers with syntax 1",
      ICheck Generators testData = fnx((1..100) seq)
      result = ICheck forAll(testData x,
        classify(one) x < 40,
        true) check!

      result classifier[:one] should == 39

      result = ICheck forAll(testData x,
        classify(one) x < 40,
        classify(two) x > 30,
        true) check!

      result classifier[:one] should == 39
      result classifier[:two] should == 70
    )

    it("takes zero or more classifiers with syntax 2",
      ICheck Generators testData = fnx((1..100) seq)
      result = ICheck forAll(testData x,
        classifyAs(one) x < 40,
        true) check!

      result classifier[:one] should == 39

      result = ICheck forAll(testData x,
        classifyAs(one) x < 40,
        classifyAs(two) x > 30,
        true) check!

      result classifier[:one] should == 39
      result classifier[:two] should == 70
    )

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
    it("returns a newly created property",
      prop = ICheck forEvery(1 should == 1)
      prop should mimic(ICheck Property)
      prop should not be(ICheck Property)
    )

    it("takes one code argument",
      ICheck forEvery(1 should == 1)
    )

    it("will wrap the code argument in a lexical block",
      thisVariableShouldBeVisibleInsideTheBlock = 25
      prop = ICheck forEvery(
        thisVariableShouldBeVisibleInsideTheBlock should == 25
        thisVariableShouldNotBeVisibleOutsideOfThisLexicalBlock = 42
      )
      prop check!
                      cell?(:thisVariableShouldNotBeVisibleOutsideOfThisLexicalBlock) should be false
      ICheck          cell?(:thisVariableShouldNotBeVisibleOutsideOfThisLexicalBlock) should be false
      ICheck Property cell?(:thisVariableShouldNotBeVisibleOutsideOfThisLexicalBlock) should be false
      prop            cell?(:thisVariableShouldNotBeVisibleOutsideOfThisLexicalBlock) should be false
    )

    it("takes zero or more generator arguments",
      ICheck forEvery(integer x,
        42 should == 42) check!

      ICheck forEvery(integer x, integer y,
        42 should == 42) check!

      ICheck forEvery(integer x, integer y, integer z,
        42 should == 42) check!
    )

    it("will add the generator argument names as arguments to the lexical block",
      ICheck forEvery(integer x,
        (x + x) should == (x*2)) check!

      ICheck forEvery(integer thisNameIsNotReallyVisibleOutsideEither,
        thisNameIsNotReallyVisibleOutsideEither should mimic(Number Rational)
        ) check!
      cell?(:thisNameIsNotReallyVisibleOutsideEither) should be false
    )

    it("will use a specific generator and call that to get values to the block",
      ICheck Generators basicSetOfCreatedValues = fnx([42, 55, 12, 42425, 7756] seq)
      allValuesGiven = []
      ICheck forEvery(basicSetOfCreatedValues blarg,
        allValuesGiven << blarg) check!(count: 5)
      allValuesGiven should == [42, 55, 12, 42425, 7756]
    )

    it("executes the generator statements in the lexical context mainly, and with generator macros added to it",
      ICheck Generators anotherSetOfCreatedValues = fnx(inp, Origin with(next: inp + 42))
      bladiBlaTest = 55
      ICheck forEvery(anotherSetOfCreatedValues(bladiBlaTest) x,
        x should == 97) check!(count: 1)
    )

    it("takes zero or more guard statements",
      ICheck forEvery(integer x, where x > 40,
        nil) check!(count: 1)
    )

    it("should allow a guard statement with keyword syntax too",
      ICheck forEvery(integer x, where: x > 40,
        nil) check!(count: 1)
    )

    it("will use the guards to reject the values that fails the guard",
      ICheck Generators testData = fnx((1..100) seq)
      allValuesGiven = []
      ICheck forEvery(testData x, where x > 40,
        allValuesGiven << x) check!(count: 60)
      allValuesGiven should == (41..100) asList
    )

    it("executes the guards in the lexical scope of where it was created",
      outsideVal = [] 
      ICheck forEvery(integer x, where . outsideVal << 42. true,
        true) check!(count: 2)
      outsideVal should == [42, 42]
    )

    it("takes zero or more classifiers with syntax 1",
      ICheck Generators testData = fnx((1..100) seq)
      result = ICheck forEvery(testData x,
        classify(one) x < 40,
        true) check!

      result classifier[:one] should == 39

      result = ICheck forEvery(testData x,
        classify(one) x < 40,
        classify(two) x > 30,
        true) check!

      result classifier[:one] should == 39
      result classifier[:two] should == 70
    )

    it("takes zero or more classifiers with syntax 2",
      ICheck Generators testData = fnx((1..100) seq)
      result = ICheck forEvery(testData x,
        classifyAs(one) x < 40,
        true) check!

      result classifier[:one] should == 39

      result = ICheck forEvery(testData x,
        classifyAs(one) x < 40,
        classifyAs(two) x > 30,
        true) check!

      result classifier[:one] should == 39
      result classifier[:two] should == 70
    )

    it("works when creating a new valid property and testing it",
      Ground testCount = 0
      prop = ICheck forEvery(
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
      prop = ICheck forEvery(
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

  describe("Property",
    it("should have tests")

    describe("check!",
      it("takes an optional amount of tests to run")
      it("runs a property a hundred times by default")
      it("takes a flag whether it should print verbosely or not")
      it("returns a data structure with results from the run")
    )
  )
  
  describe("Generators",
    it("should have tests")

    describe("int",
      it("returns a new generator when called",
        g1 = ICheck Generators int
        g1 should mimic(ICheck Generator)
        g1 should not be(ICheck Generator)
      )

      it("gives new number every time next is called, both negative and positive",
        g1 = ICheck Generators int
        atLeastOnePositive = false
        atLeastOneNegative = false
        50 times(
          x = g1 next
          y = g1 next
          if(x < 0 || y < 0,
            atLeastOneNegative = true,
            atLeastOnePositive = true)
          x should not == y
        )
      )

      it("gives new number every time next is called, both negative and positive, based on the size given")
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

    describe("\#{}",
      it("should have tests")
    )
  )
)
