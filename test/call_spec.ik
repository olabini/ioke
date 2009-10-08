
use("ispec")

describe(Call,
  describe("ground",
    it("should return the surrounding context of the call",
      x = macro(call ground)
      should == x
    )

    it("should check the receiver type and signal an appropriate condition",
      Call should checkReceiverTypeOn(:ground)
    )
  )

  describe("message",
    it("should return the message used to invoke this call",
      x = macro(call message)
      x name should == :x
    )

    it("should check the receiver type and signal an appropriate condition",
      Call should checkReceiverTypeOn(:message)
    )
  )

  describe("argAt",
    it("should evaluate and return the argument at the specific place",
      x = macro(call argAt(0))
      x(23+44) should ==  67
    )

;     it("should raise an error if no arg at the index specified was available",
;       x = macro(call argAt(0))
;       fn(x) should signal(Condition Warning)
;     )
  )

  describe("arguments",
    it("should return all arguments in a list, unevaluated",
      x = macro(call arguments)

      x(foo bar, x rrr)[0] name should == :foo
      x(foo bar, x rrr)[1] name should == :x
    )

    it("should check the receiver type and signal an appropriate condition",
      Call should checkReceiverTypeOn(:arguments)
    )
  )

  describe("evaluatedArguments",
    it("should return a list of all the evaluated arguments",
      x = macro(call evaluatedArguments)

      x(13+55, 18+18, 3-2)[0] should == 68
      x(13+55, 18+18, 3-2)[1] should == 36
      x(13+55, 18+18, 3-2)[2] should == 1
    )

    it("should check the receiver type and signal an appropriate condition",
      Call should checkReceiverTypeOn(:evaluatedArguments)
    )
  )

  describe("resendToMethod",
    it("it should resend the thing with the same arguments",
      x = macro(call resendToMethod(:f))
      f = method(a, b, c, [a, b, c])
      w = 13

      x(1+w, w+w, w+3+w)[0] should == 14
      x(1+w, w+w, w+3+w)[1] should == 26
      x(1+w, w+w, w+3+w)[2] should == 29
    )

    it("should check the receiver type and signal an appropriate condition",
      Call should checkReceiverTypeOn(:resendToMethod, :f)
    )
  )

  describe("resendToReceiver",
    it("it should resend the thing with the same arguments",
      blarg = Origin mimic
      blarg2 = Origin mimic
      blarg x = lecro(call resendToReceiver(blarg2))
      blarg2 x = method(a, b, c, [a, b, c])
      w = 13

      blarg x(1+w, w+w, w+3+w)[0] should == 14
      blarg x(1+w, w+w, w+3+w)[1] should == 26
      blarg x(1+w, w+w, w+3+w)[2] should == 29
    )

    it("should check the receiver type and signal an appropriate condition",
      Call should checkReceiverTypeOn(:resendToReceiver, :f)
    )
  )

  describe("receiver",
    it("should check the receiver type and signal an appropriate condition",
      Call should checkReceiverTypeOn(:receiver)
    )
  )

  describe("currentContext",
    it("should check the receiver type and signal an appropriate condition",
      Call should checkReceiverTypeOn(:currentContext)
    )
  )

  describe("resendToValue",
    it("should check the receiver type and signal an appropriate condition",
      Call should checkReceiverTypeOn(:resendToValue, method())
    )
  )

  describe("activateValue",
    it("should check the receiver type and signal an appropriate condition",
      Call should checkReceiverTypeOn(:activateValue, method())
    )
  )

  describe("activateValueWithCachedArguments",
    it("should check the receiver type and signal an appropriate condition",
      Call should checkReceiverTypeOn(:activateValueWithCachedArguments, method())
    )
  )
)
