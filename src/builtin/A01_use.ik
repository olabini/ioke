
DefaultBehavior use = method("takes one or more evaluated string argument. will import the files corresponding to each of the strings named based on the Ioke loading behavior that can be found in the documentation for the loadBehavior cell on System.", module nil,
  unless(module,
    return(DefaultBehavior cell(:use)),
    System lowLevelLoad!(module, false)))
