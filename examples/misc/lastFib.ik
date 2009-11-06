FibSequence = Sequence with(
  initialize: method(
    @index = 0
    @last1 = 1
    @last2 = 1
  ),

  next?: true,
  next: method(
    result = case(@index,
      0, 1,
      1, 1,
      else, @last1 + @last2)

    @index++
    @last1 = @last2
    @last2 = result

    result
  )
)

fib = method("Returns a sequence that generates all the fibonacci numbers",
  FibSequence mimic
)

fib2 = method(
  fn(a, b, [b, a + b]) iterate(0, 1) mapped(first)
)

; find the index of the first fibonacci number larger than a thousand
(fib indexed(from: 1) takeWhile(second < 1000) last first + 1) println
fib indexed(from: 1) droppedWhile(second < 1000) first first println
