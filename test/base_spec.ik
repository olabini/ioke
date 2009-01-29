use("ispec")

describe("Base",
  describe("identity",
    it("should return a newly created Origin",
      x = Origin mimic
      x identity should be same(x)
    )
  )

  describe("removeCell!",
    it("should remove the cell",
      x = Origin mimic
      x flurgus_cell_test = 123
      x removeCell!(:flurgus_cell_test)
      x cell?(:flurgus_cell_test) should be false
    )

    it("should signal a condition if no such cell exists",
      fn(Origin mimic removeCell!(:foo)) should signal(Condition Error NoSuchCell)
    )

    it("should offer an ignore restart if the cell can't be found",
      x = Origin mimic
      fn(x removeCell!(:foo)) should offer(restart(ignore, fn))
      fn(x removeCell!(:foo)) should returnFromRestart(:ignore) == x
    )

    it("should only remove a cell on the current object",
      x = Origin mimic
      y = x mimic
    
      x foo = "blurg"
      y foo = "blarg"

      y removeCell!(:foo)
      y cell?(:foo) should be true
      y foo should == "blurg"
    )
  )

  describe("undefineCell!",
    it("should remove the cell",
      x = Origin mimic
      x flurgus_cell_test = 123
      x undefineCell!(:flurgus_cell_test)
      x cell?(:flurgus_cell_test) should be false
    )

    it("should not signal a condition if no such cell exists",
      Origin mimic undefineCell!(:test_undefine_cell)
    )

    it("should make the cell inaccessible",
      x = Origin mimic
      y = x mimic
    
      x foo = "blurg"
      y foo = "blarg"

      y undefineCell!(:foo)
      x cell?(:foo) should be true
      y cell?(:foo) should be false
      fn(y foo) should signal(Condition Error NoSuchCell)
      fn(y mimic foo) should signal(Condition Error NoSuchCell)
    )

    it("should stop the cell from showing up in cellNames",
      x = Origin mimic
      y = x mimic
    
      x foo = "blurg"
      y foo = "blarg"

      y undefineCell!(:foo)

      x cellNames should == [:foo]
      y cellNames should == []

      x cellNames(true) should include(:foo)
      y cellNames(true) should not include(:foo)
      y mimic cellNames(true) should not include(:foo)

      z = y mimic
      z foo = 123
      z cellNames(true) should include(:foo)
    )

    it("should stop the cell from showing up in cells",
      x = Origin mimic
      y = x mimic
    
      x foo = "blurg"
      y foo = "blarg"

      y undefineCell!(:foo)

      x cells should == {foo: "blurg"}
      y cells should == {}

      x cells(true) keys should include(:foo)
      y cells(true) keys should not include(:foo)
      y mimic cells(true) keys should not include(:foo)

      z = y mimic
      z foo = 123
      z cells(true) keys should include(:foo)
    )

    it("should stop the cell from being able to get with cell",
      x = Origin mimic
      y = x mimic
    
      x foo = "blurg"
      y foo = "blarg"

      y undefineCell!(:foo)
      
      x cell(:foo) should == "blurg"
      fn(y cell(:foo)) should signal(Condition Error NoSuchCell)

      z = y mimic
      z foo = 123
      z foo should == 123
    )

    it("should stop the cell from showing up with cellOwner",
      x = Origin mimic
      y = x mimic
    
      x foo = "blurg"
      y foo = "blarg"

      y undefineCell!(:foo)
      fn(y cellOwner(:foo)) should signal(Condition Error NoSuchCell)
    )

    it("should stop the cell from showing up with cellOwner?",
      x = Origin mimic
      y = x mimic
    
      x foo = "blurg"
      y foo = "blarg"

      y undefineCell!(:foo)
      fn(y cellOwner?(:foo)) should signal(Condition Error NoSuchCell)
    )

    it("should be possible to remove the undefine with removeCell!",
      x = Origin mimic
      y = x mimic
    
      x foo = "blurg"
      y foo = "blarg"

      y undefineCell!(:foo)
      y removeCell!(:foo)
      y foo should == "blurg"
    )
  )

  describe("cellOwner?",
    it("should return true if the cell name is owned by this object",
      x = Origin mimic
      y = x mimic

      x foo = 123
      y foo = "bar"

      x cellOwner?(:foo) should be true
      y cellOwner?(:foo) should be true
    )

    it("should return false if the cell name is owned by another object",
      x = Origin mimic
      y = x mimic

      x foo = 123

      y cellOwner?(:foo) should be false
    )

    it("should signal a condition if there is no such cell",
      fn(Origin cellOwner?(:test_cell_owner)) should signal(Condition Error NoSuchCell)
    )

    it("should offer an ignore restart if the cell can't be found",
      fn(Origin cellOwner?(:test_cell_owner)) should offer(restart(ignore, fn))
      fn(Origin cellOwner?(:test_cell_owner)) should returnFromRestart(:ignore) == false
    )
  )

  describe("cellOwner",
    it("should return the closest owner of a cell",
      x = Origin mimic
      y = x mimic

      x foo = 123
      y foo = "bar"

      x cellOwner(:foo) should be same(x)
      y cellOwner(:foo) should be same(y)
      x mimic cellOwner(:foo) should be same(x)
    )

    it("should signal a condition if there is no such cell",
      fn(Origin cellOwner(:test_cell_owner)) should signal(Condition Error NoSuchCell)
    )

    it("should offer an ignore restart if the cell can't be found",
      fn(Origin cellOwner(:test_cell_owner)) should offer(restart(ignore, fn))
      fn(Origin cellOwner(:test_cell_owner)) should returnFromRestart(:ignore) == nil
    )
  )

  describe("cells",
    it("should return the cells of this object by default",
      x = Origin mimic
      x cells should == {}

      x = Origin mimic
      x f = 13
      x cells should == {f: 13}

      x = Origin mimic
      x f = 13
      x Why = 1
      x cells should == {f: 13, Why: 1}

      x = Origin mimic
      x Why = 1
      x f = 13
      x cells should == {f: 13, Why: 1}
    )

    it("should take a boolean, when given will make it return all cells in both this and it's parents objects",
      x = Base mimic
      x cells(true) should == {
        kind: Base cell(:kind), 
        mimic: Base cell(:mimic), 
        :"=" => Base cell(:"="), 
        :"==" => Base cell(:"=="), 
        documentation: Base cell(:documentation),
        :"documentation=" => Base cell(:"documentation="),
        cell: Base cell(:cell), 
        identity: Base cell(:identity), 
        cellNames: Base cell(:cellNames), 
        cells: Base cell(:cells), 
        :"cell=" => Base cell(:"cell="), 
        notice: "Base", 
        inspect: "Base", 
        :"removeCell!" => Base cell(:"removeCell!"),
        :"undefineCell!" => Base cell(:"undefineCell!"),
        :"cellOwner?" => Base cell(:"cellOwner?"),
        :"cellOwner" => Base cell(:"cellOwner"),
        :"cell?" => Base cell("cell?")}

      x = Base mimic
      x kind = "blarg"
      x cells(true) should == {
        kind: "blarg", 
        mimic: Base cell(:mimic), 
        :"=" => Base cell(:"="), 
        :"==" => Base cell(:"=="), 
        documentation: Base cell(:documentation),
        :"documentation=" => Base cell(:"documentation="),
        cell: Base cell(:cell), 
        identity: Base cell(:identity), 
        cellNames: Base cell(:cellNames), 
        cells: Base cell(:cells), 
        :"cell=" => Base cell(:"cell="), 
        notice: "Base", 
        inspect: "Base", 
        :"removeCell!" => Base cell(:"removeCell!"),
        :"undefineCell!" => Base cell(:"undefineCell!"),
        :"cellOwner?" => Base cell(:"cellOwner?"),
        :"cellOwner" => Base cell(:"cellOwner"),
        :"cell?" => Base cell("cell?")}
    )
  )

  describe("cellNames",
    it("should return the cell names of this object by default", 
      x = Origin mimic. 
      x cellNames should == []
      
      x f = 13
      x cellNames should == [:f]

      x Why = 1
      x cellNames should == [:f, :Why]

      x = Origin mimic
      x Why = 1
      x f = 13
      x cellNames should == [:Why, :f]
    )
    
    it("should take a boolean, when given will make it return all cell names in both this and it's parents objects", 
      baseNames = Base cells keys asList sort
      defaultBehaviorNames = DefaultBehavior cells keys sort
      defaultBehaviorAllNames = DefaultBehavior cells(true) keys sort
      groundNames = Ground cells keys sort
      originNames = Origin cells keys sort

      ;; Easy way to remove duplicates - create a set of it and then sort it back into a list
      groundAllNames = set(*(groundNames + baseNames + defaultBehaviorAllNames)) sort
      javaGroundAllNames = JavaGround cells keys sort
      originAllNames = set(*(originNames + groundAllNames + javaGroundAllNames)) sort

      Base cellNames sort should == baseNames
      Base cellNames(false) sort should == baseNames
      Base cellNames(true) sort should == baseNames

      DefaultBehavior cellNames sort should == defaultBehaviorNames
      DefaultBehavior cellNames(false) sort should == defaultBehaviorNames
      DefaultBehavior cellNames(true) sort should == defaultBehaviorAllNames

      Ground cellNames sort should == groundNames
      Ground cellNames(false) sort should == groundNames
      Ground cellNames(true) sort should == groundAllNames

      Origin cellNames sort should == originNames
      Origin cellNames(false) sort should == originNames
      Origin cellNames(true) sort should == originAllNames

      Text x = Origin mimic
      Text x cellNames(true) sort should == originAllNames 

      Text x = Origin mimic
      Text x foxy_base_spec = 12
      Text x cellNames(true) sort should == ([:foxy_base_spec] + originAllNames) sort
    )
  )

  describe("cell?",
    it("should be possible to check for the existance of a cell using a text argument", 
      x = 42
      cell?("x") should be true
    )

    it("should be possible to check for the existance of a cell using a symbol argument", 
      x = 42
      cell?(:x) should be true
    )

    it("should be possible to check for the existance of a cell with an empty name", 
      cell?("") should be true
    )

    it("should be possible to check for the existance of a cell that doesn't exist", 
      cell?(:murg) should be false
    )

    it("should be possible to check for the existance of a cell that does exist", 
      cell?(:Ground) should be true
    )
  )
  
  describe("cell",
    it("should be possible to get a cell using a Text argument", 
      x = 42
      cell("x") should == x

      Text x = 42
      Text cell("x") should == Text x
    )

    it("should be possible to get a cell using a Symbol argument", 
      x = 42
      cell(:x) should == x
      
      Text x = 42
      Text cell(:x) should == Text x
    )

    it("should be possible to get a cell with an empty name", 
      cell(:"") kind should == "DefaultMethod"
    )

    it("should report an error if trying to get a cell that doesn't exist in that object", 
      fn(cell(:clurg)) should signal(Condition Error NoSuchCell)
      fn(cell("clurg")) should signal(Condition Error NoSuchCell)
    )
  )

  describe("cell=",
    it("should be possible to set a cell using a Text argument", 
      cell("blurg") = 42
      blurg should == 42

      Text cell("murg") = 42
      Text murg should == 42
    )

    it("should be possible to set a cell using a Symbol argument", 
      cell(:blurg) = 42
      blurg should == 42

      Text cell(:murg) = 42
      Text murg should == 42
    )

    it("should be possible to set a cell with an empty name", 
      oldEmpty = cell("")
      Text cell("") = 42
      Text cell("") should == 42
      Text cell("") = cell(:oldEmpty)
    )

    it("should be possible to set a cell with complicated expressions", 
      f = Origin mimic
      f b = "foobar"
      Text cell(f b) = 42+24-3
      Text cell(:foobar) should == 63
    )

    it("should be possible to set a cell that doesn't exist", 
      cell(:blurg) = 42
      blurg should == 42
      Text cell(:murg) = 42
      Text murg should == 42
    ) 

    it("should be possible to set a cell that does exist", 
      Ground x = 42
      cell(:x) = 43
      x should == 43
    )

    it("should be possible to set a cell that does exist in a mimic. this should not change the mimic value", 
      one = Origin mimic
      one x = 42
      two = one mimic
      two cell(:x) = 43
      one x should == 42

      one = Origin mimic
      one x = 42
      two = one mimic
      two cell(:x) = 43
      two x should == 43
    )
  )

  describe("documentation",
    it("should return nil for a new object",
      Origin mimic documentation should be nil
    )
    
    it("should return the documentation string for an object that has documentation",
      Origin documentation should == "Any object created from scratch should usually be derived from Origin."
    )
  )

  describe("documentation=",
    it("should set the documentation for an object",
      x = Origin mimic
      x cell(:documentation) kind should == "JavaMethod"

      x documentation = "Wow, you didn't believe that, right?"

      x cell(:documentation) kind should == "JavaMethod"

      x documentation should == "Wow, you didn't believe that, right?"
    )

    it("should return the documentation string set",
      (Origin mimic documentation = "something") should == "something"
    )

    it("should validate type of argument",
      fn(Origin mimic documentation = []) should signal(Condition Error Type IncorrectType)
    )
  )
)
