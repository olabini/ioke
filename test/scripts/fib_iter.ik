fib = method(n,
  i = 0
  j = cur = 1
  while(cur <= n,
    k = i
    i = j
    j = k + j
    cur ++)
  i)

System ifMain(fib(300000) println)
