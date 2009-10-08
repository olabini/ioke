
use("ispec")

describe(DefaultBehavior,
  describe("FlowControl",
    describe("let",
      it("should take a code argument, apply that on the current ground and return the result",
        let(40+2) should == 42
      )

      it("should establish a new lexical scope inside",
        let(non_existing_let_binding = 42)
        cell?(:non_existing_let_binding) should be false
      )

      it("should take zero or more name-value pairs",
        let(42)
        let(x, 42, x)
        let(
          x, 42,
          y, 43,
          x + y)
      )

      it("should bind a simple name to a value",
        let(probably_not_existing_name, 42,
          probably_not_existing_name*2) should == 84
      )

      it("should shadow an existing name",
        wow_this_is_a_test = 42
        let(wow_this_is_a_test, 43, wow_this_is_a_test) should == 43
        wow_this_is_a_test should == 42
      )

      it("should rebind a place specification during the time of the code running",
        Text fluxie = Origin mimic
        Text fluxie wowsie = 13
        let(
          Text fluxie wowsie, 14,
          "foo" fluxie wowsie) should == 14
        Text fluxie wowsie should == 13
      )

      it("should unbind places even if a non-local transfer happens",
        Text fluxie2 = Origin mimic
        Text fluxie2 wowsie = 13
        bind(rescue(Condition Error, fn(c, nil)),
          let(
            Text fluxie2 wowsie, 14,
            "foo" fluxie2 wowsie should == 14
            error!("non-local yay!")))
        Text fluxie2 wowsie should == 13
      )

      it("should bind a new place temporarily, and then remove it",
        X = Origin mimic
        let(X testOfLetMethod, method(42),
          X testOfLetMethod should == 42
        )
        X cellNames should not include(:testOfLetMethod)
      )

      it("should bind a new place with cell temporarily, and then remove it",
        X = Origin mimic
        let(X cell(:testOfLetMethod2), method(42),
          X testOfLetMethod2 should == 42
        )
        X cellNames should not include(:testOfLetMethod2)
      )
    )
  )
)

