include_class('ioke.lang.Runtime') { 'IokeRuntime' } unless defined?(IokeRuntime)
include_class('ioke.lang.PlainTextBuiltin') unless defined?(PlainTextBuiltin)

def run_with_cwd(str, ioke = IokeRuntime.get_runtime)
  ioke.current_working_directory = File.expand_path(File.dirname(__FILE__))
  [ioke.evaluate_string(str), ioke]
end

describe "DefaultBehavior" do 
  describe "'use'" do 
    it "should load a file in the same directory" do 
      result, runtime = run_with_cwd("use(\"load1\")")
      result.should == runtime.true
      runtime.ground.find_cell(nil, nil, "val").data.as_java_integer.should == 42
    end

    it "should load a file in the same directory when explicitly have suffix" do 
      result, runtime = run_with_cwd("use(\"load1.ik\")")
      result.should == runtime.true
      runtime.ground.find_cell(nil, nil, "val").data.as_java_integer.should == 42
    end
    
    it "should not load something that's already been loaded" do 
      ioke = IokeRuntime.get_runtime
      
      ioke.add_builtin_script("load1", PlainTextBuiltin.new("load1", "Ground vex ++"))
      result, _ = run_with_cwd("Ground vex = 13. use(\"load1\")", ioke)
      result.should == ioke.true
      result, _ = run_with_cwd("use(\"load1\")", ioke)
      result.should == ioke.false
      ioke.ground.find_cell(nil, nil, "vex").data.as_java_integer.should == 14
    end

    it "should search the added load paths" do 
      xpath = File.expand_path(File.join(File.dirname(__FILE__), "sub_load"))
      ioke = IokeRuntime.get_runtime
      result = ioke.evaluate_string(<<CODE)
System loadPath << "#{xpath}"
use("foo1")
Ground fooHasBeenLoaded
CODE
      result.data.as_java_integer.should == 42
    end

    it "should raise exception if it can't find something" do 
      proc do 
        run_with_cwd('use("blarg")')
      end.should raise_error
    end

    it "should first try to load on name from predefined" do 
      runtime = IokeRuntime.get_runtime
      runtime.add_builtin_script("load1", PlainTextBuiltin.new("load1", "Ground vex = 25"))
      result, _ = run_with_cwd("use(\"load1\")", runtime)
      result.should == runtime.true
      runtime.ground.find_cell(nil, nil, "val").should == runtime.nul
      runtime.ground.find_cell(nil, nil, "vex").data.as_java_integer.should == 25
    end
  end
end
