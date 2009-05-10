
use("ispec")

describe(Origin,
  describe("print",
    it("should print asText of object to 'System out'",
      oldSystemOutPrint = System out cell(:print)
      Ground expected = nil
      System out print = method(arg, Ground expected = arg)
      
      "foobarz" print

      System out print = cell(:oldSystemOutPrint)
      
      expected should == "foobarz"
    )
  )

  describe("println",
    it("should print asText of object to 'System out'",
      oldSystemOutPrintln = System out cell(:println)
      Ground expected = nil
      System out println = method(arg, Ground expected = arg)
      
      "foobarz" println

      System out println = cell(:oldSystemOutPrintln)
      
      expected should == "foobarz"
    )
  )

  describe("===",
    it("should check for mimicness if receiver is Origin",
      Origin should === Origin
      Origin should === Origin mimic
      Origin should === "foo"
      Origin should not === Ground
    )

    it("should check for equalness if receiver is not Origin",
      x = Origin mimic
      y = Origin mimic

      z = Origin mimic
      z == = fnx(other, other same?(x))

      x should === x
      x should not === y
      x should not === Origin
      x should not === z
      
      z should not === z
      z should === x
    )
  )

  describe("around mimic",
    it("should ignore arguments sent to mimic",
      fn(Origin mimic(1,2,3,4,5)) should not signal(Condition Error)
    )

    it("should call initalize if such a cell exists",
      X = Origin mimic
      Ground argumentsGiven = []
      X initialize = method(+rest, +:krest, argumentsGiven << [rest, krest])
      X mimic(12, foo: 42, 555+2)
      argumentsGiven should == [[[12, 557],{foo: 42}]]

    )

    it("should return a new mimic of the object",
      X = Origin mimic
      x = X mimic
      x should not be same(X)
      x should be mimic(X)
    )
  )

  describe("eval",
    it("should eval on the receiver",
      x = Origin mimic
      x foo = 42
      x eval("foo should == 42")
      x eval("identity") should be same(x)
   )

    it("should eval an empty string",
      Origin eval("") should == nil
    )

    it("should eval a number",
      Origin eval("1") should == 1
    )

    it("should eval a simple message",
      Origin eval("[](1,2,3,4)") should == [1,2,3,4]
    )

    it("should eval a message with operator shuffling",
      Origin eval("1 + 2") should == 3
    )

    it("should eval multiple message chains",
      Origin eval("sam = 1. boris = 5. sooze = 10. sam + boris + sooze") should == 16
    )
  )
      
)
  
