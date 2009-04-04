
Regexp do(=== = generateMatchMethod(=~))

Regexp cell("!~") = method(
  "returns true if the regular expression doesn't match, otherwise false",
  text,
  if(self =~ text,
    false,
    true))
