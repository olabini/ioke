use("ispec")
use("iopt")

describe(IOpt,

  describe("parse",
    it("should execute tasks by priority level",
      opt = IOpt mimic
      order = []
      opt on("-a", order << :a) priority = -10
      opt on("-b", order << :b) priority = 5
      opt on("-c", order << :c)
      opt on("-d", order << :d) priority = 1
      opt on("-e", order << :e)
      
      opt parse(["-d", "-b", "-e", "-a", "-c"])
      order should == [:a, :e, :c, :d, :b]))

  describe("[]=",

    it("should assign an option some code to execute",
      opt = IOpt mimic
      opt["--help"] = fn("Show help" println)
      help = opt["--help"]
      help should mimic(IOpt Action))

    it("should alias an option if RHS is an string",
      opt = IOpt mimic
      opt["--help"] = fn("Show help")
      opt["-h"] = "--help"
      opt["-h"] should == opt["--help"])

    it("should allow multiple options bound to the same action",
      opt = IOpt mimic
      opt["-h", "--help"] = fn("Show help", opt print)
      opt["-h"] should == opt["--help"])

  ); []=

  describe("[]",
    it("should return nil for a non existing option",
      opt = IOpt mimic
      opt["--missing"] should be nil)
    
    it("should obtain the action to handle alt option", 
      opt = IOpt mimic
      action = opt["--[dont-]cry"] = fn("Should you cry", v, v)
      opt["--cry"] should == action
      opt["--dont-cry"] should == action
      opt["--cry=yes"] should == action
      opt["--dont-cry=yes"] should == action)

    it("should obtain the action to handle short option",
      opt = IOpt mimic
      action = opt["-d", "-c"] = fn("Should you cry", v, v)
      opt["-cvf"] should == action
      opt["-d0"] should == action
      opt["-d=0"] should == action)

  ); []

  describe("on",

    it("should create a lexical block to handle option",
      opt = IOpt mimic
      opt magic? = false
      opt on("-m", "Does Magic", opt magic? = true)
      opt["-m"] should mimic(IOpt Action)
      opt should not be magic
      opt["-m"] call
      opt should be magic)

    it("should create an option for calling an object's method",
      obj = Origin mimic do(foo = method("Foes", v, @r = v))
      opt = IOpt mimic
      opt on(obj, :foo)
      obj cell?(:r) should be false
      opt["--foo"] should mimic(IOpt Action)
      opt["--foo"] call(:bar)
      obj r should == :bar)

    it("should create an option for calling an object's method",
      obj = Origin mimic do(foo = method("Foes", v, @r = v))
      opt = IOpt mimic
      opt on(obj, "--moo" :foo)
      obj cell?(:r) should be false
      opt["--moo"] should mimic(IOpt Action)
      opt["--moo"] call(:bar)
      obj r should == :bar)

    it("should create an option for storing an object cell",
      obj = Origin mimic
      opt = IOpt mimic
      opt on(obj, @moo)
      obj cell?(:moo) should be false
      opt["--moo"] should mimic(IOpt Action)
      opt["--moo"] call(:bar)
      obj cell(:moo) should == :bar)

    it("should create an option for storing an object cell",
      obj = Origin mimic
      opt = IOpt mimic
      opt on(obj, "--foo" @moo)
      obj cell?(:moo) should be false
      opt["--foo"] should mimic(IOpt Action)
      opt["--foo"] call(:bar)
      obj cell(:moo) should == :bar)

    it("should create an option for calling an object's setter",
      obj = Origin mimic do(cell(:"moo=") = method(v, @foo = v))
      opt = IOpt mimic
      opt on(obj, "--foo" :"moo=")
      obj cell?(:foo) should be false
      opt["--foo"] should mimic(IOpt Action)
      opt["--foo"] call(:bar)
      obj cell(:foo) should == :bar)

    it("should create an option for storing an object flag",
      obj = Origin mimic
      opt = IOpt mimic
      opt on(obj, @moo?)
      obj cell?(:moo) should be false
      opt["--moo"] should mimic(IOpt Action)
      opt["--moo"] call(true)
      obj moo? should be true
      opt["--no-moo"] should mimic(IOpt Action)
      opt["--no-moo"] call(false)
      obj moo? should be false)

    it("should create an option for applying a message to an object",
      obj = Origin mimic
      opt = IOpt mimic
      opt on(obj, "--moo" ''(cell(it) = "foo #{it}"))
      opt["--moo"] should mimic(IOpt Action)
      opt["--moo"] call(:bar)
      obj bar should == "foo bar")

    it("should create an option for applying a message to an object",
      obj = dict()
      opt = IOpt mimic
      key = "jojo"
      opt on(obj, "--moo" ''([key] = it))
      opt["--moo"] should mimic(IOpt Action)
      opt["--moo"] call(:bar)
      obj["jojo"] should == :bar)
    
    it("should create an option for applying a value on an object",
      obj = Origin with(foo: "Bat")
      opt = IOpt mimic
      opt on(obj, "--moo" method(bat, @r = foo + bat))
      opt["--moo"] should mimic(IOpt Action)
      opt["--moo"] call("Man")
      obj r should == "BatMan")

  ) ; on


  describe(IOpt Action,
    describe("mimic", 
      it("should take a callable argument as body",
        body = fn(.)
        a = IOpt Action mimic(cell(:body))
        a cell(:body) should == cell(:body)))

    describe("helpItems",
      it("should format an action as text",
        a = IOpt Action mimic(fn("Use magic", .))
        a flags << "-m", "--magic"
        a helpItems should == {
          flags: ["-m", "--magic"],
          desc: "Use magic",
          args: nil
          kargs: nil
          default: "true"
          }
      )
    )

    describe("handleData",
      it("should have default value set to true",
        a = IOpt Action mimic(fn)
        d = a handleData("-o", "-o")
        d[:value] should be true
        d = a handleData("--option", "--option")
        d[:value] should be true)

      it("should use the cell(:default) if set",
        a = IOpt Action mimic(fn)
        a default = "Foo"
        d = a handleData("-p", "-p")
        d[:value] should == "Foo"
        d = a handleData("--path", "--path")
        d[:value] should == "Foo")

      it("should use cell(:alternative) for alt opt",
        a = IOpt Action mimic(fn)
        lin = Origin mimic
        win = Origin mimic
        a default = lin
        a alternative = win
        d = a handleData("--[disable-]unix", "--unix")
        d[:value] should == lin
        d = a handleData("--[disable-]unix", "--disable-unix")
        d[:value] should == win)

      it("should use cell(:default) cell(:not) for alt opt",
        a = IOpt Action mimic(fn)
        d = a handleData("--[dont-]use", "--use")
        d[:value] should == true
        d = a handleData("--[dont-]use", "--dont-use")
        d[:value] should == false

        lin = Origin mimic
        win = Origin mimic
        lin cell(:not) = win
        win cell(:not) = lin
        a default = lin
        d = a handleData("--[not-]unix", "--unix")
        d[:value] should == lin
        d = a handleData("--[not-]unix", "--not-unix")
        d[:value] should == win)
      
      it("should return the string provided after =",
        a = IOpt Action mimic(fn)
        a default = "/home"
        d = a handleData("-p", "-p")
        d[:value] should == "/home"
        d = a handleData("--path", "--path=/root")
        d[:value] should == "/root"
        d = a handleData("-p", "-p=/opt")
        d[:value] should == "/opt")

      it("should return the string provided after single opt",
        a = IOpt Action mimic(fn)
        a default = 0
        d = a handleData("-n", "-n123")
        d[:value] should == "123")
    )

    describe("handle",
      
      it("should signal error if it doesnt handle that option",
        a = IOpt Action mimic(fn) do(flags << "--foo" << "-f")
        fn(a handle(["-m"])) should signal(Condition Error Default)
        fn(a handle(["--moo"])) should signal(Condition Error Default))

      it("should consume only the option if it takes no args",
        value = nil
        a = IOpt Action mimic(fn(v, value = v)) do(flags << "-f"
          argumentsCode = nil)
        res = a handle("-f", "hello")
        value should == true
        res remnant should == ["hello"])

      it("should consume arguments for one named arg",
        value = nil
        a = IOpt Action mimic(fn(v, value = v)) do(flags << "-f")
        res = a handle("-f", "hello world")
        value should == "hello world"
        res remnant should be empty)

      it("should consume arguments for one named arg and another optional",
        value = nil
        a = IOpt Action mimic(fn(a, b "world", value = "#{a} #{b}"))
        a flags << "-f"
      
        res = a handle("-f", "hello")
        value should == "hello world"
        res remnant should be empty
        
        res = a handle("-f", "hola", "mundo")
        value should == "hola mundo"
        res remnant should be empty)

      it("should consume arguments until next option",
        value = nil
        a = IOpt Action mimic(fn(a, b "world", value = "#{a} #{b}"))
        a flags << "-f"
        res = a handle("-f", "hello", "--another-option")
        value should == "hello world"
        res remnant should == ["--another-option"])


      it("should consume keyword arguments until next option",
        value = nil
        a = IOpt Action mimic(fn(a, c "le", b: "world",
            value = "#{a} #{c} #{b}"))
        a flags << "-f"
        
        res = a handle("-f", "hello", "b:", "mundo", "al", 
          "--another-option")
        value should == "hello al mundo"
        res remnant should == ["--another-option"])

      it("should take keyword arguments in any order",
        value = nil
        a = IOpt Action mimic(fn(a, c "le", b: "world",
            value = "#{a} #{c} #{b}"))
        a flags << "-f"
        
        res = a handle("-f", "b:monde", "hola")
        value should == "hola le monde"
        res remnant should be empty)

      it("should take rest arguments until next option",
        value = nil
        a = IOpt Action mimic(fn(a, b "le", +c,
            value = "%[%s %] %s %s" format(c, a, b)))
        a flags << "-f"
        res = a handle("-f", "hola", "que", "tal", "amigo", "-h")
        value should == "tal amigo  hola que"
        res remnant should == ["-h"])
      
      it("should take rest keywords arguments until next option",
        value = nil
        a = IOpt Action mimic(fn(a:, b: "b", +:c,
            value = dict(a: a, b: b, c: c)))
        a flags << "-f"
        res = a handle("-f",
          "e:", "hola", "b:", "que", "a:tal", "g:amigo", "m:", "!",
          "-h")
        value[:a] should == "tal"
        value[:b] should == "que"
        value[:c] should == dict(e: "hola", g: "amigo", m: "!")
        res remnant should == ["-h"])
      
    )

  ); Action
  
); IOpt
