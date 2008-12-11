use("ispec")

describe("Base",
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
        cell: Base cell(:cell), 
        cellNames: Base cell(:cellNames), 
        cells: Base cell(:cells), 
        :"cell=" => Base cell(:"cell="), 
        notice: "Base", 
        :"cell?" => Base cell("cell?")}

      x = Base mimic
      x kind = "blarg"
      x cells(true) should == {
        kind: "blarg", 
        mimic: Base cell(:mimic), 
        :"=" => Base cell(:"="), 
        cell: Base cell(:cell), 
        cellNames: Base cell(:cellNames), 
        cells: Base cell(:cells), 
        :"cell=" => Base cell(:"cell="), 
        notice: "Base", 
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
      originAllNames = set(*(originNames + groundAllNames)) sort

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
      cell?("x") should == true
    )

    it("should be possible to check for the existance of a cell using a symbol argument", 
      x = 42
      cell?(:x) should == true
    )

    it("should be possible to check for the existance of a cell with an empty name", 
      cell?("") should == true
    )

    it("should be possible to check for the existance of a cell that doesn't exist", 
      cell?(:murg) should == false
    )

    it("should be possible to check for the existance of a cell that does exist", 
      cell?(:Ground) should == true
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
      fn(cell(:flurg)) should signal(Condition Error NoSuchCell)
      fn(cell("flurg")) should signal(Condition Error NoSuchCell)
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
)
