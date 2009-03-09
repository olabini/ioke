IOpt Help Plain = Origin mimic
IOpt Help Plain do(
  Simple = Origin mimic do(
    
    initialize = method(iopt, 
      @iopt = iopt)

    asList = method(
      lines = list()
      
      if(iopt cell?(:banner), lines << iopt banner << "")
      lines << "OPTIONS:" << ""
      
      actions = set()
      iopt cell("iopt:actions") each(pair, actions << pair value)
      actions sort each(action,
        option = action options join(", ")
        unless(action arity empty?, option += " (" + action argumentsCode + ")")
        docs = list()
        if(action documentation && !action documentation empty?,
          docs = action documentation split("\n"))
        lines << "  %-40s %s" format(option, docs first)
        docs rest each(d, lines << "  %-40s %s" format("", d))
        lines << "")
      
      lines)
    
    asText = method("Help string as simple plain text.",
      "%[%s\n%]" format(asList))

    ); Simple

  ); IOpt Help Plain