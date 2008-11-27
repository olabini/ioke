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
  end
end

describe "Origin" do 
  describe "'notice'" do 
    it "should return 'Origin'" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string('Origin notice').data.text.should == "Origin"
    end
  end
end

