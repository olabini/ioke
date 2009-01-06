
Pattern = Origin mimic do(
  from = dmacro(
    [pattern]
    Pattern with(pattern: pattern))

  variable? = method(current, current symbol?)
  varName = method(msg, :(msg name asText[1..-1]))

  matchVariable = method(var, input, bindings,
    binding = bindings[varName(var)]
    case(binding,
      nil,
        bindings merge(varName(var) => input name asText),
      input name asText, 
        bindings,
        nil))

  doMatch = method(pat, input, bindings,
    cond(
      bindings == nil,
        nil,

      pat == nil || input == nil,
        if(pat == input, bindings, nil),
      
      variable?(pat), 
        doMatch(pat next, input next, matchVariable(pat, input, bindings)),

      pat name == input name,
        doMatch(pat next, input next, bindings),
    
        nil))

  match = dmacro("Does pattern match input? A variable in the form of a symbol message can match anything.",
    [input, >bindings {}]
    doMatch(self pattern, input, bindings))
)

System ifMain(
  Pattern from(I need a :X) match(I need a vacation) inspect println
  Pattern from(I need a :X) match(I really need a vacation) inspect println
  Pattern from(I :X need a :Y) match(I would need a vacation) inspect println
)