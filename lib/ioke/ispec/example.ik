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
    
    fail? = method(
      tags[:fail]
    )
    
    pending? = method(
      tags[:pending] || !code
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
          
        if(pending?,
          if(code,
            error!(ISpec ExamplePending, text: "Disabled example"),
            
            error!(ISpec ExamplePending, text: "Not Yet Implemented")
          )
        )
        
        if(fail?,
          error!(ISpec Condition, text: "Forced fail")
        )
        ;; don't evaluate directly, instead send it to a macro on the newContext, which can give it a real back trace context
        context runBefores
        code evaluateOn(context, context)
        context runAfters
      )

      reporter exampleFinished(self, executionError)

      (executionError nil?) || (executionError mimics?(ISpec ExamplePending))
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
