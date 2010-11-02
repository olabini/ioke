use("icheck")

ISpec do(
  PropertyExample = Origin mimic do(
    initialize = method(context, property,
      self context = context mimic
      self property = property
      self description = property fullDescription replaceAll("\n", "\n  ")
      self fullDescription = property fullDescription replaceAll("\n", "")
    )

    fail? = false
    pending? = false

    run = method(
      "runs property with given reporter",
      reporter,

      executionError = nil
      reporter propertyExampleStarted(self)

      result = ICheck Property createResult
      bind(
        rescue(Ground Condition Error,
          fn(c, executionError ||= c)),
        rescue(ISpec Condition,
          fn(c, executionError ||= c)),
        handle(Ground Condition,
          fn(c, c example = self)),

        property check!(result: result)
      )

      reporter propertyExampleFinished(self, executionError, result)

      executionError nil? && !(result exhausted?)
    )

    stackTraceAsText = method(condition,
      message = if(condition cell?(:shouldMessage),
        condition shouldMessage,
        code
      )
      "#{message filename}:#{message line}:#{message position}"
    )
  )
)
