
Struct = fn(+attributes, +:attributesWithDefaultValues,
  attributeNames = attributes + attributesWithDefaultValues map(key)
  val = fn(+values, +:keywordValues,
    result = fn(+newVals, +:newKeywordVals,
      Struct createWithValuesFrom(result, attributeNames, newVals, newKeywordVals))
    result mimic!(val)
    (attributesWithDefaultValues seq +
      values zipped(attributes) mapped(reverse) +
      keywordValues seq) each(vv,
      result cell(vv first) = vv second)
    result
  )
  val mimic!(Struct)
  val)

Struct createWithValuesFrom = method(orig, attributeNames, newValues, newKeywordValues,
  res = orig mimic
  (newValues zipped(attributeNames) mapped(reverse) +
    newKeywordValues seq) each(vv,
    res cell(vv first) = vv second)
  res
)
