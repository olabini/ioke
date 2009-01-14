
use("pattern")

Eliza = Origin mimic do(
  p = dsyntax(
    [pattern]
    ''(Pattern from('pattern)))
  
  Rules = [
    p(*(:x) hello *(:y)) => ['(How do you do. Please state your problem)],
    p(*(:x) I want *(:y)) => [
      '(What would it mean if you got :y ?),
      '(Why do you want :y ?),
      '(Suppose you got :y soon?)],
    p(*(:x) if *(:y)) => [
      '(Do you really think its likely that :y ?),
      '(Do you wish that :y ?),
      '(What do you think about :y ?),
      '(Really if :y ?)],
    p(*(:x) no *(:y)) => [
      '(Why not?),
      '(You are being a bit negative),
      '(Are you saying NO just to be negative?)],
    p(*(:x) I was *(:y)) => [
      '(Were you really?),
      '(Perhaps I already knew you were :y ?),
      '(Why do you tell me you were :y now?)],
    p(*(:x) I feel *(:y)) => ['(Do you often feel :y ?)],
    p(*(:x) I felt *(:y)) => ['(What other feelings do you have?)]
    ]

  randomElement = method(from,
    from[System randomNumber % from length]
  )

  useElizaRules = method(input,
    Rules some(rule, 
      result = rule first matchSimple(input)
      if(result,
        Pattern subst(result fold({}, sum, pair, sum[:(pair key inspect)] = Message fromText(pair value). sum), randomElement(rule second))
      )
    )
  )

  run = method(
    loop(
      "eliza> " print
      result = Pattern flatten(useElizaRules(System in read))
      if(result,
        result code println,
        "[no match]" println)
    )
  )
)

Eliza run
