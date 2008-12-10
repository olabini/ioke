
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
)
  
