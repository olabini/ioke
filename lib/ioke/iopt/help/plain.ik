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
        flag = "%[ %s%] " format(action flags)
        unless(action arity empty?, flag += " (" + action argumentsCode + ")")
        lines << flag
        if(action documentation && !action documentation empty?,
          lines << "  #{action documentation}")
        lines << "")
      
      lines)
    
    asText = method("Help string as simple plain text.",
      "%[%s\n%]" format(asList))

    ); Simple

  ); IOpt Help Plain