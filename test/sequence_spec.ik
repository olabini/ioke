
use("ispec")

SequenceTester = Origin mimic do(
  seq = method(
    s = Sequence mimic
    s val = [1,2,3,4]
    s index = 0
    s len = 4

    s next = method(
      result = @val[@index]
      @index++
      result
    )

    s next? = method(@index < @len)
    s reset! = method(@index = 0)
    s
  )
)

SequenceHelper = Origin mimic do(
  initialize = method(@called = false)
  mapped = macro(@called = true. @callInfo = call. 42)
  collected = macro(@called = true. @callInfo = call. 42)
  sorted = macro(@called = true. @callInfo = call. 42)
  sortedBy = macro(@called = true. @callInfo = call. 42)
  folded = macro(@called = true. @callInfo = call. 42)
  injected = macro(@called = true. @callInfo = call. 42)
  reduced = macro(@called = true. @callInfo = call. 42)
  filtered = macro(@called = true. @callInfo = call. 42)
  selected = macro(@called = true. @callInfo = call. 42)
  grepped = macro(@called = true. @callInfo = call. 42)
  zipped = macro(@called = true. @callInfo = call. 42)
  dropped = macro(@called = true. @callInfo = call. 42)
  droppedWhile = macro(@called = true. @callInfo = call. 42)
  rejected = macro(@called = true. @callInfo = call. 42)
)

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
      it("should resend the call with all arguments to the result of calling seq",
        x = Origin mimic
        x mimic!(Mixins Sequenced)
        seqObj = SequenceHelper mimic
        x mock!(:seq) andReturn(seqObj)

        x mapped(foo, bar x * 43) should == 42

        seqObj called should be true
        seqObj callInfo arguments should == ['foo, '(bar x * 43)]
      )
    )

    describe("collected",
      it("should resend the call with all arguments to the result of calling seq",
        x = Origin mimic
        x mimic!(Mixins Sequenced)
        seqObj = SequenceHelper mimic
        x mock!(:seq) andReturn(seqObj)

        x collected(foo, bar x * 43) should == 42

        seqObj called should be true
        seqObj callInfo arguments should == ['foo, '(bar x * 43)]
      )
    )

    describe("sorted",
      it("should resend the call with all arguments to the result of calling seq",
        x = Origin mimic
        x mimic!(Mixins Sequenced)
        seqObj = SequenceHelper mimic
        x mock!(:seq) andReturn(seqObj)

        x sorted(foo, bar x * 43) should == 42

        seqObj called should be true
        seqObj callInfo arguments should == ['foo, '(bar x * 43)]
      )
    )

    describe("sortedBy",
      it("should resend the call with all arguments to the result of calling seq",
        x = Origin mimic
        x mimic!(Mixins Sequenced)
        seqObj = SequenceHelper mimic
        x mock!(:seq) andReturn(seqObj)

        x sortedBy(foo, bar x * 43) should == 42

        seqObj called should be true
        seqObj callInfo arguments should == ['foo, '(bar x * 43)]
      )
    )

    describe("folded",
      it("should resend the call with all arguments to the result of calling seq",
        x = Origin mimic
        x mimic!(Mixins Sequenced)
        seqObj = SequenceHelper mimic
        x mock!(:seq) andReturn(seqObj)

        x folded(foo, bar x * 43) should == 42

        seqObj called should be true
        seqObj callInfo arguments should == ['foo, '(bar x * 43)]
      )
    )

    describe("injected",
      it("should resend the call with all arguments to the result of calling seq",
        x = Origin mimic
        x mimic!(Mixins Sequenced)
        seqObj = SequenceHelper mimic
        x mock!(:seq) andReturn(seqObj)

        x injected(foo, bar x * 43) should == 42

        seqObj called should be true
        seqObj callInfo arguments should == ['foo, '(bar x * 43)]
      )
    )

    describe("reduced",
      it("should resend the call with all arguments to the result of calling seq",
        x = Origin mimic
        x mimic!(Mixins Sequenced)
        seqObj = SequenceHelper mimic
        x mock!(:seq) andReturn(seqObj)

        x reduced(foo, bar x * 43) should == 42

        seqObj called should be true
        seqObj callInfo arguments should == ['foo, '(bar x * 43)]
      )
    )

    describe("filtered",
      it("should resend the call with all arguments to the result of calling seq",
        x = Origin mimic
        x mimic!(Mixins Sequenced)
        seqObj = SequenceHelper mimic
        x mock!(:seq) andReturn(seqObj)

        x filtered(foo, bar x * 43) should == 42

        seqObj called should be true
        seqObj callInfo arguments should == ['foo, '(bar x * 43)]
      )
    )

    describe("selected",
      it("should resend the call with all arguments to the result of calling seq",
        x = Origin mimic
        x mimic!(Mixins Sequenced)
        seqObj = SequenceHelper mimic
        x mock!(:seq) andReturn(seqObj)

        x selected(foo, bar x * 43) should == 42

        seqObj called should be true
        seqObj callInfo arguments should == ['foo, '(bar x * 43)]
      )
    )

    describe("grepped",
      it("should resend the call with all arguments to the result of calling seq",
        x = Origin mimic
        x mimic!(Mixins Sequenced)
        seqObj = SequenceHelper mimic
        x mock!(:seq) andReturn(seqObj)

        x grepped(foo, bar x * 43) should == 42

        seqObj called should be true
        seqObj callInfo arguments should == ['foo, '(bar x * 43)]
      )
    )

    describe("zipped",
      it("should resend the call with all arguments to the result of calling seq",
        x = Origin mimic
        x mimic!(Mixins Sequenced)
        seqObj = SequenceHelper mimic
        x mock!(:seq) andReturn(seqObj)

        x zipped(foo, bar x * 43) should == 42

        seqObj called should be true
        seqObj callInfo arguments should == ['foo, '(bar x * 43)]
      )
    )

    describe("dropped",
      it("should resend the call with all arguments to the result of calling seq",
        x = Origin mimic
        x mimic!(Mixins Sequenced)
        seqObj = SequenceHelper mimic
        x mock!(:seq) andReturn(seqObj)

        x dropped(foo, bar x * 43) should == 42

        seqObj called should be true
        seqObj callInfo arguments should == ['foo, '(bar x * 43)]
      )
    )

    describe("droppedWhile",
      it("should resend the call with all arguments to the result of calling seq",
        x = Origin mimic
        x mimic!(Mixins Sequenced)
        seqObj = SequenceHelper mimic
        x mock!(:seq) andReturn(seqObj)

        x droppedWhile(foo, bar x * 43) should == 42

        seqObj called should be true
        seqObj callInfo arguments should == ['foo, '(bar x * 43)]
      )
    )

    describe("rejected",
      it("should resend the call with all arguments to the result of calling seq",
        x = Origin mimic
        x mimic!(Mixins Sequenced)
        seqObj = SequenceHelper mimic
        x mock!(:seq) andReturn(seqObj)

        x rejected(foo, bar x * 43) should == 42

        seqObj called should be true
        seqObj callInfo arguments should == ['foo, '(bar x * 43)]
      )
    )
  )
)

