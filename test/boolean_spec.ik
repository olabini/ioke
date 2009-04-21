
use("ispec")

describe(true, 
  describe("false?", 
    it("should return false", 
      true false? should be false
      x = true. x false? should be false
    )
  )

  describe("true?", 
    it("should return true", 
      true true? should be true
      x = true. x true? should be true
    )
  )

  describe("not", 
    it("should return false", 
      true not should be false
      x = true. x not should be false
    )
  )

  describe("and", 
    it("should evaluate it's argument", 
      x=41. true and(x=42). x should == 42
    )

;     it("should complain if no argument is given", 
;       fn(true and()) should signal(Condition Error NativeException)
;     )

    it("should return the result of the argument", 
      (true and(42)) should == 42
    )

    it("should be available in infix", 
      (true and 43) should == 43
    )
  )

  describe("or", 
    it("should not evaluate it's argument", 
      x=41. true or(x=42). x should == 41
    )

    it("should return true", 
      (true or(42)) should be true
    )

    it("should be available in infix", 
      (true or 43) should be true
    )
  )

  describe("&&", 
    it("should evaluate it's argument", 
      x=41. true &&(x=42). x should == 42
    )

    it("should return the result of the argument", 
      (true &&(42)) should == 42
    )

    it("should be available in infix", 
      (true && 43) should == 43
    )
  )

  describe("||", 
    it("should not evaluate it's argument", 
      x=41. true ||(x=42). x should == 41
    )

    it("should return true", 
      (true ||(42)) should be true
    )

    it("should be available in infix", 
      (true || 43) should be true
    )
  )

  describe("?&", 
    it("should evaluate it's argument", 
      x=41. true ?&(x=42). x should == 42
    )

    it("should return the result of the argument", 
      (true ?&(42)) should == 42
    )

    it("should be available in infix", 
      (true ?& 43) should == 43
    )
  )

  describe("?|", 
    it("should not evaluate it's argument", 
      x=41. true ?|(x=42). x should == 41
    )

    it("should return true", 
      (true ?|(42)) should be true
    )

    it("should be available in infix", 
      (true ?| 43) should be true
    )
  )
  
  describe("xor", 
    it("should evaluate it's argument", 
      x=41. true xor(x=42). x should == 42
    )

;     it("should complain if no argument is given", 
;       fn(true xor()) should signal(Condition Warning)
;     )

    it("should return false if the argument is true", 
      (true xor(true)) should be false
    )

    it("should return true if the argument is false", 
      (true xor(false)) should be true
    )

    it("should return true if the argument is nil", 
      (true xor(nil)) should be true
    )
    
    it("should be available in infix", 
      (true xor 43) should be false
    )
  )

  describe("nor", 
    it("should not evaluate it's argument", 
      x=41. true nor(x=42). x should == 41
    )

    it("should return false", 
      (true nor(42)) should be false
    )

    it("should be available in infix", 
      (true nor 43) should be false
    )
  )

  describe("nand", 
    it("should evaluate it's argument", 
      x=41. true nand(x=42). x should == 42
    )

;     it("should complain if no argument is given", 
;       fn(true nand()) should signal(Condition Warning)
;     )

    it("should return false if the argument evaluates to true", 
      (true nand(42)) should be false
    )
    
    it("should return true if the argument evaluates to false", 
      (true nand(false)) should be true
    )
    
    it("should return true if the argument evaluates to nil", 
      (true nand(nil)) should be true
    )

    it("should be available in infix", 
      (true nand 43) should be false
    )
  )
  
  describe("ifTrue", 
    it("should execute it's argument", 
      x=41. true ifTrue(x=42). x should == 42
    )

    it("should return true", 
      true ifTrue(x=42) should be true
    )
  )

  describe("ifFalse", 
    it("should not execute it's argument", 
      x=41. true ifFalse(x=42). x should == 41
    )

    it("should return true", 
      true ifFalse(x=42) should be true
    )
  )
)

describe(false, 
  describe("false?", 
    it("should return true", 
      false false? should be true
      x = false. x false? should be true
    )
  )

  describe("true?", 
    it("should return false", 
      false true? should be false
      x = false. x true? should be false
    )
  )

  describe("not", 
    it("should return true", 
      false not should be true
      x = false. x not should be true
    )
  )

  describe("and", 
    it("should not evaluate it's argument", 
      x=41. false and(x=42). x should == 41
    )

    it("should return false", 
      (false and(42)) should be false
    )

    it("should be available in infix", 
      (false and 43) should be false
    )
  )

  describe("&&", 
    it("should not evaluate it's argument", 
      x=41. false &&(x=42). x should == 41
    )

    it("should return false", 
      (false &&(42)) should be false
    )

    it("should be available in infix", 
      (false && 43) should be false
    )
  )

  describe("?&", 
    it("should not evaluate it's argument", 
      x=41. false ?&(x=42). x should == 41
    )

    it("should return false", 
      (false ?&(42)) should be false
    )

    it("should be available in infix", 
      (false ?& 43) should be false
    )
  )
  
  describe("xor", 
    it("should evaluate it's argument", 
      x=41. false xor(x=42). x should == 42
    )

;     it("should complain if no argument is given", 
;       fn(false xor()) should signal(Condition Warning)
;     )

    it("should return true if the argument is true", 
      (false xor(true)) should be true
    )

    it("should return false if the argument is false", 
      (false xor(false)) should be false
    )

    it("should return false if the argument is nil", 
      (false xor(nil)) should be false
    )
    
    it("should be available in infix", 
      (false xor 43) should be true
    )
  )

  describe("nand", 
    it("should not evaluate it's argument", 
      x=41. false nand(x=42). x should == 41
    )

    it("should return true", 
      (false nand(42)) should be true
      (false nand(false)) should be true
      (false nand(nil)) should be true
      (false nand(true)) should be true
    )
    
    it("should be available in infix", 
      (false nand 43) should be true
    )
  )

  describe("or", 
    it("should evaluate it's argument", 
      x=41. false or(x=42). x should == 42
    )

    it("should return the result of the argument", 
      (false or(42)) should == 42
    )

    it("should be available in infix", 
      (false or 43) should == 43
    )
  )

  describe("||", 
    it("should evaluate it's argument", 
      x=41. false ||(x=42). x should == 42
    )

    it("should return the result of the argument", 
      (false ||(42)) should == 42
    )

    it("should be available in infix", 
      (false || 43) should == 43
    )
  )

  describe("?|", 
    it("should evaluate it's argument", 
      x=41. false ?|(x=42). x should == 42
    )

    it("should return the result of the argument", 
      (false ?|(42)) should == 42
    )

    it("should be available in infix", 
      (false ?| 43) should == 43
    )
  )
  
  describe("nor", 
    it("should evaluate it's argument", 
      x=41. false nor(x=42). x should == 42
    )

;     it("should complain if no argument is given", 
;       fn(false nor()) should signal(Condition Warning)
;     )

    it("should return false if the argument is true", 
      (false nor(42)) should be false
    )

    it("should return false if the argument is false", 
      (false nor(false)) should be true
    )

    it("should return false if the argument is nil", 
      (false nor(nil)) should be true
    )

    it("should be available in infix", 
      (false nor 43) should be false
    )
  )
  
  describe("ifTrue", 
    it("should not execute it's argument", 
      x=41. false ifTrue(x=42). x should == 41
    )

    it("should return false", 
      false ifTrue(x=42) should be false
    )
  )

  describe("ifFalse", 
    it("should execute it's argument", 
      x=41. false ifFalse(x=42). x should == 42
    )

    it("should return false", 
      false ifFalse(x=42) should be false
    )
  )
)
