
Struct = fn(+attributes, +:attributesWithDefaultValues,
  attributeNames = attributes + attributesWithDefaultValues map(key)
  val = fn(+values, +:keywordValues,
    Struct internal:createInitial(val, attributeNames, attributes, attributesWithDefaultValues, values, keywordValues)
  )
  val attributeNames = attributeNames
  val prependMimic!(Struct)
  val)

Struct attributeNames = []
Struct structInstance? = false

Struct internal:createInitial = method(val, attributeNames, attributes, attributesWithDefaultValues, values, keywordValues,
  result = fn(+newVals, +:newKeywordVals,
    Struct internal:createDerived(result, attributeNames, newVals, newKeywordVals))
  result prependMimic!(val)
  result structInstance? = true
  (attributesWithDefaultValues seq +
    attributes zipped(values) +
    keywordValues seq) each(vv,
    result cell(vv first) = vv second)
  result)

Struct internal:createDerived = method(orig, attributeNames, newValues, newKeywordValues,
  res = orig mimic
  (newValues zipped(attributeNames) mapped(reverse) +
    newKeywordValues seq) each(vv,
    res cell(vv first) = vv second)
  res
)

Struct create = method(+values, +:keywordValues,
  @ call(*values, *keywordValues)
)

Struct mimic!(Mixins Sequenced)
Struct seq = method(
  attributeNames mapped(name, name => @cell(name))
)

Struct attributes = method(
  attributeNames fold({}, d, x, d[x] = @cell(x). d)
)

Struct valuesAt = method(+indices,
  indices map(ix,
    self[ix]))

Struct cell("[]") = method(index,
  ix = if(index mimics?(Number),
    attributeNames[index],
    index)
  @cell(ix))

Struct cell("[]=") = method(index, value,
  ix = if(index mimics?(Number),
    attributeNames[index],
    index)
  @cell(ix) = value)

Struct cell("==") = method(other,
  (other mimics?(Struct) &&
    attributes == other attributes))

Struct hash = method(attributes hash)

Struct asText = method(
  if(structInstance?,
    "(#{attributeNames map(name, "#{name}: #{@cell(name)}") join(", ")})",
    "Struct(#{attributeNames join(", ")})"))

Struct notice = method(
  if(structInstance?,
    "(#{attributeNames map(name, "#{name}: #{@cell(name) notice}") join(", ")})",
    "Struct(#{attributeNames join(", ")})"))

Struct inspect = method(
  if(structInstance?,
    "(#{attributeNames map(name, "#{name}: #{@cell(name) inspect}") join(", ")})",
    "Struct(#{attributeNames join(", ")})"))
