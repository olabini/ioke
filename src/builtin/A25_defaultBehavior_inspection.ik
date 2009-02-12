
Base notice = "Base"
Base inspect = "Base"

DefaultBehavior inspect = method(
    "returns a longer description of the receiver, in general including cell information",
    
    cellSummary)



DefaultBehavior notice = method(
    "returns a short text description of the receiver",

    if(currentMessage Origin == cell(:self),
      "Origin",
      if(currentMessage Ground == cell(:self),
        "Ground",

        "#{cell(:self) kind}_#{cell(:self) uniqueHexId}"
  )))



DefaultBehavior cellDescriptionDict = method(
    "returns a dict containing each cell and it's corresponding description",

	cellNames = cell(:self) cellNames sort
	cellDescs = cellNames map(name, cell(:self) cell(name) notice)
	{} addKeysAndValues(cellNames, cellDescs))



DefaultBehavior cellSummary = method(
    "returns a representation of the current object that includes information about it's cells",

    cellDescriptions = cellDescriptionDict
    vals = cellDescriptions keys sort map(k, list(k, cellDescriptions[k]))
  " #{cell(:self) notice}:
%*[  %-28s = %s\n%]" format(vals))



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

DefaultBehavior Aspects notice  = "DefaultBehavior Aspects"
DefaultBehavior Aspects inspect = "DefaultBehavior Aspects"

DefaultBehavior Assignment notice  = "DefaultBehavior Assignment"
DefaultBehavior Assignment inspect = "DefaultBehavior Assignment"

DefaultBehavior BaseBehavior notice  = "DefaultBehavior BaseBehavior"
DefaultBehavior BaseBehavior inspect = "DefaultBehavior BaseBehavior"

DefaultBehavior Boolean notice  = "DefaultBehavior Boolean"
DefaultBehavior Boolean inspect = "DefaultBehavior Boolean"

DefaultBehavior Case notice  = "DefaultBehavior Case"
DefaultBehavior Case inspect = "DefaultBehavior Case"

DefaultBehavior Conditions notice  = "DefaultBehavior Conditions"
DefaultBehavior Conditions inspect = "DefaultBehavior Conditions"

DefaultBehavior Definitions notice  = "DefaultBehavior Definitions"
DefaultBehavior Definitions inspect = "DefaultBehavior Definitions"

DefaultBehavior FlowControl notice  = "DefaultBehavior FlowControl"
DefaultBehavior FlowControl inspect = "DefaultBehavior FlowControl"

DefaultBehavior Internal notice  = "DefaultBehavior Internal"
DefaultBehavior Internal inspect = "DefaultBehavior Internal"

DefaultBehavior Literals notice  = "DefaultBehavior Literals"
DefaultBehavior Literals inspect = "DefaultBehavior Literals"

DefaultBehavior Reflection notice  = "DefaultBehavior Reflection"
DefaultBehavior Reflection inspect = "DefaultBehavior Reflection"

