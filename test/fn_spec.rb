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

      ioke.evaluate_stream(StringReader.new(%q[x = fn(42+4). x call. x call])).data.as_java_integer.should == 46
    end
    
    it "should have access to variables in the scope it was defined, in simple do" do 
      ioke = IokeRuntime.get_runtime()
      ioke.evaluate_stream(StringReader.new(%q[x = 26. fn(x) call])).data.as_java_integer.should == 26

      result = ioke.evaluate_stream(StringReader.new(<<CODE))
x = Origin mimic
x do (
  y = 42
  z = fn(y+1) call)
x z
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
)
x y
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
fn(blarg = 42. blarg) call
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
fn(x, x = 13. x) call(123)
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
first  = fnx(x 13, y "foo".(x + 42)-1, y)
CODE

    ioke.evaluate_stream(StringReader.new("first")).data.as_java_integer.should == 54
    ioke.evaluate_stream(StringReader.new("first(12)")).data.as_java_integer.should == 53
    ioke.evaluate_stream(StringReader.new("first(12, 52)")).data.as_java_integer.should == 52
  end
  
  it "should be possible to define a block with a keyword argument" do 
    ioke = IokeRuntime.get_runtime()
    ioke.evaluate_stream(StringReader.new(<<CODE))
fn(x:, x)
CODE
  end

  it "should give nil as default value to keyword argument" do 
    ioke = IokeRuntime.get_runtime()
    ioke.evaluate_stream(StringReader.new(<<CODE))
first = fnx(x:, x)
CODE
    
    ioke.evaluate_stream(StringReader.new("first")).should == ioke.nil
    ioke.evaluate_stream(StringReader.new("first()")).should == ioke.nil
  end

  it "should be possible to call with keyword argument" do 
    ioke = IokeRuntime.get_runtime()
    ioke.evaluate_stream(StringReader.new(<<CODE))
first = fnx(x:, x)
CODE
    
    ioke.evaluate_stream(StringReader.new("first(x: 12)")).data.as_java_integer.should == 12
  end

  it "should be possible to give a keyword argument a default value" do 
    ioke = IokeRuntime.get_runtime()
    ioke.evaluate_stream(StringReader.new(<<CODE))
first = fnx(x: 42, x)
CODE
    
    ioke.evaluate_stream(StringReader.new("first")).data.as_java_integer.should == 42
    ioke.evaluate_stream(StringReader.new("first(x: 12)")).data.as_java_integer.should == 12
  end

  it "should be possible to give more than one keyword argument in any order" do 
    ioke = IokeRuntime.get_runtime()
    ioke.evaluate_stream(StringReader.new(<<CODE))
first = fnx(x:, y:, x)
second = fnx(x:, y:, y)
CODE
    
    ioke.evaluate_stream(StringReader.new("first")).should == ioke.nil
    ioke.evaluate_stream(StringReader.new("second")).should == ioke.nil

    ioke.evaluate_stream(StringReader.new("first(x: 42)")).data.as_java_integer.should == 42
    ioke.evaluate_stream(StringReader.new("second(x: 42)")).should == ioke.nil

    ioke.evaluate_stream(StringReader.new("first(x: 42,y: 33)")).data.as_java_integer.should == 42
    ioke.evaluate_stream(StringReader.new("second(x: 42, y: 33)")).data.as_java_integer.should == 33

    ioke.evaluate_stream(StringReader.new("first(y: 42,x: 33)")).data.as_java_integer.should == 33
    ioke.evaluate_stream(StringReader.new("second(y: 42, x: 33)")).data.as_java_integer.should == 42
  end

  it "should be possible to have both keyword argument and regular argument and give keyword argument before regular argument" do 
    ioke = IokeRuntime.get_runtime()
    ioke.evaluate_stream(StringReader.new(<<CODE))
