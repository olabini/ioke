include_class('ioke.lang.Runtime') { 'IokeRuntime' } unless defined?(IokeRuntime)

describe "Mixins" do 
  describe "'cell'" do 
    it "should be possible to get a cell using a Text argument" do 
      ioke = IokeRuntime.get_runtime()
      ioke.evaluate_string("Mixins x = 42. Mixins cell(\"x\") == Mixins x").should == ioke.true
      ioke.evaluate_string("Mixins Comparing x = 43. Mixins Comparing cell(\"x\") == Mixins Comparing x").should == ioke.true
    end

    it "should be possible to get a cell using a Symbol argument" do 
      ioke = IokeRuntime.get_runtime()
      ioke.evaluate_string("Mixins x = 42. Mixins cell(:x) == Mixins x").should == ioke.true
      ioke.evaluate_string("Mixins Comparing x = 43. Mixins Comparing cell(:x) == Mixins Comparing x").should == ioke.true
    end

    it "should report an error if trying to get a cell that doesn't exist in that object" do 
      ioke = IokeRuntime.get_runtime

      proc do 
        ioke.evaluate_string("Mixins cell(:flurg)")
      end.should raise_error

      proc do 
        ioke.evaluate_string("Mixins cell(\"flurg\")")
      end.should raise_error

      proc do 
        ioke.evaluate_string("Mixins Comparing cell(:flurg)")
      end.should raise_error

      proc do 
        ioke.evaluate_string("Mixins Comparing cell(\"flurg\")")
      end.should raise_error
    end
  end

  describe "'cell='" do 
    it "should be possible to set a cell using a Text argument" do 
      ioke = IokeRuntime.get_runtime()
      ioke.evaluate_string("Mixins cell(\"blurg\") = 42. Mixins blurg").data.as_java_integer.should == 42
      ioke.evaluate_string("Mixins Comparing cell(\"murg\") = 43. Mixins Comparing murg").data.as_java_integer.should == 43
    end

    it "should be possible to set a cell using a Symbol argument" do 
      ioke = IokeRuntime.get_runtime()
      ioke.evaluate_string("Mixins cell(:blurg) = 42. Mixins blurg").data.as_java_integer.should == 42
      ioke.evaluate_string("Mixins Comparing cell(:murg) = 43. Mixins Comparing murg").data.as_java_integer.should == 43
    end

    it "should be possible to set a cell with an empty name" do 
      ioke = IokeRuntime.get_runtime()
      ioke.evaluate_string("Mixins Comparing cell(\"\") = 42. Mixins Comparing cell(\"\")").data.as_java_integer.should == 42
    end

    it "should be possible to set a cell with complicated expressions" do 
      ioke = IokeRuntime.get_runtime()
      ioke.evaluate_string("f = Origin mimic. f b = \"foobar\". Mixins cell(f b) = 42+24-3. Mixins cell(:foobar)").data.as_java_integer.should == 63
    end

    it "should be possible to set a cell that doesn't exist" do 
      ioke = IokeRuntime.get_runtime()
      ioke.evaluate_string("Mixins cell(:blurg) = 42. Mixins blurg").data.as_java_integer.should == 42
      ioke.evaluate_string("Mixins Comparing cell(:murg) = 43. Mixins Comparing murg").data.as_java_integer.should == 43
    end 

    it "should be possible to set a cell that does exist" do 
      ioke = IokeRuntime.get_runtime()
      ioke.evaluate_string("Mixins x = 42. Mixins cell(:x) = 43. Mixins x").data.as_java_integer.should == 43
      ioke.evaluate_string("Mixins Comparing x = 42. Mixins Comparing cell(:x) = 44. Mixins Comparing x").data.as_java_integer.should == 44
    end

    it "should be possible to set a cell that does exist in a mimic. this should not change the mimic value" do 
      ioke = IokeRuntime.get_runtime()
      ioke.evaluate_string("one = Mixins mimic. one x = 42. two = one mimic. two cell(:x) = 43. one x").data.as_java_integer.should == 42
      ioke = IokeRuntime.get_runtime()
      ioke.evaluate_string("one = Mixins mimic. one x = 42. two = one mimic. two cell(:x) = 43. two x").data.as_java_integer.should == 43
    end
  end

  describe "'cells'" do 
    it "should return the cells of this object by default" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string("x = Mixins mimic. x cells == {}").should == ioke.true
      ioke.evaluate_string("x = Mixins mimic. x f = 13. x cells == {f: 13}").should == ioke.true
      ioke.evaluate_string("x = Mixins mimic. x f = 13. x Why = 1. x cells == {f: 13, Why: 1}").should == ioke.true
      ioke.evaluate_string("x = Mixins mimic. x Why = 1. x f = 13. x cells == {f: 13, Why: 1}").should == ioke.true
    end

    it "should take a boolean, when given will make it return all cells in both this and it's parents objects"
  end

  describe "'cellNames'" do 
    it "should return the cell names of this object by default" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string("x = Mixins mimic. x cellNames == []").should == ioke.true
      ioke.evaluate_string("x = Mixins mimic. x f = 13. x cellNames == [:f]").should == ioke.true
      ioke.evaluate_string("x = Mixins mimic. x f = 13. x Why = 1. x cellNames == [:f, :Why]").should == ioke.true
      ioke.evaluate_string("x = Mixins mimic. x Why = 1. x f = 13. x cellNames == [:Why, :f]").should == ioke.true
    end

    it "should take a boolean, when given will make it return all cell names in both this and it's parents objects"
  end
end
