
use("ispec")

describe(DefaultBehavior,
  describe("FlowControl",
    describe("for",
      it("should handle a simple iteration",
        for(x <- [1,2,3], x) should == [1,2,3]
        for(x <- 1..10, x) should == [1,2,3,4,5,6,7,8,9,10]
        for(x <- set(:a, :b, :c), x) sort should == [:a, :b, :c]
      )

      it("should be possible to do something advanced in the output part",
        for(x <- 1..10, x*2) should == [2,4,6,8,10,12,14,16,18,20]

        mex = method(f, f+f+f)
        for(x <- 1...5, mex(x)) should == [3, 6, 9, 12]
      )

      it("should be possible to combine two iterations")
      it("should be possible to filter output by using 'if'")
      it("should be possible to do midlevel assignment")
      it("should be possble to combine these parts into a larger comprehension")
    )
  )
)
