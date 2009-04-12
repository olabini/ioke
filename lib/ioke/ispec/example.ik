ISpec do(
  Example = Origin mimic do(
    initialize = method(context, name nil, code nil, tags {},
      self context = context mimic
      self name = name
      self code = code
      self tags = context tags merge(tags)
      self description = name
      self fullDescription = "#{self context fullName} #{name}"
    )
    
    run = method(
      "runs tests with given reporter",
      reporter,
      
      executionError = nil
      reporter exampleStarted(self)

      bind(
        rescue(Ground Condition Error, 
          fn(c, executionError ||= c)),
        rescue(ISpec Condition, 
          fn(c, executionError ||= c)),
        handle(Ground Condition,  
          fn(c, c example = self)),
        if(tags[:pending],
          error!(ISpec ExamplePending, text: "Disabled example"))
        if(code,
          ;; don't evaluate directly, instead send it to a macro on the newContext, which can give it a real back trace context
          code evaluateOn(context, context),

          error!(ISpec ExamplePending, text: "Not Yet Implemented")))

      reporter exampleFinished(self, executionError)

      (executionError nil?) || (executionError mimics?(ISpec ExamplePending))
    )
    
    stackTraceAsText = method(condition,
      if(condition cell?(:shouldMessage),
        "#{shouldMessage filename}:#{shouldMessage line}:#{shouldMessage position}",
        "#{code filename}:#{code line}:#{code position}")
    )
  )
)
