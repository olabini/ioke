include_class('ioke.lang.Runtime') { 'IokeRuntime' } unless defined?(IokeRuntime)
include_class('ioke.lang.exceptions.ControlFlow') unless defined?(ControlFlow)

import Java::java.io.StringReader unless defined?(StringReader)

describe "DefaultBehavior" do
  describe "'fn'" do 
    it "should mimic LexicalBlock" do 
      ioke = IokeRuntime.get_runtime()
      result = ioke.evaluate_stream(StringReader.new(%q[fn("hello" println)]))
      result.find_cell(nil,nil, 'kind').data.text.should == 'LexicalBlock'
      result.should_not == ioke.lexical_block
    end
    
    it "should return nil from an empty block"
    it "should be possible to execute it by invoking 'call' on it"
    it "should be possible to get the code for the block by calling 'code' on it"
    it "should have access to variables in the scope it was defined"
    it "should be able to update variables in the scope it was defined"
    it "should create a new variable when assigning something that doesn't exist"
    it "should take arguments"
    it "should shadow outer variables when getting arguments"
  end
end
