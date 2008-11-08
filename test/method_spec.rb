include_class('ioke.lang.Runtime') { 'IokeRuntime' } unless defined?(IokeRuntime)
include_class('ioke.lang.exceptions.MismatchedArgumentCount') unless defined?(MismatchedArgumentCount)
include_class('ioke.lang.exceptions.ArgumentWithoutDefaultValue') unless defined?(ArgumentWithoutDefaultValue)
include_class('ioke.lang.exceptions.MismatchedKeywords') unless defined?(MismatchedKeywords)
include_class('ioke.lang.exceptions.NoSuchCellException') unless defined?(NoSuchCellException)

import Java::java.io.StringReader unless defined?(StringReader)

describe "DefaultBehavior" do 
  describe "'method'" do 
    it "should return a method that returns nil when called with no arguments" do 
      ioke = IokeRuntime.get_runtime()
      ioke.evaluate_stream(StringReader.new("method call")).should == ioke.nil
      ioke.evaluate_stream(StringReader.new("method() call")).should == ioke.nil
    end
    
    it "should name itself after the slot it's assigned to if it has no name" do 
      ioke = IokeRuntime.get_runtime()
      ioke.evaluate_stream(StringReader.new("x = method(nil)")).data.name.should == "x"
    end
    
    it "should not change it's name if it already has a name" do 
      ioke = IokeRuntime.get_runtime()
      ioke.evaluate_stream(StringReader.new("x = method(nil)\ny = cell(\"x\")\ncell(\"y\")")).data.name.should == "x"
    end
    
    it "should know it's own name" do 
      ioke = IokeRuntime.get_runtime()
      ioke.evaluate_stream(StringReader.new("(x = method(nil)) name")).data.text.should == "x"
    end
  end
end

describe "DefaultMethod" do 
  it "should be possible to give it a documentation string" do 
    ioke = IokeRuntime.get_runtime()
    ioke.evaluate_stream(StringReader.new("method(\"foo is bar\", nil) documentation")).data.text.should == "foo is bar"
  end
  
  it "should report arity failures with regular arguments" do 
    ioke = IokeRuntime.get_runtime()
    ioke.evaluate_stream(StringReader.new(<<CODE))
noargs = method(nil)
onearg = method(x, nil)
twoargs = method(x, y, nil)
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
oneopt       = method(x 1, nil)
twoopt       = method(x 1, y 2, nil)
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
oneopt       = method(y, x 1, nil)
twoopt       = method(z, x 1, y 2, nil)
oneopttworeg = method(z, q, x 1, nil)
twoopttworeg = method(z, q, x 1, y 2, nil)
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
method(x 1, y, nil)
CODE
    end.should raise_error(ArgumentWithoutDefaultValue)
  end
    
  it "should be possible to give it one optional argument with simple data" do 
    ioke = IokeRuntime.get_runtime()
    ioke.evaluate_stream(StringReader.new(<<CODE))
m = method(x 42, x)
CODE
    ioke.evaluate_stream(StringReader.new("m")).data.as_java_integer.should == 42
    ioke.evaluate_stream(StringReader.new("m(43)")).data.as_java_integer.should == 43
  end

  it "should be possible to give it one optional argument and one regular argument with simple data" do 
    ioke = IokeRuntime.get_runtime()
    ioke.evaluate_stream(StringReader.new(<<CODE))
first = method(x, y 42, x)
second = method(x, y 42, y)
CODE

    ioke.evaluate_stream(StringReader.new("first(10)")).data.as_java_integer.should == 10
    ioke.evaluate_stream(StringReader.new("second(10)")).data.as_java_integer.should == 42

    ioke.evaluate_stream(StringReader.new("first(10, 13)")).data.as_java_integer.should == 10
    ioke.evaluate_stream(StringReader.new("second(10, 13)")).data.as_java_integer.should == 13
  end
  
  it "should be possible to give it one regular argument and one optional argument that refers to the first one" do 
    ioke = IokeRuntime.get_runtime()
    ioke.evaluate_stream(StringReader.new(<<CODE))
first = method(x, y x + 42, y)
CODE
    ioke.evaluate_stream(StringReader.new("first(10)")).data.as_java_integer.should == 52
    ioke.evaluate_stream(StringReader.new("first(10, 33)")).data.as_java_integer.should == 33
  end
  
  it "should be possible to give it two optional arguments where the second refers to the first one" do 
    ioke = IokeRuntime.get_runtime()
    ioke.evaluate_stream(StringReader.new(<<CODE))
first  = method(x 13, y x + 42, x)
second = method(x 13, y x + 42, y)
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
first  = method(x 13, y "foo".(x + 42)-1, y)
CODE

    ioke.evaluate_stream(StringReader.new("first")).data.as_java_integer.should == 54
    ioke.evaluate_stream(StringReader.new("first(12)")).data.as_java_integer.should == 53
    ioke.evaluate_stream(StringReader.new("first(12, 52)")).data.as_java_integer.should == 52
  end
  
  it "should be possible to define a method with a keyword argument" do 
    ioke = IokeRuntime.get_runtime()
    ioke.evaluate_stream(StringReader.new(<<CODE))
method(x:, x)
CODE
  end

  it "should give nil as default value to keyword argument" do 
    ioke = IokeRuntime.get_runtime()
    ioke.evaluate_stream(StringReader.new(<<CODE))
