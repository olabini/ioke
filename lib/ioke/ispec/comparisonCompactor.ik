
ISpec do(
  ;; This implementation is a straight port of the JUnit ComparisonCompactor
  ComparisonCompactor = Origin mimic do(
    ELLIPSIS = "..."
    DELTA_END = "]"
    DELTA_START = "["

    format = method(message, expected, actual,
      formatted = ""
      if(!message nil? && message != "",
        formatted = "#{message} ")
      "#{formatted}expected:<#{expected}> but was:<#{actual}>"
    )

    compact = method(contextLength, expected, actual, message:,
      if(expected nil? || actual nil? || expected == actual,
        format(message, expected, actual),
        with(
          contextLength: contextLength,
          expected: expected,
          actual: actual,
          message: message) compacted)
    )

    compacted = method(
      findCommonPrefix!
      findCommonSuffix!
      expected = compactString(@expected)
      actual = compactString(@actual)
      format(message, expected, actual)
    )

    compactString = method(source,
      result = DELTA_START + source[prefix..(-(suffix))] + DELTA_END
      if(prefix > 0,
        result = commonPrefix + result)
      if(suffix > 0,
        result = result + commonSuffix)
      result
    )

    findCommonPrefix! = method(
      @prefix = 0
      end = [expected length, actual length] min
      while(prefix < end,
        if(expected[prefix] != actual[prefix],
          break)
        @prefix ++
      )
    )

    findCommonSuffix! = method(
      expectedSuffix = expected length - 1
      actualSuffix = actual length - 1
      while(actualSuffix >= prefix && expectedSuffix >= prefix,
        if(expected[expectedSuffix] != actual[actualSuffix],
          break)
        actualSuffix--
        expectedSuffix--
      )
      @suffix = expected length - expectedSuffix
    )

    commonPrefix = method(
      if(prefix > contextLength, ELLIPSIS, "") + expected[([0, prefix - contextLength] max)...prefix]
    )

    commonSuffix = method(
      end = [expected length - suffix + 1 + contextLength, expected length] min
	  expected[(expected length - suffix + 1)...end] + if(expected length - suffix + 1 < expected length - contextLength, ELLIPSIS, "")
    )
  )
)
