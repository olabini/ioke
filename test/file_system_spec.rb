include_class('ioke.lang.Runtime') { 'IokeRuntime' } unless defined?(IokeRuntime)

import Java::java.io.StringReader unless defined?(StringReader)
import Java::java.io.PrintWriter unless defined?(PrintWriter)
import Java::java.io.StringWriter unless defined?(StringWriter)
import Java::java.io.InputStreamReader unless defined?(InputStreamReader)
import Java::java.lang.System unless defined?(System)

describe "FileSystem" do 
  it "should have the correct kind" do 
    ioke = IokeRuntime.get_runtime
    result = ioke.file_system.find_cell(nil, nil, "kind")
    result.data.text.should == 'FileSystem'
  end

  describe "'[]'" do 
    def setupTestDir
      @start = Dir.getwd
      teardownTestDir
      begin
        Dir.mkdir("_test")
      rescue
        $stderr.puts "Cannot run a file or directory test: " + 
          "will destroy existing directory _test"
        exit(99)
      end
      File.open(File.join("_test", "_file1"), "w", 0644) {}
      File.open(File.join("_test", "_file2"), "w", 0644) {}
      @files = %w(. .. _file1 _file2)
    end

    def deldir(name)
      File.chmod(0755, name)
      Dir.foreach(name) do |f|
        next if f == '.' || f == '..'
        f = File.join(name, f)
        if File.lstat(f).directory?
          deldir(f) 
        else
          File.chmod(0644, f) rescue true
          File.delete(f)
        end 
      end
      Dir.rmdir(name)
    end

    def teardownTestDir
      Dir.chdir(@start)
      deldir("_test") if (File.exists?("_test"))
    end

    it "should glob correctly" do 
      ioke = IokeRuntime.get_runtime
      begin 
        setupTestDir
        [
         [ %w( _test ),                     "_test" ],
         [ %w( _test/ ),                    "_test/" ],
         [ %w( _test/_file1 _test/_file2 ), "_test/*" ],
         [ %w( _test/_file1 _test/_file2 ), "_test/_file*" ],
         [ %w(  ),                          "_test/frog*" ],
         
         [ %w( _test/_file1 _test/_file2 ), "**/_file*" ],
         
         [ %w( _test/_file1 _test/_file2 ), "_test/_file[0-9]*" ],
         [ %w( ),                           "_test/_file[a-z]*" ],
         
         [ %w( _test/_file1 _test/_file2 ), "_test/_file{0,1,2,3}" ],
         [ %w( ),                           "_test/_file{4,5,6,7}" ],
         
         [ %w( _test/_file1 _test/_file2 ), "**/_f*[il]l*" ],    
         [ %w( _test/_file1 _test/_file2 ), "**/_f*[il]e[0-9]" ],
         [ %w( _test/_file1              ), "**/_f*[il]e[01]" ],
         [ %w( _test/_file1              ), "**/_f*[il]e[01]*" ],
         [ %w( _test/_file1              ), "**/_f*[^ie]e[01]*" ],
        ].each do |expected, glob_pattern|
          ioke.evaluate_string("FileSystem[\"#{glob_pattern}\"] inspect").data.text.should == expected.inspect
        end
      ensure
        teardownTestDir
      end
    end
  end
end
