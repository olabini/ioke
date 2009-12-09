
Struct = fn(+attributes, +:attributesWithDefaultValues,
  val = fn(+values, +:keywordValues,
    result = val mimic
    attributesWithDefaultValues each(vv,
      result cell(vv key) = vv value)
    attributes zip(values) each(vv,
      result cell(vv first) = vv second)
    keywordValues each(vv,
      result cell(vv key) = vv value)
    result
  )
  val mimic!(Struct)
  val)

