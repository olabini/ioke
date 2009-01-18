
use("ispec")

describe(DefaultBehavior,
  describe("Aspects",
    describe("before",
      it("should return an Aspect Pointcut",
        Origin mimic before(:foo) should have kind("DefaultBehavior Aspects Pointcut")
      )

      describe("with no specifier",
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

        it("should be possible to signal an error from inside the before method")

        it("should be possible to specify for a cell that doesn't exist")

        it("should still raise a nosuchcell after the before advice have run for a non-existing cell")

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

        it("should only evaluate arguments once")

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
      )

      describe("with :get specifier",
        it("should have specs")
      )

      describe("with :activate specifier",
        it("should have specs")
      )

      describe("with :remove specifier",
        it("should have specs")
      )

      describe("with :update specifier",
        it("should have specs")
      )

      describe("with combined specifier",
        it("should have specs")
      )

      describe("with matching: keyword",
        it("should have specs")
      )

      describe("with except: keyword",
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
