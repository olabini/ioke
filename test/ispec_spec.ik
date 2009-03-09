
use("ispec")

describe(ISpec Runner OptionParser,

  describe("when parsing arguments",

    it("should add the test directory if it exists and is no given files/dirs",
      parser = ISpec Runner OptionParser create(nil, nil)
      parser order([]) directories should == ["test"]
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
      parser = ISpec Runner OptionParser create(nil, nil)
      parser order(["--format", "specdoc", "to:", "file"])
      parser options formatters first output kind should == "java:io:PrintStream"
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

    it("should load onlyMatching from a file if --example is given a path",
     parser = ISpec Runner OptionParser create(nil, nil)
      parser order(["-e", "test/fixtures/names.txt",
          ]) onlyMatching should == ["Ola", "Martin", "Sam", "Carlos", "Brian", "Felipe"]
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