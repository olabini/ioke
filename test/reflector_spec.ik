
use("ispec")

describe(Reflector,
  it("should have the correct kind",
    Reflector should have kind("Reflector")
  )

  describe("other:documentation",
    it("should fetch an objects documentation",
      obj = Origin mimic

      Reflector other:documentation(obj) should be nil

      obj documentation = "foo bar"

      Reflector other:documentation(obj) should == "foo bar"

      obj removeAllMimics!

      Reflector other:documentation(obj) should == "foo bar"
    )
  )

  describe("other:documentation=",
    it("should set the documentation on an object",
      obj = Origin mimic
      Reflector other:documentation(obj) = "flux"
      obj documentation should == "flux"

      obj removeAllMimics!

      Reflector other:documentation(obj) should == "flux"
    )
  )

  describe("other:mimics",
    it("should return the mimics for an object",
      obj = Origin mimic
      obj2 = obj mimic
      obj3 = Origin mimic
      obj2 mimic!(obj3)

      Reflector other:mimics(obj) should == [Origin]
      Reflector other:mimics(obj2) should == [obj, obj3]
      Reflector other:mimics(obj3) should == [Origin]

      obj3 removeAllMimics!

      Reflector other:mimics(obj3) should == []
    )
  )

  describe("other:is?",
    it("should work correctly for any object",
      Reflector other:is?(DefaultBehavior, Origin) should be false
      Reflector other:is?(Ground, Base) should be true
      obj = Origin mimic

      Reflector other:is?(obj, Origin) should be true
      Reflector other:is?(obj, Base) should be true

      obj removeAllMimics!

      Reflector other:is?(obj, Origin) should be false
    )
  )

  describe("other:uniqueHexId",
    it("should return a unique hex id for any object",
      obj = Origin mimic
      hex = obj uniqueHexId

      Reflector other:uniqueHexId(obj) should == hex

      obj removeAllMimics!

      Reflector other:uniqueHexId(obj) should == hex
    )
  )

  describe("other:same?",
    it("should work for all kinds of objects",
      obj = Origin mimic
      Reflector other:same?(Base, Base) should be true
      Reflector other:same?(Base, Origin) should be false
      Reflector other:same?(obj, Origin) should be false
      Reflector other:same?(obj, obj) should be true

      obj removeAllMimics!

      Reflector other:same?(obj, Origin) should be false
      Reflector other:same?(obj, obj) should be true
    )
  )

  describe("other:send",
    it("should work on all objects",
      x = Origin mimic do(
        foo = method(42))

      Reflector other:send(x, :foo) should == 42

      x removeAllMimics!

      Reflector other:send(x, :foo) should == 42
    )
  )

  describe("other:kind?",
    it("should return false if the kind doesn't match", 
      Reflector other:kind?(Text, "nil") should be false
      Reflector other:kind?(Text, "Number") should be false
      Reflector other:kind?("", "nil") should be false
      Reflector other:kind?("", "Number") should be false
      Reflector other:kind?("", "System") should be false
    )

    it("should return true if the current object has the kind", 
      Reflector other:kind?(Text, "Text") should be true
    )
    
    it("should return true if the main mimic has the kind", 
      Reflector other:kind?("", "Text") should be true
      Reflector other:kind?("", "DefaultBehavior") should be true
      Reflector other:kind?("", "Base") should be true
      Reflector other:kind?("", "Ground") should be true
      Reflector other:kind?("", "Origin") should be true
    )

    it("should return true if another mimic has the kind", 
      Reflector other:kind?(123, "Mixins Comparing") should be true
    )

    it("should handle a cycle of mimics correctly", 
      f = Origin mimic. f mimic!(f). Reflector other:kind?(f, "Origin") should be true
      f = Origin mimic. Origin mimic!(f). Reflector other:kind?(f, "Origin") should be true
      f = Origin mimic. Origin mimic!(f). Reflector other:kind?(f, "DefaultBehavior") should be true
    )
  )

  describe("other:become!",
    it("should not be possible to have nil become something",
      fn(Reflector other:become!(nil, 42)) should signal(Condition Error CantMimicOddball)
    )

    it("should not be possible to have true become something",
      fn(Reflector other:become!(true, 42)) should signal(Condition Error CantMimicOddball)
    )

    it("should not be possible to have false become something",
      fn(Reflector other:become!(false, 42)) should signal(Condition Error CantMimicOddball)
    )

    it("should be possible to have a number become something else",
      x = Origin mimic
      ; this number should really NOT be used in ANY other test
      y = -324234534534145

      Reflector other:become!(y, x)

      y should have kind("Origin")
      y asText should not == "-324234534534145"
    )

    it("should be possible to have something become a number",
      x = Origin mimic
      y = 42

      Reflector other:become!(x, y)

      x should have kind("Number")
      x should == 42
    )

    it("should be possible to have a text become something else",
      x = Origin mimic
      y = "foobar"

      Reflector other:become!(y, x)

      y should have kind("Origin")
      y should not == "foobar"
    )

    it("should be possible to have something become a text",
      x = Origin mimic
      y = "foobar"

      Reflector other:become!(x, y)

      x should have kind("Text")
      x should == "foobar"
    )

    it("should return the receiver",
      x = Origin mimic
      y = Origin mimic

      Reflector other:become!(x, y) should be same(y)
    )

    it("should modify the reciever to have the same documentation",
      x = Origin mimic
      y = Origin mimic
      x documentation = "foo"
      y documentation = "quux"

      Reflector other:become!(x, y)

      x documentation should == "quux"
    )

    it("should give both objects the same uniqueHexId",
      x = Origin mimic
      y = Origin mimic

      x uniqueHexId should not == y uniqueHexId
      y uniqueHexId should not == x uniqueHexId

      Reflector other:become!(x, y)
      
      x uniqueHexId should == y uniqueHexId
      y uniqueHexId should == x uniqueHexId
    )

    it("should give objects that are the same",
      x = Origin mimic
      y = Origin mimic
      x should not be same(y)
      y should not be same(x)

      Reflector other:become!(x, y)
      
      x should be same(y)
      y should be same(x)
    )
    
    it("should give objects that mimic each other",
      x = Origin mimic
      y = Origin mimic

      Reflector other:become!(x, y)
      
      x should be mimic(y)
      y should be mimic(x)
    )
    
    it("should give objects that when modified will change each other",
      x = Origin mimic
      y = Origin mimic

      Reflector other:become!(x, y)

      x z = 42
      y z should == 42

      y q = 35
      x q should == 35

      b = Origin mimic
      x mimic!(b)

      y should have mimic(b)
    )
  )

  describe("other:frozen?",
    it("should return false on something that isn't frozen",
      x = Origin mimic
      Reflector other:frozen?(x) should be false
      
      x freeze!

      Reflector other:frozen?(x) should be true
    )
  )

  describe("other:freeze!",
    it("should be possible to call several times without effect",
      x = Origin mimic
      Reflector other:freeze!(x)
      x freeze!
    )

    it("should not be possible to modify a frozen object",
      x = Origin mimic
      x existing = 43
      Reflector other:freeze!(x)

      ;; create new cell
      fn(x y = 42) should signal(Condition Error ModifyOnFrozen)

      ;; modify existing
      fn(x existing = 42) should signal(Condition Error ModifyOnFrozen)

      ;; add new mimic
      fn(x mimic!(Origin mimic)) should signal(Condition Error ModifyOnFrozen)
      fn(x prependMimic!(Origin mimic)) should signal(Condition Error ModifyOnFrozen)

      ;; remove mimic
      fn(x removeMimic!(Origin)) should signal(Condition Error ModifyOnFrozen)

      ;; remove all mimics
      fn(x removeAllMimics!) should signal(Condition Error ModifyOnFrozen)

      ;; set documentation
      fn(x documentation = "blarg") should signal(Condition Error ModifyOnFrozen)

      ;; become something else
      fn(x become!(42)) should signal(Condition Error ModifyOnFrozen)
    )

    it("should be copied when becoming",
      x = Origin mimic
      y = Origin mimic
      Reflector other:freeze!(x)

      y become!(x)
      
      y should be frozen
    )
  )

  describe("other:thaw!",
    it("should be possible to call several times without effect",
      x = Origin mimic
      x freeze!

      Reflector other:thaw!(x)
      Reflector other:thaw!(x)
    )

    it("should unfreeze an object",
      x = Origin mimic
      x freeze!

      Reflector other:thaw!(x)

      x should not be frozen
    )
  )

  describe("other:mimics?",
    it("should return false if the object doesn't mimic the argument", 
      f = Origin mimic. Reflector other:mimics?(Origin, f) should be false
      f = Origin mimic. Reflector other:mimics?(DefaultBehavior, f) should be false
      f = Origin mimic. Reflector other:mimics?(12, f) should be false
      f = Origin mimic. Reflector other:mimics?(f, 12) should be false
    )
    
    it("should return true if the object is the same as the argument", 
      f = Origin mimic. Reflector other:mimics?(f, f) should be true
      Reflector other:mimics?(Origin, Origin) should be true
    )

    it("should return true if any of the mimics are the argument", 
      x = Origin mimic. y = x mimic. z = y mimic. Reflector other:mimics?(z, Origin) should be true
      x = Origin mimic. y = x mimic. z = y mimic. Reflector other:mimics?(z, x) should be true
      x = Origin mimic. y = x mimic. z = y mimic. Reflector other:mimics?(z, y) should be true
      x = Origin mimic. y = x mimic. z = y mimic. Reflector other:mimics?(z, z) should be true
      f = Origin mimic. Origin mimic!(f). x = Origin mimic. y = x mimic. z = y mimic. Reflector other:mimics?(z, f) should be true
    )
    
    it("should handle a cycle of mimics correctly", 
      x = Origin mimic. y = x mimic. z = y mimic. Origin mimic!(z). Reflector other:mimics?(z, Number) should be false
      x = Origin mimic. y = x mimic. z = y mimic. Origin mimic!(z). Reflector other:mimics?(z, Origin) should be true
      x = Origin mimic. y = x mimic. z = y mimic. Origin mimic!(z). Reflector other:mimics?(z, Base) should be true
      x = Origin mimic. x mimic!(x). Reflector other:mimics?(x, Origin) should be true
    )
  )

  describe("other:mimic",
    it("should be able to mimic Origin", 
      result = Reflector other:mimic(Origin)
      result should have kind("Origin")
      result should not be same(Origin)
    )

    it("should be able to mimic Ground", 
      result = Reflector other:mimic(Ground)
      result should have kind("Ground")
      result should not be same(Ground)
    )

    it("should be able to mimic Base", 
      result = Reflector other:mimic(Base)
      result kind should == "Base"
    )

    it("should be able to mimic Text", 
      result = Reflector other:mimic(Text)
      result should have kind("Text")
      result should not be same(Text)
    )
  )

  describe("other:mimic!",
    it("should add a new mimic to the list of mimics", 
      f = Origin mimic. g = Origin mimic. Reflector other:mimic!(f, g)
      f mimics length should == 2
      f mimics[0] should == Origin
      f mimics[1] should == g
    )

    it("should not add a mimic that's already in the list", 
      f = Origin mimic
      Reflector other:mimic!(f, Origin)
      Reflector other:mimic!(f, Origin)
      Reflector other:mimic!(f, Origin)
      Reflector other:mimic!(f, Origin)
      f mimics length should == 1
    )

    it("should not be able to mimic nil", 
      fn(Reflector other:mimic!(Origin mimic, nil)) should signal(Condition Error CantMimicOddball)
    )
    
    it("should not be able to mimic true", 
      fn(Reflector other:mimic!(Origin mimic, true)) should signal(Condition Error CantMimicOddball)
    )
    
    it("should not be able to mimic false", 
      fn(Reflector other:mimic!(Origin mimic, false)) should signal(Condition Error CantMimicOddball)
    )
    
    it("should not be able to mimic symbols", 
      fn(Reflector other:mimic!(Origin mimic, :foo)) should signal(Condition Error CantMimicOddball)
    )
    
    it("should return the receiving object", 
      f = Origin mimic
      Reflector other:mimic!(f, Origin) should == f
    )
  )

  describe("other:prependMimic!",
    it("should add a new mimic to the list of mimics", 
      f = Origin mimic
      g = Origin mimic
      Reflector other:prependMimic!(f, g)
      f mimics length should == 2
      f mimics[1] should == Origin
      f mimics[0] should == g
    )

    it("should not add a mimic that's already in the list", 
      f = Origin mimic
      Reflector other:prependMimic!(f, Origin)
      Reflector other:prependMimic!(f, Origin)
      Reflector other:prependMimic!(f, Origin)
      Reflector other:prependMimic!(f, Origin)
      f mimics length should == 1
    )

    it("should not be able to mimic nil", 
      fn(Reflector other:prependMimic!(Origin mimic, nil)) should signal(Condition Error CantMimicOddball)
    )
    
    it("should not be able to mimic true", 
      fn(Reflector other:prependMimic!(Origin mimic, true)) should signal(Condition Error CantMimicOddball)
    )
    
    it("should not be able to mimic false", 
      fn(Reflector other:prependMimic!(Origin mimic, false)) should signal(Condition Error CantMimicOddball)
    )
    
    it("should not be able to mimic symbols", 
      fn(Reflector other:prependMimic!(Origin mimic, :foo)) should signal(Condition Error CantMimicOddball)
    )
    
    it("should return the receiving object", 
      f = Origin mimic
      Reflector other:prependMimic!(f, Origin) should == f
    )
  )

  describe("other:removeMimics!",
    it("should not remove something it doesn't mimic", 
      Reflector other:removeMimic!(Origin mimic, "foo") mimics should == [Origin]
    )

    it("should return the object", 
      x = Origin mimic
      Reflector other:removeMimic!(x, 1) should == x
    )
    
    it("should remove any mimic it has", 
      x = Origin mimic
      x mimics = DefaultBehavior cell(:mimics)
      Reflector other:removeMimic!(x, Origin)
      x mimics should == []
    )

    it("should not remove any other mimic", 
      x = Origin mimic
      y = Origin mimic
      x mimic!(y)
      Reflector other:removeMimic!(x, y)
      x mimics should == [Origin]
    )
  )

  describe("other:removeAllMimics!",
    it("should return the object", 
      x = Origin mimic
      x uniqueHexId = DefaultBehavior cell(:uniqueHexId)
      Reflector other:removeAllMimics!(x) uniqueHexId should == x uniqueHexId
    )

    it("should remove all mimics", 
      x = Origin mimic
      x mimic!(Text)
      x mimics = DefaultBehavior cell(:mimics)
      Reflector other:removeAllMimics!(x) mimics should == []
    )
  )

  describe("other:cell",
    it("should be possible to get a cell using a Text argument", 
      x = 42
      Reflector other:cell(identity, "x") should == x

      Text x = 42
      Reflector other:cell(Text, "x") should == Text x
    )

    it("should be possible to get a cell using a Symbol argument", 
      x = 42
      Reflector other:cell(identity, :x) should == x
      
      Text x = 42
      Reflector other:cell(Text, :x) should == Text x
    )

    it("should be possible to get a cell with an empty name", 
      Reflector other:cell(identity, :"") kind should == "DefaultMethod"
    )

    it("should report an error if trying to get a cell that doesn't exist in that object", 
      fn(Reflector other:cell(identity, :clurg)) should signal(Condition Error NoSuchCell)
      fn(Reflector other:cell(identity, "clurg")) should signal(Condition Error NoSuchCell)
    )
  )

  describe("other:cell=",
    it("should be possible to set a cell using a Text argument", 
      Reflector other:cell(Text, "murg") = 42
      Text murg should == 42
    )

    it("should be possible to set a cell using a Symbol argument", 
      Reflector other:cell(Text,:murg) = 42
      Text murg should == 42
    )

    it("should be possible to set a cell with an empty name", 
      oldEmpty = cell("")
      Reflector other:cell(Text, "") = 42
      Text cell("") should == 42
      Text cell("") = cell(:oldEmpty)
    )

    it("should be possible to set a cell with complicated expressions", 
      f = Origin mimic
      f b = "foobar"
      Reflector other:cell(Text, f b) = 42+24-3
      Text cell(:foobar) should == 63
    )

    it("should be possible to set a cell that doesn't exist", 
      Reflector other:cell(Text, :murg) = 42
      Text murg should == 42
    ) 

    it("should be possible to set a cell that does exist", 
      Ground x = 42
      Reflector other:cell(identity, :x) = 43
      x should == 43
    )

    it("should be possible to set a cell that does exist in a mimic. this should not change the mimic value", 
      one = Origin mimic
      one x = 42
      two = one mimic
      Reflector other:cell(two, :x) = 43
      one x should == 42

      one = Origin mimic
      one x = 42
      two = one mimic
      Reflector other:cell(two, :x) = 43
      two x should == 43
    )
  )

  describe("other:cell?",
    it("should be possible to check for the existance of a cell using a text argument", 
      x = 42
      Reflector other:cell?(identity, "x") should be true
    )

    it("should be possible to check for the existance of a cell using a symbol argument", 
      x = 42
      Reflector other:cell?(identity, :x) should be true
    )

    it("should be possible to check for the existance of a cell with an empty name", 
      Reflector other:cell?(identity, "") should be true
    )

    it("should be possible to check for the existance of a cell that doesn't exist", 
      Reflector other:cell?(identity, :murg) should be false
    )

    it("should be possible to check for the existance of a cell that does exist", 
      Reflector other:cell?(identity, :Ground) should be true
    )
  )

  describe("other:cellNames",
    it("should return the cell names of this object by default", 
      x = Origin mimic. 
      Reflector other:cellNames(x) should == []
      
      x f = 13
      Reflector other:cellNames(x) should == [:f]

      x Why = 1
      Reflector other:cellNames(x) should == [:f, :Why]

      x = Origin mimic
      x Why = 1
      x f = 13
      Reflector other:cellNames(x) should == [:Why, :f]
    )
    
    it("should take a boolean, when given will make it return all cell names in both this and it's parents objects", 
      baseNames = Base cells keys asList sort
      defaultBehaviorNames = DefaultBehavior cells keys sort
      defaultBehaviorAllNames = DefaultBehavior cells(true) keys sort
      iokeGroundNames = IokeGround cells keys sort
      groundNames = Ground cells keys sort
      originNames = Origin cells keys sort

      ;; Easy way to remove duplicates - create a set of it and then sort it back into a list
      nativeGroundAllNames = if(System feature?(:java), JavaGround cells keys sort, [])
      groundAllNames = set(*(iokeGroundNames + groundNames + nativeGroundAllNames + baseNames + defaultBehaviorAllNames)) sort
      originAllNames = set(*(originNames + groundAllNames + nativeGroundAllNames)) sort

      Reflector other:cellNames(Base) sort should == baseNames
      Reflector other:cellNames(Base, false) sort should == baseNames
      Reflector other:cellNames(Base, true) sort should == baseNames

      Reflector other:cellNames(DefaultBehavior) sort should == defaultBehaviorNames
      Reflector other:cellNames(DefaultBehavior, false) sort should == defaultBehaviorNames
      Reflector other:cellNames(DefaultBehavior, true) sort should == defaultBehaviorAllNames

      Reflector other:cellNames(Ground) sort should == groundNames
      Reflector other:cellNames(Ground, false) sort should == groundNames
      Reflector other:cellNames(Ground, true) sort should == groundAllNames

      Reflector other:cellNames(Origin) sort should == originNames
      Reflector other:cellNames(Origin, false) sort should == originNames
      Reflector other:cellNames(Origin, true) sort should == originAllNames

      Text x = Origin mimic
      Reflector other:cellNames(Text x, true) sort should == originAllNames 

      Text x = Origin mimic
      Text x foxy_base_spec = 12
      Reflector other:cellNames(Text x, true) sort should == ([:foxy_base_spec] + originAllNames) sort
    )
  )

  describe("other:cells",
    it("should return the cells of this object by default",
      x = Origin mimic
      Reflector other:cells(x) should == {}

      x = Origin mimic
      x f = 13
      Reflector other:cells(x) should == {f: 13}

      x = Origin mimic
      x f = 13
      x Why = 1
      Reflector other:cells(x) should == {f: 13, Why: 1}

      x = Origin mimic
      x Why = 1
      x f = 13
      Reflector other:cells(x) should == {f: 13, Why: 1}
    )

    it("should take a boolean, when given will make it return all cells in both this and it's parents objects",
      x = Base mimic
      Reflector other:cells(x, true) should == {
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
      Reflector other:cells(x, true) should == {
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

  describe("other:cellOwner",
    it("should return the closest owner of a cell",
      x = Origin mimic
      y = x mimic

      x foo = 123
      y foo = "bar"

      Reflector other:cellOwner(x, :foo) should be same(x)
      Reflector other:cellOwner(y, :foo) should be same(y)
      Reflector other:cellOwner(x mimic, :foo) should be same(x)
    )

    it("should signal a condition if there is no such cell",
      fn(Reflector other:cellOwner(Origin, :test_cell_owner)) should signal(Condition Error NoSuchCell)
    )

    it("should offer an ignore restart if the cell can't be found",
      fn(Reflector other:cellOwner(Origin, :test_cell_owner)) should offer(restart(ignore, fn))
      fn(Reflector other:cellOwner(Origin, :test_cell_owner)) should returnFromRestart(:ignore) == nil
    )
  )

  describe("other:cellOwner?",
    it("should return true if the cell name is owned by this object",
      x = Origin mimic
      y = x mimic

      x foo = 123
      y foo = "bar"

      Reflector other:cellOwner?(x, :foo) should be true
      Reflector other:cellOwner?(y, :foo) should be true
    )

    it("should return false if the cell name is owned by another object",
      x = Origin mimic
      y = x mimic

      x foo = 123

      Reflector other:cellOwner?(y, :foo) should be false
    )

    it("should signal a condition if there is no such cell",
      fn(Reflector other:cellOwner?(Origin, :test_cell_owner)) should signal(Condition Error NoSuchCell)
    )

    it("should offer an ignore restart if the cell can't be found",
      fn(Reflector other:cellOwner?(Origin, :test_cell_owner)) should offer(restart(ignore, fn))
      fn(Reflector other:cellOwner?(Origin, :test_cell_owner)) should returnFromRestart(:ignore) == false
    )
  )

  describe("other:removeCell!",
    it("should remove the cell",
      x = Origin mimic
      x flurgus_cell_test = 123
      Reflector other:removeCell!(x, :flurgus_cell_test)
      x cell?(:flurgus_cell_test) should be false
    )

    it("should signal a condition if no such cell exists",
      fn(Reflector other:removeCell!(Origin mimic, :foo)) should signal(Condition Error NoSuchCell)
    )

    it("should offer an ignore restart if the cell can't be found",
      x = Origin mimic
      fn(Reflector other:removeCell!(x, :foo)) should offer(restart(ignore, fn))
      fn(Reflector other:removeCell!(x, :foo)) should returnFromRestart(:ignore) == x
    )

    it("should only remove a cell on the current object",
      x = Origin mimic
      y = x mimic
    
      x foo = "blurg"
      y foo = "blarg"

      Reflector other:removeCell!(y, :foo)
      y cell?(:foo) should be true
      y foo should == "blurg"
    )
  )

  describe("other:undefineCell!",
    it("should remove the cell",
      x = Origin mimic
      x flurgus_cell_test = 123
      Reflector other:undefineCell!(x, :flurgus_cell_test)
      x cell?(:flurgus_cell_test) should be false
    )

    it("should not signal a condition if no such cell exists",
      Reflector other:undefineCell!(Origin mimic, :test_undefine_cell)
    )

    it("should stop the cell from showing up in cellNames",
      x = Origin mimic
      y = x mimic
    
      x foo = "blurg"
      y foo = "blarg"

      Reflector other:undefineCell!(y, :foo)

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

      Reflector other:undefineCell!(y, :foo)

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

      Reflector other:undefineCell!(y, :foo)
      
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

      Reflector other:undefineCell!(y, :foo)
      fn(y cellOwner(:foo)) should signal(Condition Error NoSuchCell)
    )

    it("should stop the cell from showing up with cellOwner?",
      x = Origin mimic
      y = x mimic
    
      x foo = "blurg"
      y foo = "blarg"

      Reflector other:undefineCell!(y, :foo)
      fn(y cellOwner?(:foo)) should signal(Condition Error NoSuchCell)
    )

    it("should be possible to remove the undefine with removeCell!",
      x = Origin mimic
      y = x mimic
    
      x foo = "blurg"
      y foo = "blarg"

      Reflector other:undefineCell!(y, :foo)
      y removeCell!(:foo)
      y foo should == "blurg"
    )
  )
)
