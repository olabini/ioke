include_class('ioke.lang.Runtime') { 'IokeRuntime' } unless defined?(IokeRuntime)
include_class('ioke.lang.exceptions.ControlFlow') unless defined?(ControlFlow)

import Java::java.io.StringReader unless defined?(StringReader)
import Java::java.io.PrintWriter unless defined?(PrintWriter)
import Java::java.io.StringWriter unless defined?(StringWriter)
import Java::java.io.InputStreamReader unless defined?(InputStreamReader)
import Java::java.lang.System unless defined?(System)

describe "DefaultBehavior" do 
  describe "'internal:concatenateText'" do 
    it "should combine several strings" do 
      ioke = IokeRuntime.get_runtime()
      ioke.evaluate_string(%q[internal:concatenateText("foo", "bar", "flux")]).data.text.should == "foobarflux"
      ioke.evaluate_string(%q[x = "str". internal:concatenateText("foo", x, "flux")]).data.text.should == "foostrflux"
    end

    it "should combine strings with the text representation of other stuff" do 
      ioke = IokeRuntime.get_runtime()
      ioke.evaluate_string(%q[internal:concatenateText("foo", 123, "flux")]).data.text.should == "foo123flux"
      ioke.evaluate_string(%q[internal:concatenateText([1,2,3], "foo")]).data.text.should == "[1, 2, 3]foo"
    end
  end
  
  describe "'internal:createText'" do 
    it "should be possible to invoke from Ioke with a regular String" do 
      ioke = IokeRuntime.get_runtime()
      ioke.evaluate_string(%q[internal:createText("foo")]).data.text.should == "foo"
    end
  end

  describe "'same?'" do 
    it "should return false for different objects" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string("Origin mimic same?(Origin mimic)").should == ioke.false
    end

    it "should return true for the same objects" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string("x = Origin mimic. x same?(x)").should == ioke.true
    end
  end
  
  describe "'uniqueHexId'" do 
    it "should return different ids for different objects" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string("Origin mimic uniqueHexId != Origin mimic uniqueHexId").should == ioke.true
    end

    it "should return the same id for the same object" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string("x = Origin mimic. x uniqueHexId == x uniqueHexId").should == ioke.true
    end
  end
  
  describe "'in?'" do 
    it "should call 'include?' on the argument with itself as argument" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string(<<CODE).should == ioke.true
