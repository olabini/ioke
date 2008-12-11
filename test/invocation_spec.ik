
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
)

; describe("activate", 
;   it("should have specs")
; )
