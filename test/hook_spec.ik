
use("ispec")

describe(Hook,
  it("should have the correct kind",
    Hook should have kind("Hook")
  )

  describe("connectedObjects",
    it("should return the connected objects for that hook",
      x = Origin mimic
      y = Origin mimic
      z = Origin mimic

      Hook into(x) connectedObjects[0] should be(x)
      Hook into(x, y) connectedObjects[0] should be(x)
      Hook into(x, y) connectedObjects[1] should be(y)
      Hook into(x, y, z) connectedObjects[0] should be(x)
      Hook into(x, y, z) connectedObjects[1] should be(y)
      Hook into(x, y, z) connectedObjects[2] should be(z)

      Hook into(x, y, z) connectedObjects length should == 3
    )
  )

  describe("into",
    it("should return a new hook object",
      xx = Origin mimic
      yy = Hook into(xx)
      yy should mimic(Hook)
      yy should not be(Hook)
    )

    it("should take one or more arguments",
      Hook into(Origin mimic)
      Hook into(Origin mimic, Origin mimic)
      Hook into(Origin mimic, Origin mimic, Origin mimic)
      Hook into(Origin mimic, Origin mimic, Origin mimic, Origin mimic)
      Hook into(Origin mimic, Origin mimic, Origin mimic, Origin mimic, Origin mimic)

      fn(Hook into()) should signal(Condition Error Invocation TooFewArguments)
    )
  )

  describe("into!",
    it("should add itself to the mimic chain of the first argument and bind it to the second object")
  )

  describe("hook!",
    it("should add a new observed object to the receiver")
  )

  describe("cellAdded",
    it("should be called on the hook when a cell is added on the observed object",
      xx = Origin mimic
      yy = Hook into(xx)
      yy invoked = 0
      yy cellAdded = method(obj, _,  @invoked++)
      xx bar = "hello"
      yy invoked should == 1
      xx flux = method(nil)
      yy invoked should == 2
    )

    it("should be called after the cell has been added",
      xx = Origin mimic
      yy = Hook into(xx)
      yy cellAdded = fnx(obj, _,
        xx fox should == "blarg"
      )
      xx fox = "blarg"
    )

    it("should give the object that has been updated",
      xx = Origin mimic
      yy = Hook into(xx)
      yy cellAdded = fnx(obj, _,
        obj should be(xx)
      )
      xx fox = "blarg"
    )

    it("should give the name of the added cell to the hook as an argument",
      xx = Origin mimic
      yy = Hook into(xx)
      yy cellAdded = fnx(obj, sym,
        sym should == :fox
      )
      xx fox = "blarg"
    )

    it("should fire on more than one hook if available",
      xx = Origin mimic
      yy = Origin mimic
      zz = Hook into(xx, yy)
      zz invoked = 0
      zz cellAdded = method(_, _,
        @invoked++
      )
      xx blah = "arg"
      yy foo = "ax"
      yy muuh = "wow"
      zz invoked should == 3
    )

    it("should not fire when a cell is updated",
      xx = Origin mimic
      yy = Hook into(xx)
      xx blarg = "hello"
      yy invoked = 0
      yy cellAdded = method(obj, _,  @invoked++)
      xx blarg = "goodbye"
      yy invoked should == 0
    )
  )

  describe("cellRemoved",
    it("should be called on the hook when a cell is removed on the observed object",
      xx = Origin mimic
      xx val = "foo"
      xx vax = "fox"
      yy = Hook into(xx)
      yy invoked = 0
      yy cellRemoved = method(_, _, @invoked++)
      xx removeCell!(:val)
      yy invoked should == 1
      xx removeCell!(:vax)
      yy invoked should == 2
    )

    it("should be called after cellChanged",
      xx = Origin mimic
      xx val = "foo"
      yy = Hook into(xx)
      yy doneCellChanged? = false
      yy cellChanged = method(_, _, _, @doneCellChanged? = true)
      yy cellRemoved = method(_, _, should have doneCellChanged)
      xx removeCell!(:val)
    )

    it("should be called after the cell has been removed",
      xx = Origin mimic
      xx one = 42
      yy = Hook into(xx)
      yy cellRemoved = fnx(_, _, xx cell?(:one) should be false)
      xx removeCell!(:one)
    )

    it("should yield the object the cell belonged on",
      xx = Origin mimic
      xx one = 42
      yy = Hook into(xx)
      yy cellRemoved = fnx(obj, _, obj should be(xx))
      xx removeCell!(:one)
    )

    it("should yield the name of the cell",
      xx = Origin mimic
      xx one = 42
      yy = Hook into(xx)
      yy cellRemoved = fnx(_, sym, sym should == :one)
      xx removeCell!(:one)
    )

    it("should yield the previous value of the cell")
  )

  describe("cellChanged",
    it("should be called on the hook when a cell is added on the observed object",
      xx = Origin mimic
      yy = Hook into(xx)
      yy invoked = 0
      yy cellChanged = method(_, _, _, @invoked++)
      xx bar = "hello"
      yy invoked should == 1
      xx flux = method(nil)
      yy invoked should == 2
    )

    it("should yield nil as the previous value when adding a cell",
      xx = Origin mimic
      yy = Hook into(xx)
      yy cellChanged = method(_, _, prev, prev should be nil)
      xx bar = "hello"
      xx flux = method(nil)
    )

    it("should be called on the hook when a cell is removed on the observed object",
      xx = Origin mimic
      xx one = 42
      xx two = 43
      yy = Hook into(xx)
      yy invoked = 0
      yy cellChanged = method(_, _, _, @invoked++)
      xx removeCell!(:one)
      yy invoked should == 1
      xx removeCell!(:two)
      yy invoked should == 2
    )

    it("should be called after the cell has been removed",
      xx = Origin mimic
      xx one = 42
      yy = Hook into(xx)
      yy cellChanged = fnx(_, _, _, xx cell?(:one) should be false)
      xx removeCell!(:one)
    )

    it("should yield the original value of the cell when removing",
      xx = Origin mimic
      xx val = "foxy"
      yy = Hook into(xx)
      yy cellChanged = fnx(_, _, orig, orig should == "foxy")
      xx removeCell!(:val)
    )

    it("should be called on the hook when a cell is undefined on the observed object",
      xx = Origin mimic
      xx one = 42
      xx two = 43
      yy = Hook into(xx)
      yy invoked = 0
      yy cellChanged = method(_, _, _, @invoked++)
      xx undefineCell!(:one)
      yy invoked should == 1
      xx undefineCell!(:two)
      yy invoked should == 2
    )

    it("should be called after the cell has been undefined",
      xx = Origin mimic
      xx one = 42
      yy = Hook into(xx)
      yy cellChanged = fnx(_, _, _, xx cell?(:one) should be false)
      xx undefineCell!(:one)
    )

    it("should yield the original value of the cell when undefined",
      xx = Origin mimic
      xx val = "foxy"
      yy = Hook into(xx)
      yy cellChanged = fnx(_, _, orig, orig should == "foxy")
      xx undefineCell!(:val)
    )

    it("should be called on the hook when a cell is changed on the observed object",
      xx = Origin mimic
      xx val = "foxy"
      yy = Hook into(xx)
      yy invoked = 0
      yy cellChanged = method(_, _, _, @invoked++)
      xx val = "blaxy"
      yy invoked should == 1
      xx val = "no way"
      yy invoked should == 2
    )

    it("should be called after the change",
      xx = Origin mimic
      xx val = "foxy"
      yy = Hook into(xx)
      yy cellChanged = fnx(_, _, _, xx val should == "more")
      xx val = "more"
    )

    it("should yield the object the change happened on",
      xx = Origin mimic
      xx val = "foxy"
      yy = Hook into(xx)
      yy cellChanged = fnx(obj, _, _, obj should be(xx))
      xx val = "more"
    )

    it("should yield the name of the cell",
      xx = Origin mimic
      xx val = "foxy"
      yy = Hook into(xx)
      yy cellChanged = fnx(_, sym, _, sym should == :val)
      xx val = "more"
    )

    it("should yield the original value of the cell",
      xx = Origin mimic
      xx val = "foxy"
      yy = Hook into(xx)
      yy cellChanged = fnx(_, _, orig, orig should == "foxy")
      xx val = "more"
    )

    it("should fire on more than one hook if available",
      xx = Origin mimic
      yy = Origin mimic
      zz = Hook into(xx, yy)
      zz invoked = 0
      zz cellChanged = method(_, _, _,
        @invoked++
      )
      xx blah = "arg"
      yy foo = "ax"
      yy muuh = "wow"
      xx blah = "no way"
      zz invoked should == 4
    )
  )

  describe("cellUndefined",
    it("should have tests")
  )

  describe("mimicked",
    it("should have tests")
  )

  describe("mimicAdded",
    it("should have tests")
  )

  describe("mimicRemoved",
    it("should have tests")
  )

  describe("mimicsChanged",
    it("should have tests")
  )
)