first = fnx(z, x:, x)
second = fnx(z, x:, z)
third = fnx(x:, z,  x)
fourth = fnx(x:, z,  z)
CODE
    
    ioke.evaluate_stream(StringReader.new("second(12)")).data.as_java_integer.should == 12
    ioke.evaluate_stream(StringReader.new("fourth(13)")).data.as_java_integer.should == 13

    ioke.evaluate_stream(StringReader.new("first(12)")).should == ioke.nil
    ioke.evaluate_stream(StringReader.new("third(13)")).should == ioke.nil

    ioke.evaluate_stream(StringReader.new("second(x: 321, 12)")).data.as_java_integer.should == 12
    ioke.evaluate_stream(StringReader.new("fourth(x: 321, 13)")).data.as_java_integer.should == 13

    ioke.evaluate_stream(StringReader.new("first(x: 333, 12)")).data.as_java_integer.should == 333
    ioke.evaluate_stream(StringReader.new("third(x: 343, 13)")).data.as_java_integer.should == 343
  end

  it "should be possible to have both keyword argument and regular argument and give keyword argument after regular argument" do 
    ioke = IokeRuntime.get_runtime()
    ioke.evaluate_stream(StringReader.new(<<CODE))
first = fnx(z, x:, x)
second = fnx(z, x:, z)
third = fnx(x:, z,  x)
fourth = fnx(x:, z,  z)
CODE
    
    ioke.evaluate_stream(StringReader.new("second(12)")).data.as_java_integer.should == 12
    ioke.evaluate_stream(StringReader.new("fourth(13)")).data.as_java_integer.should == 13

    ioke.evaluate_stream(StringReader.new("first(12)")).should == ioke.nil
    ioke.evaluate_stream(StringReader.new("third(13)")).should == ioke.nil

    ioke.evaluate_stream(StringReader.new("second(12, x: 321)")).data.as_java_integer.should == 12
    ioke.evaluate_stream(StringReader.new("fourth(13, x: 321)")).data.as_java_integer.should == 13

    ioke.evaluate_stream(StringReader.new("first(12, x: 333)")).data.as_java_integer.should == 333
    ioke.evaluate_stream(StringReader.new("third(13, x: 343)")).data.as_java_integer.should == 343
  end
  
  it "should be possible to have both keyword argument and optional argument and intersperse keyword arguments" do 
    ioke = IokeRuntime.get_runtime()
    ioke.evaluate_stream(StringReader.new(<<CODE))
