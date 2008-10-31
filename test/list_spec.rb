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
    it "should create a new empty list when given no arguments" do 
      ioke = IokeRuntime.get_runtime
      result = ioke.evaluate_string("x = list")
      result.data.class.should == IokeList
      result.should_not == ioke.list
      result.data.should_not == ioke.list.data

      ioke.evaluate_string("x mimics?(List)").should == ioke.true
      ioke.evaluate_string("x kind?(\"List\")").should == ioke.true

      result = ioke.evaluate_string("x = list()")
      result.data.class.should == IokeList
      result.should_not == ioke.list
      result.data.should_not == ioke.list.data

      ioke.evaluate_string("x mimics?(List)").should == ioke.true
      ioke.evaluate_string("x kind?(\"List\")").should == ioke.true
    end
    
    it "should create a new list with the evaluated arguments" do 
      ioke = IokeRuntime.get_runtime
      result = ioke.evaluate_string("list(1, 2, \"abc\", 3+42)")
      data = result.data.list
      data.size.should == 4
      data[0].data.as_java_integer.should == 1
      data[1].data.as_java_integer.should == 2
      data[2].data.text.should == "abc"
      data[3].data.as_java_integer.should == 45
    end
  end
  
  describe "'[]'" do 
    it "should create a new empty list when given no arguments" do 
      ioke = IokeRuntime.get_runtime
      result = ioke.evaluate_string("x = []")
      result.data.class.should == IokeList
      result.should_not == ioke.list
      result.data.should_not == ioke.list.data

      ioke.evaluate_string("x mimics?(List)").should == ioke.true
      ioke.evaluate_string("x kind?(\"List\")").should == ioke.true
    end
    
    it "should create a new list with the evaluated arguments" do 
      ioke = IokeRuntime.get_runtime
      result = ioke.evaluate_string("[1, 2, \"abc\", 3+42]")
      data = result.data.list
      data.size.should == 4
      data[0].data.as_java_integer.should == 1
      data[1].data.as_java_integer.should == 2
      data[2].data.text.should == "abc"
      data[3].data.as_java_integer.should == 45
    end
  end
end
