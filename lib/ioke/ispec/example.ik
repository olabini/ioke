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
          fn(c, c describeContext = context. if(c cell?(:shouldMessage), context shouldMessage = c shouldMessage))),
        if(tags[:pending],
          error!(ISpec ExamplePending, text: "Disabled example"))
        if(code,
          ;; don't evaluate directly, instead send it to a macro on the newContext, which can give it a real back trace context
          code evaluateOn(context, context),

          error!(ISpec ExamplePending, text: "Not Yet Implemented")))

      reporter exampleFinished(context, executionError)

      (executionError nil?) || (executionError mimics?(ExamplePending))
    )
  )
)
