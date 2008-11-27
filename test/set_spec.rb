include_class('ioke.lang.Runtime') { 'IokeRuntime' } unless defined?(IokeRuntime)
include_class('ioke.lang.IokeSet') unless defined?(IokeSet)
include_class('ioke.lang.Text') unless defined?(Text)

import Java::java.io.StringReader unless defined?(StringReader)
import Java::java.io.PrintWriter unless defined?(PrintWriter)
import Java::java.io.StringWriter unless defined?(StringWriter)
import Java::java.io.InputStreamReader unless defined?(InputStreamReader)
import Java::java.lang.System unless defined?(System)

describe "Set" do 
  it "should have the correct kind" do 
    ioke = IokeRuntime.get_runtime
    result = ioke.set.find_cell(nil, nil, "kind")
    result.data.text.should == 'Set'
  end

  it "should be possible to mimic" do 
    ioke = IokeRuntime.get_runtime
    result = ioke.evaluate_string("x = Set mimic")
    result.data.class.should == IokeSet
    result.data.object_id.should_not == ioke.set.data.object_id

    ioke.evaluate_string("x mimics?(Set)").should == ioke.true
    ioke.evaluate_string("x kind?(\"Set\")").should == ioke.true
  end
  
  it "should mimic Enumerable" do 
    ioke = IokeRuntime.get_runtime
    ioke.set.get_mimics.should include(ioke.mixins.find_cell(nil, nil, "Enumerable"))
  end

  describe "'each'" do 
    it "should not do anything for an empty set" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string("x = 0. set() each(. x++). x").data.as_java_integer.should == 0
    end
    
    it "should be possible to just give it a message chain, that will be invoked on each object" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string("y = []. x = method(Ground y << self). set(1,2,3) each(x). y sort == [1,2,3]").should == ioke.true
      ioke.evaluate_string("x = 0. set(1,2,3) each(nil. x++). x == 3").should == ioke.true
    end
    
    it "should be possible to give it an argument name, and code" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string("y = []. set(1,2,3) each(x, y<<x). y sort == [1,2,3]").should == ioke.true
    end

    it "should return the object" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string("y = set(1,2,3). (y each(x, x)) == y").should == ioke.true
    end
    
    it "should be possible to give it an extra argument to get the index" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string("y = []. set(1, 2, 3, 4) each(i, x, y << i). y == [0,1,2,3]").should == ioke.true
    end

    it "should establish a lexical context when invoking the methods. this context will be the same for all invocations." do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string("set(1,2,3) each(x, blarg=32)")
      ioke.ground.find_cell(nil, nil, "x").should == ioke.nul
      ioke.ground.find_cell(nil, nil, "blarg").should == ioke.nul
      ioke.evaluate_string("x=14. set(1,2,3) each(x, blarg=32)")
      ioke.ground.find_cell(nil, nil, "x").data.as_java_integer.should == 14
    end
  end

  describe "'=='" do 
    it "should return false when sent an argument that is not a set" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string("set() == 1").should == ioke.false
      ioke.evaluate_string("set(1) == 1").should == ioke.false
      ioke.evaluate_string("set(1,2,3) == \"foo\"").should == ioke.false
      ioke.evaluate_string("set() == method([])").should == ioke.false
    end
    
    it "should return true for two empty sets" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string("x = set(). x == x").should == ioke.true
      ioke.evaluate_string("set() == set()").should == ioke.true
    end
    
    it "should return true for two empty sets where one has a new cell" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string("x = set(). y = set(). x blarg = 12. x == y").should == ioke.true
    end
    
    it "should return false when the two sets have an element of different types" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string("set(1) == set(\"1\")").should == ioke.false
      ioke.evaluate_string("set(1, 2, 3) == set(\"1\", \"2\", \"3\")").should == ioke.false
    end

    it "should return false when the two sets have different length" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string("set(1) == set()").should == ioke.false
      ioke.evaluate_string("set(1) == set(1,2,3)").should == ioke.false
    end
    
    it "should return true if the elements in the set are the same" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string("set(1) == set(1)").should == ioke.true
      ioke.evaluate_string("set(\"1\") == set(\"1\")").should == ioke.true
      ioke.evaluate_string("set(1,2,3,4,5,6,7) == set(1,2,3,4,5,6,7)").should == ioke.true
      ioke.evaluate_string("set(1,1,1,1,1,1,2,3,4,5,6,7) == set(1,2,3,4,5,6,7)").should == ioke.true
      ioke.evaluate_string("set(1,2,3,4,5,6,7) == set(1,2,3,5,4,6,7)").should == ioke.true
    end
  end
end

describe "DefaultBehavior" do 
  describe "'set'" do 
    it "should create a new empty set when given no arguments" do 
      ioke = IokeRuntime.get_runtime
      result = ioke.evaluate_string("x = set")
      result.data.class.should == IokeSet
      result.data.object_id.should_not == ioke.set.data.object_id

      ioke.evaluate_string("x mimics?(Set)").should == ioke.true
      ioke.evaluate_string("x kind?(\"Set\")").should == ioke.true

      result = ioke.evaluate_string("x = set()")
      result.data.class.should == IokeSet
      result.data.object_id.should_not == ioke.set.data.object_id

      ioke.evaluate_string("x mimics?(Set)").should == ioke.true
      ioke.evaluate_string("x kind?(\"Set\")").should == ioke.true
    end
    
    it "should create a new set with the evaluated arguments" do 
      ioke = IokeRuntime.get_runtime
      result = ioke.evaluate_string("set(1, 2, \"abc\", 3+42)")
      data = result.data.set
      data.size.should == 4
      vals = []
      data.each { |x| 
        vv = x.data
        if vv.kind_of?(Text)
          vals << vv.text
        else
          vals << vv.as_java_integer
        end
      }
      vals.sort_by { |v| v.is_a?(Integer) ? v : 99 }.should == [1,2,45, "abc"]
    end
  end
end
