
use("ispec")

describe(Message,
  describe("rewrite",
    it("should rewrite a very simple message chain",
      msg = 'foo

      output = msg rewrite(
        '(:x) => '(something(:x))
      )

      msg should == 'foo

      output should == 'something(foo)
    )

    it("should rewrite a next into an argument",
      msg = '(foo bar)

      output = msg rewrite(
        '(:x :y) => '(:x(:y)))

      output should == 'foo(bar)
    )

    it("should rewrite an argument into a next",
      msg = 'foo(bar)

      output = msg rewrite(
        '(:x(:y)) => '(:x :y))

      output should == '(foo bar)
    )
  )
)
