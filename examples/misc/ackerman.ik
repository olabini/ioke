ack = method(m, n, 
  if (m < 1, return n + 1) 
  if (n < 1, return ack(m - 1, 1)) 
  return ack(m - 1, ack(m, n - 1)) 
) 

System ifMain(
  ack(3, 4) println
)
