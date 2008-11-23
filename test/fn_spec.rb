include_class('ioke.lang.Runtime') { 'IokeRuntime' } unless defined?(IokeRuntime)
include_class('ioke.lang.exceptions.ControlFlow') unless defined?(ControlFlow)
include_class('ioke.lang.exceptions.MismatchedArgumentCount') unless defined?(MismatchedArgumentCount)

import Java::java.io.StringReader unless defined?(StringReader)
import Java::java.io.PrintWriter unless defined?(PrintWriter)
import Java::java.io.StringWriter unless defined?(StringWriter)
import Java::java.io.InputStreamReader unless defined?(InputStreamReader)
import Java::java.lang.System unless defined?(System)

describe "DefaultBehavior" do
  # TODO: when tests are converted to Ioke, this should be unescaped again.
  # Since Java 1.5 and 1.6 on Java + JRuby have trouble with the lambda sign, comment it out for now.
#   describe "'ʎ'" do 
#     it "should be possible to create a new LexicalBlock with it" do 
#       ioke = IokeRuntime.get_runtime()
#       ioke.evaluate_stream(StringReader.new(%q[ʎ call])).should == ioke.nil
#     end

#     it "should be possible to create a new LexicalBlock with it that returns a value" do 
#       ioke = IokeRuntime.get_runtime()
#       ioke.evaluate_stream(StringReader.new(%q[ʎ(42) call])).data.as_java_integer.should == 42
#     end
#   end
  
#   describe "'fnx'" do 
#     it "should return something that is activatable for empty list" do 
#       ioke = IokeRuntime.get_runtime()
#       ioke.evaluate_stream(StringReader.new(%q[fnx activatable])).should == ioke.true
#     end

#     it "should return something that is activatable for code" do 
#       ioke = IokeRuntime.get_runtime()
#       ioke.evaluate_stream(StringReader.new(%q[fnx("hello") activatable])).should == ioke.true
#     end

