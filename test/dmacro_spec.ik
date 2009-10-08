
use("ispec")

describe(DefaultBehavior,
  describe("Definitions",
    describe("dlecro",
      it("should return a LexicalMacro that is activatable",
        foo = dlecro(
          [] nil)

        cell(:foo) kind should == "LexicalMacro"
        cell(:foo) activatable should be true
      )

      it("should pass on a possible documentation string",
        foo = dlecro(
          "docstring42",

          [a] a code)

        cell(:foo) documentation should == "docstring42"
      )

      it("should destructure a simple argument list",
        foo = dlecro(
          [a] a code)

        foo(abc foo bar) should == "abc foo bar"
        foo(10*20) should == "10 *(20)"
      )
    )

    describe("dlecrox",
      it("should return a LexicalMacro that is not activatable",
        foo = dlecrox(
          [] nil)

        cell(:foo) kind should == "LexicalMacro"
        cell(:foo) activatable should be false
      )

      it("should pass on a possible documentation string",
        foo = dlecrox(
          "docstring42",

          [a] a code)

        cell(:foo) documentation should == "docstring42"
      )

      it("should destructure a simple argument list",
        foo = dlecrox(
          [a] a code)

        foo call(abc foo bar) should == "abc foo bar"
        foo call(10*20) should == "10 *(20)"
      )
    )

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

      it("should destructure and evaluate part of destructuring",
        foo = dmacro(
          [x, >y, z] [x code, y, z code])

        foo(abc foo, 42+17, murgicox) should == ["abc foo", 59, "murgicox"]
      )

      it("should destructure a rest argument correctly",
        foo = dmacro(
          [+rest] rest map(code))

        foo should == []
        foo(aha) should == ["aha"]
        foo(abc foo, 42+17, murgicox) should == ["abc foo", "42 +(17)", "murgicox"]

        foo = dmacro(
          [one, two] nil,
          [one, two, +rest] rest map(code)
        )

        foo(abc foo, 42+17, murgicox) should == ["murgicox"]
      )

      it("should destructure an evaluated rest argument correctly",
        foo = dmacro(
          [+>rest] rest)

        foo should == []
        foo("str") should == ["str"]
        xx = 42
        foo(2**3, 42+17, xx) should == [8, 59, 42]

        foo = dmacro(
          [one, two] nil,
          [one, two, +>rest] rest
        )

        foo(abc foo, murgicox, 42+17) should == [59]
      )

      it("should generate an error if not matching could happen",
        foo = dmacro(
          [] nil)

        fn(foo(1)) should signal(Condition Error Invocation NoMatch)
      )

      it("should handle some extra newlines",
        foo = dmacro(
          [one]

          :one,

          [two, three]

          :two)

        foo(1) should == :one
        foo(1,2) should == :two
      )
    )
  )
)
