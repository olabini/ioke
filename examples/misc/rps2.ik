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

  play = macro(
    field = Field with(plays: [])
    call arguments[0] evaluateOn(field)
    p1 = field plays[0]
    p2 = field plays[1]

    case([p1 value, p2 value],
      or(
        [:paper, :rock],
        [:rock, :scissors],
        [:scissors, :paper]),
      scores[p1 key] += 1
      "#{p1 key} wins" println,

      or(
        [:rock, :paper],
        [:paper, :scissors],
        [:scissors, :rock]),
      scores[p2 key] += 1
      "#{p2 key} wins" println,

      "Draw" println)
    
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

  "\nScores:\n%*[%s: %s\n]" format(RPS scores map(x, [x key, x value])) println
)

