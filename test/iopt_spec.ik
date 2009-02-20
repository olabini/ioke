use("ispec")
use("iopt")

describe(IOpt,


  describe("iopt:ion", 
    
    it("should recognize a short option", 
      m = IOpt cell("iopt:ion") call("-f")
      m should not be nil
      m long should be nil
      m flag should == "-f"
      m immediate should be nil)
    
    it("should recognize a long option", 
      m = IOpt cell("iopt:ion") call("--foo")
      m should not be nil
      m long should not be nil
      m flag should == "--foo"
      m immediate should be nil)
    
    it("should not recognize something that is not an option", 
      IOpt cell("iopt:ion") call("foo") should be nil
      IOpt cell("iopt:ion") call("- foo") should be nil
      IOpt cell("iopt:ion") call(" -foo") should be nil
      IOpt cell("iopt:ion") call("--@foo") should be nil
      IOpt cell("iopt:ion") call("--fo@") should be nil)
    
    it("should obtain the immediate value for a short option using =",
      m = IOpt cell("iopt:ion") call("-f=22")
      m should not be nil
      m long should be nil
      m flag should == "-f"
      m immediate should == "22")
    
    it("should obtain the immediate value for a short option using =",
      m = IOpt cell("iopt:ion") call("-f22=moo")
      m should not be nil
      m long should be nil
      m flag should == "-f22"
      m immediate should == "moo")
    
    it("should obtain the immediate value for a short option",
      m = IOpt cell("iopt:ion") call("-f22")
      m should not be nil
      m long should be nil
      m flag should == "-f"
      m immediate should == "22")

    it("should obtain the immediate value for a long option using =",
        m = IOpt cell("iopt:ion") call("--foo=bar")
        m should not be nil
        m long should not be nil
        m flag should == "--foo"
        m immediate should == "bar")
      
  );iopt:ion

  describe("iopt:key",
    it("should return nil for a non option keyword",
      m = IOpt cell("iopt:key") call("--foo")
      m should be nil)

    it("should return nil for a non option keyword",
      m = IOpt cell("iopt:key") call("jojo :")
      m should be nil)

    it("should recognize an option keyword",
      m = IOpt cell("iopt:key") call("foo:")
      m should not be nil
      m name should == "foo"
      m immediate should be nil)

    it("should obtain the immediate value for an option keyword",
      m = IOpt cell("iopt:key") call("foo:jojo")
      m should not be nil
      m name should == "foo"
      m immediate should == "jojo")
  );iopt:key

  describe("[]", 
      
    it("should return nil for a non existing option", 
      o = IOpt mimic
      o["-f"] should be nil)
    
    it("should return the action that handles an option",
      a = IOpt Action mimic
      o = IOpt mimic
      o cell("iopt:actions")["-f"] = a
      o["-f"] should == a
      o["-f22"] should == a
      o["-f=22"] should == a)
    
    it("should signal error if the option has not associated an action",
      o = IOpt mimic
      o cell("iopt:actions")["-f"] = :foo
      fn(o["-f"]) should signal(IOpt NoActionForOption))
    
  );[]

   describe("[]=",
    
     it("should create an action by assigning a value to a flag",
       o = IOpt mimic
       o["-f"] = fn()
       o["-f"] should mimic(IOpt Action ValueActivation))

     it("should create an action that activates a cell by assigning a symbol to a flag",
       o = IOpt mimic
       o["-f"] = :flag
       o["-f"] should mimic(IOpt Action CellActivation))

     it("should create an action that evaluates a message by assigning to a flag",
       o = IOpt mimic
       o["-f"] = Message fromText("why")
       o["-f"] should mimic(IOpt Action MessageEvaluation)
       o["-f"] = 'not
       o["-f"] should mimic(IOpt Action MessageEvaluation))

     it("should create an action that stores a cell by assigning a :@thing to a flag",
       o = IOpt mimic
       o["-f"] = :"@flag"
       o["-f"] should mimic(IOpt Action CellAssignment)
       o["-f"] = :@thing
       o["-f"] should mimic(IOpt Action CellAssignment))

    it("should not create an action if given one to bind to a flag",
      o = IOpt mimic
      o["-f"] = fn
      a = o["-f"]
      o["--foo"] = a
      o["--foo"] should == a)
    
    it("should alias an action by assigning an existing flag to a new flag",
      o = IOpt mimic
      o["-f"] = fn
      a = o["-f"]
      o["--foo"] = "-f"
      o["--foo"] should == a)

    it("should signal error if the option being aliased does not exist",
      o = IOpt mimic
      fn(o["--foo"] = "-f") should signal(IOpt NoActionForOption))
    
    it("should be possible to assign multiple flags for a single action",
      o = IOpt mimic
      o["-f", "--foo"] = fn
      o["-f"] should == o["--foo"])

    it("should remove an action by assigning nil to its flag", 
      o = IOpt mimic
      o["-f", "--foo", "--bar"] = fn
      a = o["-f"]
      o["-f"] = nil
      o["--foo"] should == a
      o["--foo", "--bar"] = nil
      o["--foo"] should be nil
      o["--bar"] should be nil)
    
   );[]=

   describe("on", 

    describe("when given flags as first arguments", 
      it("should create a lexical block to handle the option",
        o = IOpt mimic
        o on("-h", "--help", "Display Help", @print. System exit)
        o["-h"] should mimic(IOpt Action ValueActivation)
        o["--help"] should mimic(IOpt Action ValueActivation))

      describe("when the last argument is a symbol",

        it("should create a cell assingment action if symbol starts with :@",
          o = IOpt mimic
          o on("--set", "Assign value to a cell on o", :@setMePlease)
          o["--set"] should mimic(IOpt Action CellAssignment))

        it("should create a cell activation action",
          o = IOpt mimic
          o on("--call", "Activating a cell on o", :pleaseCallMe!)
          o["--call"] should mimic(IOpt Action CellActivation))
        
      )
    )

    describe("when given an object as only argument",

      it("should return a mimic of the original Iopt object",
        o = IOpt mimic
        ;;o on(nil) should mimic(o)
      )        

      it("should set the new receiver for actions defined with []=",
        v = Origin mimic
        o = IOpt mimic
        o on(v)["-f"] = :foo
        o["-f"] receiver should == v)

      it("should set the new receiver for actions defined with on",
        v = Origin mimic
        o = IOpt mimic
        o on(v) on("--yay", "Yay!", yay println)
        o["--yay"] receiver should == v)
    )

    describe("when given an object as first argument",
      
      it("should create a lexical block having that object as receiver",
        v = Origin mimic
        o = IOpt mimic
        o on(v, "-h", "--help", "Display Help", @print. System exit)
        o["-h"] should mimic(IOpt Action ValueActivation)
        o["--help"] should mimic(IOpt Action ValueActivation)
        o["--help"] receiver should == v)

      describe("when the last argument is a symbol",

        it("should create a cell assingment action if symbol starts with :@",
          v = Origin mimic
          o = IOpt mimic
          o on(v, "--set", "Assign value to a cell on v", :@setMePlease)
          o["--set"] should mimic(IOpt Action CellAssignment)
          o["--set"] receiver should == v)

        it("should create a cell activation action",
          v = Origin mimic
          o = IOpt mimic
          o on(v, "--call", "Activating a cell on v", :pleaseCallMe!)
          o["--call"] should mimic(IOpt Action CellActivation)
          o["--call"] receiver should == v)
  
      )
    )

   );on

); IOpt
