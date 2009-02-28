
use("ispec")

describe("JavaGround",
  describe("integrate",
    describe("extending classes and implementing interfaces",
      it("should be possible to create a simple implementation of a simple interface",
        OneObject = integrate(ioke:lang:test:SimpleInterface)
        OneObject doSomething = method("called from a simple integration")
        
        OtherObject = OneObject mimic
        OtherObject doSomething = method("called from another simple integration")

        otherObject = OtherObject new
        otherObject doSomething = method("called from a single instance ...")

        anotherObject = otherObject mimic
        anotherObject doSomething = method("called from a mimic of a single instance ...")

        ioke:lang:test:SimpleInterfaceUser useObject(OneObject new) asText should == "called from a simple integration"
        ioke:lang:test:SimpleInterfaceUser useObject(OtherObject new) asText should == "called from another simple integration"
        ioke:lang:test:SimpleInterfaceUser useObject(otherObject) asText should == "called from a single instance ..."
        ioke:lang:test:SimpleInterfaceUser useObject(anotherObject) asText should == "called from a mimic of a single instance ..."
      )

      it("should be possible to create a simple extension of a simple class",
        FirstObject = integrate(ioke:lang:test:SimpleClass)
        SecondObject = FirstObject mimic
        SecondObject doTheThing = method("SecondObject implementation")
        
        OtherObject = SecondObject mimic
        OtherObject doTheThing = method("OtherObject implementation")

        otherObject = OtherObject new
        otherObject doTheThing = method("otherObject implementation")

        anotherObject = otherObject mimic
        anotherObject doTheThing = method("anotherObject implementation")

        ioke:lang:test:SimpleClassUser useObject(FirstObject new) asText should == "SimpleClass implementation"
        ioke:lang:test:SimpleClassUser useObject(SecondObject new) asText should == "SecondObject implementation"
        ioke:lang:test:SimpleClassUser useObject(OtherObject new) asText should == "OtherObject implementation"
        ioke:lang:test:SimpleClassUser useObject(otherObject) asText should == "otherObject implementation" 
        ioke:lang:test:SimpleClassUser useObject(anotherObject) asText should == "anotherObject implementation"
     )
    )
  )
)
