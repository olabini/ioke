
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
  )

  describe("cellRemoved",
    it("should have tests")
  )

  describe("cellChanged",
    it("should be called on the hook when a cell is added on the observed object")
    it("should be called on the hook when a cell is removed on the observed object")
    it("should be called on the hook when a cell is undefined on the observed object")
    it("should be called after the change")
    it("should yield the object the change happened on")
    it("should yield the name of the cell")
    it("should yield the original value of the cell")
    it("should fire on more than one hook if available")
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
