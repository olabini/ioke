
use("ispec")

describe("ISpec Options",

  describe("when parsing arguments",
    it("should set hasHelp? when -h specified",
      options = ISpec Options create(nil, nil)
      options argv = ["-h"]
      options parse!
      options hasHelp? should == true
    )

    it("should set hasHelp? when --help specified",
      options = ISpec Options create(nil, nil)
      options argv = ["--help"]
      options parse!
      options hasHelp? should == true
    )
    
    it("should set default formatter",
      options = ISpec Options create(nil, nil)
      options argv = []
      options parse!
      options formatters empty? should == false
    )
    
    it("should set progress bar formatter",
    options = ISpec Options create(nil, nil)
    options argv = ["-fp"]
    options parse!
    options formatters first kind should == ISpec Formatter ProgressBarFormatter kind
    )

    it("should set spec doc formatter",
    options = ISpec Options create(nil, nil)
    options argv = ["-fs"]
    options parse!
    options formatters first kind should == ISpec Formatter SpecDocFormatter kind
    )
  )
)