x = Origin mimic
x include? = method(arg, [arg, 42])
y = Origin mimic
y in?(x) == [y, 42]
CODE
    end
    
    it "should return true if the object is in a list" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string("1 in?([1,2,3])").should == ioke.true
    end

    it "should return false if the object is not in a list" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string("1 in?([2, 3, 4])").should == ioke.false
    end
  end
  
  describe "'derive'" do 
    it "should be able to derive from Origin" do 
      ioke = IokeRuntime.get_runtime()
      result = ioke.evaluate_stream(StringReader.new(%q[Origin derive]))
      result.find_cell(nil,nil, 'kind').data.text.should == 'Origin'
      result.should_not == ioke.origin
    end

    it "should be able to derive from Ground" do 
      ioke = IokeRuntime.get_runtime()
      result = ioke.evaluate_stream(StringReader.new(%q[Ground derive]))
      result.find_cell(nil,nil, 'kind').data.text.should == 'Ground'
      result.object_id.should_not == ioke.ground.object_id
    end

    it "should be able to derive from Text" do 
      ioke = IokeRuntime.get_runtime()
      result = ioke.evaluate_stream(StringReader.new(%q[Text derive]))
      result.find_cell(nil,nil, 'kind').data.text.should == 'Text'
      result.object_id.should_not == ioke.text.object_id
    end
  end
  
  describe "'break'" do 
    it "should raise a control flow exception" do 
      ioke = IokeRuntime.get_runtime()
      proc do 
        ioke.evaluate_string("break")
      end.should raise_error(NativeException)
    end

    it "should have nil as value by default" do 
      ioke = IokeRuntime.get_runtime()
      begin 
        ioke.evaluate_string("break")
        false.should == true
      rescue NativeException => e
        e.cause.value.should == ioke.nil
      end
    end

    it "should take a return value" do 
      ioke = IokeRuntime.get_runtime()
      begin 
        ioke.evaluate_string("break(42)")
        false.should == true
      rescue NativeException => e
        e.cause.value.data.as_java_integer.should == 42
      end
    end
  end
  
  describe "'continue'" do 
    it "should raise a control flow exception" do 
      ioke = IokeRuntime.get_runtime()
      proc do 
        ioke.evaluate_string("continue")
      end.should raise_error(NativeException)
    end

    it "should have nil as value" do 
      ioke = IokeRuntime.get_runtime()
      begin 
        ioke.evaluate_string("continue")
        false.should == true
      rescue NativeException => e
        e.cause.value.should == nil
      end
    end
  end

  describe "'return'" do 
    it "should raise a control flow exception" do 
      ioke = IokeRuntime.get_runtime()
      proc do 
        ioke.evaluate_string("return")
      end.should raise_error(NativeException)
    end

    it "should have nil as value by default" do 
      ioke = IokeRuntime.get_runtime()
      begin 
        ioke.evaluate_string("return")
        false.should == true
      rescue NativeException => e
        e.cause.value.should == ioke.nil
      end
    end

    it "should take a return value" do 
      ioke = IokeRuntime.get_runtime()
      begin 
        ioke.evaluate_string("return(42)")
        false.should == true
      rescue NativeException => e
        e.cause.value.data.as_java_integer.should == 42
      end
    end
  end
  
  describe "'until'" do 
    it "should not do anything if initial argument is true" do 
      ioke = IokeRuntime.get_runtime()
      ioke.evaluate_string((%q[x=42. until(true, x=43)]))
      ioke.ground.find_cell(nil, nil, "x").data.as_java_integer.should == 42
    end
    
    it "should loop until the argument becomes true" do 
      ioke = IokeRuntime.get_runtime()
      ioke.evaluate_string((%q[x=42. until(x==45, x++)]))
      ioke.ground.find_cell(nil, nil, "x").data.as_java_integer.should == 45
    end
    
    it "should return the last statement value" do 
      ioke = IokeRuntime.get_runtime()
      result = ioke.evaluate_string((%q[x=42. until(x==43, x++. "blurg")]))
      result.data.text.should == "blurg"
    end
    
    it "should be interrupted by break" do 
      ioke = IokeRuntime.get_runtime()
      ioke.evaluate_string((%q[x=42. until(x==50, x++. if(x==45, break))]))
      ioke.ground.find_cell(nil, nil, "x").data.as_java_integer.should == 45
    end
    
    it "should be continued by continue" do 
      ioke = IokeRuntime.get_runtime()
      ioke.evaluate_string((%q[count=0. x=42. until(x==50, count++. if(x==45, x = 47. continue). x++.)]))
      ioke.ground.find_cell(nil, nil, "x").data.as_java_integer.should == 50
      ioke.ground.find_cell(nil, nil, "count").data.as_java_integer.should == 7
    end

    it "should return nil if no arguments provided" do 
      ioke = IokeRuntime.get_runtime()
      ioke.evaluate_string((%q[until()])).should == ioke.nil
    end
  end

  describe "'while'" do 
    it "should not do anything if initial argument is false" do 
      ioke = IokeRuntime.get_runtime()
      ioke.evaluate_stream(StringReader.new(%q[x=42. while(false, x=43)]))
      ioke.ground.find_cell(nil, nil, "x").data.as_java_integer.should == 42
    end
    
    it "should loop until the argument becomes false" do 
      ioke = IokeRuntime.get_runtime()
      ioke.evaluate_stream(StringReader.new(%q[x=42. while(x<45, x++)]))
      ioke.ground.find_cell(nil, nil, "x").data.as_java_integer.should == 45
    end
    
    it "should return the last statement value" do 
      ioke = IokeRuntime.get_runtime()
      result = ioke.evaluate_stream(StringReader.new(%q[x=42. while(x<43, x++. "blurg")]))
      result.data.text.should == "blurg"
    end
    
    it "should be interrupted by break" do 
      ioke = IokeRuntime.get_runtime()
      ioke.evaluate_stream(StringReader.new(%q[x=42. while(x<50, x++. if(x==45, break))]))
      ioke.ground.find_cell(nil, nil, "x").data.as_java_integer.should == 45
    end

    it "should be continued by continue" do 
      ioke = IokeRuntime.get_runtime()
      ioke.evaluate_string((%q[count=0. x=42. while(x<50, count++. if(x==45, x = 47. continue). x++.)]))
      ioke.ground.find_cell(nil, nil, "x").data.as_java_integer.should == 50
      ioke.ground.find_cell(nil, nil, "count").data.as_java_integer.should == 7
    end
    
    it "should return nil if no arguments provided" do 
      ioke = IokeRuntime.get_runtime()
      ioke.evaluate_stream(StringReader.new(%q[while()])).should == ioke.nil
    end
  end
  
  describe "'loop'" do 
    it "should loop until interrupted by break" do 
      ioke = IokeRuntime.get_runtime()
      ioke.evaluate_stream(StringReader.new(%q[x=42. loop(x++. if(x==45, break))]))
      ioke.ground.find_cell(nil, nil, "x").data.as_java_integer.should == 45
    end
  end

  describe "'if'" do 
    it "should evaluate it's first element once" do 
      ioke = IokeRuntime.get_runtime()
      ioke.evaluate_stream(StringReader.new(%q[x=42. if(x++)]))
      ioke.ground.find_cell(nil, nil, "x").data.as_java_integer.should == 43
    end
    
    it "should return it's second argument if the first element evaluates to true" do 
      ioke = IokeRuntime.get_runtime()
      ioke.evaluate_stream(StringReader.new(%q[if(true, 42, 43)])).data.as_java_integer.should == 42
    end

    it "should return it's third argument if the first element evaluates to false" do 
      ioke = IokeRuntime.get_runtime()
      ioke.evaluate_stream(StringReader.new(%q[if(false, 42, 43)])).data.as_java_integer.should == 43
    end
    
    it "should return the result of evaluating the first argument if there are no more arguments" do 
      ioke = IokeRuntime.get_runtime()
      ioke.evaluate_stream(StringReader.new(%q[if(44)])).data.as_java_integer.should == 44
    end
    
    it "should return the result of evaluating the first argument if it is false and there are only two arguments" do 
      ioke = IokeRuntime.get_runtime()
      ioke.evaluate_stream(StringReader.new(%q[if(false)])).should == ioke.false
      ioke.evaluate_stream(StringReader.new(%q[if(nil)])).should == ioke.nil
    end
    
    it "should assign the test result to the variable it" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string("if(42, it) == 42").should == ioke.true
      ioke.evaluate_string("if(nil, 42, it) == nil").should == ioke.true
      ioke.evaluate_string("if(false, 42, it) == false").should == ioke.true
      ioke.evaluate_string("if(\"str\", 42, it) == 42").should == ioke.true
    end

    it "should have a lexical context for the it variable" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string("if(42, fn(it)) call == 42").should == ioke.true
    end

    it "should be possible to nest it variables lexically" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string("if(42, [it, if(13, [it, if(nil, 44, it), it])]) == [42, [13, nil, 13]]").should == ioke.true
    end
  end

  describe "'unless'" do 
    it "should evaluate it's first element once" do 
      ioke = IokeRuntime.get_runtime()
      ioke.evaluate_string(%q[x=42. unless(x++)])
      ioke.ground.find_cell(nil, nil, "x").data.as_java_integer.should == 43
    end
    
    it "should return it's second argument if the first element evaluates to false" do 
      ioke = IokeRuntime.get_runtime()
      ioke.evaluate_string(%q[unless(false, 42, 43)]).data.as_java_integer.should == 42
    end

    it "should return it's third argument if the first element evaluates to true" do 
      ioke = IokeRuntime.get_runtime()
      ioke.evaluate_string(%q[unless(true, 42, 43)]).data.as_java_integer.should == 43
    end
    
    it "should return the result of evaluating the first argument if there are no more arguments" do 
      ioke = IokeRuntime.get_runtime()
      ioke.evaluate_string(%q[unless(44)]).data.as_java_integer.should == 44
    end
    
    it "should return the result of evaluating the first argument if it is true and there are only two arguments" do 
      ioke = IokeRuntime.get_runtime()
      ioke.evaluate_string(%q[unless(true, 13)]).should == ioke.true
    end
    
    it "should assign the test result to the variable it" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string("unless(42, nil, it) == 42").should == ioke.true
      ioke.evaluate_string("unless(nil, it, 42) == nil").should == ioke.true
      ioke.evaluate_string("unless(false, it, 42) == false").should == ioke.true
      ioke.evaluate_string("unless(\"str\", it, 42) == 42").should == ioke.true
    end

    it "should have a lexical context for the it variable" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string("unless(42, nil, fn(it)) call == 42").should == ioke.true
    end

    it "should be possible to nest it variables lexically" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string("unless(42, nil, [it, unless(13, nil, [it, unless(nil, it, 44), it])]) == [42, [13, nil, 13]]").should == ioke.true
    end
  end
  
  describe "'asText'" do 
    it "should call toString and return the text from that" do 
      ioke = IokeRuntime.get_runtime()
      ioke.evaluate_stream(StringReader.new(%q[Origin mimic asText])).data.text.should match(/^#<Origin:[0-9A-F]+>$/)
    end
  end

  describe "'do'" do 
    it "should execute a piece of code inside an object" do 
      ioke = IokeRuntime.get_runtime()
      ioke.evaluate_stream(StringReader.new(<<CODE))
x = Origin mimic
x do(
  y = 42
  z = "str"
)
CODE
      ioke.ground.find_cell(nil,nil, 'y').should == ioke.nul
      ioke.ground.find_cell(nil,nil, 'x').find_cell(nil,nil, 'y').data.as_java_integer.should == 42
      ioke.ground.find_cell(nil,nil, 'x').find_cell(nil,nil, 'z').data.text.should == "str"
    end
  end
  
  describe "'nil?'" do 
    it "should return true for nil" do 
      ioke = IokeRuntime.get_runtime()
      ioke.evaluate_stream(StringReader.new("nil nil?")).should == ioke.true
    end

    it "should return false for false" do 
      ioke = IokeRuntime.get_runtime()
      ioke.evaluate_stream(StringReader.new("false nil?")).should == ioke.false
    end
    
    it "should return false for true" do 
      ioke = IokeRuntime.get_runtime()
      ioke.evaluate_stream(StringReader.new("true nil?")).should == ioke.false
    end
    
    it "should return false for a Number" do 
      ioke = IokeRuntime.get_runtime()
      ioke.evaluate_stream(StringReader.new("123 nil?")).should == ioke.false
    end
    
    it "should return false for a Text" do 
      ioke = IokeRuntime.get_runtime()
      ioke.evaluate_stream(StringReader.new("\"flurg\" nil?")).should == ioke.false
    end
  end

  describe "'true?'" do 
    it "should return false for nil" do 
      ioke = IokeRuntime.get_runtime()
      ioke.evaluate_stream(StringReader.new("nil true?")).should == ioke.false
    end

    it "should return false for false" do 
      ioke = IokeRuntime.get_runtime()
      ioke.evaluate_stream(StringReader.new("false true?")).should == ioke.false
    end
    
    it "should return true for true" do 
      ioke = IokeRuntime.get_runtime()
      ioke.evaluate_stream(StringReader.new("true true?")).should == ioke.true
    end
    
    it "should return true for a Number" do 
      ioke = IokeRuntime.get_runtime()
      ioke.evaluate_stream(StringReader.new("123 true?")).should == ioke.true
    end
    
    it "should return true for a Text" do 
      ioke = IokeRuntime.get_runtime()
      ioke.evaluate_stream(StringReader.new("\"flurg\" true?")).should == ioke.true
    end
  end

  describe "'false?'" do 
    it "should return true for nil" do 
      ioke = IokeRuntime.get_runtime()
      ioke.evaluate_stream(StringReader.new("nil false?")).should == ioke.true
    end

    it "should return true for false" do 
      ioke = IokeRuntime.get_runtime()
      ioke.evaluate_stream(StringReader.new("false false?")).should == ioke.true
    end
    
    it "should return false for true" do 
      ioke = IokeRuntime.get_runtime()
      ioke.evaluate_stream(StringReader.new("true false?")).should == ioke.false
    end
    
    it "should return false for a Number" do 
      ioke = IokeRuntime.get_runtime()
      ioke.evaluate_stream(StringReader.new("123 false?")).should == ioke.false
    end
    
    it "should return false for a Text" do 
      ioke = IokeRuntime.get_runtime()
      ioke.evaluate_stream(StringReader.new("\"flurg\" false?")).should == ioke.false
    end
  end

  describe "'mimics'" do 
    it "should return an empty list for DefaultBehavior" do 
      ioke = IokeRuntime.get_runtime()
      ioke.evaluate_string("DefaultBehavior mimics == []").should == ioke.true
    end

    it "should return a list with Origin for a simple mimic" do 
      ioke = IokeRuntime.get_runtime()
      ioke.evaluate_string("Origin mimic mimics == [Origin]").should == ioke.true
    end

    it "should return a list with all mimics" do 
      ioke = IokeRuntime.get_runtime()
      ioke.evaluate_string(<<CODE).should == ioke.true
X = Origin mimic
Y = Origin mimic
Z = Origin mimic
y = Y mimic
y mimic!(X)
y mimic!(Z)
y mimics == [Y, X, Z]
CODE
    end
  end

  describe "'removeAllMimics!'" do 
    it "should return the object" do 
      ioke = IokeRuntime.get_runtime()
      ioke.evaluate_string(<<CODE).should == ioke.true
x = Origin mimic
x uniqueHexId = DefaultBehavior cell(:uniqueHexId)
x removeAllMimics! uniqueHexId == x uniqueHexId
CODE
    end

    it "should remove all mimics" do 
      ioke = IokeRuntime.get_runtime()
      ioke.evaluate_string(<<CODE).should == ioke.true
x = Origin mimic
x mimic!(Text)
x mimics = DefaultBehavior cell(:mimics)
x removeAllMimics! mimics == []
CODE
    end
  end

  describe "'removeMimic!'" do 
    it "should not remove something it doesn't mimic" do 
      ioke = IokeRuntime.get_runtime()
      ioke.evaluate_string("Origin mimic removeMimic!(\"foo\") mimics == [Origin]").should == ioke.true
    end

    it "should return the object" do 
      ioke = IokeRuntime.get_runtime()
      ioke.evaluate_string("x = Origin mimic. x removeMimic!(1) == x").should == ioke.true
    end
    
    it "should remove any mimic it has" do 
      ioke = IokeRuntime.get_runtime()
      ioke.evaluate_string(<<CODE).should == ioke.true
x = Origin mimic
x mimics = DefaultBehavior cell(:mimics)
x removeMimic!(Origin)
x mimics == []
CODE
    end

    it "should not remove any other mimic" do 
      ioke = IokeRuntime.get_runtime()
      ioke.evaluate_string(<<CODE).should == ioke.true
x = Origin mimic
y = Origin mimic
x mimic!(y)
x removeMimic!(y)
x mimics == [Origin]
CODE
    end
  end
  
  
  describe "'prependMimic!'" do 
    it "should add a new mimic to the list of mimics" do 
      ioke = IokeRuntime.get_runtime()
      ioke.evaluate_stream(StringReader.new("f = Origin mimic. g = Origin mimic. f prependMimic!(g)"))
      ioke.ground.find_cell(nil, nil, "f").get_mimics.size.should == 2
      ioke.ground.find_cell(nil, nil, "f").get_mimics.get(1).should == ioke.origin
      ioke.ground.find_cell(nil, nil, "f").get_mimics.get(0).should == ioke.ground.find_cell(nil, nil, "g")
    end

    it "should not add a mimic that's already in the list" do 
      ioke = IokeRuntime.get_runtime()
      ioke.evaluate_stream(StringReader.new("f = Origin mimic. f prependMimic!(Origin). f prependMimic!(Origin). f prependMimic!(Origin). f prependMimic!(Origin)"))
      ioke.ground.find_cell(nil, nil, "f").get_mimics.size.should == 1
    end

    it "should not be able to mimic nil" do 
      sw = StringWriter.new(20)
      out = PrintWriter.new(sw)

      ioke = IokeRuntime.get_runtime(out, InputStreamReader.new(System.in), out)
      proc do 
        ioke.evaluate_stream(StringReader.new("f = Origin mimic. f prependMimic!(nil)"))
      end.should raise_error
    end
    
    it "should not be able to mimic true" do 
      sw = StringWriter.new(20)
      out = PrintWriter.new(sw)

      ioke = IokeRuntime.get_runtime(out, InputStreamReader.new(System.in), out)
      proc do 
        ioke.evaluate_stream(StringReader.new("f = Origin mimic. f prependMimic!(true)"))
      end.should raise_error
    end
    
    it "should not be able to mimic false" do 
      sw = StringWriter.new(20)
      out = PrintWriter.new(sw)

      ioke = IokeRuntime.get_runtime(out, InputStreamReader.new(System.in), out)
      proc do 
        ioke.evaluate_stream(StringReader.new("f = Origin mimic. f prependMimic!(false)"))
      end.should raise_error
    end
    
    it "should not be able to mimic symbols" do 
      sw = StringWriter.new(20)
      out = PrintWriter.new(sw)

      ioke = IokeRuntime.get_runtime(out, InputStreamReader.new(System.in), out)
      proc do 
        ioke.evaluate_stream(StringReader.new("f = Origin mimic. f prependMimic!(:foo)"))
      end.should raise_error
    end
    
    it "should return the receiving object" do 
      ioke = IokeRuntime.get_runtime()
      result = ioke.evaluate_stream(StringReader.new("f = Origin mimic. f prependMimic!(Origin)"))
      result.should == ioke.ground.find_cell(nil, nil, "f")
    end
  end
  
  describe "'kind?'" do 
    it "should return false if the kind doesn't match" do 
      ioke = IokeRuntime.get_runtime()
      ioke.evaluate_stream(StringReader.new("Text kind?(\"nil\")")).should == ioke.false
      ioke.evaluate_stream(StringReader.new("Text kind?(\"Number\")")).should == ioke.false
      ioke.evaluate_stream(StringReader.new("\"\" kind?(\"nil\")")).should == ioke.false
      ioke.evaluate_stream(StringReader.new("\"\" kind?(\"Number\")")).should == ioke.false
      ioke.evaluate_stream(StringReader.new("\"\" kind?(\"System\")")).should == ioke.false
    end

    it "should return true if the current object has the kind" do 
      ioke = IokeRuntime.get_runtime()
      ioke.evaluate_stream(StringReader.new("Text kind?(\"Text\")")).should == ioke.true
    end
    
    it "should return true if the main mimic has the kind" do 
      ioke = IokeRuntime.get_runtime()

      ioke.evaluate_stream(StringReader.new("\"\" kind?(\"Text\")")).should == ioke.true
      ioke.evaluate_stream(StringReader.new("\"\" kind?(\"DefaultBehavior\")")).should == ioke.true
      ioke.evaluate_stream(StringReader.new("\"\" kind?(\"Base\")")).should == ioke.true
      ioke.evaluate_stream(StringReader.new("\"\" kind?(\"Ground\")")).should == ioke.true
      ioke.evaluate_stream(StringReader.new("\"\" kind?(\"Origin\")")).should == ioke.true
    end

    it "should return true if another mimic has the kind" do 
      ioke = IokeRuntime.get_runtime()

      ioke.evaluate_stream(StringReader.new("123 kind?(\"Mixins Comparing\")")).should == ioke.true
    end

    it "should handle a cycle of mimics correctly" do 
      ioke = IokeRuntime.get_runtime()

      ioke.evaluate_stream(StringReader.new("f = Origin mimic. f mimic!(f). f kind?(\"Origin\")")).should == ioke.true
      ioke.evaluate_stream(StringReader.new("f = Origin mimic. Origin mimic!(f). f kind?(\"Origin\")")).should == ioke.true
      ioke.evaluate_stream(StringReader.new("f = Origin mimic. Origin mimic!(f). f kind?(\"DefaultBehavior\")")).should == ioke.true
    end
  end
  
  describe "'mimics?'" do 
    it "should return false if the object doesn't mimic the argument" do 
      ioke = IokeRuntime.get_runtime()

      ioke.evaluate_stream(StringReader.new("f = Origin mimic. Origin mimics?(f)")).should == ioke.false
      ioke.evaluate_stream(StringReader.new("f = Origin mimic. DefaultBehavior mimics?(f)")).should == ioke.false
      ioke.evaluate_stream(StringReader.new("f = Origin mimic. 12 mimics?(f)")).should == ioke.false
      ioke.evaluate_stream(StringReader.new("f = Origin mimic. f mimics?(12)")).should == ioke.false
    end
    
    it "should return true if the object is the same as the argument" do 
      ioke = IokeRuntime.get_runtime()

      ioke.evaluate_stream(StringReader.new("f = Origin mimic. f mimics?(f)")).should == ioke.true
      ioke.evaluate_stream(StringReader.new("Origin mimics?(Origin)")).should == ioke.true
    end

    it "should return true if any of the mimics are the argument" do 
      ioke = IokeRuntime.get_runtime()

      ioke.evaluate_stream(StringReader.new("x = Origin mimic. y = x mimic. z = y mimic. z mimics?(Origin)")).should == ioke.true
      ioke.evaluate_stream(StringReader.new("x = Origin mimic. y = x mimic. z = y mimic. z mimics?(x)")).should == ioke.true
      ioke.evaluate_stream(StringReader.new("x = Origin mimic. y = x mimic. z = y mimic. z mimics?(y)")).should == ioke.true
      ioke.evaluate_stream(StringReader.new("x = Origin mimic. y = x mimic. z = y mimic. z mimics?(z)")).should == ioke.true
      ioke.evaluate_stream(StringReader.new("f = Origin mimic. Origin mimic!(f). x = Origin mimic. y = x mimic. z = y mimic. z mimics?(f)")).should == ioke.true
    end
    
    it "should handle a cycle of mimics correctly" do 
      ioke = IokeRuntime.get_runtime()

      ioke.evaluate_stream(StringReader.new("x = Origin mimic. y = x mimic. z = y mimic. Origin mimic!(z). z mimics?(Number)")).should == ioke.false
      ioke.evaluate_stream(StringReader.new("x = Origin mimic. y = x mimic. z = y mimic. Origin mimic!(z). z mimics?(Origin)")).should == ioke.true
      ioke.evaluate_stream(StringReader.new("x = Origin mimic. y = x mimic. z = y mimic. Origin mimic!(z). z mimics?(Base)")).should == ioke.true
      ioke.evaluate_stream(StringReader.new("x = Origin mimic. x mimic!(x). x mimics?(Origin)")).should == ioke.true
    end
  end

  describe "'is?'" do 
    it "should return false if the object doesn't mimic the argument" do 
      ioke = IokeRuntime.get_runtime()

      ioke.evaluate_stream(StringReader.new("f = Origin mimic. Origin is?(f)")).should == ioke.false
      ioke.evaluate_stream(StringReader.new("f = Origin mimic. DefaultBehavior is?(f)")).should == ioke.false
      ioke.evaluate_stream(StringReader.new("f = Origin mimic. 12 is?(f)")).should == ioke.false
      ioke.evaluate_stream(StringReader.new("f = Origin mimic. f is?(12)")).should == ioke.false
    end
    
    it "should return true if the object is the same as the argument" do 
      ioke = IokeRuntime.get_runtime()

      ioke.evaluate_stream(StringReader.new("f = Origin mimic. f is?(f)")).should == ioke.true
      ioke.evaluate_stream(StringReader.new("Origin is?(Origin)")).should == ioke.true
    end

    it "should return true if any of the mimics are the argument" do 
      ioke = IokeRuntime.get_runtime()

      ioke.evaluate_stream(StringReader.new("x = Origin mimic. y = x mimic. z = y mimic. z is?(Origin)")).should == ioke.true
      ioke.evaluate_stream(StringReader.new("x = Origin mimic. y = x mimic. z = y mimic. z is?(x)")).should == ioke.true
      ioke.evaluate_stream(StringReader.new("x = Origin mimic. y = x mimic. z = y mimic. z is?(y)")).should == ioke.true
      ioke.evaluate_stream(StringReader.new("x = Origin mimic. y = x mimic. z = y mimic. z is?(z)")).should == ioke.true
      ioke.evaluate_stream(StringReader.new("f = Origin mimic. Origin mimic!(f). x = Origin mimic. y = x mimic. z = y mimic. z is?(f)")).should == ioke.true
    end
    
    it "should handle a cycle of mimics correctly" do 
      ioke = IokeRuntime.get_runtime()

      ioke.evaluate_stream(StringReader.new("x = Origin mimic. y = x mimic. z = y mimic. Origin mimic!(z). z is?(Number)")).should == ioke.false
      ioke.evaluate_stream(StringReader.new("x = Origin mimic. y = x mimic. z = y mimic. Origin mimic!(z). z is?(Origin)")).should == ioke.true
      ioke.evaluate_stream(StringReader.new("x = Origin mimic. y = x mimic. z = y mimic. Origin mimic!(z). z is?(Base)")).should == ioke.true
      ioke.evaluate_stream(StringReader.new("x = Origin mimic. x mimic!(x). x is?(Origin)")).should == ioke.true
    end
  end
  
  describe "'mimic!'" do 
    it "should add a new mimic to the list of mimics" do 
      ioke = IokeRuntime.get_runtime()
      ioke.evaluate_stream(StringReader.new("f = Origin mimic. g = Origin mimic. f mimic!(g)"))
      ioke.ground.find_cell(nil, nil, "f").get_mimics.size.should == 2
      ioke.ground.find_cell(nil, nil, "f").get_mimics.get(0).should == ioke.origin
      ioke.ground.find_cell(nil, nil, "f").get_mimics.get(1).should == ioke.ground.find_cell(nil, nil, "g")
    end

    it "should not add a mimic that's already in the list" do 
      ioke = IokeRuntime.get_runtime()
      ioke.evaluate_stream(StringReader.new("f = Origin mimic. f mimic!(Origin). f mimic!(Origin). f mimic!(Origin). f mimic!(Origin)"))
      ioke.ground.find_cell(nil, nil, "f").get_mimics.size.should == 1
    end

    it "should not be able to mimic nil" do 
      sw = StringWriter.new(20)
      out = PrintWriter.new(sw)

      ioke = IokeRuntime.get_runtime(out, InputStreamReader.new(System.in), out)
      proc do 
        ioke.evaluate_stream(StringReader.new("f = Origin mimic. f mimic!(nil)"))
      end.should raise_error
    end
    
    it "should not be able to mimic true" do 
      sw = StringWriter.new(20)
      out = PrintWriter.new(sw)

      ioke = IokeRuntime.get_runtime(out, InputStreamReader.new(System.in), out)
      proc do 
        ioke.evaluate_stream(StringReader.new("f = Origin mimic. f mimic!(true)"))
      end.should raise_error
    end
    
    it "should not be able to mimic false" do 
      sw = StringWriter.new(20)
      out = PrintWriter.new(sw)

      ioke = IokeRuntime.get_runtime(out, InputStreamReader.new(System.in), out)
      proc do 
        ioke.evaluate_stream(StringReader.new("f = Origin mimic. f mimic!(false)"))
      end.should raise_error
    end
    
    it "should not be able to mimic symbols" do 
      sw = StringWriter.new(20)
      out = PrintWriter.new(sw)

      ioke = IokeRuntime.get_runtime(out, InputStreamReader.new(System.in), out)
      proc do 
        ioke.evaluate_stream(StringReader.new("f = Origin mimic. f mimic!(:foo)"))
      end.should raise_error
    end
    
    it "should return the receiving object" do 
      ioke = IokeRuntime.get_runtime()
      result = ioke.evaluate_stream(StringReader.new("f = Origin mimic. f mimic!(Origin)"))
      result.should == ioke.ground.find_cell(nil, nil, "f")
    end
  end
  
  describe "'with'" do 
    it "should just mimic an object if no arguments given" do 
      ioke = IokeRuntime.get_runtime()
      ioke.evaluate_string("Origin with cellNames == []").should == ioke.true
    end

    it "should set the given keywords as cells" do 
      ioke = IokeRuntime.get_runtime()
      ioke.evaluate_string("Origin with(foo: 13) cellNames == [:foo]").should == ioke.true
      ioke.evaluate_string("Origin with(foo: 13) cells == {foo: 13}").should == ioke.true
      ioke.evaluate_string("Origin with(foo: 13, bar: 14) cellNames == [:foo, :bar]").should == ioke.true
      ioke.evaluate_string("Origin with(foo: 13, bar: 14) cells == {foo: 13, bar: 14}").should == ioke.true
    end
  end

  describe "'!'" do 
    it "should return the result of calling not on the object" do 
      ioke = IokeRuntime.get_runtime()
      ioke.evaluate_string("x = Origin mimic. x not = method(53). !x").data.as_java_integer.should == 53
      ioke.evaluate_string("x = Origin mimic. x not = method(33). !x").data.as_java_integer.should == 33
    end
  end

  describe "'not'" do 
    it "should return nil for a number" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string("123 not").should == ioke.nil
    end

    it "should return nil for a text" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string('"foo" not').should == ioke.nil
    end
  end

  describe "'and'" do 
    it "should evaluate it's argument" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string("x=41. 13 and(x=42). x").data.as_java_integer.should == 42
    end

    it "should complain if no argument is given" do 
      sw = StringWriter.new(20)
      out = PrintWriter.new(sw)

      ioke = IokeRuntime.get_runtime(out, InputStreamReader.new(System.in), out)
      proc do 
        ioke.evaluate_string("\"blarg\" and()")
      end.should raise_error
    end

    it "should return the result of the argument" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string("5353 and(42)").data.as_java_integer.should == 42
    end

    it "should be available in infix" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string("\"flurg\" and 43").data.as_java_integer.should == 43
    end
  end

  describe "'&&'" do 
    it "should evaluate it's argument" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string("x=41. 13 &&(x=42). x").data.as_java_integer.should == 42
    end

    it "should complain if no argument is given" do 
      sw = StringWriter.new(20)
      out = PrintWriter.new(sw)

      ioke = IokeRuntime.get_runtime(out, InputStreamReader.new(System.in), out)
      proc do 
        ioke.evaluate_string("\"blarg\" &&()")
      end.should raise_error
    end

    it "should return the result of the argument" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string("5353 &&(42)").data.as_java_integer.should == 42
    end

    it "should be available in infix" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string("\"flurg\" && 43").data.as_java_integer.should == 43
    end
  end
  
  describe "'or'" do 
    it "should not evaluate it's argument" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string("x=41. 123 or(x=42). x").data.as_java_integer.should == 41
    end

    it "should return the receiver" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string("\"murg\" or(42)").data.text.should == "murg"
    end

    it "should be available in infix" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string("444 or 43").data.as_java_integer.should == 444
    end
  end

  describe "'||'" do 
    it "should not evaluate it's argument" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string("x=41. 123 ||(x=42). x").data.as_java_integer.should == 41
    end

    it "should return the receiver" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string("\"murg\" ||(42)").data.text.should == "murg"
    end

    it "should be available in infix" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string("444 || 43").data.as_java_integer.should == 444
    end
  end
  
  describe "'xor'" do 
    it "should evaluate it's argument" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string("x=41. 30 xor(x=42). x").data.as_java_integer.should == 42
    end

    it "should complain if no argument is given" do 
      sw = StringWriter.new(20)
      out = PrintWriter.new(sw)

      ioke = IokeRuntime.get_runtime(out, InputStreamReader.new(System.in), out)
      proc do 
        ioke.evaluate_string("30 xor()")
      end.should raise_error
    end

    it "should return false if the argument is true" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string("30 xor(true)").should == ioke.false
    end

    it "should return true if the argument is false" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string("30 xor(false)").should == ioke.true
    end

    it "should return true if the argument is nil" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string("30 xor(nil)").should == ioke.true
    end
    
    it "should be available in infix" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string("30 xor 43").should == ioke.false
    end
  end

  describe "'nor'" do 
    it "should not evaluate it's argument" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string("x=41. 30 nor(x=42). x").data.as_java_integer.should == 41
    end

    it "should return false" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string("30 nor(42)").should == ioke.false
    end

    it "should be available in infix" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string("30 nor 43").should == ioke.false
    end
  end

  describe "'nand'" do 
    it "should evaluate it's argument" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string("x=41. 30 nand(x=42). x").data.as_java_integer.should == 42
    end

    it "should complain if no argument is given" do 
      sw = StringWriter.new(20)
      out = PrintWriter.new(sw)

      ioke = IokeRuntime.get_runtime(out, InputStreamReader.new(System.in), out)
      proc do 
        ioke.evaluate_string("30 nand()")
      end.should raise_error
    end

    it "should return false if the argument evaluates to true" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string("30 nand(42)").should == ioke.false
    end
    
    it "should return true if the argument evaluates to false" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string("30 nand(false)").should == ioke.true
    end
    
    it "should return true if the argument evaluates to nil" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string("30 nand(nil)").should == ioke.true
    end

    it "should be available in infix" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string("30 nand 43").should == ioke.false
    end
  end
  
  describe "'genSym'" do 
    it "should generate a new thing every time called" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string("genSym == genSym").should == ioke.false
    end

    it "should generate a symbol" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string('genSym kind == "Symbol"').should == ioke.true
    end
  end
  
  describe "'message'" do 
    it "should return a new message" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string('message("foo") kind?("Message")').should == ioke.true
    end
    
    it "should take a text argument" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string('message("foo") name == :foo').should == ioke.true
    end

    it "should take a symbol argument" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string('message(:foo) name == :foo').should == ioke.true
    end
  end
end
