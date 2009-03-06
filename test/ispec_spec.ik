
use("ispec")

describe("ISpec Options",

  describe("when parsing arguments",
    it("should set hasHelp? when -h specified",
      options = ISpec Options create(nil, nil)
      options argv = ["-h"]
      options parse!
      options hasHelp? should be true
    )

    it("should set hasHelp? when --help specified",
      options = ISpec Options create(nil, nil)
      options argv = ["--help"]
      options parse!
      options hasHelp? should be true
    )
    
    it("should set default formatter",
      options = ISpec Options create(nil, nil)
      options argv = []
      options parse!
      options formatters should not be empty
    )
    
    it("should set progress bar formatter",
      options = ISpec Options create(nil, nil)
      options argv = ["-fp"]
      options parse!
      options formatters first should be kind("ISpec Formatter ProgressBarFormatter")
    )

    it("should set spec doc formatter",
      options = ISpec Options create(nil, nil)
      options argv = ["-fs"]
      options parse!
      options formatters first should be kind("ISpec Formatter SpecDocFormatter")
    )
    
    it("should add file when exists",
      options = ISpec Options create(nil, nil)
      options argv = ["test/ispec_spec.ik"]
      options parse!
      options files should not be empty
    )
    
    it("should add directory when exists",
      options = ISpec Options create(nil, nil)
      options argv = ["test"]
      options parse!
      options directories should not be empty
    )
    
    it("should add missing file",
      options = ISpec Options create(nil, nil)
      options argv = ["xxxzz"]
      options parse!
      options missingFiles should not be empty
    )
    
    it("should add unknown option",
      options = ISpec Options create(nil, nil)
      options argv = ["-foo"]
      options parse!
      options unknownOptions should not be empty
    )
  )
)