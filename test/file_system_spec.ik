
use("ispec")

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
        FileSystem[theList second] should == theList first
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
