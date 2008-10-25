include_class('ioke.lang.Runtime') { 'IokeRuntime' } unless defined?(IokeRuntime)
include_class('ioke.lang.exceptions.ControlFlow') unless defined?(ControlFlow)

import Java::java.io.StringReader unless defined?(StringReader)

describe "DefaultBehavior" do
  describe "'fnx'" do 
    it "should return something that is activatable for empty list" do 
      ioke = IokeRuntime.get_runtime()
      ioke.evaluate_stream(StringReader.new(%q[fnx activatable])).should == ioke.true
    end

    it "should return something that is activatable for code" do 
      ioke = IokeRuntime.get_runtime()
      ioke.evaluate_stream(StringReader.new(%q[fnx("hello") activatable])).should == ioke.true
    end

    it "should return something that is activatable for code with arguments" do 
      ioke = IokeRuntime.get_runtime()
      ioke.evaluate_stream(StringReader.new(%q[fnx(x, y, x+y) activatable])).should == ioke.true
    end
  end
  
  describe "'fn'" do 
    it "should mimic LexicalBlock" do 
      ioke = IokeRuntime.get_runtime()
      result = ioke.evaluate_stream(StringReader.new(%q[fn("hello" println)]))
      result.find_cell(nil,nil, 'kind').data.text.should == 'LexicalBlock'
      result.should_not == ioke.lexical_block
    end
    
    it "should return nil when invoking 'call' on an empty block" do 
      ioke = IokeRuntime.get_runtime()
      ioke.evaluate_stream(StringReader.new(%q[fn call])).should == ioke.nil
    end
    
    it "should be possible to execute it by invoking 'call' on it" do 
      ioke = IokeRuntime.get_runtime()
      ioke.evaluate_stream(StringReader.new(%q[fn(1+1) call])).data.as_java_integer.should == 2

      ioke.evaluate_stream(StringReader.new(%q[x = fn(42+4); x call; x call])).data.as_java_integer.should == 46
    end
    
    it "should have access to variables in the scope it was defined, in simple do" do 
      ioke = IokeRuntime.get_runtime()
      ioke.evaluate_stream(StringReader.new(%q[x = 26; fn(x) call])).data.as_java_integer.should == 26

      result = ioke.evaluate_stream(StringReader.new(<<CODE))
x = Origin mimic
x do (
  y = 42
  fn(y+1) call)
CODE
      result.data.as_java_integer.should == 43
    end
    
    it "should have access to variables in the scope it was defined, in more complicated do" do 
      ioke = IokeRuntime.get_runtime()
      result = ioke.evaluate_stream(StringReader.new(<<CODE))
x = Origin mimic
x do (
  y = 42
  z = fn(y+2))
x z call
CODE
      result.data.as_java_integer.should == 44
    end
    
    it "should have access to variables in the scope it was defined, in more nested blocks" do 
      ioke = IokeRuntime.get_runtime()
      result = ioke.evaluate_stream(StringReader.new(<<CODE))
x = Origin mimic
x do (
  y = 42
  z = fn(fn(y+3) call))
x z call
CODE
      result.data.as_java_integer.should == 45
    end
    
    it "should have access to variables in the scope it was defined, in method" do 
      ioke = IokeRuntime.get_runtime()
      result = ioke.evaluate_stream(StringReader.new(<<CODE))
x = Origin mimic
x y = method(
  z = 42
  fn(z+5)
)

x y() call
CODE
      result.data.as_java_integer.should == 47
    end
    
    it "should have access to variables in the scope it was defined, in method, getting self" do 
      ioke = IokeRuntime.get_runtime()
      result = ioke.evaluate_stream(StringReader.new(<<CODE))
x = Origin mimic
x y = method(
  fn(self)
)

x y() call
CODE
      result.should == ioke.ground.find_cell(nil, nil, "x")
    end

    it "should take arguments" do 
      ioke = IokeRuntime.get_runtime()
      ioke.evaluate_stream(StringReader.new(%q[fn(x, x) call(42)])).data.as_java_integer.should == 42
      ioke.evaluate_stream(StringReader.new(%q[fn(x, x+2) call(42)])).data.as_java_integer.should == 44
      ioke.evaluate_stream(StringReader.new(%q[fn(x, y, x+y+2) call(3,7)])).data.as_java_integer.should == 12
    end
    
    it "should complain when given the wrong number of arguments" do 
      ioke = IokeRuntime.get_runtime()

      proc do 
        ioke.evaluate_stream(StringReader.new(%q[fn() call(42)]))
      end.should raise_error

      proc do 
        ioke.evaluate_stream(StringReader.new(%q[fn(x, x) call()]))
      end.should raise_error

      proc do 
        ioke.evaluate_stream(StringReader.new(%q[fn(x, x) call(12, 42)]))
      end.should raise_error
    end

    it "should be able to update variables in the scope it was defined" do 
      ioke = IokeRuntime.get_runtime()
      result = ioke.evaluate_stream(StringReader.new(<<CODE))
x = Origin mimic
x do(
  y = 42
  fn(y = 43) call
  y
)
CODE
      result.data.as_java_integer.should == 43

      result = ioke.evaluate_stream(StringReader.new(<<CODE))
x = Origin mimic
x do(
  y = 44
  zz = fn(y = 45)
)
x zz call
x y
CODE
      result.data.as_java_integer.should == 45
    end
    
    
    it "should create a new variable when assigning something that doesn't exist" do 
      ioke = IokeRuntime.get_runtime()
      result = ioke.evaluate_stream(StringReader.new(<<CODE))
fn(blarg = 42; blarg) call
CODE
      result.data.as_java_integer.should == 42
      ioke.ground.find_cell(nil, nil, "blarg").should == ioke.nul
    end
    
    it "should be possible to get the code for the block by calling 'code' on it"

    it "should shadow reading of outer variables when getting arguments" do 
      ioke = IokeRuntime.get_runtime()
      result = ioke.evaluate_stream(StringReader.new(<<CODE))
x = 32
fn(x, x) call(43)
CODE
      result.data.as_java_integer.should == 43
      ioke.ground.find_cell(nil, nil, "x").data.as_java_integer.should == 32
    end
    
    it "should shadow writing of outer variables when getting arguments" do 
      ioke = IokeRuntime.get_runtime()
      result = ioke.evaluate_stream(StringReader.new(<<CODE))
x = 32
fn(x, x = 13; x) call(123)
CODE
      result.data.as_java_integer.should == 13
      ioke.ground.find_cell(nil, nil, "x").data.as_java_integer.should == 32
    end
  end
end
