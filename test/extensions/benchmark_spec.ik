
use("ispec")
use("benchmark")

collectOutput = macro(
  oldOut = System out
  newOut = Origin mimic
  newOut collected = ""
  newOut print = method(arg,
    @collected += arg)
  newOut println = method(arg,
    @collected += arg + "\n")
  
  System out = newOut

  call argAt(0)
  
  result = newOut collected
  System out = oldOut
  result)

describe("Extensions",
  describe("Benchmark",
    describe("report",
      it("should execute code 10x1 times by default", 
        
        iterations = 0
        collectOutput(Benchmark report(iterations++))
        iterations should == 10
      )
    
      it("should report the code used for benchmarking", 
        iterations = 0
        collectOutput(Benchmark report(iterations++))

        ;; output each line should match #/^\+\+\(iterations\) +0\./
      )

      it("should be possible to customize the amount of benchmarking rounds", 
        iterations = 0
        collectOutput(Benchmark report(5, iterations++))
        iterations should == 5
      )
      it("should be possible to customize the iterations for each benchmarking round", 
        iterations = 0
        collectOutput(Benchmark report(2, 3, iterations++))
        iterations should == 6
      )
    )
  )
)
