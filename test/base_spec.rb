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

    it "should take a boolean, when given will make it return all cells in both this and it's parents objects" do 
      ioke = IokeRuntime.get_runtime

      ioke.evaluate_string("x = Base mimic. x cells(true) == {kind: Base cell(:kind), mimic: Base cell(:mimic), :\"=\" => Base cell(:\"=\"), cell: Base cell(:cell), cellNames: Base cell(:cellNames), cells: Base cell(:cells), :\"cell=\" => Base cell(:\"cell=\"), notice: \"Base\", :\"cell?\" => Base cell(\"cell?\")}").should == ioke.true

      ioke.evaluate_string("x = Base mimic. x kind = \"blarg\". x cells(true) == {kind: \"blarg\", mimic: Base cell(:mimic), :\"=\" => Base cell(:\"=\"), cell: Base cell(:cell), cellNames: Base cell(:cellNames), cells: Base cell(:cells), :\"cell=\" => Base cell(:\"cell=\"), notice: \"Base\", :\"cell?\" => Base cell(\"cell?\")}").should == ioke.true
    end
  end

  describe "'cellNames'" do 
    it "should return the cell names of this object by default" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string("x = Origin mimic. x cellNames == []").should == ioke.true
      ioke.evaluate_string("x = Origin mimic. x f = 13. x cellNames == [:f]").should == ioke.true
      ioke.evaluate_string("x = Origin mimic. x f = 13. x Why = 1. x cellNames == [:f, :Why]").should == ioke.true
      ioke.evaluate_string("x = Origin mimic. x Why = 1. x f = 13. x cellNames == [:Why, :f]").should == ioke.true
    end
    
    it "should take a boolean, when given will make it return all cell names in both this and it's parents objects" do 
      ioke = IokeRuntime.get_runtime
      base_names = ioke.base.cells.key_set.to_a.map do |s| 
        if s == "" || s =~ /[=\.:\-\+&|\{\[]/
          ":\"#{s}\""
        else
          ":#{s}"
        end
      end

      default_behavior_names = ioke.default_behavior.cells.key_set.to_a.map do |s| 
        if s == "" || s =~ /[=\.:\-\+&|\{\[]/
          ":\"#{s}\""
        else
          ":#{s}"
        end
      end

      ground_names = ioke.ground.cells.key_set.to_a.map do |s| 
        if s == "" || s =~ /[=\.:\-\+&|\{\[]/
          ":\"#{s}\""
        else
          ":#{s}"
        end
      end

      origin_names = ioke.origin.cells.key_set.to_a.map do |s| 
        if s == "" || s =~ /[=\.:\-\+&|\{\[]/
          ":\"#{s}\""
        else
          ":#{s}"
        end
      end

      ground_all_names = ground_names + base_names + default_behavior_names
      ground_all_names.uniq!

      origin_all_names = origin_names + ground_all_names
      origin_all_names.uniq!

      ioke.evaluate_string("Base cellNames == [#{base_names.join(", ")}]").should == ioke.true
      ioke.evaluate_string("Base cellNames(false) == [#{base_names.join(", ")}]").should == ioke.true
      ioke.evaluate_string("Base cellNames(true) == [#{base_names.join(", ")}]").should == ioke.true

      ioke.evaluate_string("DefaultBehavior cellNames == [#{default_behavior_names.join(", ")}]").should == ioke.true
      ioke.evaluate_string("DefaultBehavior cellNames(false) == [#{default_behavior_names.join(", ")}]").should == ioke.true
      ioke.evaluate_string("DefaultBehavior cellNames(true) == [#{default_behavior_names.join(", ")}]").should == ioke.true

      ioke.evaluate_string("Ground cellNames == [#{ground_names.join(", ")}]").should == ioke.true
      ioke.evaluate_string("Ground cellNames(false) == [#{ground_names.join(", ")}]").should == ioke.true
      ioke.evaluate_string("Ground cellNames(true) sort inspect").data.text.should == ioke.evaluate_string("[#{ground_all_names.join(", ")}] sort inspect").data.text

      ioke.evaluate_string("Origin cellNames == [#{origin_names.join(", ")}]").should == ioke.true
      ioke.evaluate_string("Origin cellNames(false) == [#{origin_names.join(", ")}]").should == ioke.true
      ioke.evaluate_string("Origin cellNames(true) sort == [#{origin_all_names.join(", ")}] sort").should == ioke.true

      ioke.evaluate_string("Text x = Origin mimic. Text x cellNames(true) sort == [#{origin_all_names.join(", ")}] sort").should == ioke.true
      ioke.evaluate_string("Text x = Origin mimic. Text x foo = 12. Text x cellNames(true) sort == [:foo, #{origin_all_names.join(", ")}] sort").should == ioke.true
    end
  end

  describe "'cell?'" do 
    it "should be possible to check for the existance of a cell using a text argument" do 
      ioke = IokeRuntime.get_runtime()
      ioke.evaluate_string("x = 42. cell?(\"x\")").should == ioke.true
    end

    it "should be possible to check for the existance of a cell using a symbol argument" do 
      ioke = IokeRuntime.get_runtime()
      ioke.evaluate_string("x = 42. cell?(:x)").should == ioke.true
    end

    it "should be possible to check for the existance of a cell with an empty name" do 
      ioke = IokeRuntime.get_runtime()
      ioke.evaluate_string('cell?("")').should == ioke.true
    end

    it "should be possible to check for the existance of a cell that doesn't exist" do 
      ioke = IokeRuntime.get_runtime()
      ioke.evaluate_string('cell?(:murg)').should == ioke.false
    end

    it "should be possible to check for the existance of a cell that does exist" do 
      ioke = IokeRuntime.get_runtime()
      ioke.evaluate_string('cell?(:Ground)').should == ioke.true
    end
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
      sw = StringWriter.new(20)
      out = PrintWriter.new(sw)

      ioke = IokeRuntime.get_runtime(out, InputStreamReader.new(System.in), out)

      begin 
        ioke.evaluate_string("cell(:flurg)")
        true.should be_false
      rescue NativeException => cfe
        cfe.cause.value.find_cell(nil, nil, "kind").data.text.should == "Condition Error NoSuchCell"
      end

      begin 
        ioke.evaluate_string("cell(\"flurg\")")
        true.should be_false
      rescue NativeException => cfe
        cfe.cause.value.find_cell(nil, nil, "kind").data.text.should == "Condition Error NoSuchCell"
      end
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
