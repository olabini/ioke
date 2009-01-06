
Pattern = Origin mimic do(
  from = dmacro(

    [pattern]
    Pattern with(pattern: pattern))

  variable? = method(current,
    current mimics?(Symbol) && current asText[0..0] == ":")

  matchVariable = method(var, input, bindings,
    binding = bindings[var]
    case(binding,

      nil, bindings merge(var => input asText),
    
      input asText, bindings,

      nil))

  doMatch = method(pat, input, bindings,
    cond(
      bindings == nil, nil,
      
      variable?(pat), matchVariable(pat, input, bindings),

      pat == input, bindings,

      pat mimics?(Message) && pat next && input next, 
      doMatch(pat next, input next, doMatch(pat name, input name, bindings)),

      pat mimics?(Message), 
      doMatch(pat name, input name, bindings),
    
      nil))

  match = dmacro(
    "does pattern match input? a variable can match anything.",

    [input, >bindings {}]
    doMatch(self pattern, input, bindings))
)

System ifMain(
  Pattern from(I need a :X) match(I need a vacation) inspect println
  Pattern from(I need a :X) match(I really need a vacation) inspect println
  Pattern from(I :X need a :Y) match(I would need a vacation) inspect println
)
