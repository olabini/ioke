H = method(n, f, u, t,
  if(n < 2,
    "#{f} --> #{t}" println,

    H(n - 1, f, t, u)
    "#{f} --> #{t}" println
    H(n - 1, u, f, t)
  )
)

hanoi = method(n,
  H(n, 1, 2, 3)
)

System ifMain(
  if(System programArguments size == 1,
    hanoi(System programArguments first toRational),

    "usage: hanoi n, where 0 < n <= 10" println
  )
)
