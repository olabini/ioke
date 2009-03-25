
use("ispec")

describe(DefaultBehavior,
  describe("Aspects",
    describe("before",
      it("should return an Aspect Pointcut",
        Origin mimic before(:foo) should have kind("DefaultBehavior Aspects Pointcut")
      )

      describe("with one cell name",
        it("should execute a block before a cell is accessed in any way",
          x = Origin mimic do(
            foo1 = 42)
          accesses = []
          x before(:foo1) << fn(accesses << :accessed)
          x foo1 should == 42
          x foo1 should == 42
          accesses should == [:accessed, :accessed]
        )

        it("should execute a method before a cell is accessed in any way",
          x = Origin mimic do(
            foo2 = 42)
          Ground accesses = []
          x before(:foo2) << method(accesses << :accessed)
          x foo2 should == 42
          x foo2 should == 42
          accesses should == [:accessed, :accessed]
        )

        it("should give the same arguments as was given to the original call",
          x = Origin mimic do(
            foo3 = method(+args, args))
          Ground accesses = []
          x before(:foo3) << method(+args, accesses << [:method, args])
          x before(:foo3) << fn(a, b, +args, accesses << [:fn, a, b, args])
          x foo3(1,2) should == [1,2]
          x foo3(53, 43, 6613, 4353) should == [53, 43, 6613, 4353]
          accesses should == [[:fn, 1, 2, []], [:method, [1,2]], [:fn, 53, 43, [6613, 4353]], [:method, [53, 43, 6613, 4353]]]
        )

        it("should supply a 'call' to macros that specify the original call, including name, for a cell get",
          x = Origin mimic do(
            foo4 = 42)
          Ground accesses = []
          x before(:foo4) << macro(accesses << call message name)
          x foo4 should == 42
          x foo4 should == 42
          accesses should == [:foo4, :foo4]
        )

        it("should supply a 'call' to macros that specify the original call, including name, for a method call",
          x = Origin mimic do(
            foox = method(a, a+42))
          Ground accesses = []
          x before(:foox) << macro(accesses << call message name)
          x foox(32) should == 74
          x foox(1) should == 43
          accesses should == [:foox, :foox]
        )

        it("should be possible to signal a condition from inside the before method",
          x = Origin mimic do(
            foo5 = method(42))
          accesses = []
          x before(:foo5) << fn(accesses << :one)
          x before(:foo5) << fn(accesses << :two)
          x before(:foo5) << fn(accesses << :three)
          x before(:foo5) << fn(accesses << :four. error!("this doesn't work..."))
          x before(:foo5) << fn(accesses << :five)
          x before(:foo5) << fn(accesses << :six)
          fn(x foo5) should signal(Condition Error Default)
          accesses should == [:six, :five, :four]
          
        )

        it("should be possible to specify for a cell that doesn't exist",
          x = Origin mimic
          accesses = []
          x before(:unexisting_aspect_before_cell) << fn(accesses << :wow)
          bind(rescue(Condition Error NoSuchCell, fn(c, nil)),
            x unexisting_aspect_before_cell)
          accesses should == [:wow]
        )

        it("should still raise a nosuchcell after the before advice have run for a non-existing cell",
          x = Origin mimic
          x before(:unexisting_aspect_before_cell) << fn(nil)
          fn(x unexisting_aspect_before_cell) should signal(Condition Error NoSuchCell)
        )

        it("should set the self of a method to the same self as the receiver",
          x = Origin mimic do(
            foo6 = method(42))
          Ground accesses = []
          x before(:foo6) << method(accesses << self)
          x before(:foo6) << macro(accesses << self)
          x foo6
          accesses[0] should be same(x)
          accesses[1] should be same(x)
        )

        it("should only evaluate arguments once",
          x = Origin mimic do(
            foo7 = method(arg, 42))
          Ground accesses = []
          x before(:foo7) << method(arg, accesses << [:method, arg])
          x before(:foo7) << macro(accesses << [:macro, call arguments[0] code])
          x before(:foo7) << fn(arg, accesses << [:fn, arg])
          x foo7(accesses << :arg_evaled. 42 + 14)
          accesses should == [:arg_evaled, [:fn, 56], [:macro, "accesses <<(:arg_evaled) .\n42 +(14)"], [:method, 56]]
        )

        it("should evaluate advice in inverse order",
          x = Origin mimic do(
            foo8 = method(42))
          accesses = []
          x before(:foo8) << fn(accesses << :one)
          x before(:foo8) << fn(accesses << :two)
          x before(:foo8) << fn(accesses << :three)
          x foo8
          accesses should == [:three, :two, :one]
        )

        it("should retain the original documentation",
          x = Origin mimic do(
            foo9 = method("Does something very interesting", 42))
          x before(:foo9) << fn("blarg", 42)
          x cell(:foo9) documentation should == "Does something very interesting"
        )
      )

      describe("with more than one cell name",
        it("should add the advice to both the cells",
          x = Origin mimic do(
            foo10 = 42
            bar10 = 62
          )
          Ground accesses = []
          x before(:foo10, :bar10) << macro(accesses << call message name)
          x foo10
          x bar10
          x foo10
          accesses should == [:foo10, :bar10, :foo10]
        )
      )

      describe("with matching: keyword",
        it("should take :any and add it to all existing cells for that object and mimics, up to Origin",
          X = Origin mimic
          Y = X mimic
          Y foo11 = 42
          X bar11 = 13
          y = Y mimic
          Origin mucus11 = 777
          Ground accesses = []
          y before(matching: :any) << macro(accesses << call message name)
          y foo11
          y bar11
          y mucus11
          accesses should == [:foo11, :bar11, :mucus11]
        )

        it("should take :anyFromSelf and add it to all existing cells for that object only",
          X = Origin mimic
          Y = X mimic
          Y foo12 = 42
          X bar12 = 13
          y = Y mimic
          y quux12 = 555
          Ground accesses = []
          y before(matching: :anyFromSelf) << macro(accesses << call message name)
          y foo12
          y bar12
          y quux12
          accesses should == [:quux12]
        )

        it("should take a regular expression and use that to choose which cells to handle",
          X = Origin mimic
          x = X mimic
          X match_aspect_abc13 = 555
          X mutch_aspect_abc13 = 555
          X match_aspect_aaa13 = 5345
          x match_aspect_hmm13 = 1111

          Ground accesses = []
          x before(matching: #/match_aspect_/) << macro(accesses << call message name)
          x match_aspect_abc13
          x mutch_aspect_abc13
          x match_aspect_aaa13
          x match_aspect_hmm13
          accesses should == [:match_aspect_abc13, :match_aspect_aaa13, :match_aspect_hmm13]
        )

        it("should take a block and use that to choose which cells to handle",
          X = Origin mimic
          x = X mimic
          X match_aspect_abc14 = 555
          X mutch_aspect_abc14 = 555
          X match_aspect_aaa14 = 5345
          x match_aspect_hmm14 = 1111

          Ground accesses = []
          x before(matching: fn(arg, #/match_aspect_/ =~ arg)) << macro(accesses << call message name)
          x match_aspect_abc14
          x mutch_aspect_abc14
          x match_aspect_aaa14
          x match_aspect_hmm14
          accesses should == [:match_aspect_abc14, :match_aspect_aaa14, :match_aspect_hmm14]
        )

        it("should take a list of specifiers to use for matching",
          X = Origin mimic
          x = X mimic
          X match_aspect_abc15 = 555
          X mutch_aspect_abc15 = 555
          X match_aspect_aaa15 = 5345
          x match_aspect_hmm15 = 1111
          x blarg_aspect_hmm15 = 1111

          Ground accesses = []
          x before(matching: [#/match_aspect_/, #/blarg_/]) << macro(accesses << call message name)
          x match_aspect_abc15
          x mutch_aspect_abc15
          x match_aspect_aaa15
          x match_aspect_hmm15
          x blarg_aspect_hmm15
          accesses should == [:match_aspect_abc15, :match_aspect_aaa15, :match_aspect_hmm15, :blarg_aspect_hmm15]
        )
      )

      describe("with except: keyword",
        it("should take a name to not include",
          X = Origin mimic
          Y = X mimic
          Y foo16 = 42
          X bar16 = 13
          y = Y mimic
          y quux16 = 555
          Ground accesses = []
          y before(matching: :any, except: :bar16) << macro(accesses << call message name)
          y foo16
          y bar16
          y quux16
          accesses should == [:foo16, :quux16]
        )

        it("should take a list of names to not include",
          X = Origin mimic
          Y = X mimic
          Y foo17 = 42
          X bar17 = 13
          y = Y mimic
          y quux17 = 555
          Ground accesses = []
          y before(matching: :any, except: [:bar17, :quux17]) << macro(accesses << call message name)
          y foo17
          y bar17
          y quux17
          accesses should == [:foo17]
        )
        
        it("should take a regular expression",
          X = Origin mimic
          Y = X mimic
          Y foo18 = 42
          X bar18 = 13
          y = Y mimic
          y quux18 = 555
          Ground accesses = []
          y before(matching: :any, except: #/bar18/) << macro(accesses << call message name)
          y foo18
          y bar18
          y quux18
          accesses should == [:foo18, :quux18]
        )

        it("should take a block",
          X = Origin mimic
          Y = X mimic
          Y foo19 = 42
          X bar19 = 13
          y = Y mimic
          y quux19 = 555
          Ground accesses = []
          y before(matching: :any, except: fn(c, #/bar19/ =~ c)) << macro(accesses << call message name)
          y foo19
          y bar19
          y quux19
          accesses should == [:foo19, :quux19]
        )

        it("should take a list of specifiers",
          X = Origin mimic
          Y = X mimic
          Y foo20 = 42
          X bar20 = 13
          y = Y mimic
          y quux20 = 555
          Ground accesses = []
          y before(matching: :any, except: [#/bar20/, #/foo20/]) << macro(accesses << call message name)
          y foo20
          y bar20
          y quux20
          accesses should == [:quux20]
        )
      )

      describe("adding named advice",
        describe("with one cell name",
          it("should execute a block before a cell is accessed in any way",
            x = Origin mimic do(
              foo1 = 42)
            accesses = []
            x before(:foo1) add(:floxie, fn(accesses << :accessed))
            x foo1 should == 42
            x foo1 should == 42
            accesses should == [:accessed, :accessed]
          )

          it("should execute a method before a cell is accessed in any way",
            x = Origin mimic do(
              foo2 = 42)
            Ground accesses = []
            x before(:foo2) add(:floxie, method(accesses << :accessed))
            x foo2 should == 42
            x foo2 should == 42
            accesses should == [:accessed, :accessed]
          )

          it("should give the same arguments as was given to the original call",
            x = Origin mimic do(
              foo3 = method(+args, args))
            Ground accesses = []
            x before(:foo3) add(:floxie, method(+args, accesses << [:method, args]))
            x before(:foo3) add(:floxie, fn(a, b, +args, accesses << [:fn, a, b, args]))
            x foo3(1,2) should == [1,2]
            x foo3(53, 43, 6613, 4353) should == [53, 43, 6613, 4353]
            accesses should == [[:fn, 1, 2, []], [:method, [1,2]], [:fn, 53, 43, [6613, 4353]], [:method, [53, 43, 6613, 4353]]]
          )

          it("should supply a 'call' to macros that specify the original call, including name, for a cell get",
            x = Origin mimic do(
              foo4 = 42)
            Ground accesses = []
            x before(:foo4) add(:floxie, macro(accesses << call message name))
            x foo4 should == 42
            x foo4 should == 42
            accesses should == [:foo4, :foo4]
          )

          it("should supply a 'call' to macros that specify the original call, including name, for a method call",
            x = Origin mimic do(
              foox = method(a, a+42))
            Ground accesses = []
            x before(:foox) add(:floxie, macro(accesses << call message name))
            x foox(32) should == 74
            x foox(1) should == 43
            accesses should == [:foox, :foox]
          )

          it("should be possible to signal a condition from inside the before method",
            x = Origin mimic do(
              foo5 = method(42))
            accesses = []
            x before(:foo5) add(:floxie, fn(accesses << :one))
            x before(:foo5) add(:floxie, fn(accesses << :two))
            x before(:foo5) add(:floxie, fn(accesses << :three))
            x before(:foo5) add(:floxie, fn(accesses << :four. error!("this doesn't work...")))
            x before(:foo5) add(:floxie, fn(accesses << :five))
            x before(:foo5) add(:floxie, fn(accesses << :six))
            fn(x foo5) should signal(Condition Error Default)
            accesses should == [:six, :five, :four]
            
          )

          it("should be possible to specify for a cell that doesn't exist",
            x = Origin mimic
            accesses = []
            x before(:unexisting_aspect_before_cell) add(:floxie, fn(accesses << :wow))
            bind(rescue(Condition Error NoSuchCell, fn(c, nil)),
              x unexisting_aspect_before_cell)
            accesses should == [:wow]
          )

          it("should still raise a nosuchcell after the before advice have run for a non-existing cell",
            x = Origin mimic
            x before(:unexisting_aspect_before_cell) add(:floxie, fn(nil))
            fn(x unexisting_aspect_before_cell) should signal(Condition Error NoSuchCell)
          )

          it("should set the self of a method to the same self as the receiver",
            x = Origin mimic do(
              foo6 = method(42))
            Ground accesses = []
            x before(:foo6) add(:floxie, method(accesses << self))
            x before(:foo6) add(:floxie, macro(accesses << self))
            x foo6
            accesses[0] should be same(x)
            accesses[1] should be same(x)
          )

          it("should only evaluate arguments once",
            x = Origin mimic do(
              foo7 = method(arg, 42))
            Ground accesses = []
            x before(:foo7) add(:floxie, method(arg, accesses << [:method, arg]))
            x before(:foo7) add(:floxie, macro(accesses << [:macro, call arguments[0] code]))
            x before(:foo7) add(:floxie, fn(arg, accesses << [:fn, arg]))
            x foo7(accesses << :arg_evaled. 42 + 14)
            accesses should == [:arg_evaled, [:fn, 56], [:macro, "accesses <<(:arg_evaled) .\n42 +(14)"], [:method, 56]]
          )

          it("should evaluate advice in inverse order",
            x = Origin mimic do(
              foo8 = method(42))
            accesses = []
            x before(:foo8) add(:floxie, fn(accesses << :one))
            x before(:foo8) add(:floxie, fn(accesses << :two))
            x before(:foo8) add(:floxie, fn(accesses << :three))
            x foo8
            accesses should == [:three, :two, :one]
          )

          it("should retain the original documentation",
            x = Origin mimic do(
              foo9 = method("Does something very interesting", 42))
            x before(:foo9) add(:floxie, fn("blarg", 42))
            x cell(:foo9) documentation should == "Does something very interesting"
          )
        )

        describe("with more than one cell name",
          it("should add the advice to both the cells",
            x = Origin mimic do(
              foo10 = 42
              bar10 = 62
            )
            Ground accesses = []
            x before(:foo10, :bar10) add(:floxie, macro(accesses << call message name))
            x foo10
            x bar10
            x foo10
            accesses should == [:foo10, :bar10, :foo10]
          )
        )

        describe("with matching: keyword",
          it("should take :any and add it to all existing cells for that object and mimics, up to Origin",
            X = Origin mimic
            Y = X mimic
            Y foo11 = 42
            X bar11 = 13
            y = Y mimic
            Origin mucus11 = 777
            Ground accesses = []
            y before(matching: :any) add(:floxie, macro(accesses << call message name))
            y foo11
            y bar11
            y mucus11
            accesses should == [:foo11, :bar11, :mucus11]
          )

          it("should take :anyFromSelf and add it to all existing cells for that object only",
            X = Origin mimic
            Y = X mimic
            Y foo12 = 42
            X bar12 = 13
            y = Y mimic
            y quux12 = 555
            Ground accesses = []
            y before(matching: :anyFromSelf) add(:floxie, macro(accesses << call message name))
            y foo12
            y bar12
            y quux12
            accesses should == [:quux12]
          )

          it("should take a regular expression and use that to choose which cells to handle",
            X = Origin mimic
            x = X mimic
            X match_aspect_abc13 = 555
            X mutch_aspect_abc13 = 555
            X match_aspect_aaa13 = 5345
            x match_aspect_hmm13 = 1111

            Ground accesses = []
            x before(matching: #/match_aspect_/) add(:floxie, macro(accesses << call message name))
            x match_aspect_abc13
            x mutch_aspect_abc13
            x match_aspect_aaa13
            x match_aspect_hmm13
            accesses should == [:match_aspect_abc13, :match_aspect_aaa13, :match_aspect_hmm13]
          )

          it("should take a block and use that to choose which cells to handle",
            X = Origin mimic
            x = X mimic
            X match_aspect_abc14 = 555
            X mutch_aspect_abc14 = 555
            X match_aspect_aaa14 = 5345
            x match_aspect_hmm14 = 1111

            Ground accesses = []
            x before(matching: fn(arg, #/match_aspect_/ =~ arg)) add(:floxie, macro(accesses << call message name))
            x match_aspect_abc14
            x mutch_aspect_abc14
            x match_aspect_aaa14
            x match_aspect_hmm14
            accesses should == [:match_aspect_abc14, :match_aspect_aaa14, :match_aspect_hmm14]
          )

          it("should take a list of specifiers to use for matching",
            X = Origin mimic
            x = X mimic
            X match_aspect_abc15 = 555
            X mutch_aspect_abc15 = 555
            X match_aspect_aaa15 = 5345
            x match_aspect_hmm15 = 1111
            x blarg_aspect_hmm15 = 1111

            Ground accesses = []
            x before(matching: [#/match_aspect_/, #/blarg_/]) add(:floxie, macro(accesses << call message name))
            x match_aspect_abc15
            x mutch_aspect_abc15
            x match_aspect_aaa15
            x match_aspect_hmm15
            x blarg_aspect_hmm15
            accesses should == [:match_aspect_abc15, :match_aspect_aaa15, :match_aspect_hmm15, :blarg_aspect_hmm15]
          )
        )

        describe("with except: keyword",
          it("should take a name to not include",
            X = Origin mimic
            Y = X mimic
            Y foo16 = 42
            X bar16 = 13
            y = Y mimic
            y quux16 = 555
            Ground accesses = []
            y before(matching: :any, except: :bar16) add(:floxie, macro(accesses << call message name))
            y foo16
            y bar16
            y quux16
            accesses should == [:foo16, :quux16]
          )

          it("should take a list of names to not include",
            X = Origin mimic
            Y = X mimic
            Y foo17 = 42
            X bar17 = 13
            y = Y mimic
            y quux17 = 555
            Ground accesses = []
            y before(matching: :any, except: [:bar17, :quux17]) add(:floxie, macro(accesses << call message name))
            y foo17
            y bar17
            y quux17
            accesses should == [:foo17]
          )
          
          it("should take a regular expression",
            X = Origin mimic
            Y = X mimic
            Y foo18 = 42
            X bar18 = 13
            y = Y mimic
            y quux18 = 555
            Ground accesses = []
            y before(matching: :any, except: #/bar18/) add(:floxie, macro(accesses << call message name))
            y foo18
            y bar18
            y quux18
            accesses should == [:foo18, :quux18]
          )

          it("should take a block",
            X = Origin mimic
            Y = X mimic
            Y foo19 = 42
            X bar19 = 13
            y = Y mimic
            y quux19 = 555
            Ground accesses = []
            y before(matching: :any, except: fn(c, #/bar19/ =~ c)) add(:floxie, macro(accesses << call message name))
            y foo19
            y bar19
            y quux19
            accesses should == [:foo19, :quux19]
          )

          it("should take a list of specifiers",
            X = Origin mimic
            Y = X mimic
            Y foo20 = 42
            X bar20 = 13
            y = Y mimic
            y quux20 = 555
            Ground accesses = []
            y before(matching: :any, except: [#/bar20/, #/foo20/]) add(:floxie, macro(accesses << call message name))
            y foo20
            y bar20
            y quux20
            accesses should == [:quux20]
          )
        )
      )

      describe("removing named advice",
        it("should only remove the outermost advice with the name",
          x = Origin mimic do(
            foo = 14)
          accesses = []
          x before(:foo) add(:someone, fn(accesses << :one))
          x before(:foo) add(:someone, fn(accesses << :two))
          x before(:foo) add(:someone, fn(accesses << :three))

          x before(:foo) remove(:someone)

          x foo
          accesses should == [:two, :one]
        )

        it("should signal a condition if no such advice could be found",
          x = Origin mimic do(
            foo = 14)
          fn(x before(:foo) remove(:someone)) should signal(Condition Error NoSuchAdvice)
          x before(:foo) << fn()
          fn(x before(:foo) remove(:someone)) should signal(Condition Error NoSuchAdvice)
          x before(:foo) add(:anotherName, fn)
          fn(x before(:foo) remove(:someone)) should signal(Condition Error NoSuchAdvice)
        )

        it("should not touch unnamed advice",
          x = Origin mimic do(
            foo = 14)
          accesses = []
          x before(:foo) << fn(accesses << :one)
          x before(:foo) add(:someone, fn(accesses << :two))
          x before(:foo) << fn(accesses << :three)

          x before(:foo) remove(:someone)

          x foo
          accesses should == [:three, :one]
        )

        it("should not touch advice with other names",
          x = Origin mimic do(
            foo = 14)
          accesses = []
          x before(:foo) add(:buck, fn(accesses << :one))
          x before(:foo) add(:someone, fn(accesses << :two))
          x before(:foo) add(:blarg, fn(accesses << :three))

          x before(:foo) remove(:someone)

          x foo
          accesses should == [:three, :one]
        )

        it("should only remove the named advice from the specific point cut",
          x = Origin mimic do(
            foo = 14
            bar = 13)
          accesses = []
          x before(:foo, :bar) add(:someone, lecro(accesses << [:one, call message name]))
          x before(:foo, :bar) add(:someone, lecro(accesses << [:two, call message name]))
          x before(:foo, :bar) add(:someone, lecro(accesses << [:three, call message name]))

          x before(:foo) remove(:someone)

          x foo
          x bar

          accesses should == [[:two, :foo], [:one, :foo], [:three, :bar], [:two, :bar], [:one, :bar]]
        )
      )
    )

    describe("removing all named advice",
      it("should remove all advice with the name",
          x = Origin mimic do(
            foo = 14)
          accesses = []
          x before(:foo) add(:someone, fn(accesses << :one))
          x before(:foo) add(:someone, fn(accesses << :two))
          x before(:foo) add(:someone, fn(accesses << :three))

          x before(:foo) removeAll(:someone)

          x foo should == 14
          accesses should == []
        )

        it("should signal a condition if no such advice could be found",
          x = Origin mimic do(
            foo = 14)
          x before(:foo) removeAll(:someone)
        )

        it("should not touch unnamed advice",
          x = Origin mimic do(
            foo = 14)
          accesses = []
          x before(:foo) << fn(accesses << :one)
          x before(:foo) add(:someone, fn(accesses << :two))
          x before(:foo) << fn(accesses << :three)

          x before(:foo) removeAll(:someone)

          x foo
          accesses should == [:three, :one]
        )

        it("should not touch advice with other names",
          x = Origin mimic do(
            foo = 14)
          accesses = []
          x before(:foo) add(:buck, fn(accesses << :one))
          x before(:foo) add(:someone, fn(accesses << :two))
          x before(:foo) add(:blarg, fn(accesses << :three))

          x before(:foo) removeAll(:someone)

          x foo
          accesses should == [:three, :one]
        )

        it("should only remove the named advice from the specific point cut",
          x = Origin mimic do(
            foo = 14
            bar = 13)
          accesses = []
          x before(:foo, :bar) add(:someone, lecro(accesses << [:one, call message name]))
          x before(:foo, :bar) add(:someone, lecro(accesses << [:two, call message name]))
          x before(:foo, :bar) add(:someone, lecro(accesses << [:three, call message name]))

          x before(:foo) removeAll(:someone)

          x foo
          x bar

          accesses should == [[:three, :bar], [:two, :bar], [:one, :bar]]
        )
    )

    describe("after",
      it("should return an Aspect Pointcut",
        Origin mimic after(:foo) should have kind("DefaultBehavior Aspects Pointcut")
      )

      describe("with one cell name",
        it("should execute a block after a cell is accessed in any way",
          x = Origin mimic do(
            foo1 = 42)
          accesses = []
          x after(:foo1) << fn(accesses << :accessed)
          x foo1 should == 42
          x foo1 should == 42
          accesses should == [:accessed, :accessed]
        )

        it("should execute a method after a cell is accessed in any way",
          x = Origin mimic do(
            foo2 = 42)
          Ground accesses = []
          x after(:foo2) << method(accesses << :accessed)
          x foo2 should == 42
          x foo2 should == 42
          accesses should == [:accessed, :accessed]
        )

        it("should give the same arguments as was given to the original call",
          x = Origin mimic do(
            foo3 = method(+args, args))
          Ground accesses = []
          x after(:foo3) << method(+args, accesses << [:method, args])
          x after(:foo3) << fn(a, b, +args, accesses << [:fn, a, b, args])
          x foo3(1,2) should == [1,2]
          x foo3(53, 43, 6613, 4353) should == [53, 43, 6613, 4353]
          accesses should == [[:method, [1,2]], [:fn, 1, 2, []], [:method, [53, 43, 6613, 4353]], [:fn, 53, 43, [6613, 4353]]]
        )

        it("should supply a 'call' to macros that specify the original call, including name, for a cell get",
          x = Origin mimic do(
            foo4 = 42)
          Ground accesses = []
          x after(:foo4) << macro(accesses << call message name)
          x foo4 should == 42
          x foo4 should == 42
          accesses should == [:foo4, :foo4]
        )

        it("should supply a 'call' to macros that specify the original call, including name, for a method call",
          x = Origin mimic do(
            foox = method(a, a+42))
          Ground accesses = []
          x after(:foox) << macro(accesses << call message name)
          x foox(32) should == 74
          x foox(1) should == 43
          accesses should == [:foox, :foox]
        )

        it("should be possible to signal a condition from inside the after method",
          x = Origin mimic do(
            foo5 = method(42))
          accesses = []
          x after(:foo5) << fn(accesses << :one)
          x after(:foo5) << fn(accesses << :two)
          x after(:foo5) << fn(accesses << :three)
          x after(:foo5) << fn(accesses << :four. error!("this doesn't work..."))
          x after(:foo5) << fn(accesses << :five)
          x after(:foo5) << fn(accesses << :six)
          fn(x foo5) should signal(Condition Error Default)
          accesses should == [:one, :two, :three, :four]
          
        )

        it("should be possible to specify for a cell that doesn't exist",
          x = Origin mimic
          accesses = []
          x after(:unexisting_aspect_after_cell) << fn(accesses << :wow)
          bind(rescue(Condition Error NoSuchCell, fn(c, nil)),
            x unexisting_aspect_after_cell)
          accesses should == []
        )

        it("should still raise a nosuchcell after the after advice have run for a non-existing cell",
          x = Origin mimic
          x after(:unexisting_aspect_after_cell) << fn(nil)
          fn(x unexisting_aspect_after_cell) should signal(Condition Error NoSuchCell)
        )

        it("should set the self of a method to the same self as the receiver",
          x = Origin mimic do(
            foo6 = method(42))
          Ground accesses = []
          x after(:foo6) << method(accesses << self)
          x after(:foo6) << macro(accesses << self)
          x foo6
          accesses[0] should be same(x)
          accesses[1] should be same(x)
        )

        it("should only evaluate arguments once",
          x = Origin mimic do(
            foo7 = method(arg, 42))
          Ground accesses = []
          x after(:foo7) << method(arg, accesses << [:method, arg])
          x after(:foo7) << macro(accesses << [:macro, call arguments[0] code])
          x after(:foo7) << fn(arg, accesses << [:fn, arg])
          x foo7(accesses << :arg_evaled. 42 + 14)
          accesses should == [:arg_evaled, [:method, 56], [:macro, "accesses <<(:arg_evaled) .\n42 +(14)"], [:fn, 56]]
        )

        it("should evaluate advice in inverse order",
          x = Origin mimic do(
            foo8 = method(42))
          accesses = []
          x after(:foo8) << fn(accesses << :one)
          x after(:foo8) << fn(accesses << :two)
          x after(:foo8) << fn(accesses << :three)
          x foo8
          accesses should == [:one, :two, :three]
        )

        it("should retain the original documentation",
          x = Origin mimic do(
            foo9 = method("Does something very interesting", 42))
          x after(:foo9) << fn("blarg", 42)
          x cell(:foo9) documentation should == "Does something very interesting"
        )
      )

      describe("with more than one cell name",
        it("should add the advice to both the cells",
          x = Origin mimic do(
            foo10 = 42
            bar10 = 62
          )
          Ground accesses = []
          x after(:foo10, :bar10) << macro(accesses << call message name)
          x foo10
          x bar10
          x foo10
          accesses should == [:foo10, :bar10, :foo10]
        )
      )

      describe("with matching: keyword",
        it("should take :any and add it to all existing cells for that object and mimics, up to Origin",
          X = Origin mimic
          Y = X mimic
          Y foo11 = 42
          X bar11 = 13
          y = Y mimic
          Origin mucus11 = 777
          Ground accesses = []
          y after(matching: :any) << macro(accesses << call message name)
          y foo11
          y bar11
          y mucus11
          accesses should == [:foo11, :bar11, :mucus11]
        )

        it("should take :anyFromSelf and add it to all existing cells for that object only",
          X = Origin mimic
          Y = X mimic
          Y foo12 = 42
          X bar12 = 13
          y = Y mimic
          y quux12 = 555
          Ground accesses = []
          y after(matching: :anyFromSelf) << macro(accesses << call message name)
          y foo12
          y bar12
          y quux12
          accesses should == [:quux12]
        )

        it("should take a regular expression and use that to choose which cells to handle",
          X = Origin mimic
          x = X mimic
          X match_aspect_abc13 = 555
          X mutch_aspect_abc13 = 555
          X match_aspect_aaa13 = 5345
          x match_aspect_hmm13 = 1111

          Ground accesses = []
          x after(matching: #/match_aspect_/) << macro(accesses << call message name)
          x match_aspect_abc13
          x mutch_aspect_abc13
          x match_aspect_aaa13
          x match_aspect_hmm13
          accesses should == [:match_aspect_abc13, :match_aspect_aaa13, :match_aspect_hmm13]
        )

        it("should take a block and use that to choose which cells to handle",
          X = Origin mimic
          x = X mimic
          X match_aspect_abc14 = 555
          X mutch_aspect_abc14 = 555
          X match_aspect_aaa14 = 5345
          x match_aspect_hmm14 = 1111

          Ground accesses = []
          x after(matching: fn(arg, #/match_aspect_/ =~ arg)) << macro(accesses << call message name)
          x match_aspect_abc14
          x mutch_aspect_abc14
          x match_aspect_aaa14
          x match_aspect_hmm14
          accesses should == [:match_aspect_abc14, :match_aspect_aaa14, :match_aspect_hmm14]
        )

        it("should take a list of specifiers to use for matching",
          X = Origin mimic
          x = X mimic
          X match_aspect_abc15 = 555
          X mutch_aspect_abc15 = 555
          X match_aspect_aaa15 = 5345
          x match_aspect_hmm15 = 1111
          x blarg_aspect_hmm15 = 1111

          Ground accesses = []
          x after(matching: [#/match_aspect_/, #/blarg_/]) << macro(accesses << call message name)
          x match_aspect_abc15
          x mutch_aspect_abc15
          x match_aspect_aaa15
          x match_aspect_hmm15
          x blarg_aspect_hmm15
          accesses should == [:match_aspect_abc15, :match_aspect_aaa15, :match_aspect_hmm15, :blarg_aspect_hmm15]
        )
      )

      describe("with except: keyword",
        it("should take a name to not include",
          X = Origin mimic
          Y = X mimic
          Y foo16 = 42
          X bar16 = 13
          y = Y mimic
          y quux16 = 555
          Ground accesses = []
          y after(matching: :any, except: :bar16) << macro(accesses << call message name)
          y foo16
          y bar16
          y quux16
          accesses should == [:foo16, :quux16]
        )

        it("should take a list of names to not include",
          X = Origin mimic
          Y = X mimic
          Y foo17 = 42
          X bar17 = 13
          y = Y mimic
          y quux17 = 555
          Ground accesses = []
          y after(matching: :any, except: [:bar17, :quux17]) << macro(accesses << call message name)
          y foo17
          y bar17
          y quux17
          accesses should == [:foo17]
        )
        
        it("should take a regular expression",
          X = Origin mimic
          Y = X mimic
          Y foo18 = 42
          X bar18 = 13
          y = Y mimic
          y quux18 = 555
          Ground accesses = []
          y after(matching: :any, except: #/bar18/) << macro(accesses << call message name)
          y foo18
          y bar18
          y quux18
          accesses should == [:foo18, :quux18]
        )

        it("should take a block",
          X = Origin mimic
          Y = X mimic
          Y foo19 = 42
          X bar19 = 13
          y = Y mimic
          y quux19 = 555
          Ground accesses = []
          y after(matching: :any, except: fn(c, #/bar19/ =~ c)) << macro(accesses << call message name)
          y foo19
          y bar19
          y quux19
          accesses should == [:foo19, :quux19]
        )

        it("should take a list of specifiers",
          X = Origin mimic
          Y = X mimic
          Y foo20 = 42
          X bar20 = 13
          y = Y mimic
          y quux20 = 555
          Ground accesses = []
          y after(matching: :any, except: [#/bar20/, #/foo20/]) << macro(accesses << call message name)
          y foo20
          y bar20
          y quux20
          accesses should == [:quux20]
        )
      )

      describe("adding named advice",
        describe("with one cell name",
          it("should execute a block after a cell is accessed in any way",
            x = Origin mimic do(
              foo1 = 42)
            accesses = []
            x after(:foo1) add(:floxie, fn(accesses << :accessed))
            x foo1 should == 42
            x foo1 should == 42
            accesses should == [:accessed, :accessed]
          )

          it("should execute a method after a cell is accessed in any way",
            x = Origin mimic do(
              foo2 = 42)
            Ground accesses = []
            x after(:foo2) add(:floxie, method(accesses << :accessed))
            x foo2 should == 42
            x foo2 should == 42
            accesses should == [:accessed, :accessed]
          )

          it("should give the same arguments as was given to the original call",
            x = Origin mimic do(
              foo3 = method(+args, args))
            Ground accesses = []
            x after(:foo3) add(:floxie, method(+args, accesses << [:method, args]))
            x after(:foo3) add(:floxie, fn(a, b, +args, accesses << [:fn, a, b, args]))
            x foo3(1,2) should == [1,2]
            x foo3(53, 43, 6613, 4353) should == [53, 43, 6613, 4353]
            accesses should == [[:method, [1,2]], [:fn, 1, 2, []], [:method, [53, 43, 6613, 4353]], [:fn, 53, 43, [6613, 4353]]]
          )

          it("should supply a 'call' to macros that specify the original call, including name, for a cell get",
            x = Origin mimic do(
              foo4 = 42)
            Ground accesses = []
            x after(:foo4) add(:floxie, macro(accesses << call message name))
            x foo4 should == 42
            x foo4 should == 42
            accesses should == [:foo4, :foo4]
          )

          it("should supply a 'call' to macros that specify the original call, including name, for a method call",
            x = Origin mimic do(
              foox = method(a, a+42))
            Ground accesses = []
            x after(:foox) add(:floxie, macro(accesses << call message name))
            x foox(32) should == 74
            x foox(1) should == 43
            accesses should == [:foox, :foox]
          )

          it("should be possible to signal a condition from inside the after method",
            x = Origin mimic do(
              foo5 = method(42))
            accesses = []
            x after(:foo5) add(:floxie, fn(accesses << :one))
            x after(:foo5) add(:floxie, fn(accesses << :two))
            x after(:foo5) add(:floxie, fn(accesses << :three))
            x after(:foo5) add(:floxie, fn(accesses << :four. error!("this doesn't work...")))
            x after(:foo5) add(:floxie, fn(accesses << :five))
            x after(:foo5) add(:floxie, fn(accesses << :six))
            fn(x foo5) should signal(Condition Error Default)
            accesses should == [:one, :two, :three, :four]
            
          )

          it("should be possible to specify for a cell that doesn't exist",
            x = Origin mimic
            accesses = []
            x after(:unexisting_aspect_after_cell) add(:floxie, fn(accesses << :wow))
            bind(rescue(Condition Error NoSuchCell, fn(c, nil)),
              x unexisting_aspect_after_cell)
            accesses should == []
          )

          it("should still raise a nosuchcell after the after advice have run for a non-existing cell",
            x = Origin mimic
            x after(:unexisting_aspect_after_cell) add(:floxie, fn(nil))
            fn(x unexisting_aspect_after_cell) should signal(Condition Error NoSuchCell)
          )

          it("should set the self of a method to the same self as the receiver",
            x = Origin mimic do(
              foo6 = method(42))
            Ground accesses = []
            x after(:foo6) add(:floxie, method(accesses << self))
            x after(:foo6) add(:floxie, macro(accesses << self))
            x foo6
            accesses[0] should be same(x)
            accesses[1] should be same(x)
          )

          it("should only evaluate arguments once",
            x = Origin mimic do(
              foo7 = method(arg, 42))
            Ground accesses = []
            x after(:foo7) add(:floxie, method(arg, accesses << [:method, arg]))
            x after(:foo7) add(:floxie, macro(accesses << [:macro, call arguments[0] code]))
            x after(:foo7) add(:floxie, fn(arg, accesses << [:fn, arg]))
            x foo7(accesses << :arg_evaled. 42 + 14)
            accesses should == [:arg_evaled, [:method, 56], [:macro, "accesses <<(:arg_evaled) .\n42 +(14)"], [:fn, 56]]
          )

          it("should evaluate advice in inverse order",
            x = Origin mimic do(
              foo8 = method(42))
            accesses = []
            x after(:foo8) add(:floxie, fn(accesses << :one))
            x after(:foo8) add(:floxie, fn(accesses << :two))
            x after(:foo8) add(:floxie, fn(accesses << :three))
            x foo8
            accesses should == [:one, :two, :three]
          )

          it("should retain the original documentation",
            x = Origin mimic do(
              foo9 = method("Does something very interesting", 42))
            x after(:foo9) add(:floxie, fn("blarg", 42))
            x cell(:foo9) documentation should == "Does something very interesting"
          )
        )

        describe("with more than one cell name",
          it("should add the advice to both the cells",
            x = Origin mimic do(
              foo10 = 42
              bar10 = 62
            )
            Ground accesses = []
            x after(:foo10, :bar10) add(:floxie, macro(accesses << call message name))
            x foo10
            x bar10
            x foo10
            accesses should == [:foo10, :bar10, :foo10]
          )
        )

        describe("with matching: keyword",
          it("should take :any and add it to all existing cells for that object and mimics, up to Origin",
            X = Origin mimic
            Y = X mimic
            Y foo11 = 42
            X bar11 = 13
            y = Y mimic
            Origin mucus11 = 777
            Ground accesses = []
            y after(matching: :any) add(:floxie, macro(accesses << call message name))
            y foo11
            y bar11
            y mucus11
            accesses should == [:foo11, :bar11, :mucus11]
          )

          it("should take :anyFromSelf and add it to all existing cells for that object only",
            X = Origin mimic
            Y = X mimic
            Y foo12 = 42
            X bar12 = 13
            y = Y mimic
            y quux12 = 555
            Ground accesses = []
            y after(matching: :anyFromSelf) add(:floxie, macro(accesses << call message name))
            y foo12
            y bar12
            y quux12
            accesses should == [:quux12]
          )

          it("should take a regular expression and use that to choose which cells to handle",
            X = Origin mimic
            x = X mimic
            X match_aspect_abc13 = 555
            X mutch_aspect_abc13 = 555
            X match_aspect_aaa13 = 5345
            x match_aspect_hmm13 = 1111

            Ground accesses = []
            x after(matching: #/match_aspect_/) add(:floxie, macro(accesses << call message name))
            x match_aspect_abc13
            x mutch_aspect_abc13
            x match_aspect_aaa13
            x match_aspect_hmm13
            accesses should == [:match_aspect_abc13, :match_aspect_aaa13, :match_aspect_hmm13]
          )

          it("should take a block and use that to choose which cells to handle",
            X = Origin mimic
            x = X mimic
            X match_aspect_abc14 = 555
            X mutch_aspect_abc14 = 555
            X match_aspect_aaa14 = 5345
            x match_aspect_hmm14 = 1111

            Ground accesses = []
            x after(matching: fn(arg, #/match_aspect_/ =~ arg)) add(:floxie, macro(accesses << call message name))
            x match_aspect_abc14
            x mutch_aspect_abc14
            x match_aspect_aaa14
            x match_aspect_hmm14
            accesses should == [:match_aspect_abc14, :match_aspect_aaa14, :match_aspect_hmm14]
          )

          it("should take a list of specifiers to use for matching",
            X = Origin mimic
            x = X mimic
            X match_aspect_abc15 = 555
            X mutch_aspect_abc15 = 555
            X match_aspect_aaa15 = 5345
            x match_aspect_hmm15 = 1111
            x blarg_aspect_hmm15 = 1111

            Ground accesses = []
            x after(matching: [#/match_aspect_/, #/blarg_/]) add(:floxie, macro(accesses << call message name))
            x match_aspect_abc15
            x mutch_aspect_abc15
            x match_aspect_aaa15
            x match_aspect_hmm15
            x blarg_aspect_hmm15
            accesses should == [:match_aspect_abc15, :match_aspect_aaa15, :match_aspect_hmm15, :blarg_aspect_hmm15]
          )
        )

        describe("with except: keyword",
          it("should take a name to not include",
            X = Origin mimic
            Y = X mimic
            Y foo16 = 42
            X bar16 = 13
            y = Y mimic
            y quux16 = 555
            Ground accesses = []
            y after(matching: :any, except: :bar16) add(:floxie, macro(accesses << call message name))
            y foo16
            y bar16
            y quux16
            accesses should == [:foo16, :quux16]
          )

          it("should take a list of names to not include",
            X = Origin mimic
            Y = X mimic
            Y foo17 = 42
            X bar17 = 13
            y = Y mimic
            y quux17 = 555
            Ground accesses = []
            y after(matching: :any, except: [:bar17, :quux17]) add(:floxie, macro(accesses << call message name))
            y foo17
            y bar17
            y quux17
            accesses should == [:foo17]
          )
          
          it("should take a regular expression",
            X = Origin mimic
            Y = X mimic
            Y foo18 = 42
            X bar18 = 13
            y = Y mimic
            y quux18 = 555
            Ground accesses = []
            y after(matching: :any, except: #/bar18/) add(:floxie, macro(accesses << call message name))
            y foo18
            y bar18
            y quux18
            accesses should == [:foo18, :quux18]
          )

          it("should take a block",
            X = Origin mimic
            Y = X mimic
            Y foo19 = 42
            X bar19 = 13
            y = Y mimic
            y quux19 = 555
            Ground accesses = []
            y after(matching: :any, except: fn(c, #/bar19/ =~ c)) add(:floxie, macro(accesses << call message name))
            y foo19
            y bar19
            y quux19
            accesses should == [:foo19, :quux19]
          )

          it("should take a list of specifiers",
            X = Origin mimic
            Y = X mimic
            Y foo20 = 42
            X bar20 = 13
            y = Y mimic
            y quux20 = 555
            Ground accesses = []
            y after(matching: :any, except: [#/bar20/, #/foo20/]) add(:floxie, macro(accesses << call message name))
            y foo20
            y bar20
            y quux20
            accesses should == [:quux20]
          )
        )

        describe("removing named advice",
          it("should only remove the outermost advice with the name",
            x = Origin mimic do(
              foo = 14)
            accesses = []
            x after(:foo) add(:someone, fn(accesses << :one))
            x after(:foo) add(:someone, fn(accesses << :two))
            x after(:foo) add(:someone, fn(accesses << :three))

            x after(:foo) remove(:someone)

            x foo
            accesses should == [:one, :two]
          )

          it("should signal a condition if no such advice could be found",
            x = Origin mimic do(
              foo = 14)
            fn(x after(:foo) remove(:someone)) should signal(Condition Error NoSuchAdvice)
            x after(:foo) << fn()
            fn(x after(:foo) remove(:someone)) should signal(Condition Error NoSuchAdvice)
            x after(:foo) add(:anotherName, fn)
            fn(x after(:foo) remove(:someone)) should signal(Condition Error NoSuchAdvice)
          )

          it("should not touch unnamed advice",
            x = Origin mimic do(
              foo = 14)
            accesses = []
            x after(:foo) << fn(accesses << :one)
            x after(:foo) add(:someone, fn(accesses << :two))
            x after(:foo) << fn(accesses << :three)

            x after(:foo) remove(:someone)

            x foo
            accesses should == [:one, :three]
          )

          it("should not touch advice with other names",
            x = Origin mimic do(
              foo = 14)
            accesses = []
            x after(:foo) add(:buck, fn(accesses << :one))
            x after(:foo) add(:someone, fn(accesses << :two))
            x after(:foo) add(:blarg, fn(accesses << :three))

            x after(:foo) remove(:someone)

            x foo
            accesses should == [:one, :three]
          )

          it("should only remove the named advice from the specific point cut",
            x = Origin mimic do(
              foo = 14
              bar = 13)
            accesses = []
            x after(:foo, :bar) add(:someone, lecro(accesses << [:one, call message name]))
            x after(:foo, :bar) add(:someone, lecro(accesses << [:two, call message name]))
            x after(:foo, :bar) add(:someone, lecro(accesses << [:three, call message name]))

            x after(:foo) remove(:someone)

            x foo
            x bar

            accesses should == [[:one, :foo], [:two, :foo], [:one, :bar], [:two, :bar], [:three, :bar]]
          )
        )
      )

      describe("removing all named advice",
        it("should remove all advice with the name",
          x = Origin mimic do(
            foo = 14)
          accesses = []
          x after(:foo) add(:someone, fn(accesses << :one))
          x after(:foo) add(:someone, fn(accesses << :two))
          x after(:foo) add(:someone, fn(accesses << :three))

          x after(:foo) removeAll(:someone)

          x foo should == 14
          accesses should == []
        )

        it("should signal a condition if no such advice could be found",
          x = Origin mimic do(
            foo = 14)
          x after(:foo) removeAll(:someone)
        )

        it("should not touch unnamed advice",
          x = Origin mimic do(
            foo = 14)
          accesses = []
          x after(:foo) << fn(accesses << :one)
          x after(:foo) add(:someone, fn(accesses << :two))
          x after(:foo) << fn(accesses << :three)

          x after(:foo) removeAll(:someone)

          x foo
          accesses should == [:one, :three]
        )

        it("should not touch advice with other names",
          x = Origin mimic do(
            foo = 14)
          accesses = []
          x after(:foo) add(:buck, fn(accesses << :one))
          x after(:foo) add(:someone, fn(accesses << :two))
          x after(:foo) add(:blarg, fn(accesses << :three))

          x after(:foo) removeAll(:someone)

          x foo
          accesses should == [:one, :three]
        )

        it("should only remove the named advice from the specific point cut",
          x = Origin mimic do(
            foo = 14
            bar = 13)
          accesses = []
          x after(:foo, :bar) add(:someone, lecro(accesses << [:one, call message name]))
          x after(:foo, :bar) add(:someone, lecro(accesses << [:two, call message name]))
          x after(:foo, :bar) add(:someone, lecro(accesses << [:three, call message name]))

          x after(:foo) removeAll(:someone)

          x foo
          x bar

          accesses should == [[:one, :bar], [:two, :bar], [:three, :bar]]
        )
      )

      it("should provide the result of the result of the original call inside a method",
        x = Origin mimic do(
          foo = method(14*14))
        Ground accesses = []
        x after(:foo) << method(accesses << aspectResult)
        x foo
        accesses should == [196]
      )

      it("should provide the result of the result of the original call inside a lecro",
        x = Origin mimic do(
          foo = method(14*14))
        Ground accesses = []
        x after(:foo) << lecro(accesses << aspectResult)
        x foo
        accesses should == [196]
      )

      it("should provide the result of the result of the original call inside a macro",
        x = Origin mimic do(
          foo = method(14*14))
        Ground accesses = []
        x after(:foo) << macro(accesses << aspectResult)
        x foo
        accesses should == [196]
      )

      it("should provide the result of the result of the original call inside a syntax",
        x = Origin mimic do(
          foo = method(14*14))
        Ground accesses = []
        x after(:foo) << syntax(accesses << aspectResult)
        x foo
        accesses should == [196]
      )

      it("should provide the result of the result of the original call inside a block",
        x = Origin mimic do(
          foo = method(14*14))
        Ground accesses = []
        x after(:foo) << fn(accesses << aspectResult)
        x foo
        accesses should == [196]
      )

      it("should allow several after advices to have access to the result",
        x = Origin mimic do(
          foo = method(14*14))
        Ground accesses = []
        x after(:foo) << fn(accesses << [:fn, aspectResult])
        x after(:foo) << method(accesses << [:method, aspectResult])
        x after(:foo) << fn(accesses << [:fn2, aspectResult])
        x after(:foo) << macro(accesses << [:macro, aspectResult])
        x foo
        accesses should == [[:fn, 196], [:method, 196], [:fn2, 196], [:macro, 196]]
      )
    )

    describe("around",
      it("should return an Aspect Pointcut",
        Origin mimic around(:foo) should have kind("DefaultBehavior Aspects Pointcut")
      )
      
      it("should execute a block instead of a cell access",
        x = Origin mimic do(
          foo = 42)
        
        accesses = []
        x around(:foo) << fn(accesses << :called)

        x foo
        x foo
        accesses should == [:called, :called]
      )

      it("should execute a method instead of a cell access",
        x = Origin mimic do(
          foo = 42)
        
        Ground accesses = []
        x around(:foo) << method(accesses << :called)

        x foo
        x foo
        accesses should == [:called, :called]
      )

      it("should execute a method instead of a cell access with the current receiver",
        x = Origin mimic do(
          foo = 42)
        
        Ground accesses = []
        x around(:foo) << method(accesses << self)

        x foo
        x foo
        accesses[0] should be same(x)
        accesses[1] should be same(x)
      )

      it("should be possible to define an around advice for a non-existing cell",
        x = Origin mimic
        accesses = []
        x around(:foo) << fn(accesses << :called)

        x foo
        x foo
        accesses should == [:called, :called]
      )

      it("should signal a nosuchcell exception for a non-existing cell, after invoking the around advice",
        x = Origin mimic
        accesses = []
        x around(:method_to_test_advice_around_non_existing_cell) << fn(accesses << :called. aspectCall())
        fn(x method_to_test_advice_around_non_existing_cell) should signal(Condition Error NoSuchCell)
        accesses should == [:called]
      )

      it("should be possible to invoke the next value",
        Ground accesses = []
        x = Origin mimic do(
          foo = method(val, accesses << [:realMethodInvoked, val]. 18))
        x around(:foo) << method(var, 
          accesses << [:aroundBefore, var]
          xx = aspectCall(42)
          accesses << [:aroundAfter, xx]
          39)
        x foo(500) should == 39
        accesses should == [[:aroundBefore, 500], [:realMethodInvoked, 42], [:aroundAfter, 18]]
      )

      it("should be possible to invoke the next value several times",
        Ground accesses = []
        x = Origin mimic do(
          foo = method(val, accesses << [:realMethodInvoked, val]. 18))
        x around(:foo) << method(var, 
          accesses << [:aroundBefore, var]
          xx = aspectCall(42)
          accesses << [:aroundAfter, xx]
          aspectCall(43)
          aspectCall(44)
          aspectCall(45)
          39)
        x foo(500) should == 39
        accesses should == [[:aroundBefore, 500], [:realMethodInvoked, 42], [:aroundAfter, 18], [:realMethodInvoked, 43], [:realMethodInvoked, 44], [:realMethodInvoked, 45]]
      )

      it("should return the value of the around advice",
        x = Origin mimic
        x around(:foo) << fn(4100)
        x foo should == 4100
      )

      it("should be possible to add a named around advice",
        x = Origin mimic
        x around(:foo) add(:something, fn(4100))
        x foo should == 4100
      )

      it("should be possible to remove a named around advice",
        x = Origin mimic do(
          foo = 42)
        x around(:foo) add(:something, fn(4100))
        x around(:foo) remove(:something)
        x foo should == 42
      )
    )

    it("should be possible to combine the different types of advice",
      Ground accesses = []
      x = Origin mimic do(
        foo = method(arg,
          accesses << [:realMethod, arg]
          18
      ))

      x around(:foo) << fn(arg1, arg2, accesses << [:around1, arg1, arg2]. aspectCall(arg2)*2)
      x before(:foo) << method(+args, accesses << [:before1, args])
      x after(:foo) << method(+args, accesses << [:after1, args, aspectResult])
      x around(:foo) << method(+args, accesses << [:around2, args]. aspectCall(*(args map(*2))))

      x foo(1,2) should == 36

      accesses should == [[:around2, [1,2]], [:before1, [2,4]], [:around1,2,4], [:realMethod,4], [:after1,[2,4],36]]
    )
  )
)
