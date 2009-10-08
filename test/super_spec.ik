
use("ispec")

describe(DefaultBehavior,
  describe("super",
    it("should not be available if no super method is there",
      fn(method(super) call) should signal(Condition Error NoSuchCell)
    )

    it("should return the super value if it is not method",
      x = Origin mimic
      x foo = 42
      x2 = x mimic
      x2 foo = method(super)
      x2 foo should == 42
    )

    it("should call the super method with the same self",
      x = Origin mimic
      x foo = method([self])
      x2 = x mimic
      x2 foo = method(super)
      x2 foo should == [x2]
    )

    it("should be possible to give different arguments to super",
      x = Origin mimic
      x foo = method(+args, args)
      x2 = x mimic
      x2 foo = method(super(1,2,3))
      x2 foo should == [1, 2, 3]
    )

    it("should be possible to call super several times in a row",
      Ground called_super_spec = []
      x = Origin mimic
      x foo = method(called_super_spec << "foo1")
      x2 = x mimic
      x2 foo = method(called_super_spec << "foo2". super)
      x3 = x2 mimic
      x3 foo = method(called_super_spec << "foo3". super)
      x3 foo
      called_super_spec should == ["foo3", "foo2", "foo1"]
    )
  )
)
