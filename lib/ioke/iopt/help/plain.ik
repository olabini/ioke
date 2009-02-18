IOpt Help Plain = Origin mimic
IOpt Help Plain do(
  Simple = Origin mimic do(
    
    initialize = method(iopt, 
      @iopt = iopt)

    asList = method(
      lines = list()
      
      if(iopt cell?(:banner), lines << iopt banner << "")
      lines << "OPTIONS:" << ""
      
      iopt actions each(action,
        lines << "%[  %s%] %s" format(
          action flags, if(action argumentsCode,
            "(#{action argumentsCode})", ""))
        if(action documentation && !action documentation empty?,
          lines << "  #{action documentation}")
        lines << "")
      
      lines)
    
    asText = method("Help string as simple plain text.",
      "%[%s\n%]" format(asList))

    ); Simple

  ); IOpt Help Plain