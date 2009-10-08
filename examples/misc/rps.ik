RPS = Origin mimic do(
  scores = {} withDefault(0)

  throws = dmacro([player, throw]

    cond(
      @p1 == nil, @p1 = player name => throw name,
      @p2 == nil, @p2 = player name => throw name

        cond(
          (@p1 value == :paper    && @p2 value == :rock)     ||
          (@p1 value == :rock     && @p2 value == :scissors) ||
          (@p1 value == :scissors && @p2 value == :paper),
            scores[@p1 key] += 1
            "#{p1 key} wins" println,

          (@p1 value == :rock     && @p2 value == :paper)    ||
          (@p1 value == :paper    && @p2 value == :scissors) ||
          (@p1 value == :scissors && @p2 value == :rock),
            scores[@p2 key] += 1
            "#{p2 key} wins" println,

          "Draw" println
        )
    )
  )

  play = macro(
    Message OperatorTable withTrinaryOperator(:throws, 14,
      instance = RPS with(p1: nil, p2: nil)
      instance winner = call arguments first shuffleOperators evaluateOn(instance)
      instance)
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

  "\nScores:" println
  RPS scores each(p, "#{p key}: #{p value}" println)
)

