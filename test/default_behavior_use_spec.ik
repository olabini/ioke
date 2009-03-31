
use("ispec")

describe(DefaultBehavior,
  describe("use",
    it("should load a file with an absolute file name",
      result = use(System currentDirectory + "/_test2/loadx")
      result should be true
      loadx_loaded should == 42
    )

    it("should load a file in the same directory", 
      result = use("test/load1")
      result should be true
      val should == 42
    )

    it("should load a file in the same directory when explicitly have suffix", 
      result = use("test/load2.ik")
      result should be true
      val2 should == 42
    )
    
    it("should not load something that's already been loaded", 
      Ground vex = 13
      use("test/load3") should be true
      use("test/load3") should be false
      vex should == 14
    )

    it("should search the added load paths", 
      System loadPath << "test/sub_load"
      use("foo1")
      Ground fooHasBeenLoaded should == 42
    )

    it("should raise exception if it can't find something", 
      fn(use("blarg")) should signal(Condition Error Load)
    )
  )
)
