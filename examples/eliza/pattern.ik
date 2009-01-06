
Pattern = Origin mimic
Pattern from = dmacro(

  [pattern]
  new = Pattern mimic
  new pattern = pattern
  new)

Pattern variable? = method(current,
  current mimics?(Symbol) && current asText[0..0] == ":")

Pattern matchVariable = method(var, input, bindings,
  binding = bindings[var]
  case(binding,

    nil, 
    newBindings = bindings mimic
    newBindings[var] = input asText
    newBindings,
    
    input asText,
    bindings,

    nil))

Pattern doMatch = method(pat, input, bindings,
  cond(
    bindings == nil, nil,

    variable?(pat), matchVariable(pat, input, bindings),

    pat == input, bindings,

    pat mimics?(Message) && pat next && input next, 
    doMatch(pat next, input next, doMatch(pat name, input name, bindings)),

    pat mimics?(Message), 
    doMatch(pat name, input name, bindings),
    
    nil))

Pattern match = dmacro(
  "does pattern match input? a variable can match anything.",

  [input, >bindings {}]
  doMatch(self pattern, input, bindings))

System ifMain(
  Pattern from(I need a :X) match(I need a vacation) inspect println
  Pattern from(I need a :X) match(I really need a vacation) inspect println

  Pattern from(I :X need a :Y) match(I would need a vacation) inspect println
)
