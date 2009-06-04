recursiveFib = method(n,
  if((0..1) include?(n), 
    n,
    recursiveFib(n - 1) + recursiveFib(n - 2)
  )
)

iterativeFib = method(n,
  curr = 0
  succ = 1
  (0...n) each(i,
    old = curr
    curr = succ
    succ += old
  )
  curr
)

generativeFib = method(
  curr = 0
  succ = 1
  fn(
    old = curr
    curr = succ
    succ += old
    old
  )
)

System ifMain(
  if(System programArguments size != 1,
    error!("usage: fibonacci.ik <iterations>")
  )

  iterations = System programArguments first toRational

  "Recursive: #{(0..iterations) map(n, recursiveFib(n))}" println
  "Iterative: #{(0..iterations) map(n, iterativeFib(n))}" println

  fib = generativeFib
  "Generator: #{(0..iterations) map(n, fib call)}" println
)
