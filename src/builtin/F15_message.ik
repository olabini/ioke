
Message from = dmacro(
  "returns the message chain for the argument given",

  [code]
  code deepCopy)


Message == = method(other,
  cell(:other) kind == "Message"          &&
     @name == other name                  &&
     @arguments == other arguments        &&
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

Message Rewriter rewrite = method(msg, pattern, recurse false,
  start = nil
  current = nil

  m_msg = msg

  while(m_msg,
    oldArguments = m_msg arguments

    if(recurse && !(Unification internal:literal?(m_msg)),
      m_msg arguments = m_msg arguments map(mm,
        if(Unification internal:literal?(mm),
          mm,
          rewrite(mm, pattern, true))))

    m = match(m_msg, pattern key)

    result = if(m,
      rewriteWith(m, pattern value),
      m_msg mimic
    )

    m_msg arguments = oldArguments

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

Message Rewriter Unification addUnification = method(name, p, msg,
  case([name, p arguments length],
    [:":all", 2],
    count = p arguments[0] evaluateOn(Ground)
    nm = :(p arguments[1] name)
    unifications[nm] = (msg, count)
    count,

    [:":all", 1],
    nm = :(p arguments[0] name)
    count = 0
    curr = msg
    until(curr nil? || curr terminator?,
      curr = curr next
      count++)
    unifications[nm] = (msg, count)
    count,

    [:":until", 2],
    stopsym = :(p arguments[0] name)
    nm = :(p arguments[1] name)

    count = 0
    curr = msg

    until(curr nil? || curr name == stopsym,
      curr = curr next
      count++)

    if(curr nil?,
      return(-1))

    count++

    unifications[nm] = (msg, count)
    count,

    else,
    if(name == :":not" && p arguments length > 0,
      capture = nil
      avoidNames = p arguments map(name)
      if(p arguments last symbol?,
        capture = p arguments last
        avoidNames removeAt!(avoidNames size - 1))

      if(avoidNames include?(msg name),
        -1,
        if(capture,
          unifications[capture name] = (msg, 1))
        1)
      ,
      unifications[name] = (msg, 1)
      1)))

Message Rewriter Unification internal:literal? = method(msg,
  if(msg name asText =~ #/^internal:/,
    true,
    false))

Message Rewriter Unification internal:eitherLiteral? = method(pattern, msg,
  internal:literal?(pattern) || internal:literal?(msg))

Message Rewriter Unification internal:unifyLiterals = method(pattern, msg,
  patternLiteral = internal:literal?(pattern)
  msgLiteral     = internal:literal?(msg)

  ; this pattern is exhaustive, since we know that at least one of the arguments HAS to be a literal
  case([patternLiteral, msgLiteral],
    [false, true],
    if(pattern symbol?,
      true,   ; we have already captured this with the unification of the message
      false), ; we can't unify since one thing is a literal and the other thing is just a regular message
    [true, false],
    false,    ; this case always fails, since the right hand side is not a literal it can never match a literal in the pattern
    [true, true],
    ; this is where we make sure we have the same message structure of literals
    pattern name == msg name && pattern arguments == msg arguments
  )
)

Message Rewriter Unification internal:macroSymbol? = method(p,
  (p name == :":all" || p name == :":until" || p name == :":not") && p arguments length > 0
)

Message Rewriter Unification internal:unify = method(pattern, msg, countNexts false,
  p = pattern
  m = msg

  while(p,
    unless(m,
      return(false)
    )

    amount = 1

    if(p symbol?,
      amount = addUnification(p name, p, m)
      if(amount == -1,
        return(false)),

      unless(p name == m name,
        return(false)
      )

    )

    unless(internal:macroSymbol?(p),
      if(internal:eitherLiteral?(p, m),
        unless(internal:unifyLiterals(p, m),
          return(false)),
        if(p arguments length != m arguments length,
          return(false))
        p arguments zip(m arguments) each(pm,
          unless(internal:unify(pm first, pm second),
            return(false)))))

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

    unless(u internal:literal?(res),
      res arguments = p arguments map(a,
        rewriteWith(u, a)))

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

Message rewrite:recursively = method("Takes zero or more pairs of message chains, that describe how rewriting of the current message chain should happen. The message patterns can use symbols to match variable pieces of the pattern.", +patterns,
  patterns inject(self,
    current,
    pattern,
    Rewriter rewrite(current, pattern, true))
)
