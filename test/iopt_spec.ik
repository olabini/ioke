use("ispec")
use("iopt")

describe(IOpt,

  describe("parse",
    
    it("should not consume arguments that arent options",
      opt = IOpt mimic
      p = nil
      opt on("-f", a, b, p = a => b)
      ary = ["hello", "-f", "one", "two", "world"]
      opt parse(ary)
      ary should == ["hello", "-f", "one", "two", "world"]
      p should == ("one" => "two")
      opt programArguments should == ["hello", "world"])

    it("should execute clustered short options",
      opt = IOpt mimic
      r = dict()
      
      opt on("-a", v, r[:a] = v)
      opt on("-b", b = 22, r[:b] = b)
      opt on("-c", r[:c] = :c)
      
      opt parse(["-c"])
      r should == dict(c: :c)

      opt parse(["-cb"])
      r should == dict(c: :c, b: 22)

      opt parse(["-cba"])
      r should == dict(c: :c, b: "a")

      opt parse(["-abc"])
      r should == dict(a: "bc")
      
      opt parse(["-ac=0"])
      r should == dict(a: "c"))
    
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
      opt cell?("--help") should be true
      help = opt["--help"]
      help should mimic(IOpt Action))

    it("should alias an option if RHS is an string",
      opt = IOpt mimic
      opt["--help"] = fn("Show help")
      opt["-h"] = "--help"
      opt cell?("-h") should be true
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
      obj = Origin with(magic?: false)
      opt on("-m", "--magic", obj magic? = true)
      opt cell("-m") should === opt cell("--magic")
      opt["-m"] should mimic(IOpt Action)
      obj should not be magic
      opt["-m"] call
      obj should be magic)

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

    describe("handleData",
      it("should have default value set to true",
        a = IOpt Action mimic(fn)
        a handleData("-o", "-o")[:value] should be true
        a handleData("--option", "--option")[:value] should be true)

      it("should use the cell(:default) if set",
        a = IOpt Action mimic(fn)
        a default = "Foo"
        a handleData("-p", "-p")[:value] should == "Foo"
        a handleData("--path", "--path")[:value] should == "Foo")

      it("should use cell(:not) for alt opt",
        a = IOpt Action mimic(fn)
        a default = :lin
        a alternative = :win
        a handleData("--[disable-]unix", "--unix")[:value] should == :lin
        a handleData("--[disable-]unix", "--disable-unix")[:value] should == :win)

      it("should use cell(:default) cell(:not) for alt opt",
        a = IOpt Action mimic(fn)
        a handleData("--[dont-]use", "--use")[:value] should == true
        a handleData("--[dont-]use", "--dont-use")[:value] should == false

        lin = Origin mimic
        win = Origin mimic
        lin cell(:not) = win
        win cell(:not) = lin
        a default = lin
        a handleData("--[not-]unix", "--unix")[:value] should == lin
        a handleData("--[not-]unix", "--not-unix")[:value] should == win)
      
      it("should return the string provided after =",
        a = IOpt Action mimic(fn)
        a default = "/home"
        a handleData("-p", "-p")[:value] should == "/home"
        a handleData("--path", "--path=/root")[:immediate] should == "/root"
        a handleData("-p", "-p=/opt")[:immediate] should == "/opt")

      it("should return the string provided after single opt",
        a = IOpt Action mimic(fn)
        a default = 0
        a handleData("-n", "-n123")[:immediate] should == "123")
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
        res = a handle(["-f", "hello"])
        value should == true
        res remnant should == ["hello"])

      it("should consume only the option if it takes no args",
        value = nil
        a = IOpt Action mimic(fn(value = :yes)) do(flags << "-f"
          argumentsCode = nil)
        res = a handle(["-f", "hello"])
        value should == :yes
        res remnant should == ["hello"])

      it("should signal error when missing a required argument",
        a = IOpt Action mimic(fn(v, v)) do(flags << "--args")
        fn(a handle(["--args"])) should signal(
          Condition Error Invocation TooFewArguments))

      it("should set the message name to the flag being used",
        a = IOpt Action mimic(lecro(call message name)) do(
          flags << "-f" << "--foo")
        a handle(["-f"]) result should == :"-f"
        a handle(["--foo"]) result should == :"--foo")

      it("should consume arguments for one named arg",
        value = nil
        a = IOpt Action mimic(fn(v, value = v)) do(flags << "-f")
        res = a handle(["-f", "hello world"])
        value should == "hello world"
        res remnant should be empty
        
        res = a handle(["-f0", "end"])
        value should == "0"
        res remnant should == ["end"]

        res = a handle(["-fone", "two"])
        value should == "one"
        res remnant should == ["two"]
        
        res = a handle(["-f=value", "done"])
        value should == "value"
        res remnant should == ["done"])

      it("should consume arguments for one named arg and another optional",
        value = nil
        a = IOpt Action mimic(fn(a, b "world", value = "#{a} #{b}"))
        a flags << "-f"
      
        res = a handle(["-f", "hello"])
        value should == "hello world"
        res remnant should be empty
        
        res = a handle(["-f", "hola", "mundo"])
        value should == "hola mundo"
        res remnant should be empty)

      it("should consume arguments until next option",
        value = nil
        a = IOpt Action mimic(fn(a, b "world", value = "#{a} #{b}"))
        a flags << "-f"
        res = a handle(["-f", "hello", "--another-option"])
        value should == "hello world"
        res remnant should == ["--another-option"])


      it("should consume keyword arguments until next option",
        value = nil
        a = IOpt Action mimic(fn(a, c "le", b: "world",
            value = "#{a} #{c} #{b}"))
        a flags << "-f"
        
        res = a handle(["-f", "hello", "b:", "mundo", "al", 
            "--another-option"])
        value should == "hello al mundo"
        res remnant should == ["--another-option"])

      it("should take keyword arguments in any order",
        value = nil
        a = IOpt Action mimic(fn(a, c "le", b: "world",
            value = "#{a} #{c} #{b}"))
        a flags << "-f"
        
        res = a handle(["-f", "b:monde", "hola"])
        value should == "hola le monde"
        res remnant should be empty)

      it("should take rest arguments until next option",
        value = nil
        a = IOpt Action mimic(fn(a, b "le", +c,
            value = "%[%s %] %s %s" format(c, a, b)))
        a flags << "-f"
        res = a handle(["-f", "hola", "que", "tal", "amigo", "-h"])
        value should == "tal amigo  hola que"
        res remnant should == ["-h"])
      
      it("should take rest keywords arguments until next option",
        value = nil
        a = IOpt Action mimic(fn(a:, b: "b", +:c,
            value = dict(a: a, b: b, c: c)))
        a flags << "-f"
        res = a handle(["-f",
          "e:", "hola", "b:", "que", "a:tal", "g:amigo", "m:", "!",
          "-h"])
        value[:a] should == "tal"
        value[:b] should == "que"
        value[:c] should == dict(e: "hola", g: "amigo", m: "!")
        res remnant should == ["-h"])
      
    )

  ); Action


  describe("help",
    
    it("should create content formatted as man page",
      opt = IOpt mimic
      
      opt help(:man,
        name = "app"
        desc = "The helpful application"
        
        NAME( p("#{@name} - #{@desc}") )

        SYNOPSYS( p("#{@name} [options] [--] <filepattern>...") )

        DESCRIPTION(
          p("This isn't actually an application",
            "This example demostrates how to write documentation",
            "that can be displayed by programs like man.")

          p("This help format can be feed to your system pager",
            "to provide a more readable reference.")

          p("In the future we could use a markup language like",
            "textile."))

        OPTIONS(
          opt options each(o,
            p("%[%s %]   (%s)" format(o flags, o argumentsCode), 
              >(o documentation))))
        
        CONFIGURATION(
          p("The file ~/.app.yml stores user settings"))
        
      )
      
  )) ;; help
  
); IOpt
