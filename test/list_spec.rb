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
  
  describe "'[]='" do 
    it "should set the first element in an empty list" do 
      ioke = IokeRuntime.get_runtime
      result = ioke.evaluate_string("x = []. x[0] = 42. x")
      result.data.list.size.should == 1
      result.data.list.get(0).data.as_java_integer.should == 42
    end
    
    it "should overwrite an existing element" do 
      ioke = IokeRuntime.get_runtime
      result = ioke.evaluate_string("x = [40]. x[0] = 42. x")
      result.data.list.size.should == 1
      result.data.list.get(0).data.as_java_integer.should == 42
    end

    it "should expand the list up to the point where the element fits, if the index is further away" do 
      ioke = IokeRuntime.get_runtime
      result = ioke.evaluate_string("x = [40, 42]. x[10] = 45. x")
      result.data.list.size.should == 11
      result.data.list.get(0).data.as_java_integer.should == 40
      result.data.list.get(1).data.as_java_integer.should == 42
      result.data.list.get(2).should == ioke.nil
      result.data.list.get(3).should == ioke.nil
      result.data.list.get(4).should == ioke.nil
      result.data.list.get(5).should == ioke.nil
      result.data.list.get(6).should == ioke.nil
      result.data.list.get(7).should == ioke.nil
      result.data.list.get(8).should == ioke.nil
      result.data.list.get(9).should == ioke.nil
      result.data.list.get(10).data.as_java_integer.should == 45
    end
    
    it "should be possible to set with negative indices" do 
      ioke = IokeRuntime.get_runtime
      result = ioke.evaluate_string("x = [40, 42, 44, 46]. x[0-2] = 52. x")
      result.data.list.size.should == 4
      result.data.list.get(0).data.as_java_integer.should == 40
      result.data.list.get(1).data.as_java_integer.should == 42
      result.data.list.get(2).data.as_java_integer.should == 52
      result.data.list.get(3).data.as_java_integer.should == 46
    end

    it "should return the value set" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string("[40, 42, 44, 46][0] = 33+44").data.as_java_integer.should == 77
    end

    it "should throw an exception if setting with negative indices outside the range" do 
      ioke = IokeRuntime.get_runtime
      proc do 
        ioke.evaluate_string("[][0-1] = 52")
      end.should raise_error
    end
  end

  describe "'at='" do 
    it "should set the first element in an empty list" do 
      ioke = IokeRuntime.get_runtime
      result = ioke.evaluate_string("x = []. x at(0) = 42. x")
      result.data.list.size.should == 1
      result.data.list.get(0).data.as_java_integer.should == 42
    end
    
    it "should overwrite an existing element" do 
      ioke = IokeRuntime.get_runtime
      result = ioke.evaluate_string("x = [40]. x at(0) = 42. x")
      result.data.list.size.should == 1
      result.data.list.get(0).data.as_java_integer.should == 42
    end

    it "should expand the list up to the point where the element fits, if the index is further away" do 
      ioke = IokeRuntime.get_runtime
      result = ioke.evaluate_string("x = [40, 42]. x at(10) = 45. x")
      result.data.list.size.should == 11
      result.data.list.get(0).data.as_java_integer.should == 40
      result.data.list.get(1).data.as_java_integer.should == 42
      result.data.list.get(2).should == ioke.nil
      result.data.list.get(3).should == ioke.nil
      result.data.list.get(4).should == ioke.nil
      result.data.list.get(5).should == ioke.nil
      result.data.list.get(6).should == ioke.nil
      result.data.list.get(7).should == ioke.nil
      result.data.list.get(8).should == ioke.nil
      result.data.list.get(9).should == ioke.nil
      result.data.list.get(10).data.as_java_integer.should == 45
    end
    
    it "should be possible to set with negative indices" do 
      ioke = IokeRuntime.get_runtime
      result = ioke.evaluate_string("x = [40, 42, 44, 46]. x at(0-2) = 52. x")
      result.data.list.size.should == 4
      result.data.list.get(0).data.as_java_integer.should == 40
      result.data.list.get(1).data.as_java_integer.should == 42
      result.data.list.get(2).data.as_java_integer.should == 52
      result.data.list.get(3).data.as_java_integer.should == 46
    end
    
    it "should return the value set" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string("[40, 42, 44, 46] at(0) = 33+44").data.as_java_integer.should == 77
    end

    it "should throw an exception if setting with negative indices outside the range" do 
      ioke = IokeRuntime.get_runtime
      proc do 
        ioke.evaluate_string("[] at(0-1) = 52")
      end.should raise_error
    end
  end

  describe "'<<'" do 
    it "should add the element at the end of an empty list" do 
      ioke = IokeRuntime.get_runtime
      result = ioke.evaluate_string("x = []. x << 42. x")
      result.data.list.size.should == 1
      result.data.list.get(0).data.as_java_integer.should == 42
    end

    it "should add the element at the end of a list with elements" do 
      ioke = IokeRuntime.get_runtime
      result = ioke.evaluate_string("x = [1, 2, 3]. x << 42. x")
      result.data.list.size.should == 4
      result.data.list.get(0).data.as_java_integer.should == 1
      result.data.list.get(1).data.as_java_integer.should == 2
      result.data.list.get(2).data.as_java_integer.should == 3
      result.data.list.get(3).data.as_java_integer.should == 42
    end
    
    it "should return the list after the append" do 
      ioke = IokeRuntime.get_runtime
      result = ioke.evaluate_string("x = []. x << 42")
      result.should == ioke.ground.find_cell(nil, nil, "x")
    end
  end
  
  #Should always be equal based on the content of the lists
  describe "'=='" do 
    it "should have tests"
  end
  
  describe "'clear!'" do 
    it "should have tests"
  end

  describe "'empty?'" do 
    it "should return true for an empty list"
    it "should return false for an non empty list"
  end
  
  describe "'each'" do 
    it "should have tests"
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
