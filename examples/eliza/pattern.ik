
Pattern = Origin mimic do(
  from = dmacro(
    [pattern]
    Pattern with(pattern: pattern))

  variable? = method(current, current symbol?)
  varName = method(msg, :(msg name asText[1..-1]))

  segmentPattern? = method(pattern,
    pattern name == :"*" && pattern arguments length == 1
  )

  noMatch! = method(invokeRestart(:noMatch))

  messageFrom = method(msg, pos,
    if(pos == 0 || msg next nil?,
      msg,
      messageFrom(msg next, pos - 1)))

  positionOf = method(name, msgChain, start: 0,
    pos = start
    while(start > 0,
      if(msgChain next nil?, return(nil))
      msgChain = msgChain next
      start--)
    while(msgChain,
      if(msgChain name == name,
        return(pos))
      pos++
      msgChain = msgChain next
    )
    nil
  )

  matchVariable = method(var, input, bindings,
    binding = bindings[varName(var)]
    case(binding,
      nil,
        bindings merge(varName(var) => input name asText),
      input name asText, 
        bindings,
        noMatch!))

  matchSegment = method(pattern, input, bindings, start 0,
    "matchSegment(#{pattern})" println
    var = pattern arguments[0]
    pat = pattern next
    if(pat nil?,
      matchVariable(var, input, bindings),
      pos = positionOf(pat name, input, start: start)
      if(pos nil?,
        noMatch!,
        b2 = bind(restart(noMatch, fn(nil)),
          doMatch(pat, messageFrom(input, pos), bindings))
        if(b2,
          matchVariable(var, input, b2),
          matchSegment(patern, input, bindings, pos+1)
        )
      )
    )
  )

  doMatch = method(pat, input, bindings,
    cond(
      pat == nil || input == nil,
        if(pat == input, bindings, noMatch!),
      
      variable?(pat), 
        doMatch(pat next, input next, matchVariable(pat, input, bindings)),

      segmentPattern?(pat),
        matchSegment(pat, input, bindings),
        
      pat name == input name,
        doMatch(pat next, input next, bindings),
    
        noMatch!))

  match = dmacro("Does pattern match input? A variable in the form of a symbol message can match anything.",
    [input, >bindings {}]
    bind(restart(noMatch, fn(nil)),
      doMatch(self pattern, input, bindings)))

  ; more or less an equivalent of common lisp sublis
  subst = method("Takes one dict of replacements, where the key should be the name of the message to replace, and the value a new message chain to insert instead of it. Returns a new copy without modifying any of the chains given",
    replacements, messages,
    msg = messages deepCopy
    head = msg
    while(msg next,
      if(replacements key?(msg name),
        insertChain(msg, replacements[msg name] deepCopy)
      )
      msg = msg next
    )
    if(replacements key?(msg name),
      insertChain(msg, replacements[msg name] deepCopy)
    )
    head
  )

  insertChain = method(main, insert,
    nx = main next
    prv = main prev
    main become!(insert)
    main last next = nx
    main prev = prv
  )
)

System ifMain(
  use("ispec")
  p1 = Pattern from(I need a :X)
  p1 match(I need a vacation) should == {X: "vacation"} 
  p1 match(I really need a vacation) should be nil
  Pattern from(I :X need a :Y) match(I would need a vacation) should == {X: "would", Y: "vacation"}
  Pattern subst({:":X" => 'vacation}, '(what would it mean to you if you got a :X ?)) code should == "what would it mean to you if you got a vacation ?"

  Pattern from(*:p need *:x) match(Mr Hulot and I need a vacation) should == {p: "Mr Hulot and I", x: "a vacation"}
)
