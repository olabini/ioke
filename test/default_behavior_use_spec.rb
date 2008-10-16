include_class('ioke.lang.Runtime') { 'IokeRuntime' } unless defined?(IokeRuntime)
include_class('ioke.lang.PlainTextBuiltin') unless defined?(PlainTextBuiltin)

import Java::java.io.StringReader unless defined?(StringReader)

def run_with_cwd(str, ioke = IokeRuntime.get_runtime)
  ioke.current_working_directory = File.expand_path(File.dirname(__FILE__))
  [ioke.evaluate_stream(StringReader.new(str)), ioke]
end

describe "DefaultBehavior" do 
  describe "use" do 
    it "should load a file without a suffix in the same directory" do 
      result, runtime = run_with_cwd("use(\"load2\")")
      result.should == runtime.true
      runtime.ground.find_cell(nil, nil, "val").as_java_integer.should == 43
    end

    it "should load a file in the same directory" do 
      result, runtime = run_with_cwd("use(\"load1\")")
      result.should == runtime.true
      runtime.ground.find_cell(nil, nil, "val").as_java_integer.should == 42
    end

    it "should load a file in the same directory when explicitly have suffix" do 
      result, runtime = run_with_cwd("use(\"load1.ik\")")
      result.should == runtime.true
      runtime.ground.find_cell(nil, nil, "val").as_java_integer.should == 42
    end
    
    it "should not load something that's already been loaded"
    it "should search all the defined load paths"
    it "should raise exception if it can't find something"
    

    it "should first try to load on name from predefined" do 
      runtime = IokeRuntime.get_runtime
      runtime.add_builtin_script("load1", PlainTextBuiltin.new("load1", "System currentFile println; Ground vex = 25"))
      result, _ = run_with_cwd("use(\"load1\")", runtime)
      result.should == runtime.true
      runtime.ground.find_cell(nil, nil, "val").should == runtime.nul
      runtime.ground.find_cell(nil, nil, "vex").as_java_integer.should == 25
    end
    
    #it "should be able to load from jar files too"
  end
end
