
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

    it("should be possible to grab more than one thing using the :all: pattern",
      msg = '(foo bar bax quux blax)

      output = msg rewrite(
        '(:x :all(2,:y)) => '(:x(:y)))

      output should == '(foo(bar bax) quux blax)
    )

    it("should be possible to grab the rest using the :all: pattern",
      msg = '(foo bar bax quux)

      output = msg rewrite(
        '(:x :all(:y)) => '(:x(:y)))

      output should == '(foo(bar bax quux))
    )

    it("should be possible to grab only up to the terminator with the rest pattern",
      msg = '(foo bar bax quux. fluxie blarb)

      output = msg rewrite(
        '(foo :all(:y)) => '(foo(:y)))

      output should == '(foo(bar bax quux). fluxie blarb)
    )

    it("should be possible to grab up to a point with until",
      msg = '(foo bar bax quux)

      output = msg rewrite(
        '(:x :until(bax, :y)) => '(:x(:y)))

      output should == '(foo(bar bax) quux)
    )

    it("should handle calls to internal: as if it was a non-argument thing",
      msg = '(foo(1))

      output = msg rewrite(
        '(:x(:y)) => '(:x bar(:y)))

      output should == '(foo bar(1))

      msg = '(foo("flux"))

      output = msg rewrite(
        '(:x(:y)) => '(:x bar(:y)))

      output should == '(foo bar("flux"))
    )

    it("should be possible to unify on specific literals")
    it("should be possible to insert a new literal")
    it("should be possible to specify unmatched names with :not")
    it("should be possible to unify on the unmatched name")
  )
)
