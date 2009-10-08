
DefaultBehavior FlowControl cond = syntax(
  "takes zero or more arguments. each two arguments are paired, where the first one is the condition part, and the second is the then-part. if there's an uneven number of arguments, that part is the else-part. if no arguments are provided, or no conditions match and there is no else part, cond returns nil.",

  DefaultBehavior FlowControl cell(:cond) createNestedIfStatements(call arguments))

DefaultBehavior FlowControl cell(:cond) createNestedIfStatements = method(args,
  if(args length == 0,
    'nil,
    if(args length == 1,
      ; an else part
      args[0],

      ; a condition, then part
      'if <<(args[0]) <<(args[1]) << createNestedIfStatements(args[2..-1])
    )
  )
)