#     it "should return something that is activatable for code with arguments" do 
#       ioke = IokeRuntime.get_runtime()
#       ioke.evaluate_stream(StringReader.new(%q[fnx(x, y, x+y) activatable])).should == ioke.true
#     end
#   end
  
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
      sw = StringWriter.new(20)
      out = PrintWriter.new(sw)

      ioke = IokeRuntime.get_runtime(out, InputStreamReader.new(System.in), out)

      begin 
        ioke.evaluate_stream(StringReader.new(%q[fn() call(42)]))
        true.should be_false
      rescue NativeException => cfe
        cfe.cause.value.find_cell(nil, nil, "kind").data.text.should == "Condition Error Invocation TooManyArguments"
      end

      begin 
        ioke.evaluate_stream(StringReader.new(%q[fn(x, x) call()]))
        true.should be_false
      rescue NativeException => cfe
        cfe.cause.value.find_cell(nil, nil, "kind").data.text.should == "Condition Error Invocation TooFewArguments"
      end

      begin 
        ioke.evaluate_stream(StringReader.new(%q[fn(x, x) call(12, 42)]))
        true.should be_false
      rescue NativeException => cfe
        cfe.cause.value.find_cell(nil, nil, "kind").data.text.should == "Condition Error Invocation TooManyArguments"
      end
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
    
    it "should be possible to get the code for the block by calling 'code' on it" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string("fn code").data.text.should == 'fn(nil)'
      ioke.evaluate_string("fn(nil) code").data.text.should == 'fn(nil)'
      ioke.evaluate_string("fn(1) code").data.text.should == 'fn(1)'
      ioke.evaluate_string("fn(1 + 1) code").data.text.should == 'fn(1 +(1))'
      ioke.evaluate_string("fn(x, x+x) code").data.text.should == 'fn(x, x +(x))'
      ioke.evaluate_string("fn(x 12, x+x) code").data.text.should == 'fn(x 12, x +(x))'
      ioke.evaluate_string("fn(x, x+x. x*x) code").data.text.should == "fn(x, x +(x) .\nx *(x))"
      ioke.evaluate_string("fn(x:, x+x. x*x) code").data.text.should == "fn(x: nil, x +(x) .\nx *(x))"
      ioke.evaluate_string("fn(x: 12, x+x. x*x) code").data.text.should == "fn(x: 12, x +(x) .\nx *(x))"
      ioke.evaluate_string("fn(x, +rest, x+x. x*x) code").data.text.should == "fn(x, +rest, x +(x) .\nx *(x))"
      ioke.evaluate_string("fn(x, +:rest, x+x. x*x) code").data.text.should == "fn(x, +:rest, x +(x) .\nx *(x))"

      ioke.evaluate_string("fnx code").data.text.should == 'fnx(nil)'
      ioke.evaluate_string("fnx(nil) code").data.text.should == 'fnx(nil)'
      ioke.evaluate_string("fnx(1) code").data.text.should == 'fnx(1)'
      ioke.evaluate_string("fnx(1 + 1) code").data.text.should == 'fnx(1 +(1))'
      ioke.evaluate_string("fnx(x, x+x) code").data.text.should == 'fnx(x, x +(x))'
      ioke.evaluate_string("fnx(x 12, x+x) code").data.text.should == 'fnx(x 12, x +(x))'
      ioke.evaluate_string("fnx(x, x+x. x*x) code").data.text.should == "fnx(x, x +(x) .\nx *(x))"
      ioke.evaluate_string("fnx(x:, x+x. x*x) code").data.text.should == "fnx(x: nil, x +(x) .\nx *(x))"
      ioke.evaluate_string("fnx(x: 12, x+x. x*x) code").data.text.should == "fnx(x: 12, x +(x) .\nx *(x))"
      ioke.evaluate_string("fnx(x, +rest, x+x. x*x) code").data.text.should == "fnx(x, +rest, x +(x) .\nx *(x))"
      ioke.evaluate_string("fnx(x, +:rest, x+x. x*x) code").data.text.should == "fnx(x, +:rest, x +(x) .\nx *(x))"
    end

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
    sw = StringWriter.new(20)
    out = PrintWriter.new(sw)

    ioke = IokeRuntime.get_runtime(out, InputStreamReader.new(System.in), out)
    ioke.evaluate_stream(StringReader.new(<<CODE))
noargs = fnx(nil)
onearg = fnx(x, nil)
twoargs = fnx(x, y, nil)
CODE

    begin 
      ioke.evaluate_stream(StringReader.new("noargs(1)"))
      true.should be_false
    rescue NativeException => cfe
      cfe.cause.value.find_cell(nil, nil, "kind").data.text.should == "Condition Error Invocation TooManyArguments"
    end

    begin 
      ioke.evaluate_stream(StringReader.new("onearg"))
      true.should be_false
    rescue NativeException => cfe
      cfe.cause.value.find_cell(nil, nil, "kind").data.text.should == "Condition Error Invocation TooFewArguments"
    end

    begin 
      ioke.evaluate_stream(StringReader.new("onearg()"))
      true.should be_false
    rescue NativeException => cfe
      cfe.cause.value.find_cell(nil, nil, "kind").data.text.should == "Condition Error Invocation TooFewArguments"
    end

    begin 
      ioke.evaluate_stream(StringReader.new("onearg(1, 2)"))
      true.should be_false
    rescue NativeException => cfe
      cfe.cause.value.find_cell(nil, nil, "kind").data.text.should == "Condition Error Invocation TooManyArguments"
    end

    begin 
      ioke.evaluate_stream(StringReader.new("twoargs"))
      true.should be_false
    rescue NativeException => cfe
      cfe.cause.value.find_cell(nil, nil, "kind").data.text.should == "Condition Error Invocation TooFewArguments"
    end

    begin 
      ioke.evaluate_stream(StringReader.new("twoargs()"))
      true.should be_false
    rescue NativeException => cfe
      cfe.cause.value.find_cell(nil, nil, "kind").data.text.should == "Condition Error Invocation TooFewArguments"
    end

    begin 
      ioke.evaluate_stream(StringReader.new("twoargs(1)"))
      true.should be_false
    rescue NativeException => cfe
      cfe.cause.value.find_cell(nil, nil, "kind").data.text.should == "Condition Error Invocation TooFewArguments"
    end

    begin 
      ioke.evaluate_stream(StringReader.new("twoargs(1, 2, 3)"))
      true.should be_false
    rescue NativeException => cfe
      cfe.cause.value.find_cell(nil, nil, "kind").data.text.should == "Condition Error Invocation TooManyArguments"
    end
  end

  it "should report arity failures with optional arguments" do 
    sw = StringWriter.new(20)
    out = PrintWriter.new(sw)

    ioke = IokeRuntime.get_runtime(out, InputStreamReader.new(System.in), out)
    ioke.evaluate_stream(StringReader.new(<<CODE))
