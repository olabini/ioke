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
    it "should return false when sent an argument that is not a list" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string("[] == 1").should == ioke.false
      ioke.evaluate_string("[1] == 1").should == ioke.false
      ioke.evaluate_string("[1,2,3] == \"foo\"").should == ioke.false
      ioke.evaluate_string("[] == method([])").should == ioke.false
    end
    
    it "should return true for two empty lists" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string("x = []. x == x").should == ioke.true
      ioke.evaluate_string("[] == []").should == ioke.true
    end
    
    it "should return true for two empty lists where one has a new cell" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string("x = []. y = []. x blarg = 12. x == y").should == ioke.true
    end
    
    it "should return false when the two lists have an element of different types" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string("[1] == [\"1\"]").should == ioke.false
      ioke.evaluate_string("[1, 2, 3] == [\"1\", \"2\", \"3\"]").should == ioke.false
    end

    it "should return false when the two lists have different length" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string("[1] == []").should == ioke.false
      ioke.evaluate_string("[1] == [1,2,3]").should == ioke.false
    end
    
    it "should return true if the elements in the list are the same" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string("[1] == [1]").should == ioke.true
      ioke.evaluate_string("[\"1\"] == [\"1\"]").should == ioke.true
      ioke.evaluate_string("[1,2,3,4,5,6,7] == [1,2,3,4,5,6,7]").should == ioke.true
    end
  end
  
  describe "'clear!'" do 
    it "should not do anything on an empty list" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string("x = []. x clear!. x size").data.as_java_integer.should == 0
    end

    it "should clear a list that has entries" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string("x = [1,2,3,4]. x clear!. x size").data.as_java_integer.should == 0
    end
    
    it "should return the list" do 
      ioke = IokeRuntime.get_runtime
      result = ioke.evaluate_string("x = [1,2,3,4]. x clear!")
      result.should == ioke.ground.find_cell(nil, nil, "x")
    end
  end

  describe "'size'" do 
    it "should return zero for an empty list" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string("x = []. x size").data.as_java_integer.should == 0
    end
    
    it "should return the size for a non-empty list" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string("[1] size").data.as_java_integer.should == 1
      ioke.evaluate_string("[\"abc\", \"cde\"] size").data.as_java_integer.should == 2
    end
  end

  describe "'length'" do 
    it "should return zero for an empty list" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string("x = []. x length").data.as_java_integer.should == 0
    end
    
    it "should return the size for a non-empty list" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string("[1] length").data.as_java_integer.should == 1
      ioke.evaluate_string("[\"abc\", \"cde\"] length").data.as_java_integer.should == 2
    end
  end

  describe "'empty?'" do 
    it "should return true for an empty list" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string("x = []. x empty?").should == ioke.true
    end
    
    it "should return false for an non empty list" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string("x = [1]. x empty?").should == ioke.false
      ioke.evaluate_string("x = [\"abc\", \"cde\"]. x empty?").should == ioke.false
    end
  end
  
  describe "'each'" do 
    it "should not do anything for an empty list" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string("x = 0. [] each(. x++). x").data.as_java_integer.should == 0
    end
    
    it "should be possible to just give it a message chain, that will be invoked on each object" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string("y = []. x = method(Ground y << self). [1,2,3] each(x). y == [1,2,3]").should == ioke.true
      ioke.evaluate_string("x = 0. [1,2,3] each(nil. x++). x == 3").should == ioke.true
    end
    
    it "should be possible to give it an argument name, and code" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string("y = []. [1,2,3] each(x, y<<x). y == [1,2,3]").should == ioke.true
    end

    it "should return the object" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string("y = [1,2,3]. (y each(x, x)) == y").should == ioke.true
    end
    
    it "should establish a lexical context when invoking the methods. this context will be the same for all invocations." do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string("[1,2,3] each(x, blarg=32)")
      ioke.ground.find_cell(nil, nil, "x").should == ioke.nul
      ioke.ground.find_cell(nil, nil, "blarg").should == ioke.nul
      ioke.evaluate_string("x=14. [1,2,3] each(x, blarg=32)")
      ioke.ground.find_cell(nil, nil, "x").data.as_java_integer.should == 14
    end

    it "should yield lists if running over a list of lists" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string("y = []. [[1],[2],[3]] each(x, y<<x). y == [[1],[2],[3]]").should == ioke.true
    end
  end

  describe "'remove!'" do 
    it "should have tests"
  end

  describe "'removeAt!'" do 
    it "should have tests"
  end

  describe "'removeIf!'" do 
    it "should have tests"
  end
end

describe "DefaultBehavior" do 
  describe "'list'" do 
    it "should create a new empty list when given no arguments" do 
      ioke = IokeRuntime.get_runtime
      result = ioke.evaluate_string("x = list")
      result.data.class.should == IokeList
      result.data.should_not == ioke.list.data

      ioke.evaluate_string("x mimics?(List)").should == ioke.true
      ioke.evaluate_string("x kind?(\"List\")").should == ioke.true

      result = ioke.evaluate_string("x = list()")
      result.data.class.should == IokeList
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
