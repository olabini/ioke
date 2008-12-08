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
)
