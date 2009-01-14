
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

  chainCopy = method(msg, start, end,
    if(start > 0,
      chainCopy(msg next, start-1, end-1),
      result = msg deepCopy
      current = result
      while(end-- > 0, current = current next)
      current next = nil
      result))

  positionOf = method(name, msgChain, start: 0,
    pos = start
    while(start > 0,
      if(msgChain next nil?, return(nil))
      msgChain = msgChain next
      start--)

    ix = msgChain findIndex(name asText lower == name asText lower )
    ix && ix + pos
  )

  matchVariable = method(var, input, bindings, part,
    binding = bindings[varName(var)]
    case(binding,
      nil,
        bindings merge(varName(var) => part call(input) ),
      part call(input),
        bindings,
        noMatch!))

  matchSegment = method(pattern, input, bindings, start 0,
    var = pattern arguments[0]
    pat = pattern next
    if(pat nil?,
      matchVariable(var, input, bindings, fn(i, i code)),
      pos = positionOf(pat name, input, start: start)
      if(pos nil?,
        noMatch!,
        bind(restart(noMatch, fn(matchSegment(pattern, input, bindings, pos+1))),
          doMatch(pat, messageFrom(input, pos), matchVariable(var, chainCopy(input, 0, pos), bindings, fn(i, i code))))
      )
    )
  )

  doMatch = method(pat, input, bindings,
    cond(
      pat != nil && input == nil && segmentPattern?(pat) && pat next == nil,
        matchVariable(pat arguments[0], input, bindings, fn(i, "")),

      pat == nil || input == nil,
        if(pat == input, bindings, noMatch!),
      
      variable?(pat), 
        doMatch(pat next, input next, matchVariable(pat, input, bindings, fn(i, i name asText))),

      segmentPattern?(pat),
        matchSegment(pat, input, bindings),
        
      pat name asText lower == input name asText lower,
        doMatch(pat next, input next, bindings),
    
        noMatch!))

  flatten = method("Takes a message chain and modifies it to be flattened. this means all the arguments will be spliced into it instead",
    msgChain,
    
    if(msgChain,
      msgChain each(m,
        if(m arguments length > 0 && !(#/^internal:/ =~ m name),
          res = m arguments fold(sum, a, sum last -> a. sum)
          m arguments clear!
          nx = m next
          m -> res
          res last -> nx
        )
      )
    )
    msgChain
  )

  match = dmacro("Does pattern match input? A variable in the form of a symbol message can match anything.",
    [input, >bindings {}]
    matchSimple(input, bindings))

  matchSimple = method(input, bindings {},
    bind(restart(noMatch, fn(nil)),
      doMatch(self pattern, flatten(input), bindings)))
    

  ; more or less an equivalent of common lisp sublis
  subst = method("Takes one dict of replacements, where the key should be the name of the message to replace, and the value a new message chain to insert instead of it. Returns a new copy without modifying any of the chains given",
    replacements, messages,
    msg = messages deepCopy
    head = msg
    msg each(m,
      if(replacements key?(m name),
        insertChain(m, replacements[m name] deepCopy)
      )
    )
    head
  )

  insertChain = method(main, insert,
    nx = main next
    prv = main prev
    main become!(insert)
    main last -> nx
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

  Pattern from(*(:p) need *(:x)) match(Mr Hulot and I need a vacation) should == {p: "Mr Hulot and I", x: "a vacation"}

  Pattern from(*(:x) a b *(:x)) match(1 2 a b a b 1 2 a b) should == {x: "1 2 a b"}
)