oneopt       = fnx(x 1, nil)
twoopt       = fnx(x 1, y 2, nil)
CODE

    begin 
      ioke.evaluate_stream(StringReader.new("oneopt(1, 2)"))
      true.should be_false
    rescue NativeException => cfe
      cfe.cause.value.find_cell(nil, nil, "kind").data.text.should == "Condition Error Invocation TooManyArguments"
    end

    begin 
      ioke.evaluate_stream(StringReader.new("twoopt(1, 2, 3)"))
      true.should be_false
    rescue NativeException => cfe
      cfe.cause.value.find_cell(nil, nil, "kind").data.text.should == "Condition Error Invocation TooManyArguments"
    end
  end

  it "should report arity failures with regular and optional arguments" do 
    sw = StringWriter.new(20)
    out = PrintWriter.new(sw)

    ioke = IokeRuntime.get_runtime(out, InputStreamReader.new(System.in), out)
    ioke.evaluate_stream(StringReader.new(<<CODE))
oneopt       = fnx(y, x 1, nil)
twoopt       = fnx(z, x 1, y 2, nil)
oneopttworeg = fnx(z, q, x 1, nil)
twoopttworeg = fnx(z, q, x 1, y 2, nil)
CODE

    begin 
      ioke.evaluate_stream(StringReader.new("oneopt"))
      true.should be_false
    rescue NativeException => cfe
      cfe.cause.value.find_cell(nil, nil, "kind").data.text.should == "Condition Error Invocation TooFewArguments"
    end

    begin 
      ioke.evaluate_stream(StringReader.new("oneopt()"))
      true.should be_false
    rescue NativeException => cfe
      cfe.cause.value.find_cell(nil, nil, "kind").data.text.should == "Condition Error Invocation TooFewArguments"
    end

    begin 
      ioke.evaluate_stream(StringReader.new("oneopt(1,2,3)"))
      true.should be_false
    rescue NativeException => cfe
      cfe.cause.value.find_cell(nil, nil, "kind").data.text.should == "Condition Error Invocation TooManyArguments"
    end
    
    begin 
      ioke.evaluate_stream(StringReader.new("twoopt"))
      true.should be_false
    rescue NativeException => cfe
      cfe.cause.value.find_cell(nil, nil, "kind").data.text.should == "Condition Error Invocation TooFewArguments"
    end

    begin 
      ioke.evaluate_stream(StringReader.new("twoopt()"))
      true.should be_false
    rescue NativeException => cfe
      cfe.cause.value.find_cell(nil, nil, "kind").data.text.should == "Condition Error Invocation TooFewArguments"
    end

    begin 
      ioke.evaluate_stream(StringReader.new("twoopt(1,2,3,4)"))
      true.should be_false
    rescue NativeException => cfe
      cfe.cause.value.find_cell(nil, nil, "kind").data.text.should == "Condition Error Invocation TooManyArguments"
    end
    
    begin 
      ioke.evaluate_stream(StringReader.new("oneopttworeg"))
      true.should be_false
    rescue NativeException => cfe
      cfe.cause.value.find_cell(nil, nil, "kind").data.text.should == "Condition Error Invocation TooFewArguments"
    end

    begin 
      ioke.evaluate_stream(StringReader.new("oneopttworeg()"))
      true.should be_false
    rescue NativeException => cfe
      cfe.cause.value.find_cell(nil, nil, "kind").data.text.should == "Condition Error Invocation TooFewArguments"
    end

    begin 
      ioke.evaluate_stream(StringReader.new("oneopttworeg(1)"))
      true.should be_false
    rescue NativeException => cfe
      cfe.cause.value.find_cell(nil, nil, "kind").data.text.should == "Condition Error Invocation TooFewArguments"
    end

    begin 
      ioke.evaluate_stream(StringReader.new("oneopttworeg(1,2,3,4)"))
      true.should be_false
    rescue NativeException => cfe
      cfe.cause.value.find_cell(nil, nil, "kind").data.text.should == "Condition Error Invocation TooManyArguments"
    end

    begin 
      ioke.evaluate_stream(StringReader.new("twoopttworeg(1,2,3,4,5)"))
      true.should be_false
    rescue NativeException => cfe
      cfe.cause.value.find_cell(nil, nil, "kind").data.text.should == "Condition Error Invocation TooManyArguments"
    end
  end

  it "should report mismatched arguments when trying to define optional arguments before regular ones" do 
    sw = StringWriter.new(20)
    out = PrintWriter.new(sw)

    ioke = IokeRuntime.get_runtime(out, InputStreamReader.new(System.in), out)
    begin 
      ioke.evaluate_stream(StringReader.new(<<CODE))
