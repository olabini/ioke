include_class('ioke.lang.Runtime') { 'IokeRuntime' } unless defined?(IokeRuntime)
include_class('ioke.lang.exceptions.ControlFlow') unless defined?(ControlFlow)
include_class('ioke.lang.exceptions.MismatchedArgumentCount') unless defined?(MismatchedArgumentCount)
include_class('ioke.lang.exceptions.ArgumentWithoutDefaultValue') unless defined?(ArgumentWithoutDefaultValue)

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

describe "LexicalBlock" do 
  it "should report arity failures with regular arguments" do 
    ioke = IokeRuntime.get_runtime()
    ioke.evaluate_stream(StringReader.new(<<CODE))
noargs = fnx(nil)
onearg = fnx(x, nil)
twoargs = fnx(x, y, nil)
CODE

    proc do 
      ioke.evaluate_stream(StringReader.new("noargs(1)"))
    end.should raise_error(MismatchedArgumentCount)

    proc do 
      ioke.evaluate_stream(StringReader.new("onearg"))
    end.should raise_error(MismatchedArgumentCount)

    proc do 
      ioke.evaluate_stream(StringReader.new("onearg()"))
    end.should raise_error(MismatchedArgumentCount)

    proc do 
      ioke.evaluate_stream(StringReader.new("onearg(1, 2)"))
    end.should raise_error(MismatchedArgumentCount)

    proc do 
      ioke.evaluate_stream(StringReader.new("twoargs"))
    end.should raise_error(MismatchedArgumentCount)

    proc do 
      ioke.evaluate_stream(StringReader.new("twoargs()"))
    end.should raise_error(MismatchedArgumentCount)

    proc do 
      ioke.evaluate_stream(StringReader.new("twoargs(1)"))
    end.should raise_error(MismatchedArgumentCount)

    proc do 
      ioke.evaluate_stream(StringReader.new("twoargs(1, 2, 3)"))
    end.should raise_error(MismatchedArgumentCount)
  end

  it "should report arity failures with optional arguments" do 
    ioke = IokeRuntime.get_runtime()
    ioke.evaluate_stream(StringReader.new(<<CODE))
oneopt       = fnx(x 1, nil)
twoopt       = fnx(x 1, y 2, nil)
CODE

    proc do 
      ioke.evaluate_stream(StringReader.new("oneopt(1, 2)"))
    end.should raise_error(MismatchedArgumentCount)

    proc do 
      ioke.evaluate_stream(StringReader.new("twoopt(1, 2, 3)"))
    end.should raise_error(MismatchedArgumentCount)
  end

  it "should report arity failures with regular and optional arguments" do 
    ioke = IokeRuntime.get_runtime()
    ioke.evaluate_stream(StringReader.new(<<CODE))
oneopt       = fnx(y, x 1, nil)
twoopt       = fnx(z, x 1, y 2, nil)
oneopttworeg = fnx(z, q, x 1, nil)
twoopttworeg = fnx(z, q, x 1, y 2, nil)
CODE

    proc do 
      ioke.evaluate_stream(StringReader.new("oneopt"))
    end.should raise_error(MismatchedArgumentCount)

    proc do 
      ioke.evaluate_stream(StringReader.new("oneopt()"))
    end.should raise_error(MismatchedArgumentCount)

    proc do 
      ioke.evaluate_stream(StringReader.new("oneopt(1,2,3)"))
    end.should raise_error(MismatchedArgumentCount)
    
    proc do 
      ioke.evaluate_stream(StringReader.new("twoopt"))
    end.should raise_error(MismatchedArgumentCount)

    proc do 
      ioke.evaluate_stream(StringReader.new("twoopt()"))
    end.should raise_error(MismatchedArgumentCount)

    proc do 
      ioke.evaluate_stream(StringReader.new("twoopt(1,2,3,4)"))
    end.should raise_error(MismatchedArgumentCount)
    
    proc do 
      ioke.evaluate_stream(StringReader.new("oneopttworeg"))
    end.should raise_error(MismatchedArgumentCount)

    proc do 
      ioke.evaluate_stream(StringReader.new("oneopttworeg()"))
    end.should raise_error(MismatchedArgumentCount)

    proc do 
      ioke.evaluate_stream(StringReader.new("oneopttworeg(1)"))
    end.should raise_error(MismatchedArgumentCount)

    proc do 
      ioke.evaluate_stream(StringReader.new("oneopttworeg(1,2,3,4)"))
    end.should raise_error(MismatchedArgumentCount)

    proc do 
      ioke.evaluate_stream(StringReader.new("twoopttworeg(1,2,3,4,5)"))
    end.should raise_error(MismatchedArgumentCount)
  end

  it "should report mismatched arguments when trying to define optional arguments before regular ones" do 
    ioke = IokeRuntime.get_runtime()
    proc do 
      ioke.evaluate_stream(StringReader.new(<<CODE))
