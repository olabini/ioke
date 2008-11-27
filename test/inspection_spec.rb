include_class('ioke.lang.Runtime') { 'IokeRuntime' } unless defined?(IokeRuntime)

describe "DefaultBehavior" do 
  describe "'cellSummary'" do 
  end
  
  describe "'inspect'" do 
  end

  describe "'notice'" do 
  end
end

describe "nil" do 
  describe "'inspect'" do 
    it "should return 'nil'" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string('nil inspect').data.text.should == "nil"
    end
  end

  describe "'notice'" do 
    it "should return 'nil'" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string('nil notice').data.text.should == "nil"
    end
  end
end

describe "true" do 
  describe "'inspect'" do 
    it "should return 'true'" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string('true inspect').data.text.should == "true"
    end
  end

  describe "'notice'" do 
    it "should return 'true'" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string('true notice').data.text.should == "true"
    end
  end
end

describe "false" do 
  describe "'inspect'" do 
    it "should return 'false'" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string('false inspect').data.text.should == "false"
    end
  end

  describe "'notice'" do 
    it "should return 'false'" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string('false notice').data.text.should == "false"
    end
  end
end

describe "Ground" do 
  describe "'notice'" do 
    it "should return 'Ground'" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string('Ground notice').data.text.should == "Ground"
    end

    it "should not return 'Ground' for a mimic" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string('Ground mimic notice').data.text.should_not == "Ground"
    end
  end
end

describe "Origin" do 
  describe "'notice'" do 
    it "should return 'Origin'" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string('Origin notice').data.text.should == "Origin"
    end

    it "should not return 'Origin' for a mimic" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string('Origin mimic notice').data.text.should_not == "Origin"
    end
  end
end

# [Text, Symbol, Number, Method, DefaultMethod, JavaMethod, 
# LexicalBlock, DefaultMacro, Restart, List, Dict, Range, Pair, Message, Call, Condition, Rescue, Handler, IO]

describe "System" do 
  describe "'notice'" do 
    it "should return 'System'" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string('System notice').data.text.should == "System"
    end

    it "should not return 'System' for a mimic" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string('System mimic notice').data.text.should_not == "System"
    end
  end
end

describe "Runtime" do 
  describe "'notice'" do 
    it "should return 'Runtime'" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string('Runtime notice').data.text.should == "Runtime"
    end

    it "should not return 'Runtime' for a mimic" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string('Runtime mimic notice').data.text.should_not == "Runtime"
    end
  end
end