describe(Sequence,
  it("should be Enumerable",
    Sequence should mimic(Mixins Enumerable)
  )

  describe("each",
    it("should start from the point where the sequence is right now",
      xx = SequenceTester seq
      xx next should == 1
      y = []
      xx each(x, y << x)
      y should == [2,3,4]
    )

    it("should be possible to give it just a message chain",
      Ground y = []
      Ground xs = method(y << self)
      SequenceTester seq each(xs)
      y should == [1,2,3,4]

      x = 0
      SequenceTester seq each(nil. x++)
      x should == 4
    )

    it("should be possible to give it an argument name and code",
      y = []
      SequenceTester seq each(x, y << x)
      y should == [1,2,3,4]
    )

    it("should return the sequence",
      y = SequenceTester seq
      (y each(x, x)) should be(y)
    )

    it("should establish a lexical context when invoking the methods. this context will be the same for all invocations.",
      SequenceTester seq each(x_list, blarg = 32)
      cell?(:x_list) should be false
      cell?(:blarg) should be false

      x = 14
      SequenceTester seq each(x, blarg = 32)
      x should == 14
    )

    it("should be possible to give it an extra argument to get the index",
      y = []
      SequenceTester seq each(i, x, y << [i, x])
      y should == [[0, 1], [1, 2], [2, 3], [3, 4]]
    )
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
    it("should mimic Sequence",
      Sequence Filter should mimic(Sequence)
    )

    it("should have tests")
  )

  describe("Map",
    it("should mimic Sequence",
      Sequence Map should mimic(Sequence)
    )

    it("should be able to take one argument for mapping",
      ss = Sequence Map create(SequenceTester seq, Ground, ['(*2)])
      ss next should == 2
      ss next should == 4
      ss asList should == [6, 8]
    )

    it("should be able to take two arguments for mapping",
      ss = Sequence Map create(SequenceTester seq, Ground, ['x, '(x*3)])
      ss next should == 3
      ss next should == 6
      ss asList should == [9, 12]
    )
  )

  describe("Sort",
    it("should mimic Sequence",
      Sequence Sort should mimic(Sequence)
    )

    it("should have tests")
  )

  describe("SortBy",
    it("should mimic Sequence",
      Sequence SortBy should mimic(Sequence)
    )

    it("should have tests")
  )

  describe("Fold",
    it("should mimic Sequence",
      Sequence Fold should mimic(Sequence)
    )

    it("should have tests")
  )

  describe("Grep",
    it("should mimic Sequence",
      Sequence Grep should mimic(Sequence)
    )

    it("should have tests")
  )

  describe("Zip",
    it("should mimic Sequence",
      Sequence Zip should mimic(Sequence)
    )

    it("should have tests")
  )

  describe("Drop",
    it("should mimic Sequence",
      Sequence Drop should mimic(Sequence)
    )

    it("should have tests")
  )

  describe("DropWhile",
    it("should mimic Sequence",
      Sequence DropWhile should mimic(Sequence)
    )

    it("should have tests")
  )

  describe("Reject",
    it("should mimic Sequence",
      Sequence Reject should mimic(Sequence)
    )

    it("should have tests")
  )
)
