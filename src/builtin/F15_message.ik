
Message from = dmacro(
  "returns the message chain for the argument given",

  [code]
  code deepCopy)

Message == = method(other,
  other mimics?(Message)           &&
     @name == other name           &&
     @arguments == other arguments &&
     @next == other next)


Message do(=== = generateMatchMethod(==))

Message OperatorTable withOperator = dmacro(
  "temporarily adds a new operator with the specified associativity, and then removes it again. if the operator is already in there, changes the associativity temporarily",

  [>name, >assoc, code]
  if(name mimics?(Text),
    name = :(name))
  let(Message OperatorTable operators, Message OperatorTable operators merge(name => assoc),
    code evaluateOn(call ground, call ground)))

Message OperatorTable withTrinaryOperator = dmacro(
  "temporarily adds a new trinary operator with the specified associativity, and then removes it again. if the operator is already in there, changes the associativity temporarily",

  [>name, >assoc, code]
  if(name mimics?(Text),
    name = :(name))
  let(Message OperatorTable trinaryOperators, Message OperatorTable trinaryOperators merge(name => assoc),
    code evaluateOn(call ground, call ground)))

Message OperatorTable withInvertedOperator = dmacro(
  "temporarily adds a new inverted operator with the specified associativity, and then removes it again. if the operator is already in there, changes the associativity temporarily",

  [>name, >assoc, code]
  if(name mimics?(Text),
    name = :(name))
  let(Message OperatorTable invertedOperators, Message OperatorTable invertedOperators merge(name => assoc),
    code evaluateOn(call ground, call ground)))

Message mimic!(Mixins Sequenced)
Message seq = method(
  s = Sequence mimic do(
    next = method(
      obj = @currentMessage
      @currentMessage = @currentMessage next
      obj
    )

    next? = method(!(@currentMessage nil?))
  )
  s currentMessage = @
  s
)

Message Rewriter = Origin mimic

Message Rewriter rewrite = method(msg, pattern,
  start = nil
  current = nil

  m_msg = msg

  while(m_msg,
    m = match(m_msg, pattern key)

    result = if(m,
      rewriteWith(m, pattern value),
      m_msg mimic
    )

    if(start nil?,
      start = result
      current = start last,

      current -> result
      current = current last
    )

    if(m,
      m nexts times(if(m_msg, m_msg = m_msg next)),
      m_msg = m_msg next)
  )

  start
)

Message Rewriter Unification = Origin mimic do(
  initialize = method(
    @unifications = {}
    @nexts = 0
  )
)

Message Rewriter Unification addUnification = method(name, msg,
  unifications[name] = msg
)

Message Rewriter Unification internal:unify = method(pattern, msg, countNexts false,
;  "internal:unify(#{pattern code}, #{msg code}" println
  p = pattern
  m = msg

  while(p,
    unless(m,
      return(false)
    )

    if(p symbol?,
      addUnification(p name, m),
      unless(p name == m name,
        return(false)
      )
    )

    if(p arguments length != m arguments length,
      return(false))

    p arguments zip(m arguments) each(pm,
      unless(internal:unify(pm first, pm second),
        return(false)))

    p = p next
    m = m next
    if(countNexts,
      @nexts = @nexts + 1)
  )
  true
)

Message Rewriter Unification tryUnify = method(pattern, msg,
  u = mimic
  if(u internal:unify(pattern, msg, true),
    u,
    false)
)

Message Rewriter rewriteWith = method(u, pattern,
  start = nil
  current = nil
  p = pattern
  while(p,
    res = if(p symbol?,
      if(u unifications[p name] nil?,
        "UNKNOWN UNIFICATION for #{u inspect} for key: #{p name inspect}" println)
      u unifications[p name] mimic,
      p mimic)

    res arguments = p arguments map(a,
      rewriteWith(u, a))

    if(start nil?,
      start = res
      current = start,
      current -> res
      current = current last)

    p = p next
  )
  start
)

Message Rewriter match = method(msg, pattern,
  Unification tryUnify(pattern, msg)
)

Message rewrite = method("Takes zero or more pairs of message chains, that describe how rewriting of the current message chain should happen. The message patterns can use symbols to match variable pieces of the pattern.", +patterns,
  patterns inject(self,
    current,
    pattern,
    Rewriter rewrite(current, pattern))
)
