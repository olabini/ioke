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
  
  it "should mimic Enumerable" do 
    ioke = IokeRuntime.get_runtime
    ioke.list.get_mimics.should include(ioke.mixins.find_cell(nil, nil, "Enumerable"))
  end
  
  describe "'at'" do 
    it "should return nil if empty list" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string("list at(0)").should == ioke.nil
      ioke.evaluate_string("list at(10)").should == ioke.nil
      ioke.evaluate_string("list at(0-1)").should == ioke.nil
    end

    it "should return nil if argument is over the size" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string("list(1) at(1)").should == ioke.nil
    end

    it "should return from the front if the argument is zero or positive" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string("[1,2,3,4] at(0)").data.as_java_integer.should == 1
      ioke.evaluate_string("[1,2,3,4] at(1)").data.as_java_integer.should == 2
      ioke.evaluate_string("[1,2,3,4] at(2)").data.as_java_integer.should == 3
      ioke.evaluate_string("[1,2,3,4] at(3)").data.as_java_integer.should == 4
    end

    it "should return from the back if the argument is negative" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string("[1,2,3,4] at(0-1)").data.as_java_integer.should == 4
      ioke.evaluate_string("[1,2,3,4] at(0-2)").data.as_java_integer.should == 3
      ioke.evaluate_string("[1,2,3,4] at(0-3)").data.as_java_integer.should == 2
      ioke.evaluate_string("[1,2,3,4] at(0-4)").data.as_java_integer.should == 1
    end
  end

  describe "'[]'" do 
    it "should return nil if empty list" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string("list[0]").should == ioke.nil
      ioke.evaluate_string("list[10]").should == ioke.nil
      ioke.evaluate_string("list[(0-1)]").should == ioke.nil
    end

    it "should return nil if argument is over the size" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string("list(1)[1]").should == ioke.nil
    end

    it "should return from the front if the argument is zero or positive" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string("[1,2,3,4][0]").data.as_java_integer.should == 1
      ioke.evaluate_string("[1,2,3,4][1]").data.as_java_integer.should == 2
      ioke.evaluate_string("[1,2,3,4][2]").data.as_java_integer.should == 3
      ioke.evaluate_string("[1,2,3,4][3]").data.as_java_integer.should == 4
    end

    it "should return from the back if the argument is negative" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string("[1,2,3,4][0-1]").data.as_java_integer.should == 4
      ioke.evaluate_string("[1,2,3,4][0-2]").data.as_java_integer.should == 3
      ioke.evaluate_string("[1,2,3,4][0-3]").data.as_java_integer.should == 2
      ioke.evaluate_string("[1,2,3,4][0-4]").data.as_java_integer.should == 1
    end
  end
  
  describe "'[]='"
  describe "'=='" #Should always be equal based on the content of the lists
  describe "'clear!'"
  describe "'empty?'"
  describe "'each'"
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
