nsieve = method(n,
  primes = (0..n) collect(true)
  count = 0
  
  (2...n) each(i,
    if(primes[i],
      k = 2 * i
      while (k < n,
        primes[k] = false
        k = k + i
      )
      count++
    )
  )
  "Primes up to #{n}: #{count}" println
)

System ifMain(
  if(System programArguments size != 1,
    error!("usage: nsieve.ik <exponent>")
    return
  )
  
  exponent = Message doText(System programArguments first)
  (0..exponent) sortBy(n, -n) each(n,
    nsieve((2 ** n) * 10000)
  )
)
