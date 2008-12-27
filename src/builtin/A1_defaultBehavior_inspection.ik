
Base notice = "Base"
Base inspect = "Base"

DefaultBehavior do(
  inspect = method(
    "returns a longer description of the receiver, in general including cell information",
    
    cellSummary)



  notice = method(
    "returns a short text description of the receiver",

    if(currentMessage Origin == cell(:self),
      "Origin",
      if(currentMessage Ground == cell(:self),
        "Ground",

        "#{cell(:self) kind}_#{cell(:self) uniqueHexId}"
  )))



  cellDescriptionDict = method(
    "returns a dict containing each cell and it's corresponding description",

	cellNames = cell(:self) cellNames sort
	cellDescs = cellNames map(name, cell(:self) cell(name) notice)
	{} addKeysAndValues(cellNames, cellDescs))



  cellSummary = method(
    "returns a representation of the current object that includes information about it's cells",

    cellDescriptions = cellDescriptionDict
    vals = cellDescriptions keys sort map(k, list(k, cellDescriptions[k]))
  " #{cell(:self) notice}:
%*[  %-28s = %s\n%]" format(vals))
)

System notice = method(
  "returns a short text description of the receiver, the text System if this is the main System object, otherwise falls back to the super implementation",
  
  if(cell(:self) == System,
    "System",
    super))

Runtime notice = method(
  "returns a short text description of the receiver, the text Runtime if this is the main Runtime object, otherwise falls back to the super implementation",

  if(cell(:self) == Runtime,
    "Runtime",
    super))
