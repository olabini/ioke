
use("ispec")

describe(DefaultBehavior,
  describe("Aspects",
    describe("before",
      it("should return an Aspect Pointcut")

      describe("with no specifier",
;         it("should execute a block before a cell is accessed in any way",
;           x = Origin mimic do(
;             foo = 42)
;           accesses = []
;           x before(:foo) << fn(accesses << :accessed)
;           x foo should == 42
;           x foo should == 42
;           accesses should == [:accessed, :accessed]
;         )

;         it("should execute a method before a cell is accessed in any way",
;           x = Origin mimic do(
;             foo = 42)
;           Ground accesses = []
;           x before(:foo) << method(accesses << :accessed)
;           x foo should == 42
;           x foo should == 42
;           accesses should == [:accessed, :accessed]
;         )

        it("should give the same arguments as was given to the original call")
        it("should supply a 'call' to macros that specify the original call, including name")
        it("should be possible to signal an error from inside the before method")
        it("should be possible to specify for a cell that doesn't exist")
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
