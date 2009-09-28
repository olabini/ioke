
use("ispec")

describe(Mixins,
  describe(Mixins Sequenced,
    it("should be Enumerable",
      ;; gymnastics necessary since we don't have the should method or mimics method on Mixins
      (Reflector other:mimics(Mixins Sequenced)[1] == Mixins Enumerable) should be true
    )

    describe("each",
      it("should be implemented in terms of 'seq'")
      it("should return a Sequence if called with no arguments")
    )

    describe("mapped",
      it("should resend the call with all arguments to the result of calling seq")
    )

    describe("collected",
      it("should resend the call with all arguments to the result of calling seq")
    )

    describe("sorted",
      it("should resend the call with all arguments to the result of calling seq")
    )

    describe("sortedBy",
      it("should resend the call with all arguments to the result of calling seq")
    )

    describe("folded",
      it("should resend the call with all arguments to the result of calling seq")
    )

    describe("injected",
      it("should resend the call with all arguments to the result of calling seq")
    )

    describe("reduced",
      it("should resend the call with all arguments to the result of calling seq")
    )

    describe("filtered",
      it("should resend the call with all arguments to the result of calling seq")
    )

    describe("selected",
      it("should resend the call with all arguments to the result of calling seq")
    )

    describe("grepped",
      it("should resend the call with all arguments to the result of calling seq")
    )

    describe("zipped",
      it("should resend the call with all arguments to the result of calling seq")
    )

    describe("dropped",
      it("should resend the call with all arguments to the result of calling seq")
    )

    describe("droppedWhile",
      it("should resend the call with all arguments to the result of calling seq")
    )

    describe("rejected",
      it("should resend the call with all arguments to the result of calling seq")
    )
  )
)

describe(Sequence,
  it("should be Enumerable",
    Sequence should mimic(Mixins Enumerable)
  )

  describe("each",
    it("should have tests")
  )

  describe("mapped",
    it("should create a new Sequence Map with the arguments sent to it")
  )

  describe("collected",
    it("should create a new Sequence Map with the arguments sent to it")
  )

  describe("sorted",
    it("should create a new Sequence Sort with the arguments sent to it")
  )

  describe("sortedBy",
    it("should create a new Sequence SortBy with the arguments sent to it")
  )

  describe("folded",
    it("should create a new Sequence Fold with the arguments sent to it")
  )

  describe("injected",
    it("should create a new Sequence Fold with the arguments sent to it")
  )

  describe("reduced",
    it("should create a new Sequence Fold with the arguments sent to it")
  )

  describe("filtered",
    it("should create a new Sequence Filter with the arguments sent to it")
  )

  describe("selected",
    it("should create a new Sequence Filter with the arguments sent to it")
  )

  describe("grepped",
    it("should create a new Sequence Grep with the arguments sent to it")
  )

  describe("zipped",
    it("should create a new Sequence Zip with the arguments sent to it")
  )

  describe("dropped",
    it("should create a new Sequence Drop with the arguments sent to it")
  )

  describe("droppedWhile",
    it("should create a new Sequence DropWhile with the arguments sent to it")
  )

  describe("rejected",
    it("should create a new Sequence Reject with the arguments sent to it")
  )

  describe("Filter",
    it("should mimic Sequence")
    it("should have tests")
  )

  describe("Map",
    it("should mimic Sequence")
    it("should have tests")
  )

  describe("Sort",
    it("should mimic Sequence")
    it("should have tests")
  )

  describe("SortBy",
    it("should mimic Sequence")
    it("should have tests")
  )

  describe("Fold",
    it("should mimic Sequence")
    it("should have tests")
  )

  describe("Grep",
    it("should mimic Sequence")
    it("should have tests")
  )

  describe("Zip",
    it("should mimic Sequence")
    it("should have tests")
  )

  describe("Drop",
    it("should mimic Sequence")
    it("should have tests")
  )

  describe("DropWhile",
    it("should mimic Sequence")
    it("should have tests")
  )

  describe("Reject",
    it("should mimic Sequence")
    it("should have tests")
  )
)
