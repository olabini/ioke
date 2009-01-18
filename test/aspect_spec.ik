
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
            foo = 42)
          accesses = []
          x before(:foo) << fn(accesses << :accessed)
          x foo should == 42
          x foo should == 42
          accesses should == [:accessed, :accessed]
        )

        it("should execute a method before a cell is accessed in any way",
          x = Origin mimic do(
            foo = 42)
          Ground accesses = []
          x before(:foo) << method(accesses << :accessed)
          x foo should == 42
          x foo should == 42
          accesses should == [:accessed, :accessed]
        )

        it("should give the same arguments as was given to the original call",
          x = Origin mimic do(
            foo = method(+args, args))
          Ground accesses = []
          x before(:foo) << method(+args, accesses << [:method, args])
          x before(:foo) << fn(a, b, +args, accesses << [:fn, a, b, args])
          x foo(1,2) should == [1,2]
          x foo(53, 43, 6613, 4353) should == [53, 43, 6613, 4353]
          accesses should == [[:fn, 1, 2, []], [:method, [1,2]], [:fn, 53, 43, [6613, 4353]], [:method, [53, 43, 6613, 4353]]]
        )

        it("should supply a 'call' to macros that specify the original call, including name, for a cell get",
          x = Origin mimic do(
            foo = 42)
          Ground accesses = []
          x before(:foo) << macro(accesses << call message name)
          x foo should == 42
          x foo should == 42
          accesses should == [:foo, :foo]
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
            foo = method(42))
          accesses = []
          x before(:foo) << fn(accesses << :one)
          x before(:foo) << fn(accesses << :two)
          x before(:foo) << fn(accesses << :three)
          x before(:foo) << fn(accesses << :four. error!("this doesn't work..."))
          x before(:foo) << fn(accesses << :five)
          x before(:foo) << fn(accesses << :six)
          fn(x foo) should signal(Condition Error Default)
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
            foo = method(42))
          Ground accesses = []
          x before(:foo) << method(accesses << self)
          x before(:foo) << macro(accesses << self)
          x foo
          accesses[0] should be same(x)
          accesses[1] should be same(x)
        )

        it("should only evaluate arguments once",
          x = Origin mimic do(
            foo = method(arg, 42))
          Ground accesses = []
          x before(:foo) << method(arg, accesses << [:method, arg])
          x before(:foo) << macro(accesses << [:macro, call arguments[0] code])
          x before(:foo) << fn(arg, accesses << [:fn, arg])
          x foo(accesses << :arg_evaled. 42 + 14)
          accesses should == [:arg_evaled, [:fn, 56], [:macro, "accesses <<(:arg_evaled) .\n42 +(14)"], [:method, 56]]
        )

        it("should evaluate advice in inverse order",
          x = Origin mimic do(
            foo = method(42))
          accesses = []
          x before(:foo) << fn(accesses << :one)
          x before(:foo) << fn(accesses << :two)
          x before(:foo) << fn(accesses << :three)
          x foo
          accesses should == [:three, :two, :one]
        )

        it("should retain the original documentation",
          x = Origin mimic do(
            foo = method("Does something very interesting", 42))
          x before(:foo) << fn("blarg", 42)
          x cell(:foo) documentation should == "Does something very interesting"
        )
      )

      describe("with more than one cell name",
        it("should add the advice to both the cells",
          x = Origin mimic do(
            foo = 42
            bar = 62
          )
          Ground accesses = []
          x before(:foo, :bar) << macro(accesses << call message name)
          x foo
          x bar
          x foo
          accesses should == [:foo, :bar, :foo]
        )
      )

      describe("with matching: keyword",
        it("should take :any and add it to all existing cells for that object and mimics, up to Origin",
          X = Origin mimic
          Y = X mimic
          Y foo = 42
          X bar = 13
          y = Y mimic
          Origin mucus = 777
          Ground accesses = []
          y before(matching: :any) << macro(accesses << call message name)
          y foo
          y bar
          y mucus
          y kind
          accesses should == [:foo, :bar, :mucus, :kind]
        )

        it("should take :anyFromSelf and add it to all existing cells for that object only",
          X = Origin mimic
          Y = X mimic
          Y foo = 42
          X bar = 13
          y = Y mimic
          y quux = 555
          Ground accesses = []
          y before(matching: :anyFromSelf) << macro(accesses << call message name)
          y foo
          y bar
          y kind
          y quux
          accesses should == [:quux]
        )

        it("should take a regular expression and use that to choose which cells to handle",
          X = Origin mimic
          x = X mimic
          X match_aspect_abc = 555
          X mutch_aspect_abc = 555
          X match_aspect_aaa = 5345
          x match_aspect_hmm = 1111

          Ground accesses = []
          x before(matching: #/match_aspect_/) << macro(accesses << call message name)
          x match_aspect_abc
          x mutch_aspect_abc
          x match_aspect_aaa
          x match_aspect_hmm
          accesses should == [:match_aspect_abc, :match_aspect_aaa, :match_aspect_hmm]
        )

        it("should take a block and use that to choose which cells to handle",
          X = Origin mimic
          x = X mimic
          X match_aspect_abc = 555
          X mutch_aspect_abc = 555
          X match_aspect_aaa = 5345
          x match_aspect_hmm = 1111

          Ground accesses = []
          x before(matching: fn(arg, #/match_aspect_/ =~ arg)) << macro(accesses << call message name)
          x match_aspect_abc
          x mutch_aspect_abc
          x match_aspect_aaa
          x match_aspect_hmm
          accesses should == [:match_aspect_abc, :match_aspect_aaa, :match_aspect_hmm]
        )

        it("should take a list of specifiers to use for matching")
      )

      describe("with except: keyword",
        it("should have specs")
      )

      describe("removing advice",
        it("should have specs")
      )
    )

    describe("after",
      it("should have specs")
    )

    describe("around",
      it("should have specs")
    )
  )
)
