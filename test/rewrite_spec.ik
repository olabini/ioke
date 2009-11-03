
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

    it("should duplicate something if needed",
      msg = 'foo(bar)

      output = msg rewrite(
        '(:x(:y)) => '(:x :y :y))

      output should == '(foo bar bar)
    )

    it("should ignore pieces before it can't do anything with",
      msg = '(bux(blarg) foo bar)

      output = msg rewrite(
        '(:x :y) => '(:x(:y)))

      output should == '(bux(blarg) foo(bar))
    )

    it("should ignore pieces after it can't do anything with",
      msg = '(foo bar bux(blarg))

      output = msg rewrite(
        '(:x :y) => '(:x(:y)))

      output should == '(foo(bar) bux(blarg))
    )

    it("should apply the same pattern at more than one place",
      msg = '(foo(bar) qux(bar) blarg foo(muxie))

      output = msg rewrite(
        '(:x(:y)) => '(:x :y))

      output should == '(foo bar qux bar blarg foo muxie)
    )


    it("should match a fixed thing on the left hand side",
      msg = '(foo(bar) blux(barg))

      output = msg rewrite(
        '(foo(:y)) => '(foo :y))

      output should == '(foo bar blux(barg))
    )

    it("should apply two patterns in a row, just as if you had called them each by its own",
      msg = '(foo(bar) bar(bax))
      msg rewrite(
        '(:x(:y)) => '(:x :y),
        '(:q :p) => '(:p :q :q)
        ) should == msg rewrite('(:x(:y)) => '(:x :y)) rewrite('(:q :p) => '(:p :q :q))
    )
  )
)
