include_class('ioke.lang.Runtime') { 'IokeRuntime' } unless defined?(IokeRuntime)

import Java::java.io.StringReader unless defined?(StringReader)

describe "core" do 
  describe "'nil'" do 
    it "should have the correct kind" do 
      runtime = IokeRuntime.get_runtime
      result = runtime.nil.find_cell(nil, nil, "kind")
      result.data.text.should == 'nil'
    end

    it "should not be possible to mimic" do 
      runtime = IokeRuntime.get_runtime
      proc do 
        runtime.evaluate_stream(StringReader.new("nil mimic"))
      end.should raise_error
    end
    
    it "should act as false in if statement" do 
      runtime = IokeRuntime.get_runtime
      runtime.evaluate_stream(StringReader.new("if(nil, 42, 43)")).
        data.as_java_integer.should == 43
    end
    
    it "should be nil" do 
      IokeRuntime.get_runtime.nil.isNil.should be_true
    end
  end

  describe "'false'" do 
    it "should have the correct kind" do 
      runtime = IokeRuntime.get_runtime
      result = runtime.false.find_cell(nil, nil, "kind")
      result.data.text.should == 'false'
    end

    it "should not be possible to mimic" do 
      runtime = IokeRuntime.get_runtime
      proc do 
        runtime.evaluate_stream(StringReader.new("false mimic"))
      end.should raise_error
    end
    
    it "should act as false in if statement" do 
      runtime = IokeRuntime.get_runtime
      runtime.evaluate_stream(StringReader.new("if(false, 42, 43)")).
        data.as_java_integer.should == 43
    end

    it "should not be nil" do 
      IokeRuntime.get_runtime.false.isNil.should be_false
    end
  end
  
  describe "'true'" do 
    it "should have the correct kind" do 
      runtime = IokeRuntime.get_runtime
      result = runtime.true.find_cell(nil, nil, "kind")
      result.data.text.should == 'true'
    end

    it "should not be possible to mimic" do 
      runtime = IokeRuntime.get_runtime
      proc do 
        runtime.evaluate_stream(StringReader.new("true mimic"))
      end.should raise_error
    end
    
    it "should act as true in if statement" do 
      runtime = IokeRuntime.get_runtime
      runtime.evaluate_stream(StringReader.new("if(true, 42, 43)")).
        data.as_java_integer.should == 42
    end

    it "should not be nil" do 
      IokeRuntime.get_runtime.true.isNil.should be_false
    end
  end
  
  describe "Base" do 
    it "should have the correct kind" do 
      runtime = IokeRuntime.get_runtime
      result = runtime.base.find_cell(nil, nil, "kind")
      result.data.text.should == 'Base'
    end

    it "should have a 'mimic' cell" do 
      runtime = IokeRuntime.get_runtime
      result = runtime.base.find_cell(nil, nil, "mimic")
      result.should_not == runtime.nul
    end
  end

  describe "Ground" do 
    it "should have the correct kind" do 
      runtime = IokeRuntime.get_runtime
      result = runtime.ground.find_cell(nil, nil, "kind")
      result.data.text.should == 'Ground'
    end

    it "should have all the expected cells" do 
      runtime = IokeRuntime.get_runtime
      runtime.ground.find_cell(nil, nil, 'Base').object_id.should == runtime.base.object_id
      runtime.ground.find_cell(nil, nil, 'DefaultBehavior').should == runtime.defaultBehavior
      runtime.ground.find_cell(nil, nil, 'Ground').object_id.should == runtime.ground.object_id
      runtime.ground.find_cell(nil, nil, 'Origin').object_id.should == runtime.origin.object_id
      runtime.ground.find_cell(nil, nil, 'System').object_id.should == runtime.system.object_id
      runtime.ground.find_cell(nil, nil, 'Runtime').object_id.should == runtime.iokeRuntime.object_id
      runtime.ground.find_cell(nil, nil, 'Text').object_id.should == runtime.text.object_id
      runtime.ground.find_cell(nil, nil, 'Number').object_id.should == runtime.number.object_id
      runtime.ground.find_cell(nil, nil, 'nil').object_id.should == runtime.nil.object_id
      runtime.ground.find_cell(nil, nil, 'true').object_id.should == runtime.true.object_id
      runtime.ground.find_cell(nil, nil, 'false').object_id.should == runtime.false.object_id
      runtime.ground.find_cell(nil, nil, 'Method').object_id.should == runtime.get_method.object_id
      runtime.ground.find_cell(nil, nil, 'Symbol').object_id.should == runtime.symbol.object_id
      runtime.ground.find_cell(nil, nil, 'DefaultMethod').object_id.should == runtime.defaultMethod.object_id
      runtime.ground.find_cell(nil, nil, 'JavaMethod').object_id.should == runtime.javaMethod.object_id
      runtime.ground.find_cell(nil, nil, 'LexicalBlock').object_id.should == runtime.lexicalBlock.object_id
      runtime.ground.find_cell(nil, nil, 'Mixins').object_id.should == runtime.mixins.object_id
      runtime.ground.find_cell(nil, nil, 'Restart').object_id.should == runtime.restart.object_id
      runtime.ground.find_cell(nil, nil, 'List').object_id.should == runtime.list.object_id
      runtime.ground.find_cell(nil, nil, 'Dict').object_id.should == runtime.dict.object_id
      runtime.ground.find_cell(nil, nil, 'Pair').object_id.should == runtime.pair.object_id
      runtime.ground.find_cell(nil, nil, 'DefaultMacro').should == runtime.defaultMacro
      runtime.ground.find_cell(nil, nil, 'Call').object_id.should == runtime.call.object_id
      runtime.ground.find_cell(nil, nil, 'Range').object_id.should == runtime.range.object_id
      runtime.ground.find_cell(nil, nil, 'Condition').object_id.should == runtime.condition.object_id
      runtime.ground.find_cell(nil, nil, 'Rescue').object_id.should == runtime.rescue.object_id
    end
  end

  describe "System" do 
    it "should have the correct kind" do 
      runtime = IokeRuntime.get_runtime
      result = runtime.system.find_cell(nil, nil, "kind")
      result.data.text.should == 'System'
    end
    
    describe "'ifMain'" do 
      it "should run block when the currently running code is the main" do 
        runtime = IokeRuntime.get_runtime
        runtime.system.data.current_program = "<eval>"
        runtime.evaluate_stream("<eval>", StringReader.new("System ifMain(xx = 42)"))
        runtime.ground.find_cell(nil, nil, "xx").data.as_java_integer.should == 42
      end

      it "should not run block when the currently running code is not the main" do 
        runtime = IokeRuntime.get_runtime
        runtime.system.data.current_program = "<eval>"
        runtime.evaluate_stream("<eval2>", StringReader.new("System ifMain(xx = 42)"))
        runtime.ground.find_cell(nil, nil, "xx").should == runtime.nul
      end
    end
    
    it "should be possible to mimic system" do 
      runtime = IokeRuntime.get_runtime
      runtime.evaluate_stream(StringReader.new("System mimic"))
    end
  end

  describe "Runtime" do 
    it "should have the correct kind" do 
      runtime = IokeRuntime.get_runtime
      result = runtime.runtime.find_cell(nil, nil, "kind")
      result.data.text.should == 'Runtime'
    end
  end

  describe "DefaultBehavior" do 
    it "should have the correct kind" do 
      runtime = IokeRuntime.get_runtime
      result = runtime.defaultBehavior.find_cell(nil, nil, "kind")
      result.data.text.should == 'DefaultBehavior'
    end
  end

  describe "Call" do 
    it "should have the correct kind" do 
      runtime = IokeRuntime.get_runtime
      result = runtime.call.find_cell(nil, nil, "kind")
      result.data.text.should == 'Call'
    end
  end
  
  describe "Origin" do 
    it "should have the correct kind" do 
      runtime = IokeRuntime.get_runtime
      result = runtime.origin.find_cell(nil, nil, "kind")
      result.data.text.should == 'Origin'
    end
  end

  describe "Text" do 
    it "should have the correct kind" do 
      runtime = IokeRuntime.get_runtime
      result = runtime.text.find_cell(nil, nil, "kind")
      result.data.text.should == 'Text'
    end
  end

  describe "Number" do 
    it "should have the correct kind" do 
      runtime = IokeRuntime.get_runtime
      result = runtime.number.find_cell(nil, nil, "kind")
      result.data.text.should == 'Number'
    end
  end

  describe "Range" do 
    it "should have the correct kind" do 
      runtime = IokeRuntime.get_runtime
      result = runtime.range.find_cell(nil, nil, "kind")
      result.data.text.should == 'Range'
    end
  end

  describe "Method" do 
    it "should have the correct kind" do 
      runtime = IokeRuntime.get_runtime
      result = runtime.getMethod.find_cell(nil, nil, "kind")
      result.data.text.should == 'Method'
    end
  end

  describe "DefaultMethod" do 
    it "should have the correct kind" do 
      runtime = IokeRuntime.get_runtime
      result = runtime.default_method.find_cell(nil, nil, "kind")
      result.data.text.should == 'DefaultMethod'
    end
  end

  describe "DefaultMacro" do 
    it "should have the correct kind" do 
      runtime = IokeRuntime.get_runtime
      result = runtime.default_macro.find_cell(nil, nil, "kind")
      result.data.text.should == 'DefaultMacro'
    end
  end
  
  describe "JavaMethod" do 
    it "should have the correct kind" do 
      runtime = IokeRuntime.get_runtime
      result = runtime.java_method.find_cell(nil, nil, "kind")
      result.data.text.should == 'JavaMethod'
    end
  end

  describe "LexicalBlock" do 
    it "should have the correct kind" do 
      runtime = IokeRuntime.get_runtime
      result = runtime.lexical_block.find_cell(nil, nil, "kind")
      result.data.text.should == 'LexicalBlock'
    end
  end

  describe "Mixins" do 
    it "should have the correct kind" do 
      runtime = IokeRuntime.get_runtime
      result = runtime.mixins.find_cell(nil, nil, "kind")
      result.data.text.should == 'Mixins'
    end

    it "should have Comparing defined" do 
      runtime = IokeRuntime.get_runtime
      runtime.mixins.find_cell(nil, nil, 'Comparing').should_not == runtime.nul
    end
  end

  describe "Message" do 
    it "should have the correct kind" do 
      runtime = IokeRuntime.get_runtime
      result = runtime.message.find_cell(nil, nil, "kind")
      result.data.text.should == 'Message'
    end
  end

  describe "Enumerable" do 
    it "should have the correct kind" do 
      runtime = IokeRuntime.get_runtime
      result = runtime.ground.find_cell(nil, nil, "Mixins").find_cell(nil, nil, "Enumerable").find_cell(nil, nil, "kind")
      result.data.text.should == 'Mixins Enumerable'
    end
  end
  
  describe "Comparing" do 
    it "should have the correct kind" do 
      runtime = IokeRuntime.get_runtime
      result = runtime.ground.find_cell(nil, nil, "Mixins").find_cell(nil, nil, "Comparing").find_cell(nil, nil, "kind")
      result.data.text.should == 'Mixins Comparing'
    end
  end

  describe "Condition" do 
    it "should have the correct kind" do 
      runtime = IokeRuntime.get_runtime
      result = runtime.ground.find_cell(nil, nil, "Condition").find_cell(nil, nil, "kind")
      result.data.text.should == 'Condition'
    end
  end
end
