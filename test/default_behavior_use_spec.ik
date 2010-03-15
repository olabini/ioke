
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

    it("should signal a condition if it can't find something",
      fn(use("blarg")) should signal(Condition Error Load)
    )

    it("should just return a use object if called without arguments",
      cell(:use) should be same(use())
    )

    describe("reload",
      it("should take an absolute file name",
        result = use reload(System currentDirectory + "/_test2/reload_loadx")
        result should be true
        reload_loadx_loaded should == 42
      )

      it("should take a file in the same directory",
        result = use reload("test/reload1")
        result should be true
        reload_val should == 42
      )

      it("should take a file in the same directory with an explicit suffix",
        result = use reload("test/reload2.ik")
        result should be true
        reload_val2 should == 42
      )

      it("should search the added load paths",
        System loadPath << "test/sub_load"
        use reload("refoo1")
        Ground refooHasBeenLoaded should == 42
      )

      it("should signal a condition if it can't find something",
        fn(use reload("blarg")) should signal(Condition Error Load)
      )

      it("should be possible to load something that has been loaded by use",
        use("test/reload_x")
        Ground reload_count_x should == 0
        use reload("test/reload_x")
        Ground reload_count_x should == 1
      )

      it("should be possible to load something that has been loaded by reload before",
        use("test/reload_y")
        Ground reload_count_y should == 0
        use reload("test/reload_y")
        Ground reload_count_x should == 1
        use reload("test/reload_y")
        Ground reload_count_y should == 2
      )

      it("should be possible to load something that hasn't been loaded before",
        use reload("test/reload_z")
        Ground reload_count_z should == 0
        use reload("test/reload_z")
        Ground reload_count_z should == 1
      )
    )
  )
)
