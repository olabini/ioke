
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
  if(name asText =~ #/^:all:({count}\d+)({realName}:.+)$/,
    count = it count toRational
    name = :(it realName)
    unifications[name] = (msg, count)
    count,
    if(name asText =~ #/^:all({realName}:.+)$/,
      name = :(it realName)
      count = 0
      curr = msg
      until(curr nil? || curr terminator?,
        curr = curr next
        count++)
      unifications[name] = (msg, count)
      count,
      if(name asText =~ #/^:until:({stopName}[^:]+)({realName}:.+)$/,
        stopsym = :(it stopName)
        name = :(it realName)

        count = 0
        curr = msg

        until(curr nil? || curr name == stopsym,
          curr = curr next
          count++)

        if(curr nil?,
          return(-1))

        count++

        unifications[name] = (msg, count)
        count,
        unifications[name] = (msg, 1)
        1))))

Message Rewriter Unification internal:unify = method(pattern, msg, countNexts false,
  p = pattern
  m = msg

  while(p,
    unless(m,
      return(false)
    )

    amount = 1

    if(p symbol?,
      amount = addUnification(p name, m)
      if(amount == -1,
        return(false)),
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
    amount times(
      unless(m,
        return(false))
      m = m next)

    if(countNexts,
      @nexts = @nexts + amount)
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
      (msg, count) = u unifications[p name]
      res = msg mimic
      curr = msg
      (1...count) each(n,
        curr = curr next
        newObj = curr mimic
        res last -> newObj
      )
      res,
      p mimic)

    res arguments = p arguments map(a,
      rewriteWith(u, a))

    if(start nil?,
      start = res
      current = start,
      current last -> res
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
