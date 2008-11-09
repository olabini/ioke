include_class('ioke.lang.Runtime') { 'IokeRuntime' } unless defined?(IokeRuntime)

describe "Base" do 
  describe "'cells'" do 
    it "should return the cells of this object by default" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string("x = Origin mimic. x cells == {}").should == ioke.true
      ioke.evaluate_string("x = Origin mimic. x f = 13. x cells == {f: 13}").should == ioke.true
      ioke.evaluate_string("x = Origin mimic. x f = 13. x Why = 1. x cells == {f: 13, Why: 1}").should == ioke.true
      ioke.evaluate_string("x = Origin mimic. x Why = 1. x f = 13. x cells == {f: 13, Why: 1}").should == ioke.true
    end

    it "should take a boolean, when given will make it return all cells in both this and it's parents objects"
  end

  describe "'cellNames'" do 
    it "should return the cell names of this object by default" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string("x = Origin mimic. x cellNames == []").should == ioke.true
      ioke.evaluate_string("x = Origin mimic. x f = 13. x cellNames == [:f]").should == ioke.true
      ioke.evaluate_string("x = Origin mimic. x f = 13. x Why = 1. x cellNames == [:f, :Why]").should == ioke.true
      ioke.evaluate_string("x = Origin mimic. x Why = 1. x f = 13. x cellNames == [:Why, :f]").should == ioke.true
    end
    
    it "should take a boolean, when given will make it return all cell names in both this and it's parents objects"
  end
  
  describe "'cell'" do 
    it "should be possible to get a cell using a Text argument" do 
      ioke = IokeRuntime.get_runtime()
      ioke.evaluate_string("x = 42. cell(\"x\") == x").should == ioke.true
      ioke.evaluate_string("Text x = 42. Text cell(\"x\") == Text x").should == ioke.true
    end

    it "should be possible to get a cell using a Symbol argument" do 
      ioke = IokeRuntime.get_runtime()
      ioke.evaluate_string("x = 42. cell(:x) == x").should == ioke.true
      ioke.evaluate_string("Text x = 42. Text cell(:x) == Text x").should == ioke.true
    end

    it "should be possible to get a cell with an empty name" do 
      ioke = IokeRuntime.get_runtime()
      ioke.evaluate_string("cell(\"\")").should_not == ioke.nil
    end

    it "should report an error if trying to get a cell that doesn't exist in that object" do 
      ioke = IokeRuntime.get_runtime()

      proc do 
        ioke.evaluate_string("cell(:flurg)")
      end.should raise_error

      proc do 
        ioke.evaluate_string("cell(\"flurg\")")
      end.should raise_error
    end
  end

  describe "'cell='" do 
    it "should be possible to set a cell using a Text argument" do 
      ioke = IokeRuntime.get_runtime()
      ioke.evaluate_string("cell(\"blurg\") = 42. blurg").data.as_java_integer.should == 42
      ioke.evaluate_string("Text cell(\"murg\") = 42. Text murg").data.as_java_integer.should == 42
    end

    it "should be possible to set a cell using a Symbol argument" do 
      ioke = IokeRuntime.get_runtime()
      ioke.evaluate_string("cell(:blurg) = 42. blurg").data.as_java_integer.should == 42
      ioke.evaluate_string("Text cell(:murg) = 42. Text murg").data.as_java_integer.should == 42
    end

    it "should be possible to set a cell with an empty name" do 
      ioke = IokeRuntime.get_runtime()
      ioke.evaluate_string("Text cell(\"\") = 42. Text cell(\"\")").data.as_java_integer.should == 42
    end

    it "should be possible to set a cell with complicated expressions" do 
      ioke = IokeRuntime.get_runtime()
      ioke.evaluate_string("f = Origin mimic. f b = \"foobar\". Text cell(f b) = 42+24-3. Text cell(:foobar)").data.as_java_integer.should == 63
    end

    it "should be possible to set a cell that doesn't exist" do 
      ioke = IokeRuntime.get_runtime()
      ioke.evaluate_string("cell(:blurg) = 42. blurg").data.as_java_integer.should == 42
      ioke.evaluate_string("Text cell(:murg) = 42. Text murg").data.as_java_integer.should == 42
    end 

    it "should be possible to set a cell that does exist" do 
      ioke = IokeRuntime.get_runtime()
      ioke.evaluate_string("Ground x = 42. cell(:x) = 43. x").data.as_java_integer.should == 43
    end

    it "should be possible to set a cell that does exist in a mimic. this should not change the mimic value" do 
      ioke = IokeRuntime.get_runtime()
      ioke.evaluate_string("one = Origin mimic. one x = 42. two = one mimic. two cell(:x) = 43. one x").data.as_java_integer.should == 42
      ioke = IokeRuntime.get_runtime()
      ioke.evaluate_string("one = Origin mimic. one x = 42. two = one mimic. two cell(:x) = 43. two x").data.as_java_integer.should == 43
    end
  end
end
