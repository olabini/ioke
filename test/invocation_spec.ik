
use("ispec")

describe("pass", 
  it("should be invoked instead of an non-existing method", 
    x = Origin mimic
    x pass = method(42)
    x bar should == 42
  )

  it("should get the correct name for a method", 
    x = Origin mimic
    x pass = macro(call message name)

    result = x bar
    result should == :bar
  )

  it("should get an argument if any is provided", 
    x = Origin mimic
    x pass = method(arg1, arg1)
    x bar(42) should == 42
  )
  
  it("should be possible to define a pass that is a macro", 
    x = Origin mimic
    x pass = macro([call message name, call evaluatedArguments])
    x bar(42,4+4) should == [:bar, [42, 8]]
  )

  it("should honor an applicable? method if one exists on the pass object",
    x = Origin mimic
    val = []
    x pass = fnx(val << :passed)
    x cell(:pass) applicable? = fnx(msg, val << [:applicable, msg name]. true)
    x blarg
    val should == [[:applicable, :blarg], :passed]
  )

  it("should raise a regular cellnotfound if the applicable method returns false",
    x = Origin mimic
    val = []
    x pass = fnx(val << :passed)
    x cell(:pass) applicable? = fnx(msg, val << [:applicable, msg name]. false)
    fn(x blarg) should signal(Condition Error NoSuchCell)
    val should == [[:applicable, :blarg]]
  )
)

; describe("activate", 
;   it("should have specs")
; )