fn(x 1, y, nil)
CODE
    end.should raise_error(ArgumentWithoutDefaultValue)
  end
    
  it "should be possible to give it one optional argument with simple data" do 
    ioke = IokeRuntime.get_runtime()
    ioke.evaluate_stream(StringReader.new("fn(x 42, x) call")).data.as_java_integer.should == 42
    ioke.evaluate_stream(StringReader.new("fn(x 42, x) call(43)")).data.as_java_integer.should == 43
  end

  it "should be possible to give it one optional argument and one regular argument with simple data" do 
    ioke = IokeRuntime.get_runtime()
    ioke.evaluate_stream(StringReader.new(<<CODE))
first = fnx(x, y 42, x)
second = fnx(x, y 42, y)
CODE

    ioke.evaluate_stream(StringReader.new("first(10)")).data.as_java_integer.should == 10
    ioke.evaluate_stream(StringReader.new("second(10)")).data.as_java_integer.should == 42

    ioke.evaluate_stream(StringReader.new("first(10, 13)")).data.as_java_integer.should == 10
    ioke.evaluate_stream(StringReader.new("second(10, 13)")).data.as_java_integer.should == 13
  end

  it "should be possible to give it one regular argument and one optional argument that refers to the first one" do 
    ioke = IokeRuntime.get_runtime()
    ioke.evaluate_stream(StringReader.new(<<CODE))
first = fnx(x, y x + 42, y)
CODE
    ioke.evaluate_stream(StringReader.new("first(10)")).data.as_java_integer.should == 52
    ioke.evaluate_stream(StringReader.new("first(10, 33)")).data.as_java_integer.should == 33
  end

  it "should be possible to give it two optional arguments where the second refers to the first one" do 
    ioke = IokeRuntime.get_runtime()
    ioke.evaluate_stream(StringReader.new(<<CODE))
first  = fnx(x 13, y x + 42, x)
second = fnx(x 13, y x + 42, y)
CODE
    ioke.evaluate_stream(StringReader.new("first")).data.as_java_integer.should == 13
    ioke.evaluate_stream(StringReader.new("first(10)")).data.as_java_integer.should == 10
    ioke.evaluate_stream(StringReader.new("first(10, 444)")).data.as_java_integer.should == 10

    ioke.evaluate_stream(StringReader.new("second")).data.as_java_integer.should == 55
    ioke.evaluate_stream(StringReader.new("second(10)")).data.as_java_integer.should == 52
    ioke.evaluate_stream(StringReader.new("second(10, 444)")).data.as_java_integer.should == 444
  end

  it "should be possible to have more complicated expression as default value" do 
    ioke = IokeRuntime.get_runtime()
    ioke.evaluate_stream(StringReader.new(<<CODE))
first  = fnx(x 13, y "foo";(x + 42)-1, y)
CODE

    ioke.evaluate_stream(StringReader.new("first")).data.as_java_integer.should == 54
    ioke.evaluate_stream(StringReader.new("first(12)")).data.as_java_integer.should == 53
    ioke.evaluate_stream(StringReader.new("first(12, 52)")).data.as_java_integer.should == 52
  end
end
