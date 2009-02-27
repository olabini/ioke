use("ispec")
use("iopt")

describe(IOpt,


  describe("iopt:ion", 
    
    it("should recognize a short option", 
      m = IOpt iopt:ion("-f")
      m should not be nil
      m long should be nil
      m flag should == "-f"
      m immediate should be nil)
    
    it("should recognize a long option", 
      m = IOpt iopt:ion("--foo")
      m should not be nil
      m long should not be nil
      m flag should == "--foo"
      m immediate should be nil)
    
    it("should not recognize something that is not an option", 
      IOpt iopt:ion("foo") should be nil
      IOpt iopt:ion("- foo") should be nil
      IOpt iopt:ion(" -foo") should be nil
      IOpt iopt:ion("--@foo") should be nil
      IOpt iopt:ion("--fo@") should be nil)
    
    it("should obtain the immediate value for a short option using =",
      m = IOpt iopt:ion("-f=22")
      m should not be nil
      m long should be nil
      m flag should == "-f"
      m immediate should == "22")
    
    it("should obtain the immediate value for a short option using =",
      m = IOpt iopt:ion("-f22=moo")
      m should not be nil
      m long should be nil
      m flag should == "-f22"
      m immediate should == "moo")
    
    it("should obtain the immediate value for a short option",
      m = IOpt iopt:ion("-f22")
      m should not be nil
      m long should be nil
      m flag should == "-f"
      m immediate should == "22")

    it("should obtain the immediate value for a long option using =",
        m = IOpt iopt:ion("--foo=bar")
        m should not be nil
        m long should not be nil
        m flag should == "--foo"
        m immediate should == "bar")
      
  );iopt:ion

  describe("iopt:key",
    it("should return nil for a non option keyword",
      m = IOpt iopt:key("--foo")
      m should be nil)

    it("should return nil for a non option keyword",
      m = IOpt iopt:key("jojo :")
      m should be nil)

    it("should recognize an option keyword",
      m = IOpt iopt:key("foo:")
      m should not be nil
      m name should == "foo"
      m immediate should be nil)

    it("should obtain the immediate value for an option keyword",
      m = IOpt iopt:key("foo:jojo")
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

     it("should have self as the default receiver",
       o = IOpt mimic
       o["-f"] = fn()
       o["-f"] receiver should == o)

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

    it("should return self if no args given", 
      o = IOpt mimic
      o on should == o)

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
        o on(nil) should mimic(o))

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

 describe("on=",

    describe("when given flags as first arguments", 
      it("should create an Action ValueActivation",
        o = IOpt mimic
        o on("-h", "--help") = fn("Display Help", @print. System exit)
        o["-h"] should mimic(IOpt Action ValueActivation)
        o["--help"] should mimic(IOpt Action ValueActivation))

      describe("when the last argument is a symbol",

        it("should create a cell assingment action if symbol starts with :@",
          o = IOpt mimic
          o on("--set") = :@setMePlease
          o["--set"] should mimic(IOpt Action CellAssignment))

        it("should create a cell activation action",
          o = IOpt mimic
          o pleaseCallMe! = method(:called)
          o on("--call") = :pleaseCallMe!
          o["--call"] should mimic(IOpt Action CellActivation))
        
      )
    )

    describe("when given an object as only argument",

      it("should signal error if not given enought arguments",
        o = IOpt mimic
        fn(o on = nil) should signal(Condition Error Invocation NoMatch))

      it("should set the new receiver for actions defined with []=",
        v = Origin mimic
        o = IOpt mimic
        o on(v, "-f") = :foo
        o["-f"] receiver should == v)

      it("should set the new receiver for actions defined with on",
        v = Origin mimic
        o = IOpt mimic
        o on(v, "--yay") = fn("Yay!", yay println)
        o["--yay"] receiver should == v)
    )

    describe("when given an object as first argument",
      
      it("should create an Action ValueActivation having a receiver",
        v = Origin mimic
        o = IOpt mimic
        o on(v, "-h", "--help") = fn("Display Help", @print. System exit)
        o["-h"] should mimic(IOpt Action ValueActivation)
        o["--help"] should mimic(IOpt Action ValueActivation)
        o["--help"] receiver should == v)

      describe("when the last argument is a symbol",

        it("should create a cell assingment action if symbol starts with :@",
          v = Origin mimic
          o = IOpt mimic
          o on(v, "--set", "Assign value to a cell on v") = :@setMePlease
          o["--set"] should mimic(IOpt Action CellAssignment)
          o["--set"] receiver should == v)

        it("should create a cell activation action",
          v = Origin mimic
          o = IOpt mimic
          o on(v, "--call", "Activating a cell on v") = :pleaseCallMe!
          o["--call"] should mimic(IOpt Action CellActivation)
          o["--call"] receiver should == v)
  
      )
    )
   
 );on=

 describe("parse!",
   it("should execute options by priority",
     order = []
     o = IOpt mimic
     o on("-a", order << :a)
     o on("-b", order << :b) priority = -2
     o on("-c", order << :c) priority = -1
     o on("-d", order << :d) priority = 3
     o on("-e", order << :e)
     o parse!(["-d", "-e", "-c", "-a", "-b"])
     order should == [:b, :c, :e, :a, :d])
   
   it("should not modify original arguments and store them on argv cell",
     o = IOpt mimic
     o on("-a", nil)
     o parse!(["-not-an-option", "-a", "yes", "hey"])
     o argv should == ["-not-an-option", "-a", "yes", "hey"])

   it("should store non option arguments on programArguments cell",
     o = IOpt mimic
     o on("-a", nil)
     o parse!(["-not-an-option", "-a", "yes", "hey"])
     o programArguments should == ["-not-an-option", "yes", "hey"])
 )

 describe("help",
   it("should have a Help Simple Plain by default", 
     o = IOpt mimic
     h = o help(:plain)
     h should not be nil)
 )

); IOpt


describe(IOpt Action ValueActivation,

  it("should obtain the documentation from the valueToActivate",
    f = fn("BlaBla", nil)
    a = IOpt Action ValueActivation mimic(cell(:f))
    a documentation should == "BlaBla")
  
  it("should obtain the argument names from the valueToActivate",
    f = fn(a, b "yes", +c, d:, f: 22, +:g, nil)
    a = IOpt Action ValueActivation mimic(cell(:f)) arity
    a names should == [:a, :b]
    a rest should == :c
    a keywords should == [:d, :f]
    a krest should == :g)

  it("should activate the value on the receiver",
    f = method(v, @cell(:yo) = v)
    a = IOpt Action ValueActivation mimic(cell(:f))
    o = Origin mimic
    a receiver = o
    a call(24)
    o yo should == 24)

  it("should set cell(:it) to the receiver when activating a block",
    v = nil
    a = IOpt Action ValueActivation mimic(fn(v = it))
    o = Origin mimic
    a receiver = o
    a call()
    v should == o)
  
);IOpt Action ValueActivation

describe(IOpt Action CellActivation, 
  
  it("should obtain the documentation from the named cell",
    o = Origin mimic do(foo = method("Fooing", bar, @baz = bar))
    a = IOpt Action CellActivation mimic(:foo)
    a receiver = o
    a documentation should == "Fooing")

  it("should obtain the arity from the named cell",
    o = Origin mimic do(foo = method("Fooing", bar, @baz = bar))
    a = IOpt Action CellActivation mimic(:foo)
    a receiver = o
    a = a arity
    a names should == [:bar]
    a keywords should be empty
    a rest should be nil
    a krest should be nil)

  it("should activate the named cell on receiver",
    o = Origin mimic do(foo = method("Fooing", bar, @baz = bar))
    a = IOpt Action CellActivation mimic(:foo)
    a receiver = o
    a call(24)
    o baz should == 24)
  
); IOpt Action CellActivation

describe(IOpt Action CellAssignment,
  
  it("should use a default documentation for setting named cell",
    o = Origin mimic
    a = IOpt Action CellAssignment mimic(:foo)
    a documentation should == "Set foo")

  it("should use an arity of one required argument named as the cell",
    o = Origin mimic
    a = IOpt Action CellAssignment mimic(:foo)
    a = a arity
    a names should == [:foo]
    a keywords should be empty
    a rest should be nil
    a krest should be nil)

  it("should set the named cell on receiver",
    o = Origin mimic
    a = IOpt Action CellAssignment mimic(:foo)
    a receiver = o
    a call(24)
    o foo should == 24)
  
); IOpt Action CellAssignmnet

describe(IOpt Action MessageEvaluation,

  it("should provide default documentation",
    a = IOpt Action MessageEvaluation mimic('foo)
    a documentation should == "Evaluate message foo")

  it("should have an empty arity by default",
    a = IOpt Action MessageEvaluation mimic('foo) arity
    a names should be empty
    a keywords should be empty
    a rest should be nil
    a krest should be nil)

  it("should activate the message without arguments",
    o = Origin mimic do(
      foo = method(@me = 24))
    a = IOpt Action MessageEvaluation mimic('foo)
    a receiver = o
    a call()
    o me should == 24)

); IOpt Action MessageEvaluation

describe(IOpt Action,

  describe("argumentsCode=",
    it("should clear arity when assigned nil",
      a = IOpt Action mimic
      a argumentsCode = nil
      i = a arity
      i names should be empty
      i keywords should be empty
      i rest should be nil
      i krest should be nil)

    it("should parse arity when assigned an string",
      a = IOpt Action mimic
      a argumentsCode = "a, b 1, +c, d:, e: 33, +:f"
      i = a arity
      i names should == [:a, :b]
      i keywords should == [:d, :e]
      i rest should == :c
      i krest should == :f)
  )

  describe("consume",

    it("should consume no arguments if the arity is empty",
      o = IOpt mimic
      a = IOpt Action mimic do(init. flags << "-f")
      a iopt = o
      a argumentsCode = nil
      c = a consume(["-f", "jojo", "-hey"])
      c flag should == "-f"
      c remnant should == ["jojo", "-hey"]
      c positional should be empty
      c keywords should be empty)

    it("should take only required arguments",
      o = IOpt mimic
      a = IOpt Action mimic do(init. flags << "-f")
      a iopt = o
      a argumentsCode = "a,b"
      c = a consume(["-f", "jojo", "jaja", "-hey"])
      c flag should == "-f"
      c remnant should == ["-hey"]
      c positional should == ["jojo", "jaja"]
      c keywords should be empty)

    it("should take only required arguments",
      o = IOpt mimic
      a = IOpt Action mimic do(init. flags << "-f")
      a iopt = o
      a argumentsCode = "a,b"
      c = a consume(["-f", "jojo", "--notanoption", "-hey"])
      c flag should == "-f"
      c remnant should == ["-hey"]
      c positional should == ["jojo", "--notanoption"]
      c keywords should be empty)


    it("should take only required arguments before next option",
      o = IOpt mimic
      a = IOpt Action mimic do(init. flags << "-f")
      o["--jaja"] = a
      a iopt = o
      a argumentsCode = "a,b"
      c = a consume(["-f", "jojo", "--jaja", "-hey"])
      c flag should == "-f"
      c remnant should == ["--jaja", "-hey"]
      c positional should == ["jojo"]
      c keywords should be empty)

    it("should take only rest arguments before next option",
      o = IOpt mimic
      a = IOpt Action mimic do(init. flags << "-f")
      o["--jaja"] = a
      a iopt = o
      a argumentsCode = "+rest"
      c = a consume(["-f", "jojo", "-hey", "you:notKey", "--jaja", "--jiji"])
      c flag should == "-f"
      c remnant should == ["--jaja", "--jiji"]
      c positional should == ["jojo", "-hey", "you:notKey"]
      c keywords should be empty)
    
    it("should take keyword arguments before next option",
      o = IOpt mimic
      a = IOpt Action mimic do(init. flags << "-f")
      o["--jaja"] = a
      a iopt = o
      a argumentsCode = "+rest, you:, +:all"
      c = a consume(["-f", "jojo", "-hey", "you:aKey",
          "one:", "1", "two:2", "--jaja", "--jiji"])
      c flag should == "-f"
      c remnant should == ["--jaja", "--jiji"]
      c positional should == ["jojo", "-hey"]
      c keywords should == dict(you: "aKey", one: "1", two: "2" ))

  )

  describe("perform",

    it("should execute actions having the iopt object as receiver",
      o = IOpt mimic
      a = o["-f"] = method(self)
      a perform(a consume(["-f"])) should == o
    )
    
    it("should take receiver from the iopt object given as second argument",
      o = IOpt mimic
      o["-f"] = method(self)
      u = o mimic
      a = u["-f"]
      a perform(a consume(["-f"]), u) should == u
    )

    it("should not mask the receiver if it was explicitly defined",
      v = Origin mimic
      o = IOpt mimic
      o on(v)["-f"] = method(self)
      u = o mimic
      a = u["-f"]
      a perform(a consume(["-f"]), u) should == v
    )
    
  )
); IOpt Action
