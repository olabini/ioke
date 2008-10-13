# count = 0
fib = method(n,
#  Ground count = count + 1
  if(n < 2,
    n,
    fib(n - 1) + 
    fib(n - 2)))

System ifMain(fib(30) println)
#count println
