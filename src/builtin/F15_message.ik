
Message from = dmacro(
  "returns the message chain for the argument given",
  
  [code]
  code deepCopy)

Message do(=== = generateMatchMethod(==))

Message OperatorTable withOperator = dmacro(
  "temporarily adds a new operator with the specified associativity, and then removes it again. if the operator is already in there, changes the associativity temporarily",

  [>name, >assoc, code]
  if(name mimics?(Text),
    name = :(name))
  let(Message OperatorTable operators, Message OperatorTable operators merge(name => assoc),
    code evaluateOn(call ground, call ground)))

Message OperatorTable withAssignOperator = dmacro(
  "temporarily adds a new assign operator with the specified associativity, and then removes it again. if the operator is already in there, changes the associativity temporarily",

  [>name, >assoc, code]
  if(name mimics?(Text),
    name = :(name))
  let(Message OperatorTable assignOperators, Message OperatorTable assignOperators merge(name => assoc),
    code evaluateOn(call ground, call ground)))

