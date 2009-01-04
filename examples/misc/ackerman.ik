ack = method(m, n, 
  cond(
    m < 1, n + 1,
    n < 1, ack(m - 1, 1),
    ack(m - 1, ack(m, n - 1))))

System ifMain(
  ack(3, 4) println
)
