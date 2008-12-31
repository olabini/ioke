
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

      it("should be possible to do midlevel assignment",
        for(x <- 1..20, y = x*2, y<10, [x,y]) should == [[1,2],[2,4],[3,6],[4,8]]
      )

      it("should be possible to combine these parts into a larger comprehension",
        for(x <- 0..10, x*x > 3, 2*x) should == [4, 6, 8, 10, 12, 14, 16, 18, 20]
        for(x <- 1..6, y <- x..6, z <- y..6, (x**2 + y**2) == z**2, [x,y,z]) should == [[3,4,5]]
      )
    )

    describe("for:set",
      it("should handle a simple iteration",
        for:set(x <- [1,2,3], x) should == set(1,2,3)
        for:set(x <- [1,2,3,1,2,3], x) should == set(1,2,3)
        for:set(x <- 1..10, x) should == set(1,2,3,4,5,6,7,8,9,10)
        for:set(x <- set(:a, :b, :c), x) should == set(:a, :b, :c)
      )

      it("should be possible to do something advanced in the output part",
        for:set(x <- 1..10, x*2) should == set(2,4,6,8,10,12,14,16,18,20)

        mex = method(f, f+f+f)
        for:set(x <- 1...5, mex(x)) should == set(3, 6, 9, 12)
      )

      it("should be possible to combine two or more iterations",
        for:set(x <- [1,2,3], y <- [15,16,17], [x,y]) should == set([1,15],[1,16],[1,17],[2,15],[2,16],[2,17],[3,15],[3,16],[3,17])
      )

      it("should be possible to filter output",
        for:set(x <- 1..100, x<5, x) should == set(1,2,3,4)

        for:set(x <- 1..10, (x%2) == 0, x) should == set(2,4,6,8,10)
      )

      it("should be possible to do midlevel assignment",
        for:set(x <- 1..20, y = x*2, y<10, [x,y]) should == set([1,2],[2,4],[3,6],[4,8])
      )

      it("should be possible to combine these parts into a larger comprehension",
        for:set(x <- 0..10, x*x > 3, 2*x) should == set(4, 6, 8, 10, 12, 14, 16, 18, 20)
        for:set(x <- 1..6, y <- x..6, z <- y..6, (x**2 + y**2) == z**2, [x,y,z]) should == set([3,4,5])
      )
    )

    describe("for:dict",
      it("should handle a simple iteration",
        for:dict(x <- [1,2,3], x => x*x) should == dict(1=>1,2=>4,3=>9)
        for:dict(x <- [1,2,3,1,2,3], x => x*x) should == dict(1=>1,2=>4,3=>9)
        for:dict(x <- 1..10, x) should == dict(1=>nil,2=>nil,3=>nil,4=>nil,5=>nil,6=>nil,7=>nil,8=>nil,9=>nil,10=>nil)
        for:dict(x <- set(:a, :b, :c), x => x asText) should == dict(a: "a", b: "b", c: "c")
      )

      it("should handle more than one generator",
        for:dict(x <- [1,2,3], y <- [10,11,12], x*y => [x,y]) should == {10=>[1,10], 11=>[1,11], 12=>[1,12], 20=>[2,10], 22=>[2,11], 24=>[2,12], 30=>[3,10], 33=>[3,11], 36=>[3,12]}
      )
    )
  )
)
