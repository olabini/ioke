fib = method(n,
  if(n < 2,
    n,
    fib(n - 1) +
    fib(n - 2)))

System ifMain(fib(30) println)
