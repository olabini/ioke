
use("ispec")

describe("Arity",
  
  it("should have the correct kind",
    Arity kind should == "Arity")

  it("should be obtained from a DefaultMacro arity", 
    a = macro(nil)
    cell(:a) arity should == Arity taking:everything
  )

  it("should be obtained from a DefaultSyntax arity", 
    a = syntax(nil)
    cell(:a) arity should == Arity taking:everything
  )

  it("should be obtained from a DefaultLecro arity", 
    a = lecro(nil)
    cell(:a) arity should == Arity taking:everything
  )

  it("should be obtained from a DefaultMethod arity", 
    a = method(nil)
    cell(:a) arity should == Arity taking:nothing
  )

  it("should be obtained from a DefaultMethod arity", 
    a = method(a, b, nil)
    cell(:a) arity required should == [:a, :b]
  )

  it("should be obtained from a LexicalBlock", 
    a = fn()
    cell(:a) arity should == Arity taking:nothing
  )

  it("should be obtained from a LexicalBlock", 
    a = fn(a, b, nil) 
    cell(:a) arity required should == [:a, :b]
  )

  describe("take:nothing", 
    it("should be the arity for empty argumentsCode", 
      Arity fromArgumentsCode("") should == Arity taking:nothing
    )
    
    it("should be an Arity",
      Arity taking:nothing should mimic(Arity)
    )

    it("should not equal taking:everything", 
      Arity taking:nothing should not == Arity taking:everything
    )

    it("should not equal Arity", 
      Arity taking:nothing should not == Arity
    )
  )
    
  describe("take:everything",
    it("should be the arity for ... argumentsCode", 
      Arity fromArgumentsCode("...") should == Arity taking:everything
    )

    it("should be an Arity", 
      Arity taking:everything should mimic(Arity)
    )

    it("should not equal taking:nothing", 
      Arity taking:everything should not == Arity taking:nothing
    )

    it("should not equal Arity",
      Arity taking:nothing should not == Arity
    )
  )

  describe("takeNothing?", 
    it("should be true for taking:nothing", 
      Arity taking:nothing should takeNothing
    )

    it("should be false for taking:everything", 
      Arity taking:everything should not takeNothing
    )

    it("should be false for arity taking arguments",
      Arity from(a) should not takeNothing
    )
  )

  describe("takeEverything?", 
    it("should be false for taking:nothing", 
      Arity taking:nothing should not takeEverything
    )

    it("should be true for taking:everything", 
      Arity taking:everything should takeEverything
    )

    it("should be false for arity taking arguments",
      Arity from(a) should not takeEverything
    )

    it("should be false for arity taking rest arguments",
      Arity from(+a, +:b) should not takeEverything
    )
  )

  describe("from",
    
    it("should return an empty arity if given no arguments",
      Arity from should == Arity taking:nothing
    )

    it("should return the arity for the given arguments definition",
      a = Arity from(a, b 0, c:, +rest, +:krest)
      a should mimic(Arity)
      a should not == Arity taking:nothing
      a should not == Arity taking:everything
    )
    
  )

  describe("fromArgumentsCode", 
    it("should return an empty arity if given nil", 
      Arity fromArgumentsCode(nil) should == Arity taking:nothing
    )

    it("should return an empty arity if given an empty text",
      Arity fromArgumentsCode("") should == Arity taking:nothing
    )
    
    it("should return taking:everything for ...",
      Arity fromArgumentsCode("...") should == Arity taking:everything
    )

    it("should return the arity for the given argumentsCode",
      a = Arity fromArgumentsCode("a, b 0, c:, +rest, +:krest")
      a should mimic(Arity)
      a should not == Arity
      a should not == Arity taking:nothing
      a should not == Arity taking:everything
    )

    it("should raise an error when given an invalid argumentsCode",
      fn(Arity fromArgumentsCode(")") should signal(Condition Error))
      fn(Arity fromArgumentsCode("=>") should signal(Condition Error))
    )
  )

  describe("asText",

    it("should return empty text for taking:nothing",
      Arity taking:nothing asText should == "")

    it("should return ... for taking:everything",
      Arity taking:everything asText should == "...")

    it("should return the argumentsCode for a simple arg", 
      Arity from(one) asText should == "one"
    )

    it("should return the argumentsCode for a simple keyword", 
      Arity from(two: 2) asText should == "two: 2"
    )

    it("should return the argumentsCode having rest arg", 
      Arity from(one, two: 2, +rest) asText should == "one, two: 2, +rest"
    )

    it("should return the argumentsCode having krest arg", 
      Arity from(one, two: 2, +rest, +:krest) asText should == "one, two: 2, +rest, +:krest"
    )

  )

  describe("positionals", 
    it("should return empty for taking:nothing", 
      Arity taking:nothing positionals should be empty
    )

    it("should return empty for taking:everything", 
      Arity taking:everything positionals should be empty
    )

    it("should return positional argument names including optionals by default", 
      Arity from(a, b, c 1, +d) positionals should == [:a, :b, :c]
    )

    it("should return positional argument names including optionals if given true", 
      Arity from(a, b, c 1, +d) positionals(true) should == [:a, :b, :c]
    )

    it("should return positional argument names excluding optionals if given false", 
      Arity from(a, b, c 1, +d) positionals(false) should == [:a, :b]
    )
  )

  describe("keywords", 
    it("should return empty for taking:nothing", 
      Arity taking:nothing keywords should be empty
    )

    it("should return empty for taking:everything", 
      Arity taking:everything keywords should be empty
    )

    it("should return keyword argument names", 
      Arity from(a:, b: c, +:d) keywords should == [:a, :b]
    )
  )

  describe("rest",
    it("should return nil for taking:nothing",
      Arity taking:nothing rest should be nil)

    it("should return nil for taking:everything",
      Arity taking:everything rest should be nil)

    it("should return nil when not rest argument is present",
      Arity from(foo) rest should be nil
    )

    it("should return the symbol name for the rest argument",
      Arity from(foo, +bar) rest should == :bar
    )
  )

  describe("krest",
    it("should return nil for taking:nothing",
      Arity taking:nothing krest should be nil)

    it("should return nil for taking:everything",
      Arity taking:everything krest should be nil)

    it("should return nil when not krest argument is present",
      Arity from(foo) krest should be nil
    )

    it("should return the symbol name for the krest argument",
      Arity from(foo, +:bar) krest should == :bar
    )
    
  )
  
  describe("required",
    it("should return empty for taking:nothing", 
      Arity taking:nothing required should be empty
    )
    
    it("should return empty for taking:everything", 
      Arity taking:everything required should be empty
    )
    
    it("should return required positional names", 
      Arity from(a, b, c 1, +d) required should == [:a, :b]
    )
  )
  
  describe("min", 
    it("should be 0 for taking:nothing", 
      Arity taking:nothing min should == 0
    )
    
    it("should be 0 for taking:everything", 
      Arity taking:everything min should == 0
    )
    
    it("should return minimum number of required arguments", 
      Arity from(a, b, c 1, +d) min should == 2
    )
  )

  describe("max", 
    it("should be 0 for taking:nothing", 
      Arity taking:nothing max should == 0
    )
    
    it("should be -1 for taking:everything", 
      Arity taking:everything max should == -1
    )
    
    it("should return max number of required arguments", 
      Arity from(a, b) max should == 2
    )

    it("should return max number of required arguments including optionals", 
      Arity from(a, b, c 1) max should == 3
    )

    it("should return max number of required arguments including rest", 
      Arity from(a, b, c 1, +d) max should == -4
    )

    it("should return negative when rest present", 
      Arity from(+d) max should == -1
    )
  )

  describe("takeKeyword?", 
    it("should be false for taking:nothing", 
      Arity taking:nothing takeKeyword?(:foo) should be false
    )

    it("should be false for taking:everything", 
      Arity taking:nothing takeKeyword?(:foo) should be false
    )

    it("should be false for arity having no keywords", 
      Arity from(a, b 2) takeKeyword?(:foo) should be false
    )

    it("should be true for arity having the keyword", 
      Arity from(a, b 2, foo:) takeKeyword?(:foo) should be true
    )

    it("should be false for arity missing the keyword", 
      Arity from(a, b 2, bar:) takeKeyword?(:foo) should be false
    )

    it("should be false for arity taking krest", 
      Arity from(a, b 2, +:bar) takeKeyword?(:foo) should be true
    )
  )

  describe("arguments",

    it("should not signal errors by default, but just collect argument info",
      a = Arity from(n) arguments('(foo(*[1, 2])))
      a should mimic(Arity Arguments)
      a notSpreadable should not be empty
    )

    it("should signal error when given an splat argument and not evaluating",
      fn(
        Arity from(n) arguments('(foo(*[1, 2])), signalErrors: true)
      ) should signal(Condition Error Invocation NotSpreadable)
    )

    it("should evaluate arguments if given a context",
      o = Origin mimic do (m = method(22))
      a = Arity from(n) arguments('(foo(m)), context: o)
      a should mimic(Arity Arguments)
      a positional should == [22]
    )
    
  )

  describe("satisfied?", 
    it("should not evaluate by default",
      o = Origin mimic do (m = method(@evaled = true) )
      Arity from(n) satisfied?(nono) should be true
      o cell?(:evaled) should be false
    )
  )

  describe("satisfiedOn?", 
    it("should evaluate by default",
      o = Origin mimic do (m = method(@evaled = true) )
      Arity from(n) satisfiedOn?(o, m) should be true
      o cell?(:evaled) should be true
    )
  )

  describe("apply", 
    it("should not evaluate by default",
      o = Origin mimic do (m = method(@evaled = true) )
      a = Arity from(n) apply(m)
      a should mimic(Arity Arguments)
      o cell?(:evaled) should be false
      a order should == 0
    )
  )

  describe("applyOn", 
    it("should evaluate by default",
      o = Origin mimic do (m = method(@evaled = true) )
      a = Arity from(n) applyOn(o, m)
      a should mimic(Arity Arguments)
      o cell?(:evaled) should be true
      a order should == 0
    )
  )

  describe("Arguments", 
    describe("positional",
      it("should be empty for taking:nothing", 
          Arity taking:nothing applyOn(Origin mimic, 1) positional should be empty
        )

        it("should be empty for taking:everything", 
          Arity taking:everything applyOn(Origin mimic, 1) positional should be empty
        )

        it("should contain the positional arguments but not rest",
          a = Arity from(a, b 1, +c) applyOn(Origin mimic, 1, 2, 3)
          a positional should == [1, 2]
        )
        
        it("should be empty if no positional arguments given",
          a = Arity from(a 0, b 1, +c, +:krest) applyOn(Origin mimic, o: 1, p: 2)
          a positional should be empty
        )
      )

    describe("keywords",
      it("should be empty for taking:nothing", 
          Arity taking:nothing applyOn(Origin mimic, a: 1) keywords should be empty
        )

        it("should be empty for taking:everything", 
          Arity taking:everything applyOn(Origin mimic, a: 1) keywords should be empty
        )

        it("should contain the keyword arguments but not krest",
          a = Arity from(a:, b: 1, +:c) applyOn(Origin mimic, a: 1, d: 2, b: 3)
          a keywords size should == 2
          a keywords[:a] should == 1
          a keywords[:b] should == 3
        )
        
        it("should be empty if no keyword arguments given",
          a = Arity from(a 0, b 1, +c, +:krest) applyOn(Origin mimic, 2, 3)
          a keywords should be empty
        )
      )

      describe("rest",
        it("should be empty for taking:nothing", 
          Arity taking:nothing applyOn(Origin mimic, 1, 2) rest should be empty
        )

        it("should be include elements for taking:everything", 
          Arity taking:everything applyOn(Origin mimic, 1, 2) rest should == [1, 2]
        )

        it("should be empty if no rest argument defined",
          a = Arity from(a, d 2, b: 1, +:c) applyOn(Origin mimic, 1, 3, d: 2, b: 3)
          a rest should be empty
        )

        it("should contain the rest arguments if given",
          a = Arity from(a:, b: 1, +d, +:c) applyOn(Origin mimic, a: 1, d: 2, b: 3, 9)
          a rest should == [9]
        )
        
        it("should be empty if no rest arguments given",
          a = Arity from(a 0, b 1, +c) applyOn(Origin mimic, 2, 3)
          a rest should be empty
        )
      )

      describe("krest",
        it("should be empty for taking:nothing", 
          Arity taking:nothing applyOn(Origin mimic, 1, 2) krest should be empty
        )

        it("should be include elements for taking:everything", 
          a = Arity taking:everything applyOn(Origin mimic, a: 1, b: 2)
          a krest size should == 2
          a krest[:a] should == 1
          a krest[:b] should == 2
        )

        it("should be empty if no krest argument defined",
          a = Arity from(a, d 2, b: 1) applyOn(Origin mimic, 1, 3, b: 3)
          a krest should be empty
        )

        it("should contain the krest arguments if given",
          a = Arity from(a:, b: 1, +d, +:c) applyOn(Origin mimic, a: 1, d: 2, b: 3, 9)
          a krest size should == 1
          a krest[:d] should == 2
        )
        
        it("should be empty if no krest arguments given",
          a = Arity from(a 0, b 1, +c, +:k) applyOn(Origin mimic, 2, 3)
          a krest should be empty
        )
      )

      describe("extraPositional",
        it("should include values for taking:nothing", 
          a = Arity taking:nothing applyOn(Origin mimic, 1, 2) 
          a extraPositional should == [1, 2]
        )

        it("should be empty for taking:everything", 
          a = Arity taking:everything applyOn(Origin mimic, 1, 2)
          a extraPositional should be empty
        )

        it("should be empty if rest argument defined",
          a = Arity from(a, +d, b: 1) applyOn(Origin mimic, 1, 3, b: 3, 9, 3)
          a extraPositional should be empty
        )

        it("should contain the extra positional arguments if given",
          a = Arity from(a:, b: 1, +:c) applyOn(Origin mimic, a: 1, d: 2, b: 3, 9)
          a extraPositional should == [9]
        )
        
        it("should be empty if no extra positional arguments given",
          a = Arity from(a 0, b 1, +:k) applyOn(Origin mimic, 2, 3, f: 22)
          a extraPositional should be empty
        )
      )

      describe("extraKeywords",
        
        it("should include values for taking:nothing", 
          a = Arity taking:nothing applyOn(Origin mimic, a: 1, b: 2) 
          a extraKeywords size should == 2
          a extraKeywords[:a] should == 1
          a extraKeywords[:b] should == 2
        )

        it("should be empty for taking:everything", 
          a = Arity taking:everything applyOn(Origin mimic, a: 1, b: 2)
          a extraKeywords should be empty
        )

        it("should be empty if krest argument defined",
          a = Arity from(a, +:k, b: 1) applyOn(Origin mimic, 1, 3, b: 3, c: 9, a: 3)
          a extraKeywords should be empty
        )

        it("should contain the extra keyword arguments if given",
          a = Arity from(a:, b: 1, +c) applyOn(Origin mimic, a: 1, d: 2, b: 3, 9)
          a extraKeywords size should == 1
          a extraKeywords[:d] should == 2
        )
        
        it("should be empty if no extra keyword arguments given",
          a = Arity from(a 0, b 1, f: 1, +c) applyOn(Origin mimic, 2, 3, f: 22, 9, 9)
          a extraKeywords should be empty
        )
      )
      

      describe("missing",
        
        it("should be empty for taking:nothing", 
          a = Arity taking:nothing applyOn(Origin mimic, 1, b: 2) 
          a missing should be empty
        )

        it("should be empty for taking:everything", 
          a = Arity taking:everything applyOn(Origin mimic, 1, b: 2)
          a missing should be empty
        )

        it("should be empty if no required arguments are missing",
          a = Arity from(a, b) applyOn(Origin mimic, 1, 2)
          a missing should be empty
        )

        it("should include the names of required arguments that are missing",
          a = Arity from(a, b, c 2) applyOn(Origin mimic)
          a missing should == [:a, :b]
          a = Arity from(a, b, c 2) applyOn(Origin mimic, 1)
          a missing should == [:b]
        )
      )


      describe("order",

        it("should be zero for taking:nothing without args", 
          a = Arity taking:nothing applyOn(Origin mimic) 
          a order should == 0
        )
        
        it("should be positive for taking:nothing with args", 
          a = Arity taking:nothing applyOn(Origin mimic, 1, b: 2) 
          a order should == 2
        )

        it("should be zero for taking:everything without args", 
          a = Arity taking:everything applyOn(Origin mimic)
          a order should == 0
        )

        it("should be zero for taking:everything with args", 
          a = Arity taking:everything applyOn(Origin mimic, 1, b: 2)
          a order should == 0
        )

        it("should be negative for missing required arguments",
          a = Arity from(a, b) applyOn(Origin mimic)
          a order should == -2
        )

        it("should be positive for unexpected arguments",
          a = Arity from(a, b: 2) applyOn(Origin mimic,1,2,b: 3,4,5)
          a order should == 3
        )

      )
    
  )
)