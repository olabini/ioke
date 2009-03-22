use("ispec")
use("iopt")

describe(IOpt,


  describe("iopt:ion", 
    
    it("should recognize a short option", 
      m = IOpt iopt:ion("-f")
      m should not be nil
      m long should be nil
      m option should == "-f"
      m immediate should be nil)
    
    it("should recognize a long option", 
      m = IOpt iopt:ion("--foo")
      m should not be nil
      m long should not be nil
      m option should == "--foo"
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
      m option should == "-f"
      m immediate should == "22")
    
    it("should obtain the immediate value for a short option using =",
      m = IOpt iopt:ion("-f22=moo")
      m should not be nil
      m long should be nil
      m option should == "-f22"
      m immediate should == "moo")
    
    it("should obtain the immediate value for a short option",
      m = IOpt iopt:ion("-f22")
      m should not be nil
      m long should be nil
      m option should == "-f"
      m immediate should == "22")

    it("should obtain the immediate value for a long option using =",
        m = IOpt iopt:ion("--foo=bar")
        m should not be nil
        m long should not be nil
        m option should == "--foo"
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
    
     it("should create an action by assigning a value to an option",
       o = IOpt mimic
       o["-f"] = fn()
       o["-f"] should mimic(IOpt Action ValueActivation))

     it("should have self as the default receiver",
       o = IOpt mimic
       o["-f"] = fn()
       o["-f"] receiver should == o)

     it("should create an action that activates a cell by assigning a symbol to an option",
       o = IOpt mimic
       o["-f"] = :flag
       o["-f"] should mimic(IOpt Action CellActivation))

     it("should create an action that evaluates a message by assigning to an option",
       o = IOpt mimic
       o["-f"] = Message fromText("why")
       o["-f"] should mimic(IOpt Action MessageEvaluation)
       o["-f"] = 'not
       o["-f"] should mimic(IOpt Action MessageEvaluation))

     it("should create an action that stores a cell by assigning a :@thing to an option",
       o = IOpt mimic
       o["-f"] = :"@flag"
       o["-f"] should mimic(IOpt Action CellAssignment)
       o["-f"] = :@thing
       o["-f"] should mimic(IOpt Action CellAssignment))

    it("should not create an action if given one to bind to an option",
      o = IOpt mimic
      o["-f"] = fn
      a = o["-f"]
      o["--foo"] = a
      o["--foo"] should == a)
    
    it("should alias an action by assigning an existing option to a new one",
      o = IOpt mimic
      o["-f"] = fn
      a = o["-f"]
      o["--foo"] = "-f"
      o["--foo"] should == a)

    it("should signal error if the option being aliased does not exist",
      o = IOpt mimic
      fn(o["--foo"] = "-f") should signal(IOpt NoActionForOption))
    
    it("should be possible to assign multiple options for a single action",
      o = IOpt mimic
      o["-f", "--foo"] = fn
      o["-f"] should == o["--foo"])

    it("should remove an action by assigning nil to its options", 
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

    describe("when given options as first arguments", 
      
      it("should create a lexical block to handle the option",
        o = IOpt mimic
        o on("-h", "--help", "Display Help", @print. System exit)
        o["-h"] should mimic(IOpt Action ValueActivation)
        o["--help"] should mimic(IOpt Action ValueActivation))

      it("should concatenate text for action documentation",
        o = IOpt mimic
        o on("-h", "Show", "This", "Help", @print)
        o["-h"] documentation should == "Show\nThis\nHelp")

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

        it("should create a cell assingment action if symbol starts with @",
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

    it("should evaluate the last argument as the action",
      o = IOpt mimic
      o showHelp = method(@print)
      o on("-h", "--help") = o cell(:showHelp)
      o["-h"] should mimic(IOpt Action ValueActivation)
      o["-h"] cell(:valueToActivate) should be same(o cell(:showHelp)))

    describe("when given options as first arguments", 
      it("should create an Action ValueActivation",
        o = IOpt mimic
        o on("-h", "--help") = fn("Display Help", @print. System exit)
        o["-h"] should mimic(IOpt Action ValueActivation)
        o["--help"] should mimic(IOpt Action ValueActivation))

      describe("when the last argument is a symbol",

        it("should create a cell assingment action if symbol starts with @",
          o = IOpt mimic
          o on("--set") = :"@setMePlease"
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

        it("should create a cell assingment action if symbol starts with @",
          v = Origin mimic
          o = IOpt mimic
          o on(v, "--set", "Assign value to a cell on v") = :"@setMePlease"
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
     argv = ["-not-an-option", "-a", "yes", "hey"]
     fn(o parse!(argv)) should signal(IOpt UnknownOption)
     o parse!(argv, errorUnknownOptions: false)
     o argv should == ["-not-an-option", "-a", "yes", "hey"])

   it("should store non option arguments on programArguments cell",
     o = IOpt mimic
     o on("-a", nil)
     argv = ["-not-an-option", "-a", "yes", "hey"]
     fn(o parse!(argv)) should signal(IOpt UnknownOption)
     o parse!(argv, errorUnknownOptions: false)
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

  it("should set self and @ to the receiver when activating a block",
    v = nil
    a = IOpt Action ValueActivation mimic(fn(v = [self, @]))
    o = Origin mimic
    a receiver = o
    a call()
    v should == [o, o])
  
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
      a = IOpt Action mimic do(options << "-f")
      a iopt = o
      a argumentsCode = nil
      c = a consume(["-f", "jojo", "-hey"])
      c option should == "-f"
      c remnant should == ["jojo", "-hey"]
      c positional should be empty
      c keywords should be empty)

    it("should take only required arguments",
      o = IOpt mimic
      a = IOpt Action mimic do(options << "-f")
      a iopt = o
      a argumentsCode = "a,b"
      c = a consume(["-f", "jojo", "jaja", "-hey"])
      c option should == "-f"
      c remnant should == ["-hey"]
      c positional should == ["jojo", "jaja"]
      c keywords should be empty)

    it("should take only required arguments",
      o = IOpt mimic
      a = IOpt Action mimic do(options << "-f")
      a iopt = o
      a argumentsCode = "a,b"
      c = a consume(["-f", "jojo", "--notanoption", "-hey"])
      c option should == "-f"
      c remnant should == ["-hey"]
      c positional should == ["jojo", "--notanoption"]
      c keywords should be empty)

    
    it("should take only required arguments before next option",
      o = IOpt mimic
      a = IOpt Action mimic do(options << "-f")
      o["--jaja"] = a
      a iopt = o
      a argumentsCode = "a,b"
      c = a consume(["-f", "jojo", "--jaja", "-hey"])
      c option should == "-f"
      c remnant should == ["--jaja", "-hey"]
      c positional should == ["jojo"]
      c keywords should be empty)

    it("should take only rest arguments before next option",
      o = IOpt mimic
      a = IOpt Action mimic do(options << "-f")
      o["--jaja"] = a
      a iopt = o
      a argumentsCode = "+rest"
      c = a consume(["-f", "jojo", "-hey", "you:notKey", "--jaja", "--jiji"])
      c option should == "-f"
      c remnant should == ["--jaja", "--jiji"]
      c positional should == ["jojo", "-hey", "you:notKey"]
      c keywords should be empty)
    
    it("should take keyword arguments before next option",
      o = IOpt mimic
      a = IOpt Action mimic do(options << "-f")
      o["--jaja"] = a
      a iopt = o
      a argumentsCode = "+rest, you:, +:all"
      c = a consume(["-f", "jojo", "-hey", "you:aKey",
          "one:", "1", "two:2", "--jaja", "--jiji"])
      c option should == "-f"
      c remnant should == ["--jaja", "--jiji"]
      c positional should == ["jojo", "-hey"]
      c keywords should == dict(you: "aKey", one: 1, two: 2 ))

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

describe(IOpt CommandLine, 

  it("should include unknown options (default)",
    o = IOpt mimic
    c = IOpt CommandLine mimic(o, ["--foo", "bar", "--bat"])
    c should be empty
    c rest should be empty
    c unknownOptions should == ["--foo", "--bat"]
    c programArguments should == ["--foo", "bar", "--bat"])

  it("should not include unknown options if includeUnknownOption is false",
    o = IOpt mimic
    c = IOpt CommandLine mimic(o, ["--foo", "bar", "--bat"], includeUnknownOption: false)
    c should be empty
    c rest should be empty
    c unknownOptions should == ["--foo", "--bat"]
    c programArguments should == ["bar"])

  it("should process option arguments until next option is found (default)",
    o = IOpt mimic
    o on("--foo", arg0, nil)
    o on("--bat", nil)
    c = IOpt CommandLine mimic(o, ["--foo", "--bat", "man"])
    c rest should be empty
    c unknownOptions should be empty
    c programArguments should == ["man"]
    c options length should == 2
    f = c options first
    f option should == "--foo"
    f args positional should be empty
    f args keywords should be empty)

  it("should process option arguments even if they are options when argUntilNextOption is false",
    o = IOpt mimic
    o on("--foo", arg0, nil)
    o on("--bat", nil)
    c = IOpt CommandLine mimic(o, ["--foo", "--bat", "man"], argUntilNextOption: false)
    c rest should be empty
    c unknownOptions should be empty
    c programArguments should == ["man"]
    c options length should == 1
    f = c options first
    f option should == "--foo"
    f args positional should == ["--bat"]
    f args keywords should be empty)

  it("should take look-like option elements as valid option argument (default)",
    o = IOpt mimic
    o on("--foo", arg0, nil)
    o on("--bat", nil)
    c = IOpt CommandLine mimic(o, ["--foo", "--bar", "--bat", "man"])
    c rest should be empty
    c unknownOptions should be empty
    c programArguments should == ["man"]
    c options length should == 2
    f = c options first
    f option should == "--foo"
    f args positional should == ["--bar"]
    f args keywords should be empty)
  
  it("should stop processing command line when found value for stopAt",
    o = IOpt mimic
    o on("-f", v, nil)
    c = IOpt CommandLine mimic(o, 
      ["-f", "--bar", "man", "--bat", "--", "jojo"], stopAt: "--")
    c should include("-f")
    c unknownOptions should == ["--bat"]
    c programArguments should == ["man", "--bat"]
    c rest should == ["jojo"]
    c = IOpt CommandLine mimic(o, 
      ["-f", "--bar", "man", "--bat", "--"], stopAt: "--")
    c programArguments should == ["man", "--bat"]
    c rest should be empty)

  it("should coerce option arguments that are literals (default)",
    o = IOpt mimic
    o on("-f", +r, nil)
    c = IOpt CommandLine mimic(o, 
      ["-f", "true", "false", "nil", ":symbol", "24", "-12", "+12", "text"])
    f = c options first
    f option should == "-f"
    f args positional should == [true, false, nil, :symbol, 24, -12, 12, "text"]
    c = IOpt CommandLine mimic(o, ["-f", "3.14159", "-5.22", "+9.81"])
    f = c options first
    f args positional first should be close(3.14159)
    f args positional second should be close(-5.22)
    f args positional third should be close(9.81))

  it("should coerce option arguments just for the selected types",
    o = IOpt mimic
    o on("-f", +r, nil)
    c = IOpt CommandLine mimic(o,
      ["-f", "true", "false", "nil", ":symbol", "24", "text"],
      coerce: IOpt CommandLine Coerce mimic(:boolean, :symbol))
    f = c options first
    f option should == "-f"
    f args positional should == [true, false, "nil", :symbol, "24", "text"])

  it("should not coerce option arguments when given coerce: false",
    o = IOpt mimic
    o on("-f", +r, nil)
    c = IOpt CommandLine mimic(o, 
      ["-f", "true", "false", "nil", ":symbol", "24", "text"],
      coerce: false)
    f = c options first
    f option should == "-f"
    f args positional should == ["true", "false", "nil", ":symbol", "24", "text"])


  it("should allow action specific coercion",
    o = IOpt mimic
    o on("-n", +r, nil) coerce = false
    o on("-y", +r, nil) coerce = IOpt CommandLine Coerce mimic(
      yesno: #/^yes|no$/ => method(t, t == "yes")
    )
    o on("-s", +r, nil) coerce = IOpt CommandLine Coerce mimic(
      *IOpt CommandLine Coerce all,
      yesno: #/^si|no$/ => method(t, t == "si")
    )

    c = IOpt CommandLine mimic(o, 
      ["-n", "true", "-y", "no", "nil", "-s", "si", "nil"])
    f = c options first
    f option should == "-n"
    f args positional should == ["true"]
    f = c options second
    f option should == "-y"
    f args positional should == [false, "nil"]
    f = c options third
    f option should == "-s"
    f args positional should == [true, nil])

  it("should correctly parse clustered short options", 
    o = IOpt mimic
    o on("-a", nil)
    o on("-b", nil)
    o on("-v", +n, nil)
    c = IOpt CommandLine mimic(o, ["-abv", "3"])
    c options length should == 3
    c options first option should == "-a"
    c options first args positional should be empty
    c options second option should == "-b"
    c options first args positional should be empty
    c options third option should == "-v"
    c options third args positional should == [3]

    c = IOpt CommandLine mimic(o, ["-vab"])
    c options length should == 1
    c options first option should == "-v"
    c options first args positional should == ["ab"]

    c = IOpt CommandLine mimic(o, ["-v41v"])
    c options length should == 1
    c options first args positional should == ["41v"])

); IOpt CommandLine