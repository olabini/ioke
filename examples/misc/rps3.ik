RPS = Origin mimic do(
  Player = Origin mimic
  Field = Origin mimic

  Field pass = macro(
    RPS Player with(name: call message name asText, field: self))

  scores = {} withDefault(0)

  Player throws = macro(
    field plays << (self name => call message next name)
    call message -> call message next next
  )

  win = method(p,
    scores[p key] += 1
    "#{p key} wins" println)

  draw = method("Draw" println)

  ; DSL implementation
  rules = macro(
    r = call arguments
    resultMessage = 'case([p1 value, p2 value])
    left = fnx(r, ":#{r name}")
    right = fnx(r, ":#{r next next name}")
    r each(rule,
      resultMessage << ''[`left(rule), `right(rule)] << 'win(p1)
      resultMessage << ''[`right(rule), `left(rule)] << 'win(p2)
    )
    resultMessage << 'else << 'draw

    ''(applyRules = method(p1, p2, `resultMessage))
  )




  ;; DSL usage
  rules(
    paper > rock,
    rock > scissors,
    scissors > paper
  )

  play = macro(
    field = Field with(plays: [])
    call arguments[0] evaluateOn(field)
    p1 = field plays[0]
    p2 = field plays[1]

    applyRules(p1, p2)

    field
  )
)

System ifMain(
  RPS play(
    Carlos throws paper
    Ola throws rock
  )

  RPS play(
    Carlos throws scissors
    Ola throws rock
  )

  RPS play(
    Carlos throws scissors
    Ola throws scissors
  )

  RPS play(
    Carlos throws paper
    Ola throws scissors
  )

  "\nScores:\n%:[%s: %s\n%]" format(RPS scores) print
)

