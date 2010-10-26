
use("ispec")
use("icheck")

describe(ICheck,
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
        allValuesGiven << blarg) check!(maxSuccess: 5)
      allValuesGiven should == [42, 55, 12, 42425, 7756]
    )

    it("executes the generator statements in the lexical context mainly, and with generator macros added to it",
      ICheck Generators anotherSetOfCreatedValues = fnx(inp, Origin with(next: inp + 42))
      bladiBlaTest = 55
      ICheck forAll(anotherSetOfCreatedValues(bladiBlaTest) x,
        x should == 97) check!(maxSuccess: 1)
    )

    it("takes zero or more guard statements",
      ICheck forAll(integer x, where x > 2,
        nil) check!(maxSuccess: 1)
    )

    it("should allow a guard statement with keyword syntax too",
      ICheck forAll(integer x, where: x > 2,
        nil) check!(maxSuccess: 1)
    )

    it("will use the guards to reject the values that fails the guard",
      ICheck Generators testData = fnx((1..100) seq)
      allValuesGiven = []
      ICheck forAll(testData x, where x > 40,
        allValuesGiven << x) check!(maxSuccess: 60)
      allValuesGiven should == (41..100) asList
    )

    it("executes the guards in the lexical scope of where it was created",
      outsideVal = [] 
      ICheck forAll(integer x, where . outsideVal << 42. true,
        true) check!(maxSuccess: 2)
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

      prop check!(maxSuccess: 42)

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
        allValuesGiven << blarg) check!(maxSuccess: 5)
      allValuesGiven should == [42, 55, 12, 42425, 7756]
    )

    it("executes the generator statements in the lexical context mainly, and with generator macros added to it",
      ICheck Generators anotherSetOfCreatedValues = fnx(inp, Origin with(next: inp + 42))
      bladiBlaTest = 55
      ICheck forEvery(anotherSetOfCreatedValues(bladiBlaTest) x,
        x should == 97) check!(maxSuccess: 1)
    )

    it("takes zero or more guard statements",
      ICheck forEvery(integer x, where x > 40,
        nil) check!(maxSuccess: 1)
    )

    it("should allow a guard statement with keyword syntax too",
      ICheck forEvery(integer x, where: x > 40,
        nil) check!(maxSuccess: 1)
    )

    it("will use the guards to reject the values that fails the guard",
      ICheck Generators testData = fnx((1..100) seq)
      allValuesGiven = []
      ICheck forEvery(testData x, where x > 40,
        allValuesGiven << x) check!(maxSuccess: 60)
      allValuesGiven should == (41..100) asList
    )

    it("executes the guards in the lexical scope of where it was created",
      outsideVal = [] 
      ICheck forEvery(integer x, where . outsideVal << 42. true,
        true) check!(maxSuccess: 2)
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

      prop check!(maxSuccess: 42)

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
  
  describe("Generators",
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
        let(ICheck Property currentSize, 10,
          50 times(
            x = g1 next
            x should mimic(Number Integer)
            if(x < 0, atLeastOneNegative = true)
            if(x > 0, atLeastOnePositive = true)
        ))
        atLeastOneNegative should be true
        atLeastOnePositive should be true
      )
    )

    describe("integer",
      it("returns a new generator when called",
        g1 = ICheck Generators integer
        g1 should mimic(ICheck Generator)
        g1 should not be(ICheck Generator)
      )

      it("gives new number every time next is called, both negative and positive",
        g1 = ICheck Generators integer
        atLeastOnePositive = false
        atLeastOneNegative = false
        let(ICheck Property currentSize, 10,
          50 times(
            x = g1 next
            x should mimic(Number Integer)
            if(x < 0, atLeastOneNegative = true)
            if(x > 0, atLeastOnePositive = true)
        ))
        atLeastOneNegative should be true
        atLeastOnePositive should be true
      )
    )

    describe("decimal",
      it("returns a new generator when called",
        g1 = ICheck Generators decimal
        g1 should mimic(ICheck Generator)
        g1 should not be(ICheck Generator)
      )

      it("gives new decimal number every time next is called, both negative and positive",
        g1 = ICheck Generators decimal
        atLeastOnePositive = false
        atLeastOneNegative = false
        let(ICheck Property currentSize, 10,
          50 times(
            x = g1 next
            x should mimic(Number Decimal)
            if(x < 0, atLeastOneNegative = true)
            if(x > 0, atLeastOnePositive = true)
        ))
        atLeastOneNegative should be true
        atLeastOnePositive should be true
      )
    )

    describe("ratio",
      it("returns a new generator when called",
        g1 = ICheck Generators ratio
        g1 should mimic(ICheck Generator)
        g1 should not be(ICheck Generator)
      )

      it("gives new ratio every time next is called",
        g1 = ICheck Generators ratio
        atLeastOnePositive = false
        atLeastOneNegative = false
        let(ICheck Property currentSize, 10,
          50 times(
            x = g1 next
            x should mimic(Number Ratio)
            if(x < 0, atLeastOneNegative = true)
            if(x > 0, atLeastOnePositive = true)
        ))
        atLeastOneNegative should be true
        atLeastOnePositive should be true
      )
    )

    describe("rational",
      it("returns a new generator when called",
        g1 = ICheck Generators rational
        g1 should mimic(ICheck Generator)
        g1 should not be(ICheck Generator)
      )

      it("gives a ratio or an integer every time next is called",
        g1 = ICheck Generators rational
        atLeastOnePositive = false
        atLeastOneNegative = false
        atLeastOneRatio = false
        atLeastOneInteger = false
        let(ICheck Property currentSize, 10,
          50 times(
            x = g1 next
            x should mimic(Number Rational)
            if(x mimics?(Number Ratio), atLeastOneRatio = true)
            if(x mimics?(Number Integer), atLeastOneInteger = true)
            if(x < 0, atLeastOneNegative = true)
            if(x > 0, atLeastOnePositive = true)
        ))
        atLeastOneNegative should be true
        atLeastOnePositive should be true
        atLeastOneRatio should be true
        atLeastOneInteger should be true
      )
    )

    describe("nat",
      it("returns a new generator when called",
        g1 = ICheck Generators nat
        g1 should mimic(ICheck Generator)
        g1 should not be(ICheck Generator)
      )

      it("gives new natural number every time next is called",
        g1 = ICheck Generators nat
        let(ICheck Property currentSize, 10,
          50 times(
            x = g1 next
            x should be > -1
        ))
      )
    )

    describe("natural",
      it("returns a new generator when called",
        g1 = ICheck Generators natural
        g1 should mimic(ICheck Generator)
        g1 should not be(ICheck Generator)
      )

      it("gives new natural number every time next is called",
        g1 = ICheck Generators natural
        let(ICheck Property currentSize, 10,
          50 times(
            x = g1 next
            x should be > -1
        ))
      )
    )

    describe("bool",
      it("returns a new generator when called",
        g1 = ICheck Generators bool
        g1 should mimic(ICheck Generator)
        g1 should not be(ICheck Generator)
      )

      it("gives both false and true",
        g1 = ICheck Generators bool
        atLeastOneTrue = false
        atLeastOneFalse = false
        50 times(
          x = g1 next
          if(x == true, atLeastOneTrue = true)
          if(x == false, atLeastOneFalse = true))
        atLeastOneTrue should be true
        atLeastOneFalse should be true
      )
    )

    describe("boolean",
      it("returns a new generator when called",
        g1 = ICheck Generators boolean
        g1 should mimic(ICheck Generator)
        g1 should not be(ICheck Generator)
      )

      it("gives both false and true",
        g1 = ICheck Generators boolean
        atLeastOneTrue = false
        atLeastOneFalse = false
        50 times(
          x = g1 next
          if(x == true, atLeastOneTrue = true)
          if(x == false, atLeastOneFalse = true))
        atLeastOneTrue should be true
        atLeastOneFalse should be true
      )
    )

    describe("kleene",
      it("returns a new generator when called",
        g1 = ICheck Generators kleene
        g1 should mimic(ICheck Generator)
        g1 should not be(ICheck Generator)
      )

      it("gives both true, false and nil",
        g1 = ICheck Generators kleene
        atLeastOneTrue = false
        atLeastOneNil = false
        atLeastOneFalse = false
        50 times(
          x = g1 next
          if(x == true, atLeastOneTrue = true)
          if(x == false, atLeastOneFalse = true)
          if(x == nil, atLeastOneNil = true))
        atLeastOneTrue should be true
        atLeastOneNil should be true
        atLeastOneFalse should be true
      )
    )

    describe("kleenean",
      it("returns a new generator when called",
        g1 = ICheck Generators kleenean
        g1 should mimic(ICheck Generator)
        g1 should not be(ICheck Generator)
      )

      it("gives both true, false and nil",
        g1 = ICheck Generators kleenean
        atLeastOneTrue = false
        atLeastOneNil = false
        atLeastOneFalse = false
        50 times(
          x = g1 next
          if(x == true, atLeastOneTrue = true)
          if(x == false, atLeastOneFalse = true)
          if(x == nil, atLeastOneNil = true))
        atLeastOneTrue should be true
        atLeastOneNil should be true
        atLeastOneFalse should be true
      )
    )

    describe("oneOf",
      it("returns a new generator when called",
        g1 = ICheck Generators oneOf("one", "two")
        g1 should mimic(ICheck Generator)
        g1 should not be(ICheck Generator)
      )

      it("returns all of the different values",
        g1 = ICheck Generators oneOf("one", "two", "three")
        got = #{}
        50 times(got << g1 next)
        got should == #{"one", "two", "three"}
      )

      it("can take generators as well as constant values",
        g1 = ICheck Generators oneOf(ICheck Generators boolean, "one", "two", "three", ICheck Generators oneOf(4, 5))
        got = #{}
        50 times(got << g1 next)
        got should == #{"one", "two", "three", true, false, 4, 5}
      )
    )

    describe("oneOfFrequency",
      it("should have tests")
    )

    describe("range",
      it("returns a new generator when called",
        g1 = ICheck Generators range("one", "two")
        g1 should mimic(ICheck Generator)
        g1 should not be(ICheck Generator)
      )

      it("generates a range with the values given",
        g1 = ICheck Generators range("foo", "bar")
        let(ICheck Property currentSize, 10,
          50 times(
            g1 next should == ("foo".."bar")
          )
        )
      )

      it("generates a range based on generators",
        g1 = ICheck Generators range(ICheck Generators oneOf("foo", "bax"), ICheck Generators oneOf("barg", "mux"))
        starts = #{}
        ends = #{}

        let(ICheck Property currentSize, 10,
          50 times(
            g1 next tap(x, 
              starts << x from
              ends << x to
        )))

        starts should == #{"foo", "bax"}
        ends should == #{"barg", "mux"}
      )
    )

    describe("xrange",
      it("returns a new generator when called",
        g1 = ICheck Generators xrange("one", "two")
        g1 should mimic(ICheck Generator)
        g1 should not be(ICheck Generator)
      )

      it("generates a range with the values given",
        g1 = ICheck Generators xrange("foo", "bar")
        let(ICheck Property currentSize, 10,
          50 times(
            g1 next should == ("foo"..."bar")
          )
        )
      )

      it("generates a range based on generators",
        g1 = ICheck Generators xrange(ICheck Generators oneOf("foo", "bax"), ICheck Generators oneOf("barg", "mux"))
        starts = #{}
        ends = #{}

        let(ICheck Property currentSize, 10,
          50 times(
            g1 next tap(x, 
              starts << x from
              ends << x to
        )))

        starts should == #{"foo", "bax"}
        ends should == #{"barg", "mux"}
      )
    )

    describe("=>",
      it("returns a new generator when called",
        g1 = ICheck Generators =>("one", "two")
        g1 should mimic(ICheck Generator)
        g1 should not be(ICheck Generator)
      )

      it("generates a pair with the values given",
        g1 = ICheck Generators =>("foo", "bar")
        let(ICheck Property currentSize, 10,
          50 times(
            g1 next should == ("foo" => "bar")
          )
        )
      )

      it("generates a pair based on generators",
        g1 = ICheck Generators =>(ICheck Generators oneOf("foo", "bax"), ICheck Generators oneOf("barg", "mux"))
        starts = #{}
        ends = #{}

        let(ICheck Property currentSize, 10,
          50 times(
            g1 next tap(x, 
              starts << x key
              ends << x value
        )))

        starts should == #{"foo", "bax"}
        ends should == #{"barg", "mux"}
      )
    )

    describe("list",
      it("returns a new generator when called",
        g1 = ICheck Generators list("one")
        g1 should mimic(ICheck Generator)
        g1 should not be(ICheck Generator)
      )

      it("generates a list with the value given of varying size",
        g1 = ICheck Generators list("foo")
        lens = #{}
        let(ICheck Property currentSize, 10,
          50 times(
            val = g1 next
            val each(should == "foo")
            lens << val length
          )
        )
        lens asList length should be > 1
      )

      it("generates a list based on another generator",
        g1 = ICheck Generators list(ICheck Generators oneOf("foo", "bax"))
        results = #{}

        let(ICheck Property currentSize, 10,
          50 times(
            g1 next each(x, results << x)
          )
        )

        results should == #{"foo", "bax"}
      )
    )

    describe("set",
      it("returns a new generator when called",
        g1 = ICheck Generators set("one")
        g1 should mimic(ICheck Generator)
        g1 should not be(ICheck Generator)
      )

      it("generates a set with the value given of varying size",
        g1 = ICheck Generators set("foo")
        let(ICheck Property currentSize, 10,
          50 times(
            g1 next each(should == "foo")
          )
        )
      )

      it("generates a set based on another generator",
        g1 = ICheck Generators set(ICheck Generators oneOf("foo", "bax"))
        results = #{}

        let(ICheck Property currentSize, 10,
          50 times(
            g1 next each(x, results << x)
          )
        )

        results should == #{"foo", "bax"}
      )
    )

    describe("dict",
      it("returns a new generator when called",
        g1 = ICheck Generators dict("foo")
        g1 should mimic(ICheck Generator)
        g1 should not be(ICheck Generator)
      )

      it("generates a dictionary with the given key as value",
        g1 = ICheck Generators dict("blarg")
        let(ICheck Property currentSize, 10,
          50 times(
            x = g1 next
            unless(x empty?,
              x should == {"blarg" => nil})
        ))
      )

      it("generates a dictionary with only the given pair",
        g1 = ICheck Generators dict("mux" => 42)
        let(ICheck Property currentSize, 10,
          50 times(
            x = g1 next
            unless(x empty?,
              x should == {"mux" => 42})
        ))
      )

      it("generates a dictionary with the given key generator",
        g1 = ICheck Generators dict(ICheck Generators oneOf("foo", "bar", "qux"))
        keys = #{}
        let(ICheck Property currentSize, 10,
          50 times(
            g1 next keys each(x, keys << x)
        ))
        keys should == #{"foo", "bar", "qux"}
      )

      it("generates a dictionary with the pair with key generator",
        g1 = ICheck Generators dict(ICheck Generators oneOf("foo", "bar", "qux") => 42)
        keys = #{}
        let(ICheck Property currentSize, 10,
          50 times(
            g1 next keys each(x, keys << x)
        ))
        keys should == #{"foo", "bar", "qux"}
      )

      it("generates a dictionary with the pair with value generator",
        g1 = ICheck Generators dict(42 => ICheck Generators oneOf("foo", "bar", "qux") )
        values = #{}
        let(ICheck Property currentSize, 10,
          50 times(
            x = g1 next
            unless(x empty?,
              values << x[42])
        ))
        values should == #{"foo", "bar", "qux"}
      )

      it("generates a dictionary with the pair with key and value generator",
        g1 = ICheck Generators dict(ICheck Generators oneOf("foo", "bar", "qux") => ICheck Generators oneOf("mi", "ma", "mo"))
        keys = #{}
        values = #{}
        let(ICheck Property currentSize, 10,
          50 times(
            g1 next each(vv, 
              keys << vv key
              values << vv value)
        ))
        keys should == #{"foo", "bar", "qux"}
        values should == #{"mi", "ma", "mo"}
      )

      it("generates a dictionary with entries from any of the given arguments",
        g1 = ICheck Generators dict(ICheck Generators oneOf("foo", "bar", "qux") => ICheck Generators oneOf("mi", "ma", "mo"), ICheck Generators oneOf("00x", "00y", "00z") => ICheck Generators oneOf("ba", "qa", "gra"))
        keys = #{}
        values = #{}
        keys2 = #{}
        values2 = #{}
        let(ICheck Property currentSize, 10,
          100 times(
            g1 next each(vv, 
              if(vv key[0..1] == "00",
                keys2 << vv key
                values2 << vv value,
                keys << vv key
                values << vv value))
        ))
        keys should == #{"foo", "bar", "qux"}
        values should == #{"mi", "ma", "mo"}
        keys2 should == #{"00x", "00y", "00z"}
        values2 should == #{"ba", "qa", "gra"}
      )
    )

    describe("text",
      it("returns a new generator when called",
        g1 = ICheck Generators text
        g1 should mimic(ICheck Generator)
        g1 should not be(ICheck Generator)
      )

      it("generates a text with varying sizes",
        g1 = ICheck Generators text
        lens = #{}
        let(ICheck Property currentSize, 10,
          50 times(
            lens << g1 next length
          )
        )
        lens asList length should be > 2
      )

      it("generates a text with varying characters",
        g1 = ICheck Generators text
        chars = #{}
        let(ICheck Property currentSize, 10,
          50 times(
            g1 next chars each(x, chars << x)
          )
        )
        chars asList length should be > 25
      )
    )

    describe("()",
      it("should have tests")
    )

    describe("[]",
      it("returns a new generator when called",
        g1 = ICheck Generators["one"]
        g1 should mimic(ICheck Generator)
        g1 should not be(ICheck Generator)
      )

      it("generates a list with the value given of varying size",
        g1 = ICheck Generators["foo"]
        lens = #{}
        let(ICheck Property currentSize, 10,
          50 times(
            val = g1 next
            val each(should == "foo")
            lens << val length
          )
        )
        lens asList length should be > 1
      )

      it("generates a list based on another generator",
        g1 = ICheck Generators[ICheck Generators oneOf("foo", "bax")]
        results = #{}

        let(ICheck Property currentSize, 10,
          50 times(
            g1 next each(x, results << x)
          )
        )

        results should == #{"foo", "bax"}
      )
    )

    describe("{}",
      it("returns a new generator when called",
        g1 = ICheck Generators {"foo"}
        g1 should mimic(ICheck Generator)
        g1 should not be(ICheck Generator)
      )

      it("generates a dictionary with the given key as value",
        g1 = ICheck Generators {"blarg"}
        let(ICheck Property currentSize, 10,
          50 times(
            x = g1 next
            unless(x empty?,
              x should == {"blarg" => nil})
        ))
      )

      it("generates a dictionary with only the given pair",
        g1 = ICheck Generators {"mux" => 42}
        let(ICheck Property currentSize, 10,
          50 times(
            x = g1 next
            unless(x empty?,
              x should == {"mux" => 42})
        ))
      )

      it("generates a dictionary with the given key generator",
        g1 = ICheck Generators {ICheck Generators oneOf("foo", "bar", "qux")}
        keys = #{}
        let(ICheck Property currentSize, 10,
          50 times(
            g1 next keys each(x, keys << x)
        ))
        keys should == #{"foo", "bar", "qux"}
      )

      it("generates a dictionary with the pair with key generator",
        g1 = ICheck Generators {ICheck Generators oneOf("foo", "bar", "qux") => 42}
        keys = #{}
        let(ICheck Property currentSize, 10,
          50 times(
            g1 next keys each(x, keys << x)
        ))
        keys should == #{"foo", "bar", "qux"}
      )

      it("generates a dictionary with the pair with value generator",
        g1 = ICheck Generators {42 => ICheck Generators oneOf("foo", "bar", "qux")}
        values = #{}
        let(ICheck Property currentSize, 10,
          50 times(
            x = g1 next
            unless(x empty?,
              values << x[42])
        ))
        values should == #{"foo", "bar", "qux"}
      )

      it("generates a dictionary with the pair with key and value generator",
        g1 = ICheck Generators {ICheck Generators oneOf("foo", "bar", "qux") => ICheck Generators oneOf("mi", "ma", "mo")}
        keys = #{}
        values = #{}
        let(ICheck Property currentSize, 10,
          50 times(
            g1 next each(vv, 
              keys << vv key
              values << vv value)
        ))
        keys should == #{"foo", "bar", "qux"}
        values should == #{"mi", "ma", "mo"}
      )

      it("generates a dictionary with entries from any of the given arguments",
        g1 = ICheck Generators {ICheck Generators oneOf("foo", "bar", "qux") => ICheck Generators oneOf("mi", "ma", "mo"), ICheck Generators oneOf("00x", "00y", "00z") => ICheck Generators oneOf("ba", "qa", "gra")}
        keys = #{}
        values = #{}
        keys2 = #{}
        values2 = #{}
        let(ICheck Property currentSize, 10,
          100 times(
            g1 next each(vv, 
              if(vv key[0..1] == "00",
                keys2 << vv key
                values2 << vv value,
                keys << vv key
                values << vv value))
        ))
        keys should == #{"foo", "bar", "qux"}
        values should == #{"mi", "ma", "mo"}
        keys2 should == #{"00x", "00y", "00z"}
        values2 should == #{"ba", "qa", "gra"}
      )
    )

    describe("\#{}",
      it("returns a new generator when called",
        g1 = ICheck Generators set("one")
        g1 should mimic(ICheck Generator)
        g1 should not be(ICheck Generator)
      )

      it("generates a set with the value given of varying size",
        g1 = ICheck Generators #{"foo"}
        let(ICheck Property currentSize, 10,
          50 times(
            g1 next each(should == "foo")
          )
        )
      )

      it("generates a set based on another generator",
        g1 = ICheck Generators #{ICheck Generators oneOf("foo", "bax")}
        results = #{}

        let(ICheck Property currentSize, 10,
          50 times(
            g1 next each(x, results << x)
          )
        )

        results should == #{"foo", "bax"}
      )
    )
  )
)