m1 = fnx(x, y 12, z:, x)
m2 = fnx(x, y 12, z:, y)
m3 = fnx(x, y 12, z:, z)
m4 = fnx(x, z:, y 12, x)
m5 = fnx(x, z:, y 12, y)
m6 = fnx(x, z:, y 12, z)
m7 = fnx(z:, x, y 12, x)
m8 = fnx(z:, x, y 12, y)
m9 = fnx(z:, x, y 12, z)
CODE

    ioke.evaluate_stream(StringReader.new("m1(42)")).data.as_java_integer.should == 42
    ioke.evaluate_stream(StringReader.new("m2(42)")).data.as_java_integer.should == 12
    ioke.evaluate_stream(StringReader.new("m3(42)")).should == ioke.nil
    ioke.evaluate_stream(StringReader.new("m4(42)")).data.as_java_integer.should == 42
    ioke.evaluate_stream(StringReader.new("m5(42)")).data.as_java_integer.should == 12
    ioke.evaluate_stream(StringReader.new("m6(42)")).should == ioke.nil
    ioke.evaluate_stream(StringReader.new("m7(42)")).data.as_java_integer.should == 42
    ioke.evaluate_stream(StringReader.new("m8(42)")).data.as_java_integer.should == 12
    ioke.evaluate_stream(StringReader.new("m9(42)")).should == ioke.nil

    ioke.evaluate_stream(StringReader.new("m1(42, 13)")).data.as_java_integer.should == 42
    ioke.evaluate_stream(StringReader.new("m2(42, 13)")).data.as_java_integer.should == 13
    ioke.evaluate_stream(StringReader.new("m3(42, 13)")).should == ioke.nil
    ioke.evaluate_stream(StringReader.new("m4(42, 13)")).data.as_java_integer.should == 42
    ioke.evaluate_stream(StringReader.new("m5(42, 13)")).data.as_java_integer.should == 13
    ioke.evaluate_stream(StringReader.new("m6(42, 13)")).should == ioke.nil
    ioke.evaluate_stream(StringReader.new("m7(42, 13)")).data.as_java_integer.should == 42
    ioke.evaluate_stream(StringReader.new("m8(42, 13)")).data.as_java_integer.should == 13
    ioke.evaluate_stream(StringReader.new("m9(42, 13)")).should == ioke.nil

    ioke.evaluate_stream(StringReader.new("m1(z: 1, 42)")).data.as_java_integer.should == 42
    ioke.evaluate_stream(StringReader.new("m2(z: 1, 42)")).data.as_java_integer.should == 12
    ioke.evaluate_stream(StringReader.new("m3(z: 1, 42)")).data.as_java_integer.should == 1
    ioke.evaluate_stream(StringReader.new("m4(z: 1, 42)")).data.as_java_integer.should == 42
    ioke.evaluate_stream(StringReader.new("m5(z: 1, 42)")).data.as_java_integer.should == 12
    ioke.evaluate_stream(StringReader.new("m6(z: 1, 42)")).data.as_java_integer.should == 1
    ioke.evaluate_stream(StringReader.new("m7(z: 1, 42)")).data.as_java_integer.should == 42
    ioke.evaluate_stream(StringReader.new("m8(z: 1, 42)")).data.as_java_integer.should == 12
    ioke.evaluate_stream(StringReader.new("m9(z: 1, 42)")).data.as_java_integer.should == 1

    ioke.evaluate_stream(StringReader.new("m1(z: 1, 42, 14)")).data.as_java_integer.should == 42
    ioke.evaluate_stream(StringReader.new("m2(z: 1, 42, 14)")).data.as_java_integer.should == 14
    ioke.evaluate_stream(StringReader.new("m3(z: 1, 42, 14)")).data.as_java_integer.should == 1
    ioke.evaluate_stream(StringReader.new("m4(z: 1, 42, 14)")).data.as_java_integer.should == 42
    ioke.evaluate_stream(StringReader.new("m5(z: 1, 42, 14)")).data.as_java_integer.should == 14
    ioke.evaluate_stream(StringReader.new("m6(z: 1, 42, 14)")).data.as_java_integer.should == 1
    ioke.evaluate_stream(StringReader.new("m7(z: 1, 42, 14)")).data.as_java_integer.should == 42
    ioke.evaluate_stream(StringReader.new("m8(z: 1, 42, 14)")).data.as_java_integer.should == 14
    ioke.evaluate_stream(StringReader.new("m9(z: 1, 42, 14)")).data.as_java_integer.should == 1

    ioke.evaluate_stream(StringReader.new("m1(42, z: 1, 14)")).data.as_java_integer.should == 42
    ioke.evaluate_stream(StringReader.new("m2(42, z: 1, 14)")).data.as_java_integer.should == 14
    ioke.evaluate_stream(StringReader.new("m3(42, z: 1, 14)")).data.as_java_integer.should == 1
    ioke.evaluate_stream(StringReader.new("m4(42, z: 1, 14)")).data.as_java_integer.should == 42
    ioke.evaluate_stream(StringReader.new("m5(42, z: 1, 14)")).data.as_java_integer.should == 14
    ioke.evaluate_stream(StringReader.new("m6(42, z: 1, 14)")).data.as_java_integer.should == 1
    ioke.evaluate_stream(StringReader.new("m7(42, z: 1, 14)")).data.as_java_integer.should == 42
    ioke.evaluate_stream(StringReader.new("m8(42, z: 1, 14)")).data.as_java_integer.should == 14
    ioke.evaluate_stream(StringReader.new("m9(42, z: 1, 14)")).data.as_java_integer.should == 1

    ioke.evaluate_stream(StringReader.new("m1(42, 14, z: 1)")).data.as_java_integer.should == 42
    ioke.evaluate_stream(StringReader.new("m2(42, 14, z: 1)")).data.as_java_integer.should == 14
    ioke.evaluate_stream(StringReader.new("m3(42, 14, z: 1)")).data.as_java_integer.should == 1
    ioke.evaluate_stream(StringReader.new("m4(42, 14, z: 1)")).data.as_java_integer.should == 42
    ioke.evaluate_stream(StringReader.new("m5(42, 14, z: 1)")).data.as_java_integer.should == 14
    ioke.evaluate_stream(StringReader.new("m6(42, 14, z: 1)")).data.as_java_integer.should == 1
    ioke.evaluate_stream(StringReader.new("m7(42, 14, z: 1)")).data.as_java_integer.should == 42
    ioke.evaluate_stream(StringReader.new("m8(42, 14, z: 1)")).data.as_java_integer.should == 14
    ioke.evaluate_stream(StringReader.new("m9(42, 14, z: 1)")).data.as_java_integer.should == 1
  end
  
  it "should be possible to have keyword arguments use as default values things defined before it in the argument list" do 
    ioke = IokeRuntime.get_runtime()
    ioke.evaluate_stream(StringReader.new(<<CODE))
