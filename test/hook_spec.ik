
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

  describe("hook!",
    it("should add a new observed object to the receiver",
      xx = Origin mimic
      yy = Hook into(xx)
      zz = Origin mimic
      yy hook!(zz)
      yy connectedObjects[1] should be(zz)
    )
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
      yy cellRemoved = method(_, _, _, @invoked++)
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
      yy cellRemoved = method(_, _, _, should have doneCellChanged)
      xx removeCell!(:val)
    )

    it("should be called after the cell has been removed",
      xx = Origin mimic
      xx one = 42
      yy = Hook into(xx)
      yy cellRemoved = fnx(_, _, _, xx cell?(:one) should be false)
      xx removeCell!(:one)
    )

    it("should yield the object the cell belonged on",
      xx = Origin mimic
      xx one = 42
      yy = Hook into(xx)
      yy cellRemoved = fnx(obj, _, _, obj should be(xx))
      xx removeCell!(:one)
    )

    it("should yield the name of the cell",
      xx = Origin mimic
      xx one = 42
      yy = Hook into(xx)
      yy cellRemoved = fnx(_, sym, _, sym should == :one)
      xx removeCell!(:one)
    )

    it("should yield the previous value of the cell",
      xx = Origin mimic
      xx one = 42
      yy = Hook into(xx)
      yy cellRemoved = fnx(_, _, prev, prev should == 42)
      xx removeCell!(:one)
    )
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
    it("should be called on the hook when a cell is removed on the observed object",
      xx = Origin mimic
      xx val = "foo"
      xx vax = "fox"
      yy = Hook into(xx)
      yy invoked = 0
      yy cellUndefined = method(_, _, _, @invoked++)
      xx undefineCell!(:val)
      yy invoked should == 1
      xx undefineCell!(:vax)
      yy invoked should == 2
    )

    it("should be called after cellChanged",
      xx = Origin mimic
      xx val = "foo"
      yy = Hook into(xx)
      yy doneCellChanged? = false
      yy cellChanged = method(_, _, _, @doneCellChanged? = true)
      yy cellUndefined = method(_, _, _, should have doneCellChanged)
      xx undefineCell!(:val)
    )

    it("should be called after the cell has been undefined",
      xx = Origin mimic
      xx one = 42
      yy = Hook into(xx)
      yy cellUndefined = fnx(_, _, _, xx cell?(:one) should be false)
      xx undefineCell!(:one)
    )

    it("should yield the object the cell belonged on",
      xx = Origin mimic
      xx one = 42
      yy = Hook into(xx)
      yy cellUndefined = fnx(obj, _, _, obj should be(xx))
      xx undefineCell!(:one)
    )

    it("should yield the name of the cell",
      xx = Origin mimic
      xx one = 42
      yy = Hook into(xx)
      yy cellUndefined = fnx(_, sym, _, sym should == :one)
      xx undefineCell!(:one)
    )

    it("should yield the previous value of the cell",
      xx = Origin mimic
      xx one = 42
      yy = Hook into(xx)
      yy cellUndefined = fnx(_, _, prev, prev should == 42)
      xx undefineCell!(:one)
    )
  )

  describe("mimicAdded",
    it("should call the hook when a mimic gets added",
      xx = Origin mimic
      yy = Hook into(xx)
      blah = Origin mimic
      blah2 = Origin mimic
      yy invoked = 0
      yy mimicAdded = method(_, _, @invoked++)
      xx mimic!(blah)
      yy invoked should == 1
      xx mimic!(blah2)
      yy invoked should == 2
    )

    it("should yield the object the mimic was added to",
      xx = Origin mimic
      yy = Hook into(xx)
      blah = Origin mimic
      yy mimicAdded = fnx(obj, _, obj should be(xx))
      xx mimic!(blah)
    )

    it("should yield the mimic added",
      xx = Origin mimic
      yy = Hook into(xx)
      blah = Origin mimic
      yy mimicAdded = fnx(_, m, m should be(blah))
      xx mimic!(blah)
    )

    it("should work correctly when using prependMimic!",
      xx = Origin mimic
      yy = Hook into(xx)
      blah = Origin mimic
      blah2 = Origin mimic
      yy invoked = 0
      yy mimicAdded = method(_, _, @invoked++)
      xx prependMimic!(blah)
      yy invoked should == 1
      xx prependMimic!(blah2)
      yy invoked should == 2
    )

    it("should fire after the mimic has been added",
      xx = Origin mimic
      yy = Hook into(xx)
      blah = Origin mimic
      yy mimicAdded = fnx(_, _, xx should mimic(blah))
      xx mimic!(blah)
    )
  )

  describe("mimicRemoved",
    it("should fire after a mimic has been removed",
      Bex = Origin mimic
      xx = Bex mimic
      xx mimic!(Origin)
      yy = Hook into(xx)
      yy invoked = 0
      yy mimicRemoved = method(_, _, @invoked++)
      xx removeMimic!(Bex)
      yy invoked should == 1
    )

    it("should fire after the mimic has been removed",
      xx = Origin mimic
      blah = Origin mimic
      xx mimic!(blah)
      yy = Hook into(xx)
      yy mimicRemoved = fnx(_, _, xx should not mimic(blah))
      xx removeMimic!(blah)
    )

    it("should fire once for every mimic removed when you are removing more than one mimic",
      xx = Origin mimic
      blah = Origin mimic
      foox = Origin mimic
      xx mimic!(blah)
      xx mimic!(foox)
      yy = Hook into(xx)
      yy invoked = 0
      yy mimicRemoved = method(_, _, @invoked++)
      xx removeAllMimics!
      yy invoked should == 3
    )

    it("should yield the object the event happened on",
      Bex = Origin mimic
      xx = Bex mimic
      xx mimic!(Origin)
      yy = Hook into(xx)
      yy mimicRemoved = fnx(obj, _, obj should be(xx))
      xx removeMimic!(Bex)
    )

    it("should yield the mimic that was removed",
      Bex = Origin mimic
      xx = Bex mimic
      xx mimic!(Origin)
      yy = Hook into(xx)
      yy mimicRemoved = fnx(_, mm, mm should be(Bex))
      xx removeMimic!(Bex)
    )
  )

  describe("mimicsChanged",
    it("should fire when a mimic is added",
      xx = Origin mimic
      yy = Hook into(xx)
      blah = Origin mimic
      blah2 = Origin mimic
      yy invoked = 0
      yy mimicsChanged = method(@invoked++)
      xx mimic!(blah)
      yy invoked should == 1
      xx mimic!(blah2)
      yy invoked should == 2
    )

    it("should fire after the mimic is added")
    it("should fire when a mimic is prepend added")
    it("should fire after the mimic is prepend added")
    it("should fire when a mimic is removed")
    it("should fire after the mimic is removed")
    it("should fire when a mimic is removed when all mimics are removed")
    it("should fire after the mimic is removed with removeAllMimics!")
    it("should yield the object that the change was made on")
    it("should yield the mimic that was removed or added")
    it("should fire after the mimic is added")
    it("should fire after the mimic is prepend added")
    it("should fire after the mimic is removed")
    it("should fire after the mimic is removed with removeAllMimics!")
  )

  describe("mimicked",
    it("should have tests")
  )
)