fn(x 1, y, nil)
CODE
      true.should be_false
    rescue NativeException => cfe
      cfe.cause.value.find_cell(nil, nil, "kind").data.text.should == "Condition Error Invocation ArgumentWithoutDefaultValue"
    end
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
    sw = StringWriter.new(20)
    out = PrintWriter.new(sw)

    ioke = IokeRuntime.get_runtime(out, InputStreamReader.new(System.in), out)

    ioke.evaluate_stream(StringReader.new(<<CODE))
m1 = fnx(x, x)
m2 = fnx(x 13, x)
m3 = fnx(x: 42, x)
CODE

    begin 
      ioke.evaluate_string("m1(1, foo: 13)")
      true.should be_false
    rescue NativeException => cfe
      cfe.cause.value.find_cell(nil, nil, "kind").data.text.should == "Condition Error Invocation MismatchedKeywords"
    end

    begin 
      ioke.evaluate_string("m2(foo: 13)")
      true.should be_false
    rescue NativeException => cfe
      cfe.cause.value.find_cell(nil, nil, "kind").data.text.should == "Condition Error Invocation MismatchedKeywords"
    end

    begin 
      ioke.evaluate_string("m3(foo: 13)")
      true.should be_false
    rescue NativeException => cfe
      cfe.cause.value.find_cell(nil, nil, "kind").data.text.should == "Condition Error Invocation MismatchedKeywords"
    end
  end

  it "should be possible to get a list of keyword arguments" do 
    ioke = IokeRuntime.get_runtime()
    ioke.evaluate_string("fn keywords == []").should == ioke.true
    ioke.evaluate_string("fn(a, a) keywords == []").should == ioke.true
    ioke.evaluate_string("fn(a 1, a) keywords == []").should == ioke.true
    ioke.evaluate_string("fn(a, b, a) keywords == []").should == ioke.true
    ioke.evaluate_string("fn(a:, a) keywords == [:a]").should == ioke.true
    ioke.evaluate_string("fn(x, a:, a) keywords == [:a]").should == ioke.true
    ioke.evaluate_string("fn(x, a:, y, a) keywords == [:a]").should == ioke.true
    ioke.evaluate_string("fn(x, a:, y, b: 123, a) keywords == [:a, :b]").should == ioke.true
    ioke.evaluate_string("fn(x, a:, y, b: 123, foo: \"foo\", a) keywords == [:a, :b, :foo]").should == ioke.true
  end

  it "should be possible to use a keyword arguments value as a default value for a regular argument" do 
    sw = StringWriter.new(20)
    out = PrintWriter.new(sw)

    ioke = IokeRuntime.get_runtime(out, InputStreamReader.new(System.in), out)
    ioke.evaluate_stream(StringReader.new(<<CODE))
