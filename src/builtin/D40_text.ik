
Text aliasMethod("internal:concatenateText", "+")

Text empty? = method(
  "returns true if the length of this text is exactly zero, otherwise false",

  length == 0)

Text cell("*") = method(
  "returns the text repeated as many times as the argument. 0 and negative means no times",
  times,

  result = ""
  counted = 0
  times times(result += self)
  result)

Text do(=== = generateMatchMethod(==))

Text chars = method(
	"returns a list of each character in this text",
	
	self split("")[0..-2])
  