m1 = fnx(x, y: x+2, y)
m2 = fnx(x 13, y: x+2, y)
CODE

    ioke.evaluate_stream(StringReader.new("m1(55)")).data.as_java_integer.should == 57
    ioke.evaluate_stream(StringReader.new("m2")).data.as_java_integer.should == 15
    ioke.evaluate_stream(StringReader.new("m2(55)")).data.as_java_integer.should == 57
    
    ioke.evaluate_stream(StringReader.new("m1(55, y: 111)")).data.as_java_integer.should == 111
    ioke.evaluate_stream(StringReader.new("m2(y: 111)")).data.as_java_integer.should == 111
    ioke.evaluate_stream(StringReader.new("m2(55, y: 111)")).data.as_java_integer.should == 111
    ioke.evaluate_stream(StringReader.new("m2(y: 111, 55)")).data.as_java_integer.should == 111
  end

  it "should raise an error when providing a keyword argument that haven't been defined" do 
    ioke = IokeRuntime.get_runtime()
    ioke.evaluate_stream(StringReader.new(<<CODE))
m1 = fnx(x, x)
m2 = fnx(x 13, x)
m3 = fnx(x: 42, x)
CODE

    proc do 
      ioke.evaluate_stream(StringReader.new("m1(1, foo: 13)"))
    end.should raise_error(MismatchedKeywords)

    proc do 
      ioke.evaluate_stream(StringReader.new("m2(foo: 13)"))
    end.should raise_error(MismatchedKeywords)

    proc do 
      ioke.evaluate_stream(StringReader.new("m3(foo: 13)"))
    end.should raise_error(MismatchedKeywords)
  end

  it "should be possible to get a list of keyword arguments"

  it "should be possible to use a keyword arguments value as a default value for a regular argument" do 
    ioke = IokeRuntime.get_runtime()
    ioke.evaluate_stream(StringReader.new(<<CODE))
m1 = fnx(x:, y x+2, y)
m2 = fnx(y x+2, x:, y)
CODE

    ioke.evaluate_stream(StringReader.new("m1(x: 14)")).data.as_java_integer.should == 16
    ioke.evaluate_stream(StringReader.new("m1(13, x: 14)")).data.as_java_integer.should == 13
    ioke.evaluate_stream(StringReader.new("m1(x: 14, 42)")).data.as_java_integer.should == 42
    ioke.evaluate_stream(StringReader.new("m2(x: 14, 44)")).data.as_java_integer.should == 44

    proc do 
      ioke.evaluate_stream(StringReader.new("m2(x:15)"))
    end.should raise_error(NoSuchCellException)
  end
end
