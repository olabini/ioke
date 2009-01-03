
use("ispec")

describe(DefaultBehavior,
  describe("Definitions",
    describe("dmacro",
      it("should pass on a possible documentation string",
        foo = dmacro(
          "docstring42",

          [a] a code)

        cell(:foo) documentation should == "docstring42"
      )

      it("should destructure a simple argument list",
        foo = dmacro(
          [a] a code)

        foo(abc foo bar) should == "abc foo bar"
        foo(10*20) should == "10 *(20)"
      )

      it("should destructure two argument lists correctly",
        foo = dmacro(
          [a] a code,
          [a, b] [a code, b code])

        foo(abc foo) should == "abc foo"
        foo(abc foo, bar blux) should == ["abc foo", "bar blux"]
      )

      it("should destructure an empty list",
        foo = dmacro(
          [] 42)

        foo should == 42
      )

      it("should destructure with default value",
        foo = dmacro(
          [x 2+2] x)

        foo code should == "2 +(2)"
        foo(blarg foo) code should == "blarg foo"

        foo = dmacro(
          [x 2+2] x,
          [y 3+3, z 4+4, q 111] [y code, z code, q code]
          )

        foo code should == "2 +(2)"
        foo(blarg foo) code should == "blarg foo"
        foo(blarg foo, murg fox) should == ["blarg foo", "murg fox", "111"]
        foo(blarg foo, murg fox, 123) should == ["blarg foo", "murg fox", "123"]
      )

      it("should destructure an evaluated part with default value",
        foo = dmacro(
          [>x 2+2] x)

        foo should == 4
        foo(13) should == 13

        foo = dmacro(
          [x, y, z] x,
          [>x 2+2, >y x+13] [x,y]
        )

        foo should == [4, 17]
        foo(12) should == [12, 25]
        foo(12, 44) should == [12, 44]
      )

      it("should destructure and evaluate part of destructuring")
      it("should destructure a rest argument correctly")
      it("should destructure an evaluated rest argument correctly")
      it("should generate a too few arguments error if that should be done")
      it("should generate a too many arguments error if that is appropriate")
    )
  )
)
