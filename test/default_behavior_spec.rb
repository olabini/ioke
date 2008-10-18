include_class('ioke.lang.Runtime') { 'IokeRuntime' } unless defined?(IokeRuntime)

import Java::java.io.StringReader unless defined?(StringReader)

describe "DefaultBehavior" do 
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
      result.should_not == ioke.ground
    end

    it "should be able to derive from Text" do 
      ioke = IokeRuntime.get_runtime()
      result = ioke.evaluate_stream(StringReader.new(%q[Text derive]))
      result.find_cell(nil,nil, 'kind').data.text.should == 'Text'
      result.should_not == ioke.text
    end
  end
  
  describe "'break'" do 
    it "should raise a control flow exception by default"
  end
  
  describe "'until'" do 
    it "should not do anything if initial argument is true"
    it "should loop until the argument becomes true"
    it "should be interrupted by break"
  end

  describe "'while'" do 
    it "should not do anything if initial argument is false"
    it "should loop until the argument becomes false"
    it "should be interrupted by break"
  end
  
  describe "'loop'" do 
    it "should loop until interrupted by break"
  end

  describe "'if'" do 
    it "should evaluate it's first element once"
    it "should return it's second argument if the first element evaluates to true"
    it "should return it's third argument if the first element evaluates to false"
    it "should return the result of evaluating the first argument if there are no more arguments"
    it "should return the result of evaluating the first argument if it is false and there are only two arguments"
  end

  describe "'asText'" do 
    it "should call toString and return the text from that"
  end

  describe "'representation'" do 
    it "should call representation and return the text from that"
  end

  describe "'method'" do 
  end
end
