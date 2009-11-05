
use("ispec")

SequenceTester = Origin mimic do(
  mimic!(Mixins Sequenced)

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
      it("should be implemented in terms of 'seq'",
        x = Origin mimic
        x mimic!(Mixins Sequenced)
        seqObj = SequenceHelper mimic
        seqObj mock!(:next?) andReturn(false)
        x mock!(:seq) andReturn(seqObj)
        x each(42)
      )

      it("should be possible to call with one message chain that will be applied to all arguments",
        Ground y = []
        Ground xs = method(y << self)
        SequenceTester each(xs)
        y should == [1,2,3,4,5,6,7,8]

        x = 0
        SequenceTester each(nil. x++)
        x should == 8
      )

      it("should be possible to call with one argument name and code that will be applied to all arguments",
        y = []
        SequenceTester each(x, y << x)
        y should == [1,2,3,4,5,6,7,8]
      )

      it("should be possible to call with two argument names and code that will be applied to all arguments",
        y = []
        SequenceTester each(i, x, y << [i, x])
        y should == [[0, 1], [1, 2], [2, 3], [3, 4], [4, 5], [5, 6], [6, 7], [7, 8]]
      )

      it("should return the object",
        (SequenceTester each(x, x)) should be(SequenceTester)
      )

      it("should establish a lexical context when invoking the methods. this context will be the same for all invocations.",
        SequenceTester each(x_list, blarg=32)
        cell?(:x_list) should be false
        cell?(:blarg) should be false

        x=14
        SequenceTester each(x, blarg=32)
        x should == 14
      )

      it("should return a Sequence if called with no arguments",
        x = Origin mimic
        x mimic!(Mixins Sequenced)
        seqObj = SequenceHelper mimic
        x mock!(:seq) andReturn(seqObj)
        x each should be same(seqObj)
      )
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
    it("should create a new Sequence Map with the arguments sent to it",
      ss = SequenceTester with(val: [1,2,3], len: 3) seq
      val = ss mapped(*2)
      val should mimic(Sequence Map)
      val wrappedSequence should be same(ss)
      val messages should == ['(*2)]
    )

    it("should map the objects",
      ss = SequenceTester with(val: [1,2,3], len: 3) seq
      ss mapped(*2) asList should == [2,4,6]

      ss = SequenceTester with(val: [1,2,3], len: 3) seq
      ss mapped(x, x*2) asList should == [2,4,6]
    )
  )

  describe("collected",
    it("should create a new Sequence Map with the arguments sent to it",
      ss = SequenceTester with(val: [1,2,3], len: 3) seq
      val = ss collected(*2)
      val should mimic(Sequence Map)
      val wrappedSequence should be same(ss)
      val messages should == ['(*2)]
    )

    it("should map the objects",
      ss = SequenceTester with(val: [1,2,3], len: 3) seq
      ss collected(*2) asList should == [2,4,6]

      ss = SequenceTester with(val: [1,2,3], len: 3) seq
      ss collected(x, x*2) asList should == [2,4,6]
    )
  )

  describe("filtered",
    it("should create a new Sequence Filter with the arguments sent to it",
      ss = SequenceTester with(val: [1,2,3,4,5,6,7,8], len: 8) seq
      val = ss filtered(>4)
      val should mimic(Sequence Filter)
      val wrappedSequence should be same(ss)
      val messages should == ['(>4)]
    )

    it("should filter the objects",
      ss = SequenceTester with(val: [true, false, nil, true, false, nil, 1], len: 7) seq
      ss filtered asList should == [true, true, 1]

      ss = SequenceTester with(val: [1,2,3,4,5,6,7,8], len: 8) seq
      ss filtered(>4) asList should == [5,6,7,8]

      ss = SequenceTester with(val: [1,2,3,4,5,6,7,8], len: 8) seq
      ss filtered(x, x>4) asList should == [5,6,7,8]
    )
  )

  describe("selected",
    it("should create a new Sequence Filter with the arguments sent to it",
      ss = SequenceTester with(val: [1,2,3,4,5,6,7,8], len: 8) seq
      val = ss selected(>4)
      val should mimic(Sequence Filter)
      val wrappedSequence should be same(ss)
      val messages should == ['(>4)]
    )

    it("should filter the objects",
      ss = SequenceTester with(val: [true, false, nil, true, false, nil, 1], len: 7) seq
      ss selected asList should == [true, true, 1]

      ss = SequenceTester with(val: [1,2,3,4,5,6,7,8], len: 8) seq
      ss selected(>4) asList should == [5,6,7,8]

      ss = SequenceTester with(val: [1,2,3,4,5,6,7,8], len: 8) seq
      ss selected(x, x>4) asList should == [5,6,7,8]
    )
  )

  describe("grepped",
    it("should create a new Sequence Grep with the arguments sent to it",
      ss = SequenceTester with(val: [1,2,3,4,5,6,7,8], len: 8) seq
      val = ss grepped(2..4)
      val should mimic(Sequence Grep)
      val wrappedSequence should be same(ss)
      val messages should == []
      val restArguments should == [2..4]
    )

    it("should grep the objects",
      ss = SequenceTester with(val: [1,2,4,5,6,7,8], len: 7) seq
      ss grepped(2..4) asList should == [2,4]
    )
  )

  describe("zipped",
    it("should create a new Sequence Zip with the arguments sent to it",
      ss = SequenceTester with(val: [1,2,3,4,5,6,7,8], len: 8) seq
      listSeq = [1,2,3,4] seq
      val = ss zipped(listSeq)
      val should mimic(Sequence Zip)
      val wrappedSequence should be same(ss)
      val messages should == []
      val restArguments[0] should be same(listSeq)
    )

    it("should zip the objects",
      ss = SequenceTester with(val: [1,2,4,5,6,7,8], len: 7) seq
      ss zipped([1,2,3,4], [55,66,77]) asList should == [[1,1,55], [2,2,66],
        [4, 3, 77],
        [5, 4, nil], [6, nil, nil],
        [7, nil, nil], [8, nil, nil]]
    )
  )

  describe("indexed",
    it("should create a new Sequence Index with the arguments sent to it",
      ss = SequenceTester with(val: [1,2,3,4,5,6,7,8], len: 8) seq
      val = ss indexed
      val should mimic(Sequence Index)
      val wrappedSequence should be same(ss)
      val messages should == []
    )

    it("should index the objects",
      ss = SequenceTester with(val: [1,2,4,5,6,7,8], len: 7) seq
      ss indexed asList should == [[0,1], [1,2], [2,4], [3,5], [4,6], [5,7], [6,8]]
    )

    it("should take an optional from: parameter",
      ss = SequenceTester with(val: [1,2,4,5,6,7,8], len: 7) seq
      ss indexed(from: 10) asList should == [[10,1], [11,2], [12,4], [13,5], [14,6], [15,7], [16,8]]
    )

    it("should take an optional step: parameter",
      ss = SequenceTester with(val: [1,2,4,5,6,7,8], len: 7) seq
      ss indexed(step: 3) asList should == [[0,1], [3,2], [6,4], [9,5], [12,6], [15,7], [18,8]]
    )
  )

  describe("dropped",
    it("should create a new Sequence Drop with the arguments sent to it",
      ss = SequenceTester with(val: [1,2,3,4,5,6,7,8], len: 8) seq
      val = ss dropped(3)
      val should mimic(Sequence Drop)
      val wrappedSequence should be same(ss)
      val messages should == []
      val restArguments should == [3]
    )

    it("should drop the objects",
      ss = SequenceTester with(val: [1,2,4,5,6,7,8], len: 7) seq
      ss dropped(3) asList should == [5,6,7,8]

      ss = SequenceTester with(val: [1,2,4,5,6,7,8], len: 7) seq
      ss dropped(10) asList should == []
    )
  )

  describe("droppedWhile",
    it("should create a new Sequence DropWhile with the arguments sent to it",
      ss = SequenceTester with(val: [1,2,3,4,5,6,7,8], len: 8) seq
      val = ss droppedWhile(<4)
      val should mimic(Sequence DropWhile)
      val wrappedSequence should be same(ss)
      val messages should == ['(<4)]
    )

    it("should drop the objects",
      ss = SequenceTester with(val: [true, true, 1, false, 2, 3], len: 6) seq
      ss droppedWhile asList should == [false, 2,3]

      ss = SequenceTester with(val: [1,2,4,5,6,7,8], len: 7) seq
      ss droppedWhile(<3) asList should == [4,5,6,7,8]

      ss = SequenceTester with(val: [1,2,4,5,6,7,8], len: 7) seq
      ss droppedWhile(x, x < 3) asList should == [4,5,6,7,8]
    )
  )

  describe("rejected",
    it("should create a new Sequence Reject with the arguments sent to it",
      ss = SequenceTester with(val: [1,2,3,4,5,6,7,8], len: 8) seq
      val = ss rejected(>4)
      val should mimic(Sequence Reject)
      val wrappedSequence should be same(ss)
      val messages should == ['(>4)]
    )

    it("should filter the objects",
      ss = SequenceTester with(val: [1,2,3,4,5,6,7,8], len: 8) seq
      ss rejected(>4) asList should == [1,2,3,4]

      ss = SequenceTester with(val: [1,2,3,4,5,6,7,8], len: 8) seq
      ss rejected(x, x>4) asList should == [1,2,3,4]
    )
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

  describe("Index",
    it("should mimic Sequence",
      Sequence Index should mimic(Sequence)
    )

    it("should take zero arguments and just index the elements",
      ss = Sequence Index create(SequenceTester with(val: [1,2,3], len: 3) seq, Ground, [], 0, 1)
      ss next should == [0, 1]
      ss asList should == [[1,2], [2,3]]
    )
  )

  describe("Zip",
    it("should mimic Sequence",
      Sequence Zip should mimic(Sequence)
    )

    it("should take zero arguments and just zip the elements",
      ss = Sequence Zip create(SequenceTester with(val: [1,2,3], len: 3) seq, Ground, [])
      ss next should == [1]
      ss asList should == [[2], [3]]
    )

    it("should take one argument as a list and zip the elements together",
      ss = Sequence Zip create(SequenceTester with(val: [1,2,3], len: 3) seq, Ground, [], [5,6,7])
      ss next should == [1,5]
      ss asList should == [[2,6], [3,7]]

      ss = Sequence Zip create(SequenceTester with(val: [1,2,3], len: 3) seq, Ground, [], [5,6,7,8])
      ss next should == [1,5]
      ss asList should == [[2,6], [3,7]]
    )

    it("should take one argument as a seq and zip the elements together",
      ss = Sequence Zip create(SequenceTester with(val: [1,2,3], len: 3) seq, Ground, [], SequenceTester with(val: [9,10,11], len: 3) seq)
      ss next should == [1,9]
      ss asList should == [[2,10], [3,11]]
    )

    it("should supply nils if the second list isn't long enough",
      ss = Sequence Zip create(SequenceTester with(val: [1,2,3], len: 3) seq, Ground, [], [5,6])
      ss next should == [1,5]
      ss asList should == [[2,6], [3,nil]]
    )

    it("should zip together several lists",
      ss = Sequence Zip create(SequenceTester with(val: [1,2,3], len: 3) seq, Ground, [], [5,6,7], [10,11,12], [15,16,17])
      ss next should == [1,5,10,15]
      ss asList should == [[2,6,11,16], [3,7,12,17]]
    )
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

    it("should take zero arguments and return everything after the point where a value is true",
      ss = Sequence DropWhile create(SequenceTester with(val: [1,2,3], len: 3) seq, Ground, [])
      ss asList should == []

      ss = Sequence DropWhile create(SequenceTester with(val: [1,2,nil,false], len: 4) seq, Ground, [])
      ss asList should == [nil, false]

      ss = Sequence DropWhile create(SequenceTester with(val: [1,2,false,3,4,nil,false], len: 7) seq, Ground, [])
      ss asList should == [false,3,4,nil,false]
    )

    it("should take one argument and apply it as a message chain, return a list with all elements after the block returns false",
      ss = Sequence DropWhile create(SequenceTester with(val: [1,2,3], len: 3) seq, Ground, ['(<3)])
      ss asList should == [3]

      ss = Sequence DropWhile create(SequenceTester with(val: [1,2,3], len: 3) seq, Ground, ['(!=2)])
      ss asList should == [2,3]
    )

    it("should take two arguments and apply the lexical block created from it, and return a list with all elements after the block returns false",
      ss = Sequence DropWhile create(SequenceTester with(val: [1,2,3], len: 3) seq, Ground, ['x, '(x<3)])
      ss asList should == [3]

      ss = Sequence DropWhile create(SequenceTester with(val: [1,2,3], len: 3) seq, Ground, ['x, '(x != 2)])
      ss asList should == [2,3]
    )
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
