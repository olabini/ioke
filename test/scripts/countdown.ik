count = method(n,
  if(n < 1,
    n,
    count(n-1)+n))

System ifMain(count(500) println)

