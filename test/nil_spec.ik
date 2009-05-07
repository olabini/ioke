
use("ispec")

describe("nil", 
  describe("nil?", 
    it("should return true", 
      nil nil? should be true
      x = nil. x nil? should be true
    )
  )

  describe("false?", 
    it("should return true", 
      nil false? should be true
      x = nil. x false? should be true
    )
  )

  describe("true?", 
    it("should return false", 
      nil true? should be false
      x = nil. x true? should be false
    )
  )

  describe("not", 
    it("should return true", 
      nil not should be true
      x = nil. x not should be true
    )
  )

  describe("and", 
    it("should not evaluate it's argument", 
      x=41. nil and(x=42). x should == 41
    )

    it("should return nil", 
      (nil and(42)) should be nil
    )

    it("should be available in infix", 
      (nil and 43) should be nil
    )
  )

  describe("&&", 
    it("should not evaluate it's argument", 
      x=41. nil &&(x=42). x should == 41
    )

    it("should return nil", 
      (nil &&(42)) should be nil
    )

    it("should be available in infix", 
      (nil && 43) should be nil
    )
  )

  describe("?&", 
    it("should not evaluate it's argument", 
      x=41. nil ?&(x=42). x should == 41
    )

    it("should return nil", 
      (nil ?&(42)) should be nil
    )

    it("should be available in infix", 
      (nil ?& 43) should be nil
    )
  )
  
  describe("or", 
    it("should evaluate it's argument", 
      x=41. nil or(x=42). x should == 42
    )

;     it("should complain if no argument is given", 
;       fn(nil or()) should signal(Condition Error NativeException)
;     )

    it("should return the result of the argument", 
      (nil or(42)) should == 42
    )

    it("should be available in infix", 
      (nil or 43) should == 43
    )
  )
  
  describe("||", 
    it("should evaluate it's argument", 
      x=41. nil ||(x=42). x should == 42
    )

    it("should return the result of the argument", 
      (nil ||(42)) should == 42
    )

    it("should be available in infix", 
      (nil || 43) should == 43
    )
  )

  describe("?|", 
    it("should evaluate it's argument", 
      x=41. nil ?|(x=42). x should == 42
    )

    it("should return the result of the argument", 
      (nil ?|(42)) should == 42
    )

    it("should be available in infix", 
      (nil ?| 43) should == 43
    )
  )
  
  describe("xor", 
    it("should evaluate it's argument", 
      x=41. nil xor(x=42). x should == 42
    )

;     it("should complain if no argument is given", 
;       fn(nil xor()) should signal(Condition Error NativeException)
;     )

    it("should return true if the argument is true", 
      (nil xor(true)) should be true
    )

    it("should return false if the argument is false", 
      (nil xor(false)) should be false
    )

    it("should return false if the argument is nil", 
      (nil xor(nil)) should be false
    )
    
    it("should be available in infix", 
      (nil xor 43) should be true
    )
  )

  describe("nor", 
    it("should evaluate it's argument", 
      x=41. nil nor(x=42). x should == 42
    )

;     it("should complain if no argument is given", 
;       fn(nil nor()) should signal(Condition Error NativeException)
;     )

    it("should return false if the argument is true", 
      (nil nor(42)) should be false
    )

    it("should return false if the argument is false", 
      (nil nor(false)) should be true
    )

    it("should return false if the argument is nil", 
      (nil nor(nil)) should be true
    )

    it("should be available in infix", 
      (nil nor 43) should be false
    )
  )

  describe("nand",  
    it("should not evaluate it's argument", 
      x=41. nil nand(x=42). x should == 41
    )

    it("should return true", 
      (nil nand(42)) should be true
      (nil nand(false)) should be true
      (nil nand(nil)) should be true
      (nil nand(true)) should be true
    )
    
    it("should be available in infix", 
      (nil nand 43) should be true
    )
  )
)
