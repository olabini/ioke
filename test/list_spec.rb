include_class('ioke.lang.Runtime') { 'IokeRuntime' } unless defined?(IokeRuntime)
include_class('ioke.lang.IokeList') unless defined?(IokeList)

import Java::java.io.StringReader unless defined?(StringReader)

describe "List" do 
  it "should have the correct kind" do 
    ioke = IokeRuntime.get_runtime
    result = ioke.list.find_cell(nil, nil, "kind")
    result.data.text.should == 'List'
  end

  it "should be possible to mimic" do 
    ioke = IokeRuntime.get_runtime
    result = ioke.evaluate_string("x = List mimic")
    result.data.class.should == IokeList
    result.should_not == ioke.list
    result.data.should_not == ioke.list.data

    ioke.evaluate_string("x mimics?(List)").should == ioke.true
    ioke.evaluate_string("x kind?(\"List\")").should == ioke.true
  end
end

describe "DefaultBehavior" do 
  describe "'list'" do 
    it "should create a new empty list when given no arguments"
    it "should create a new list with the evaluated arguments"
  end
  
  describe "'[]'" do 
    it "should create a new empty list when given no arguments"
    it "should create a new list with the evaluated arguments"
  end
end
