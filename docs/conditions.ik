
bindHandler(
  noSuchCell: block(c, c asText println),
  incorrectArity: block(c, c asText println),
  # code that might cause the above conditions
)


bindHandler(
  somethingHappened: block(c, invokeRestart(useNewValue, 24))
  loop(
    value = 1
    bindRestart(
      useNewValue: block(val, value = val),
      quit: block(break),

      value println
      signal(somethingHappened)))

