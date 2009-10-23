
use("ispec")

FileSystemTestConfig = Origin mimic
if(FileSystem exists?(".file_system_test_config.ik"),
  use(".file_system_test_config.ik"),

  warn!("You haven't specified a configuration file for testing the file system.
This should reside in the base of the Ioke distribution, be called .file_system_test_config.ik
and contain something like this:

FileSystemTestConfig homeDirectory = \"/your/home/directory\"

")
)

describe(FileSystem,
  it("should have the correct kind",
    FileSystem should have kind("FileSystem")
  )

  describe("exists?",
    it("should return false for something that doesn't exit",
      FileSystem exists?("flux_flog") should be false
      FileSystem exists?("src/flux_flog") should be false
      FileSystem exists?("flux_flog/builtin") should be false
    )

    it("should return true for a file",
      FileSystem exists?("build.xml") should be true
      FileSystem exists?("src/builtin/A10_defaultBehavior.ik") should be true
    )

    it("should return true for a directory",
      FileSystem exists?("src") should be true
      FileSystem exists?("src/") should be true
      FileSystem exists?("src/builtin") should be true
    )

    onlyWhen(FileSystemTestConfig cell?(:homeDirectory),
      it("should expand tilde for the home directory",
        realname = "#{FileSystemTestConfig homeDirectory}/.__something_that_should_only_exist_for_file_system_ioke_tests"
        fname = "~/.__something_that_should_only_exist_for_file_system_ioke_tests"
        FileSystem exists?(fname) should be false
        ensure(
          FileSystem withOpenFile(realname, fn(f, f println("hello")))
          FileSystem exists?(fname) should be true
          ,
          bind(rescue(Condition Error, fn(ignored, nil)),
            FileSystem removeFile!(realname))
        )
        FileSystem exists?(fname) should be false
      )
    )
  )

  describe("file?",
    it("should return false for something that doesn't exit",
      FileSystem file?("flux_flog") should be false
    )

    it("should return true for a file",
      FileSystem file?("build.xml") should be true
    )

    it("should return true for a file inside of a directory",
      FileSystem file?("src/builtin/A10_defaultBehavior.ik") should be true
    )

    it("should return false for a directory",
      FileSystem file?("src") should be false
      FileSystem file?("src/") should be false
    )

    it("should return false for a directory inside another directory",
      FileSystem file?("src/builtin") should be false
    )

    onlyWhen(FileSystemTestConfig cell?(:homeDirectory),
      it("should expand tilde for the home directory",
        realname = "#{FileSystemTestConfig homeDirectory}/.__something_that_should_only_exist_for_file_system_ioke_tests"
        fname = "~/.__something_that_should_only_exist_for_file_system_ioke_tests"
        FileSystem file?(fname) should be false
        ensure(
          FileSystem withOpenFile(realname, fn(f, f println("hello")))
          FileSystem file?(fname) should be true
          ,
          bind(rescue(Condition Error, fn(ignored, nil)),
            FileSystem removeFile!(realname))
        )
        FileSystem file?(fname) should be false
      )
    )
  )

  describe("directory?",
    it("should return false for something that doesn't exit",
      FileSystem directory?("flux_flog") should be false
    )

    it("should return false for a file",
      FileSystem directory?("build.xml") should be false
    )

    it("should return false for a file inside of a directory",
      FileSystem directory?("src/builtin/A10_defaultBehavior.ik") should be false
    )

    it("should return true for a directory",
      FileSystem directory?("src") should be true
      FileSystem directory?("src/") should be true
    )

    it("should return true for a directory inside another directory",
      FileSystem directory?("src/builtin") should be true
    )

    onlyWhen(FileSystemTestConfig cell?(:homeDirectory),
      it("should expand tilde for the home directory",
        realname = "#{FileSystemTestConfig homeDirectory}/.__something_that_should_only_exist_for_file_system_ioke_tests"
        fname = "~/.__something_that_should_only_exist_for_file_system_ioke_tests"
        FileSystem directory?(fname) should be false
        ensure(
          FileSystem createDirectory!(realname)
          FileSystem directory?(fname) should be true
          ,
          bind(rescue(Condition Error, fn(ignored, nil)),
            FileSystem removeDirectory!(realname))
        )
        FileSystem directory?(fname) should be false
      )
    )
  )

  describe("createDirectory!",
    it("should signal an error if the directory already exists",
      fn(FileSystem createDirectory!("src")) should signal(Condition Error IO)

      bind(rescue(Condition, fn(c, nil)), ; ignore failures
        FileSystem removeDirectory!("test/newly_created_dir"))
    )

    it("should signal an error if a file with the same name already exists",
      fn(FileSystem createDirectory!("build.xml")) should signal(Condition Error IO)

      bind(rescue(Condition, fn(c, nil)), ; ignore failures
        FileSystem removeDirectory!("test/newly_created_dir"))
    )

    it("should create the directory",
      FileSystem createDirectory!("test/newly_created_dir")
      FileSystem should have directory("test/newly_created_dir")

      bind(rescue(Condition, fn(c, nil)), ; ignore failures
        FileSystem removeDirectory!("test/newly_created_dir"))
    )

    onlyWhen(FileSystemTestConfig cell?(:homeDirectory),
      it("should expand tilde for the home directory",
        realname = "#{FileSystemTestConfig homeDirectory}/.__something_that_should_only_exist_for_file_system_ioke_tests"
        fname = "~/.__something_that_should_only_exist_for_file_system_ioke_tests"
        FileSystem directory?(realname) should be false
        ensure(
          FileSystem createDirectory!(fname)
          FileSystem directory?(realname) should be true
          ,
          bind(rescue(Condition Error, fn(ignored, nil)),
            FileSystem removeDirectory!(realname))
        )
        FileSystem directory?(realname) should be false
      )
    )
  )

  describe("removeDirectory!",
    it("should signal an error if the directory doesn't exists",
      fn(FileSystem removeDirectory!("non_existing_dir")) should signal(Condition Error IO)
    )

    it("should signal an error if a file with the same name exists",
      fn(FileSystem removeDirectory!("build.xml")) should signal(Condition Error IO)
    )

    it("should remove the directory",
      FileSystem createDirectory!("test/dir_to_remove") ; set up
      FileSystem removeDirectory!("test/dir_to_remove")

      FileSystem should not have directory("test/dir_to_remove")
    )

    onlyWhen(FileSystemTestConfig cell?(:homeDirectory),
      it("should expand tilde for the home directory",
        realname = "#{FileSystemTestConfig homeDirectory}/.__something_that_should_only_exist_for_file_system_ioke_tests"
        fname = "~/.__something_that_should_only_exist_for_file_system_ioke_tests"
        FileSystem directory?(realname) should be false
        ensure(
          FileSystem createDirectory!(realname)
          FileSystem removeDirectory!(fname)
          FileSystem directory?(realname) should be false
          ,
          bind(rescue(Condition Error, fn(ignored, nil)),
            FileSystem removeDirectory!(realname))
        )
        FileSystem directory?(realname) should be false
      )
    )
  )

  describe("removeFile!",
    it("should signal an error if the file doesn't exists",
      fn(FileSystem removeFile!("non_existing_file")) should signal(Condition Error IO)
    )

    it("should signal an error if a directory with the same name exists",
      fn(FileSystem removeFile!("build")) should signal(Condition Error IO)
    )

    it("should remove the file",
      FileSystem withOpenFile("test/file_to_remove", fn(f, f println("hello"))) ;; setup
      FileSystem removeFile!("test/file_to_remove")
      FileSystem should not have file("test/file_to_remove")
    )

    onlyWhen(FileSystemTestConfig cell?(:homeDirectory),
      it("should expand tilde for the home directory",
        realname = "#{FileSystemTestConfig homeDirectory}/.__something_that_should_only_exist_for_file_system_ioke_tests"
        fname = "~/.__something_that_should_only_exist_for_file_system_ioke_tests"
        FileSystem exists?(realname) should be false
        ensure(
          FileSystem withOpenFile(realname, fn(f, f print("hello")))
          FileSystem removeFile!(fname)
          FileSystem exists?(realname) should be false
          ,
          bind(rescue(Condition Error, fn(ignored, nil)),
            FileSystem removeFile!(realname))
        )
        FileSystem exists?(realname) should be false
      )
    )
  )

  describe("[]",
    it("should glob correctly",
      [
        [ [ "test/_test" ],                                 "test/_test" ],
        [ [ "test/_test/" ],                                "test/_test/" ],
        [ [ "test/_test/_file1", "test/_test/_file2" ],     "test/_test/*" ],
        [ [ "test/_test/_file1", "test/_test/_file2" ],     "test/_test/_file*" ],
        [ [  ],                                             "test/_test/frog*" ],

        [ [ "test/_test/_file1", "test/_test/_file2" ],     "test/**/_file*" ],

        [ [ "test/_test/_file1", "test/_test/_file2" ],     "test/_test/_file[0-9]*" ],
        [ [ ],                                              "test/_test/_file[a-z]*" ],

        [ [ "test/_test/_file1", "test/_test/_file2" ],     "test/_test/_file{0,1,2,3}" ],
        [ [ ],                                              "test/_test/_file{4,5,6,7}" ],

        [ [ "test/_test/_file1", "test/_test/_file2" ],     "test/**/_f*[il]l*" ],
        [ [ "test/_test/_file1", "test/_test/_file2" ],     "test/**/_f*[il]e[0-9]" ],
        [ [ "test/_test/_file1"              ],             "test/**/_f*[il]e[01]" ],
        [ [ "test/_test/_file1"              ],             "test/**/_f*[il]e[01]*" ],
        [ [ "test/_test/_file1"              ],             "test/**/_f*[^ie]e[01]*" ],
        ] each(theList,
        FileSystem[theList second] sort should == theList first sort
      )
    )

    onlyWhen(FileSystemTestConfig cell?(:homeDirectory),
      it("should expand tilde for the home directory",
        realname = "#{FileSystemTestConfig homeDirectory}/.__something_that_should_only_exist_for_file_system_ioke_tests"
        realname2 = "#{FileSystemTestConfig homeDirectory}/.__something_that_should_only_exist_for_file_system2_ioke_tests"
        fname = "~/.__*_ioke_tests"
        FileSystem exists?(realname) should be false
        FileSystem exists?(realname2) should be false
        ensure(
          FileSystem withOpenFile(realname, fn(f, f print("hello")))
          FileSystem withOpenFile(realname2, fn(f, f print("hello")))
          FileSystem[fname] sort should == [realname, realname2] sort
          ,
          bind(rescue(Condition Error, fn(ignored, nil)),
            FileSystem removeFile!(realname))
          bind(rescue(Condition Error, fn(ignored, nil)),
            FileSystem removeFile!(realname2))
        )
      )
    )
  )

  describe("parentOf",
    onlyWhen(System windows?,
      it("should return nil for the parent of something that doesn't have a parent",
        FileSystem parentOf("C:\\") should be nil
      )

      it("should return the parent of a relative directory",
        FileSystem parentOf("src\\builtin") should == "src"
      )

      it("should return the parent of an absolute directory",
        FileSystem parentOf("C:\\windows\\system32") should == "C:\\windows"
      )
    )
    onlyWhen(! System windows?,
      it("should return nil for the parent of something that doesn't have a parent",
        FileSystem parentOf("/") should be nil
      )

      it("should return the parent of a relative directory",
        FileSystem parentOf("src/builtin") should == "src"
      )

      it("should return nil for a relative directory that doesn't have a parent",
        FileSystem parentOf("src") should be nil
      )

      it("should return the parent of an absolute directory",
        FileSystem parentOf("/usr/local") should == "/usr"
      )
    )
  )

  describe("readFully",
    it("should correctly read in a blank file",
      FileSystem readFully("test/fixtures/blank.txt") should == ""
    )

    it("should correctly read in a list of names",
      if(System windows?,
        FileSystem readFully("test/fixtures/names.txt") should == "Ola\r\nMartin\r\nSam\r\nCarlos\r\nBrian\r\nFelipe",
        FileSystem readFully("test/fixtures/names.txt") should == "Ola\nMartin\nSam\nCarlos\nBrian\nFelipe")
    )

    onlyWhen(FileSystemTestConfig cell?(:homeDirectory),
      it("should expand tilde for the home directory",
        realname = "#{FileSystemTestConfig homeDirectory}/.__something_that_should_only_exist_for_file_system_ioke_tests"
        fname = "~/.__something_that_should_only_exist_for_file_system_ioke_tests"
        ensure(
          FileSystem withOpenFile(realname, fn(f, f print("hello you are a strange man!")))
          FileSystem readFully(fname) should == "hello you are a strange man!"
          ,
          bind(rescue(Condition Error, fn(ignored, nil)),
            FileSystem removeFile!(realname))
        )
      )
    )
  )

  describe(FileSystem File,
    it("should have the right kind",
      FileSystem File should have kind("FileSystem File"))

    describe("close",
      it("should validate type of receiver",
        FileSystem File should checkReceiverTypeOn(:close)
      )
    )
  )
)