m1 = fnx(x:, y x+2, y)
m2 = fnx(y x+2, x:, y)
CODE

    ioke.evaluate_stream(StringReader.new("m1(x: 14)")).data.as_java_integer.should == 16
    ioke.evaluate_stream(StringReader.new("m1(13, x: 14)")).data.as_java_integer.should == 13
    ioke.evaluate_stream(StringReader.new("m1(x: 14, 42)")).data.as_java_integer.should == 42
    ioke.evaluate_stream(StringReader.new("m2(x: 14, 44)")).data.as_java_integer.should == 44

    begin 
      ioke.evaluate_stream(StringReader.new("m2(x:15)"))
      true.should be_false
    rescue NativeException => cfe
      cfe.cause.value.find_cell(nil, nil, "kind").data.text.should == "Condition Error NoSuchCell"
    end
  end

  describe "rest (+)" do 
    it "should to give any length of arguments to a rest-only argument" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string("restm = fnx(+rest, rest)")
      ioke.evaluate_string("restm == []").should == ioke.true
      ioke.evaluate_string("restm(1) == [1]").should == ioke.true
      ioke.evaluate_string("restm(nil, nil, nil) == [nil, nil, nil]").should == ioke.true
      ioke.evaluate_string("restm(12+1, 13+2, 14+5) == [13, 15, 19]").should == ioke.true
    end

    it "should to give both rest and regular arguments" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string("rest2 = fnx(a, b, +rest, [a, b, rest])")
      ioke.evaluate_string("rest2(1,2) == [1,2,[]]").should == ioke.true
      ioke.evaluate_string("rest2(1,2,3) == [1,2,[3]]").should == ioke.true
      ioke.evaluate_string("rest2(1,2,3,4,5+2) == [1,2,[3,4,7]]").should == ioke.true
    end

    it "should to give both rest, optional and regular arguments" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string("rest3 = fnx(a, b, c 13, d 14, +rest, [a, b, c, d, rest])")
      ioke.evaluate_string("rest3(1,2) == [1,2,13,14,[]]").should == ioke.true
      ioke.evaluate_string("rest3(1,2,33) == [1,2,33,14,[]]").should == ioke.true
      ioke.evaluate_string("rest3(1,2,33,15) == [1,2,33,15,[]]").should == ioke.true
      ioke.evaluate_string("rest3(1,2,33,15,2+2,2+3,2+5) == [1,2,33,15,[4,5,7]]").should == ioke.true
    end

    it "should to be possible to give keyword arguments to a block with a rest argument too" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string("rest4 = fnx(a, b, boo: 12, +rest, [a, b, boo, rest])")
      ioke.evaluate_string("rest4(1,2) == [1,2,12,[]]").should == ioke.true
      ioke.evaluate_string("rest4(1,2,3,4) == [1,2,12,[3,4]]").should == ioke.true
      ioke.evaluate_string("rest4(1,2,3+4) == [1,2,12,[7]]").should == ioke.true
      ioke.evaluate_string("rest4(boo: 444, 1,2,3+4) == [1,2,444,[3+4]]").should == ioke.true
      ioke.evaluate_string("rest4(1, boo: 444, 2, 3+4) == [1,2,444,[3+4]]").should == ioke.true
      ioke.evaluate_string("rest4(1, 2, boo: 444, 3+4) == [1,2,444,[3+4]]").should == ioke.true
      ioke.evaluate_string("rest4(1, 2, 3+4, boo: 444) == [1,2,444,[3+4]]").should == ioke.true
    end

    it "should be possible to splat out arguments from a list into a block with regular, optional and rest arguments" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string("norest = fnx(a, b, [a,b])")
      ioke.evaluate_string("rests  = fnx(+rest, rest)")
      ioke.evaluate_string("rests2 = fnx(a, b, +rest, [a, b, rest])")

      ioke.evaluate_string("rests([1,2,3,4]) == [[1,2,3,4]]").should == ioke.true
      ioke.evaluate_string("rests(*[1,2,3,4]) == [1,2,3,4]").should == ioke.true
      ioke.evaluate_string("x = [1,2,3,4]. rests(*x) == [1,2,3,4]").should == ioke.true

      ioke.evaluate_string("rests2(*[1,2,3,4]) == [1,2,[3,4]]").should == ioke.true
      ioke.evaluate_string("rests2(*[1,2]) == [1,2,[]]").should == ioke.true
      ioke.evaluate_string("norest(*[1,2]) == [1,2]").should == ioke.true
    end
  end
  
  describe "keyword rest (+:)" do 
    it "should be possible to give any keyword argument to something with a keyword rest" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string("krest = fnx(+:rest, rest)")
      ioke.evaluate_string("krest == {}").should == ioke.true
      ioke.evaluate_string("krest(foo: 1) == {foo: 1}").should == ioke.true
      ioke.evaluate_string("krest(foo: nil, bar: nil, quux: nil) == {foo:, bar:, quux:}").should == ioke.true
      ioke.evaluate_string("krest(one: 12+1, two: 13+2, three: 14+5) == {one: 13, two: 15, three: 19}").should == ioke.true
    end

    it "should be possible to combine with regular argument, rest arguments and optional arguments" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string("oneeach = fnx(a, b, c 12, d 15, +rest, +:krest, [a, b, c, d, rest, krest])")
      ioke.evaluate_string("oneeach(1,2) == [1,2,12,15,[],{}]")
      ioke.evaluate_string("oneeach(1,2,3) == [1,2,3,15,[],{}]")
      ioke.evaluate_string("oneeach(f: 111, 1,2) == [1,2,12,15,[],{f: 111}]")
      ioke.evaluate_string("oneeach(1, f: 111, 2) == [1,2,12,15,[],{f: 111}]")
      ioke.evaluate_string("oneeach(1, 2, f: 111) == [1,2,12,15,[],{f: 111}]")
      ioke.evaluate_string("oneeach(1, 2, 44, f: 111) == [1,2,44,15,[],{f: 111}]")
      ioke.evaluate_string("oneeach(1, 2, 44, 10, f: 111) == [1,2,44,10,[],{f: 111}]")
      ioke.evaluate_string("oneeach(1, 2, 44, 10, 12, 13, f: 111) == [1,2,44,10,[12, 13],{f: 111}]")
      ioke.evaluate_string("oneeach(1, x: 1111111, 2, 44, 10, 12, 13, f: 111) == [1,2,44,10,[12, 13],{f: 111, x: 1111111}]")
    end
    
    it "should be possible to splat out keyword arguments" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string("oneeach = fnx(a, b, c 12, d 15, +rest, +:krest, [a, b, c, d, rest, krest])")

      ioke.evaluate_string("oneeach(1,2,*{foo: 123, bar: 333}) == [1,2,12,15,[],{foo: 123, bar: 333}]").should == ioke.true
      ioke.evaluate_string("x = {foo: 123, bar: 333}. oneeach(1,2,*x) == [1,2,12,15,[],{foo: 123, bar: 333}]").should == ioke.true

      ioke.evaluate_string("oneeach(1,2,*[18,19,20,21,22], *{foo: 123, bar: 333}) == [1,2,18,19,[20, 21, 22],{foo: 123, bar: 333}]").should == ioke.true
    end
  end
end
