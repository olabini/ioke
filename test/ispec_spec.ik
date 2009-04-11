
use("ispec")

describe(ISpec DescribeContext,
  describe("when defining tests",
    it("should add test code",
      context = ISpec DescribeContext create
      context it("test", 
        code
      )
      context specs first first should == :test
    )

    it("should add pending test without code",
      context = ISpec DescribeContext create
      context it("pending test")
      context specs first first should == :pending
    )

    it("should add pending test with code",
      context = ISpec DescribeContext create
      context it("pending test", {pending: true},
        code
      )
      context specs first first should == :pending
    )
  )
  
  describe("when describing tests",
    it("should create context",
      context = ISpec DescribeContext create
      context describe("context",
        .
      )
    )
    it("should create context without code",
      context = ISpec DescribeContext create
      context describe("context")
    )
    it("should create context with tags",
      context = ISpec DescribeContext create
      context describe("context", {pending: true},
        .
      )
    )
  )
)

describe(ISpec,
  describe("in context with pending example",
    it("should be pending", {pending: true},
      error!("Pending example is not pending")
    )
  )

  describe("in pending context", {pending: true},
    it("should be pending although has code",
      error!("Pending example is not pending")
    )
    
    describe("with nested context",
      it("should be pending as well",
        error!("Pending example is not pending")
      )
    )
  )
)

describe(ISpec Runner OptionParser,

  describe("when parsing arguments",

    it("should NOT add the test directory if it exists and is no given files/dirs",
      parser = ISpec Runner OptionParser create(nil, nil)
      parser order([]) directories should == []
    )
    
    it("should set hasHelp? when -h specified",
      parser = ISpec Runner OptionParser create(nil, nil)
      parser order(["-h"]) should hasHelp
    )

    it("should set hasHelp? when --help specified",
      parser = ISpec Runner OptionParser create(nil, nil)
      parser order(["--help"]) should hasHelp
    )
    
    it("should set default formatter",
      parser = ISpec Runner OptionParser create(nil, nil)
      parser order([]) formatters should not be empty
    )
    
    it("should set progress bar formatter",
      parser = ISpec Runner OptionParser create(nil, nil)
      parser order(["-fp"]) formatters first should be kind("ISpec Formatter ProgressBarFormatter")
    )

    it("should set spec doc formatter",
      parser = ISpec Runner OptionParser create(nil, nil)
      parser order(["-fs"]) formatters first should be kind("ISpec Formatter SpecDocFormatter")
    )

    it("should set the formatter output when given keyword arg to: file",
      ensure(
        parser = ISpec Runner OptionParser create(nil, nil)
        parser order(["--format", "specdoc", "to:", "file"])
        parser options formatters first output kind should == "java:io:PrintStream",
        
        if(FileSystem file?("file"),
          FileSystem removeFile!("file")))
    )

    it("should set the formatter output to stdout when given keyword arg to: -",
      parser = ISpec Runner OptionParser create(nil, nil)
      parser order(["--format", "specdoc", "to:", "-"])
      parser options formatters first output should mimic(System out)
    )
    
    it("should add file when exists",
      parser = ISpec Runner OptionParser create(nil, nil)
      parser order(["test/ispec_spec.ik"]) files should not be empty
    )
    
    it("should add directory when exists",
      parser = ISpec Runner OptionParser create(nil, nil)
      parser order(["test"]) directories should not be empty
    )
    
    it("should add missing file",
      parser = ISpec Runner OptionParser create(nil, nil)
      parser order(["xxxzz"]) missingFiles should not be empty
    )
    
    it("should add unknown option",
      parser = ISpec Runner OptionParser create(nil, nil)
      cl = parser parse(["--foo"])
      cl unknownOptions should not be empty
    )

    it("should have a default loadPattern", 
      parser = ISpec Runner OptionParser create(nil, nil)
      parser order([]) loadPatterns should not be empty
    )

    it("should allow to set loadPatterns with --pattern", 
      parser = ISpec Runner OptionParser create(nil, nil)
      parser order(["--pattern", "foo", 
          "--pattern", "bar"]) loadPatterns should == ["foo", "bar"]
    )

    it("should allow to set loadPatterns with -p", 
      parser = ISpec Runner OptionParser create(nil, nil)
      parser order(["-p", "foo", 
          "-p", "bar"]) loadPatterns should == ["foo", "bar"]
    )

    it("should set onlyLines with --line option",
     parser = ISpec Runner OptionParser create(nil, nil)
      parser order(["--line", "22", 
          "--line", "10"]) onlyLines should == [22, 10]
    )

    it("should set onlyLines with -l option",
     parser = ISpec Runner OptionParser create(nil, nil)
      parser order(["-l", "22", "-l10",
          "-l=90"]) onlyLines should == [22, 10, 90]
    )


    it("should set onlyMatching with --example option",
     parser = ISpec Runner OptionParser create(nil, nil)
      parser order(["--example", "some example", 
          "-e", "foo"]) onlyMatching should == ["some example", "foo"]
    )

    onlyWhen(! System windows?,
      it("should load onlyMatching from a file if --example is given a path",
        parser = ISpec Runner OptionParser create(nil, nil)
        parser order(["-e", "test/fixtures/names.txt",
            ]) onlyMatching should == ["Ola", "Martin", "Sam", "Carlos", "Brian", "Felipe"]
      )
    )

    onlyWhen(System windows?,
      it("should load onlyMatching from a file if --example is given a path",
        parser = ISpec Runner OptionParser create(nil, nil)
        parser order(["-e", "test/fixtures/names.txt",
            ]) onlyMatching should == ["Ola\r", "Martin\r", "Sam\r", "Carlos\r", "Brian\r", "Felipe"]
      )
    )

    it("should useColour by edfault",
     parser = ISpec Runner OptionParser create(nil, nil)
     parser order([]) useColour should be true
    )

    it("should set useColour to false when given --color=false",
     parser = ISpec Runner OptionParser create(nil, nil)
     parser order(["--color", "false"]) useColour should be false
    )

    it("should set formatters not to use colors when given --color=false",
     parser = ISpec Runner OptionParser create(nil, nil)
     parser order(["--color", "false"])
     parser options formatters first green("Hello") should == "Hello"
    )
    
  )
)
