
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

        ; this is a bit unintuitive, but it's the way it has to be
        ioke:lang:test:SimpleInterfaceUser useObject(anotherObject) asText should == "called from a single instance ..."
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

        ; this is a bit unintuitive, but it's the way it has to be
        ioke:lang:test:SimpleClassUser useObject(anotherObject) asText should == "otherObject implementation"
      )

      describe("returning booleans",
        it("should be possible to implement an interface method",
          Obj = integrate(ioke:lang:test:SimpleBooleanInterface)
          Obj doSomething = method(true)

          OtherObj = Obj mimic
          OtherObj doSomething = method(false)

          ioke:lang:test:SimpleUser useBooleanInterface(Obj new) should == true
          ioke:lang:test:SimpleUser useBooleanInterface(OtherObj new) should == false
        )

        it("should be possible to override a class method",
          Obj = integrate(ioke:lang:test:SimpleBooleanClass)
          SecondObj = Obj mimic
          SecondObj doTheThing = method(true)

          OtherObj = SecondObj mimic
          OtherObj doTheThing = method(false)

          ioke:lang:test:SimpleUser useBooleanObject(Obj new) should == false
          ioke:lang:test:SimpleUser useBooleanObject(SecondObj new) should == true
          ioke:lang:test:SimpleUser useBooleanObject(OtherObj new) should == false
        )
      )

      describe("returning ints",
        it("should be possible to implement an interface method",
          Obj = integrate(ioke:lang:test:SimpleIntInterface)
          Obj doSomething = method(13)

          OtherObj = Obj mimic
          OtherObj doSomething = method(54)

          ioke:lang:test:SimpleUser useIntInterface(Obj new) asRational should == 13
          ioke:lang:test:SimpleUser useIntInterface(OtherObj new) asRational should == 54
        )

        it("should be possible to override a class method",
          Obj = integrate(ioke:lang:test:SimpleIntClass)
          SecondObj = Obj mimic
          SecondObj doTheThing = method(677667)

          OtherObj = SecondObj mimic
          OtherObj doTheThing = method(12466)

          ioke:lang:test:SimpleUser useIntObject(Obj new) asRational should == 444
          ioke:lang:test:SimpleUser useIntObject(SecondObj new) asRational should == 677667
          ioke:lang:test:SimpleUser useIntObject(OtherObj new) asRational should == 12466
        )
      )

      describe("returning shorts",
        it("should be possible to implement an interface method",
          Obj = integrate(ioke:lang:test:SimpleShortInterface)
          Obj doSomething = method(13)

          OtherObj = Obj mimic
          OtherObj doSomething = method(54)

          ioke:lang:test:SimpleUser useShortInterface(Obj new) asRational should == 13
          ioke:lang:test:SimpleUser useShortInterface(OtherObj new) asRational should == 54
        )

        it("should be possible to override a class method",
          Obj = integrate(ioke:lang:test:SimpleShortClass)
          SecondObj = Obj mimic
          SecondObj doTheThing = method(43)

          OtherObj = SecondObj mimic
          OtherObj doTheThing = method(66)

          ioke:lang:test:SimpleUser useShortObject(Obj new) asRational should == 12
          ioke:lang:test:SimpleUser useShortObject(SecondObj new) asRational should == 43
          ioke:lang:test:SimpleUser useShortObject(OtherObj new) asRational should == 66
        )
      )

      describe("taking arguments",
        it("should have tests")
      )
    )
  )
)
