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

  play = macro(
    field = Field with(plays: [])
    call arguments[0] evaluateOn(field)
    p1 = field plays[0]
    p2 = field plays[1]

    case([p1 value, p2 value],
      [:paper, :rock], win(p1),
      [:rock, :scissors], win(p1),
      [:scissors, :paper], win(p1),
      [:rock, :paper], win(p2),
      [:paper, :scissors], win(p2),
      [:scissors, :rock], win(p2),
      else, draw)
    
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