first = method(x:, x)
CODE
    
    ioke.evaluate_stream(StringReader.new("first")).should == ioke.nil
    ioke.evaluate_stream(StringReader.new("first()")).should == ioke.nil
  end

  it "should be possible to call with keyword argument" do 
    ioke = IokeRuntime.get_runtime()
    ioke.evaluate_stream(StringReader.new(<<CODE))
first = method(x:, x)
CODE
    
    ioke.evaluate_stream(StringReader.new("first(x: 12)")).data.as_java_integer.should == 12
  end

  it "should be possible to give a keyword argument a default value" do 
    ioke = IokeRuntime.get_runtime()
    ioke.evaluate_stream(StringReader.new(<<CODE))
first = method(x: 42, x)
CODE
    
    ioke.evaluate_stream(StringReader.new("first")).data.as_java_integer.should == 42
    ioke.evaluate_stream(StringReader.new("first(x: 12)")).data.as_java_integer.should == 12
  end

  it "should be possible to give more than one keyword argument in any order" do 
    ioke = IokeRuntime.get_runtime()
    ioke.evaluate_stream(StringReader.new(<<CODE))
first = method(x:, y:, x)
second = method(x:, y:, y)
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
first = method(z, x:, x)
second = method(z, x:, z)
third = method(x:, z,  x)
fourth = method(x:, z,  z)
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
first = method(z, x:, x)
second = method(z, x:, z)
third = method(x:, z,  x)
fourth = method(x:, z,  z)
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
m1 = method(x, y 12, z:, x)
m2 = method(x, y 12, z:, y)
m3 = method(x, y 12, z:, z)
m4 = method(x, z:, y 12, x)
m5 = method(x, z:, y 12, y)
m6 = method(x, z:, y 12, z)
m7 = method(z:, x, y 12, x)
m8 = method(z:, x, y 12, y)
m9 = method(z:, x, y 12, z)
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
m1 = method(x, y: x+2, y)
m2 = method(x 13, y: x+2, y)
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
m1 = method(x, x)
m2 = method(x 13, x)
m3 = method(x: 42, x)
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

  it "should be possible to get a list of keyword arguments" do 
    ioke = IokeRuntime.get_runtime()
    ioke.evaluate_string("method keywords == []").should == ioke.true
    ioke.evaluate_string("method(a, a) keywords == []").should == ioke.true
    ioke.evaluate_string("method(a 1, a) keywords == []").should == ioke.true
    ioke.evaluate_string("method(a, b, a) keywords == []").should == ioke.true
    ioke.evaluate_string("method(a:, a) keywords == [:a]").should == ioke.true
    ioke.evaluate_string("method(x, a:, a) keywords == [:a]").should == ioke.true
    ioke.evaluate_string("method(x, a:, y, a) keywords == [:a]").should == ioke.true
    ioke.evaluate_string("method(x, a:, y, b: 123, a) keywords == [:a, :b]").should == ioke.true
    ioke.evaluate_string("method(x, a:, y, b: 123, foo: \"foo\", a) keywords == [:a, :b, :foo]").should == ioke.true
  end

  it "should be possible to use a keyword arguments value as a default value for a regular argument" do 
    ioke = IokeRuntime.get_runtime()
    ioke.evaluate_stream(StringReader.new(<<CODE))
m1 = method(x:, y x+2, y)
m2 = method(y x+2, x:, y)
CODE

    ioke.evaluate_stream(StringReader.new("m1(x: 14)")).data.as_java_integer.should == 16
    ioke.evaluate_stream(StringReader.new("m1(13, x: 14)")).data.as_java_integer.should == 13
    ioke.evaluate_stream(StringReader.new("m1(x: 14, 42)")).data.as_java_integer.should == 42
    ioke.evaluate_stream(StringReader.new("m2(x: 14, 44)")).data.as_java_integer.should == 44

    proc do 
      ioke.evaluate_stream(StringReader.new("m2(x:15)"))
    end.should raise_error(NoSuchCellException)
  end
  
  it "should have @ return the receiving object inside of a method" do 
    ioke = IokeRuntime.get_runtime()
    ioke.evaluate_stream(StringReader.new(<<CODE))
obj = Origin mimic
obj atSign = method(@)
obj2 = obj mimic
CODE
    ioke.evaluate_stream(StringReader.new("obj atSign")).should == ioke.ground.find_cell(nil,nil,"obj")
    ioke.evaluate_stream(StringReader.new("obj2 atSign")).should == ioke.ground.find_cell(nil,nil,"obj2")
  end

  it "should have 'self' return the receiving object inside of a method" do 
    ioke = IokeRuntime.get_runtime()
    ioke.evaluate_stream(StringReader.new(<<CODE))
obj = Origin mimic
obj selfMethod = method(self)
obj2 = obj mimic
CODE
    ioke.evaluate_stream(StringReader.new("obj selfMethod")).should == ioke.ground.find_cell(nil,nil,"obj")
    ioke.evaluate_stream(StringReader.new("obj2 selfMethod")).should == ioke.ground.find_cell(nil,nil,"obj2")
  end
  
  describe "rest (*)" do 
    it "should have tests"
  end
  
  describe "keyword rest (&)" do 
    it "should have tests"
  end
end
