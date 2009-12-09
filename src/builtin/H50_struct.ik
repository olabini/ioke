
Struct = fn(+attributes, +:attributesWithDefaultValues,
  val = fn(+values, +:keywordValues,
    result = val mimic
    (attributesWithDefaultValues seq +
      attributes zipped(values) +
      keywordValues seq) each(vv,
      result cell(vv first) = vv second)
    result
  )
  val mimic!(Struct)
  val)

