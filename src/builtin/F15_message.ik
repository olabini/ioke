
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

