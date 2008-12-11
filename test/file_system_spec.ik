
use("ispec")

describe(FileSystem, 
  it("should have the correct kind", 
    FileSystem should have kind("FileSystem")
  )

  describe("directory?", 
    it("should return false for something that doesn't exit", 
      FileSystem directory?("flux_flog") should == false
    )

    it("should return false for a file", 
      FileSystem directory?("build.xml") should == false
    )

    it("should return false for a file inside of a directory", 
      FileSystem directory?("src/builtin/A1_defaultBehavior.ik") should == false
    )

    it("should return true for a directory", 
      FileSystem directory?("src") should == true
      FileSystem directory?("src/") should == true
    )

    it("should return true for a directory inside another directory", 
      FileSystem directory?("src/builtin") should == true
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
)
