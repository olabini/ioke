
use("ispec")

SequenceTester = Origin mimic do(
  val = [1,2,3,4,5,6,7,8]
  len = 8

  seq = method(
    s = Sequence mimic
    s val = @val
    s index = 0
    s len = @len

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
      y should == [2,3,4,5,6,7,8]
    )

    it("should be possible to give it just a message chain",
      Ground y = []
      Ground xs = method(y << self)
      SequenceTester seq each(xs)
      y should == [1,2,3,4,5,6,7,8]

      x = 0
      SequenceTester seq each(nil. x++)
      x should == 8
    )

    it("should be possible to give it an argument name and code",
      y = []
      SequenceTester seq each(x, y << x)
      y should == [1,2,3,4,5,6,7,8]
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
      y should == [[0, 1], [1, 2], [2, 3], [3, 4], [4, 5], [5, 6], [6, 7], [7, 8]]
    )
  )

  describe("mapped",
    it("should create a new Sequence Map with the arguments sent to it")
  )

  describe("collected",
    it("should create a new Sequence Map with the arguments sent to it")
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

    it("should take zero arguments and return a sequence with only the true values",
      ss = Sequence Filter create(SequenceTester with(val: [1,2,3], len: 3) seq, Ground, [])
      ss next should == 1
      ss asList should == [2,3]

      ss = Sequence Filter create(SequenceTester with(val: [nil,false,nil], len: 3) seq, Ground, [])
      ss next? should be false
      ss asList should == []

      ss = Sequence Filter create(SequenceTester with(val: [nil,false,true], len: 3) seq, Ground, [])
      ss next? should be true
      ss asList should == [true]
    )

    it("should take one argument that ends up being a predicate and return a sequence of the values that is true",
      ss = Sequence Filter create(SequenceTester with(val: [1,2,3], len: 3) seq, Ground, ['(>1)])
      ss next should == 2
      ss asList should == [3]

      ss = Sequence Filter create(SequenceTester with(val: [nil,false,nil], len: 3) seq, Ground, ['(nil?)])
      ss asList should == [nil, nil]

      ss = Sequence Filter create(SequenceTester with(val: [nil,false,true], len: 3) seq, Ground, ['(==2)])
      ss next? should be false
      ss asList should == []
    )

    it("should take two arguments that ends up being a predicate and return a sequence of the values that is true",
      ss = Sequence Filter create(SequenceTester with(val: [1,2,3], len: 3) seq, Ground, ['x, '(x>1)])
      ss next should == 2
      ss asList should == [3]

      ss = Sequence Filter create(SequenceTester with(val: [nil,false,nil], len: 3) seq, Ground, ['x, '(x nil?)])
      ss asList should == [nil, nil]

      ss = Sequence Filter create(SequenceTester with(val: [nil,false,true], len: 3) seq, Ground, ['x, '(x==2)])
      ss next? should be false
      ss asList should == []
    )
  )

  describe("Map",
    it("should mimic Sequence",
      Sequence Map should mimic(Sequence)
    )

    it("should be able to take one argument for mapping",
      ss = Sequence Map create(SequenceTester seq, Ground, ['(*2)])
      ss next should == 2
      ss next should == 4
      ss asList should == [6, 8, 10, 12, 14, 16]
    )

    it("should be able to take two arguments for mapping",
      ss = Sequence Map create(SequenceTester seq, Ground, ['x, '(x*3)])
      ss next should == 3
      ss next should == 6
      ss asList should == [9, 12, 15, 18, 21, 24]
    )
  )

  describe("Grep",
    it("should mimic Sequence",
      Sequence Grep should mimic(Sequence)
    )

    it("should take one argument and return everything that matches with ===",
      ss = Sequence Grep create(SequenceTester with(val: [1,2,3,4,5,6,7,8,9], len: 9) seq, Ground, [], 2..5)
      ss next should == 2
      ss asList should == [3,4,5]

      customObj = Origin mimic
      customObj === = method(other, (other < 3) || (other > 5))
      ss = Sequence Grep create(SequenceTester with(val: [1,2,3,4,5,6,7,8,9], len: 9) seq, Ground, [], customObj)
      ss next should == 1
      ss next should == 2
      ss asList should == [6,7,8,9]
    )

    it("should take two arguments where the second argument is a message chain and return the result of calling that chain on everything that matches with ===",
      ss = Sequence Grep create(SequenceTester with(val: [1,2,3,4,5,6,7,8,9], len: 9) seq, Ground, ['(+ 1)], 2..5)
      ss next should == 3
      ss asList should == [4,5,6]

      customObj = Origin mimic
      customObj === = method(other, (other < 3) || (other > 5))
      ss = Sequence Grep create(SequenceTester with(val: [1,2,3,4,5,6,7,8,9], len: 9) seq, Ground, ['(+ 1)], customObj)
      ss next should == 2
      ss next should == 3
      ss asList should == [7,8,9,10]
    )

    it("should take three arguments where the second and third arguments gets turned into a lexical block to apply to all that matches with ===",
      ss = Sequence Grep create(SequenceTester with(val: [1,2,3,4,5,6,7,8,9], len: 9) seq, Ground, ['x, '((x + 1) asText)], 2..5)
      ss next should == "3"
      ss asList should == ["4","5","6"]

      customObj = Origin mimic
      customObj === = method(other, (other < 3) || (other > 5))
      ss = Sequence Grep create(SequenceTester with(val: [1,2,3,4,5,6,7,8,9], len: 9) seq, Ground, ['x, '((x + 1) asText)], customObj)
      ss next should == "2"
      ss next should == "3"
      ss asList should == ["7","8","9","10"]
    )
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

    it("should return a list without as many elements as requested",
      ss = Sequence Drop create(SequenceTester with(val: [1,2,3], len: 3) seq, Ground, [], 0)
      ss next should == 1
      ss asList should == [2,3]

      ss = Sequence Drop create(SequenceTester with(val: [1,2,3], len: 3) seq, Ground, [], 1)
      ss next should == 2
      ss asList should == [3]

      ss = Sequence Drop create(SequenceTester with(val: [1,2,3], len: 3) seq, Ground, [], 2)
      ss asList should == [3]

      ss = Sequence Drop create(SequenceTester with(val: [1,2,3], len: 3) seq, Ground, [], 3)
      ss asList should == []
    )

    it("should not drop more elements than the length of the collection",
      ss = Sequence Drop create(SequenceTester with(val: [1,2,3], len: 3) seq, Ground, [], 4)
      ss asList should == []

      ss = Sequence Drop create(SequenceTester with(val: [1,2,3], len: 3) seq, Ground, [], 10)
      ss asList should == []
    )
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

    it("should take one argument that ends up being a predicate and return a sequence of the values that is false",
      ss = Sequence Reject create(SequenceTester with(val: [1,2,3], len: 3) seq, Ground, ['(>1)])
      ss asList should == [1]

      ss = Sequence Reject create(SequenceTester with(val: [nil,false,nil], len: 3) seq, Ground, ['(nil?)])
      ss asList should == [false]

      ss = Sequence Reject create(SequenceTester with(val: [nil,false,true], len: 3) seq, Ground, ['(==2)])
      ss next should == nil
      ss asList should == [false, true]
    )

    it("should take two arguments that ends up being a predicate and return a sequence of the values that is false",
      ss = Sequence Reject create(SequenceTester with(val: [1,2,3], len: 3) seq, Ground, ['x, '(x>1)])
      ss asList should == [1]

      ss = Sequence Reject create(SequenceTester with(val: [nil,false,nil], len: 3) seq, Ground, ['x, '(x nil?)])
      ss asList should == [false]

      ss = Sequence Reject create(SequenceTester with(val: [nil,false,true], len: 3) seq, Ground, ['x, '(x==2)])
      ss next should be nil
      ss asList should == [false, true]
    )
  )
)
