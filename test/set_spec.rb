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
