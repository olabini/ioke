
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

      it("should be possible to combine two or more iterations",
        for(x <- [1,2,3], y <- [15,16,17], [x,y]) should == [[1,15],[1,16],[1,17],[2,15],[2,16],[2,17],[3,15],[3,16],[3,17]]
      )

      it("should be possible to filter output",
        for(x <- 1..100, x<5, x) should == [1,2,3,4]

        for(x <- 1..10, (x%2) == 0, x) should == [2,4,6,8,10]
      )

      it("should be possible to do midlevel assignment")
      it("should be possble to combine these parts into a larger comprehension")
    )
  )
)
