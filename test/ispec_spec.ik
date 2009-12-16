
use("ispec")

describe(ISpec Example,
  it("should not be pending",
    example = ISpec Example mimic(ISpec DescribeContext mimic, "example", '., {})
    example pending? should be nil
  )

  it("should be pending with pending tag",
    example = ISpec Example mimic(ISpec DescribeContext mimic, "example", '., {pending: true})
    example pending? should be true
  )

  it("should be pending without code",
    example = ISpec Example mimic(ISpec DescribeContext mimic, "example", false, {})
    example pending? should be true
  )

  it("should be failing with fail tag",
    example = ISpec Example mimic(ISpec DescribeContext mimic, "example", false, {fail: true})
    example fail? should be true
  )
)

describe(ISpec DescribeContext,
  describe("when defining tests",
    it("should add test code",
      context = ISpec DescribeContext mimic
      context it("test",
        code
      )
      context specs first pending? should be nil
    )

    it("should add pending test without code",
      context = ISpec DescribeContext mimic
      context it("pending test")
      context specs first pending? should be true
    )

    it("should add pending test with code",
      context = ISpec DescribeContext mimic
      context it("pending test", {pending: true},
        code
      )
      context specs first pending? should be true
    )
  )

  describe("when describing tests",
    it("should create context",
      context = ISpec DescribeContext mimic
      context describe("context",
        .
      )
    )

    it("should create context without code",
      context = ISpec DescribeContext mimic
      context describe("context")
    )

    it("should create context with tags",
      context = ISpec DescribeContext mimic
      context describe("context", {pending: true},
        .
      )
    )
  )

  describe("with before block defining variables",
    before(
      test = true
      test2 = false
    )
    it("should have access to variables in test",
      test should be true
    )

    describe("in nested context",
      before(
        test2 = true
      )
      it("should have access to variables in test as well",
        test should be true
      )
      it("should call before blocks in proper order",
        test2 should be true
      )
    )
  )

  describe("with after block checking for variables",
    after(
      test should be true
    )
    it("should set variable",
      test = true
    )
    describe("in nested context",
      after(
        test = true
      )
      it("should call after blocks in proper order",
        test = false
      )
    )
  )
)

describe(ISpec,
  describe("ComparisonCompactor",
    it("should display a message as part of the compacting message",
      failure = ISpec ComparisonCompactor compact(0, "b", "c", message: "a")
      failure should == "a expected:<[b]> but was:<[c]>"
    )

    it("should compact the same starting sequence",
      failure = ISpec ComparisonCompactor compact(1, "ba", "bc")
      failure should == "expected:<b[a]> but was:<b[c]>"
    )

    it("should compact the same ending sequence",
      failure = ISpec ComparisonCompactor compact(1, "ab", "cb")
      failure should == "expected:<[a]b> but was:<[c]b>"
    )

    it("should compact the same sequence",
      failure = ISpec ComparisonCompactor compact(1, "ab", "ab")
      failure should == "expected:<ab> but was:<ab>"
    )

    it("should compact with different middle and no context",
      failure = ISpec ComparisonCompactor compact(0, "abc", "adc")
      failure should == "expected:<...[b]...> but was:<...[d]...>"
    )

    it("should compact with different middle and context",
      failure = ISpec ComparisonCompactor compact(1, "abc", "adc")
      failure should == "expected:<a[b]c> but was:<a[d]c>"
    )

    it("should compact with different middle, context and ellipses",
      failure = ISpec ComparisonCompactor compact(1, "abcde", "abfde")
      failure should == "expected:<...b[c]d...> but was:<...b[f]d...>"
    )

    it("should compact when sharing the same start sequence completed with context",
      failure = ISpec ComparisonCompactor compact(2, "ab", "abc")
      failure should == "expected:<ab[]> but was:<ab[c]>"
    )

    it("should compact when sharing the same start sequence completed without context",
      failure = ISpec ComparisonCompactor compact(0, "bc", "abc")
      failure should == "expected:<[]...> but was:<[a]...>"
    )

    it("should compact when sharing the same start sequence completed with context",
      failure = ISpec ComparisonCompactor compact(2, "bc", "abc")
      failure should == "expected:<[]bc> but was:<[a]bc>"
    )

    it("should compact when sharing overlapping matches",
      failure = ISpec ComparisonCompactor compact(0, "abc", "abbc")
      failure should == "expected:<...[]...> but was:<...[b]...>"
    )

    it("should compact when sharing overlapping matches with context",
      failure = ISpec ComparisonCompactor compact(2, "abc", "abbc")
      failure should == "expected:<ab[]c> but was:<ab[b]c>"
    )

    it("should compact when sharing more overlapping matches",
      failure = ISpec ComparisonCompactor compact(0, "abcdde", "abcde")
      failure should == "expected:<...[d]...> but was:<...[]...>"
    )

    it("should compact when sharing more overlapping matches with context",
      failure = ISpec ComparisonCompactor compact(2, "abcdde", "abcde")
      failure should == "expected:<...cd[d]e> but was:<...cd[]e>"
    )

    it("should compact when comparing with nil",
      failure = ISpec ComparisonCompactor compact(0, "a", nil)
      failure should == "expected:<a> but was:<nil>"
    )

    it("should compact when comparing with nil with context",
      failure = ISpec ComparisonCompactor compact(2, "a", nil)
      failure should == "expected:<a> but was:<nil>"
    )

    it("should compact when comparing with expected nil",
      failure = ISpec ComparisonCompactor compact(0, nil, "a")
      failure should == "expected:<nil> but was:<a>"
    )

    it("should compact when comparing with nil with context",
      failure = ISpec ComparisonCompactor compact(2, nil, "a")
      failure should == "expected:<nil> but was:<a>"
    )

    it("should compact repeated pieces into a working message",
      failure = ISpec ComparisonCompactor compact(10, "S&P500", "0")
      failure should == "expected:<[S&P50]0> but was:<[]0>"
    )
  )

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

        if(System feature?(:java),
          parser options formatters first output kind should == "java:io:PrintStream"),

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
