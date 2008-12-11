
use("ispec")

describe(Mixins, 
  describe("cells", 
    it("should return the cells of this object by default", 
      x = Mixins mimic. x cells should == {}

      x = Mixins mimic. x f = 13. x cells should == {f: 13}

      x = Mixins mimic. x f = 13. x Why = 1. x cells should == {f: 13, Why: 1}

      x = Mixins mimic. x Why = 1. x f = 13. x cells should == {f: 13, Why: 1}
    )
  )

  describe("cellNames", 
    it("should return the cell names of this object by default", 
      x = Mixins mimic. x cellNames should == []

      x = Mixins mimic. x f = 13. x cellNames should == [:f]

      x = Mixins mimic. x f = 13. x Why = 1. x cellNames should == [:f, :Why]

      x = Mixins mimic. x Why = 1. x f = 13. x cellNames should == [:Why, :f]
    )
  )

  describe("cell", 
    it("should be possible to get a cell using a Text argument", 
      Mixins x = 42
      Mixins cell("x") should == Mixins x

      Mixins Comparing x = 43
      Mixins Comparing cell("x") should == Mixins Comparing x
    )

    it("should be possible to get a cell using a Symbol argument", 
      Mixins x = 42
      Mixins cell(:x) should == Mixins x

      Mixins Comparing x = 43
      Mixins Comparing cell(:x) should == Mixins Comparing x
    )

    it("should report an error if trying to get a cell that doesn't exist in that object", 
      fn(Mixins cell(:mixins_spec_non_existing)) should signal(Condition Error NoSuchCell)
      fn(Mixins cell("mixins_spec_non_existing")) should signal(Condition Error NoSuchCell)

      fn(Mixins Comparing cell(:mixins_spec_non_existing)) should signal(Condition Error NoSuchCell)
      fn(Mixins Comparing cell("mixins_spec_non_existing")) should signal(Condition Error NoSuchCell)
    )
  )

  describe("cell=", 
    it("should be possible to set a cell using a Text argument", 
      Mixins cell("blurg") = 42
      Mixins blurg should == 42

      Mixins Comparing cell("murg") = 43
      Mixins Comparing murg should == 43
    )

    it("should be possible to set a cell using a Symbol argument", 
      Mixins cell(:blurg) = 42
      Mixins blurg should == 42

      Mixins Comparing cell(:murg) = 43
      Mixins Comparing murg should == 43
    )

    it("should be possible to set a cell with an empty name", 
      oldEmpty = cell("")
      Mixins Comparing cell("") = 42
      Mixins Comparing cell("") should == 42
      Mixins Comparing cell("") = cell(:oldEmpty)
    )

    it("should be possible to set a cell with complicated expressions", 
      f = Origin mimic
      f b = "foobar"
      Mixins cell(f b) = 42+24-3
      Mixins cell(:foobar) should == 63
    )

    it("should be possible to set a cell that doesn't exist", 
      Mixins cell(:blurg) = 42
      Mixins blurg should == 42

      Mixins Comparing cell(:murg) = 43
      Mixins Comparing murg should == 43
    ) 

    it("should be possible to set a cell that does exist", 
      Mixins x = 42
      Mixins cell(:x) = 43
      Mixins x should == 43

      Mixins Comparing x = 42
      Mixins Comparing cell(:x) = 44
      Mixins Comparing x should == 44
    )

    it("should be possible to set a cell that does exist in a mimic. this should not change the mimic value", 
      one = Mixins mimic
      one x = 42
      two = one mimic
      two cell(:x) = 43
      one x should == 42

      one = Mixins mimic
      one x = 42
      two = one mimic
      two cell(:x) = 43
      two x should == 43
    )
  )
)
