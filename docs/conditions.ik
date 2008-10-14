
bindHandler(
  noSuchCell: fn(c, c asText println),
  incorrectArity: fn(c, c asText println),
  # code that might cause the above conditions
)


bindHandler(
  somethingHappened: fn(c, invokeRestart(useNewValue, 24))
  loop(
    value = 1
    bindRestart(
      useNewValue: fn(val, value = val),
      quit: fn(break),

      value println
      signal(somethingHappened)))

