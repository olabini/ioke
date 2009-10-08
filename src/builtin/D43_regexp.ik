
Regexp do(=== = generateMatchMethod(=~))

Regexp cell("!~") = method(
  "returns true if the regular expression doesn't match, otherwise false",
  text,
  if(self =~ text,
    false,
    true))

Regexp Match do(
  offsets = method(
    "returns all the offsets for this match, including the full match. the result is a list of pairs, or nil for the groups that wasn't matched",
    (0...length) map(n, offset(n))
  )

  namedOffsets = method(
    "returns a dictionary of all the names in this match. the keys will be symbols and the values either pairs of indices or nil",
    names inject({}, sum, name, sum + {name => offset(name)})
  )
)
