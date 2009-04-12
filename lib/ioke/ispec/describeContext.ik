
ISpec do(

  DescribeContext = Origin mimic do(
    describesWhat = nil
    specs = []
    surrounding = nil
    tags = {}
    befores = []
    afters = []

    create = method(surrounding, describesWhat, tags,
      newContext = mimic
      newContext describesWhat = describesWhat
      newContext surrounding = surrounding
      newContext tags = surrounding tags merge(tags)
      newContext surrounding specs << newContext
      newContext befores = []
      newContext afters = []
      newContext
    )
    
    initialize = method(
      self specs = []
    )
    
    after = macro(
      "takes one code argument and evaluates it on context after each test in the context"
      afters << call arguments first
    )
    
    before = macro(
      "takes one code argument and evaluates it on context before every test in the context"
      befores << call arguments first
    )

    fullName = method(
      "returns the name of this context, prepended with the surrounding names",
      [if(surrounding, surrounding fullName), describesWhat] compact join(" ")
    )
    
    aliasMethod("fullName", "fullDescription")
    
    description = method(describesWhat)

    onlyWhen = dmacro(
      [>condition, code]
      if(condition,
        code evaluateOn(call ground, call ground))
    )

    run = method(
      "runs all the defined descriptions and specs",
      reporter,

      reporter addExampleGroup(self)
      success = true
      specs each(spec,
        insideSuccess = spec run(reporter)
        if(success, success = insideSuccess)
      )
      success
    )
    
    aftersWithSurrounding = method(
      if(surrounding,
        afters + surrounding afters,
        afters
      )
    )
    
    beforesWithSurrounding = method(
      if(surrounding,
        surrounding befores + befores,
        befores
      )
    )
    
    runAfters = method(
      aftersWithSurrounding each(evaluateOn(self))
    )
    
    runBefores = method(
      beforesWithSurrounding each(evaluateOn(self))
    )

    it = macro(
      "takes one text argument, and one optional code argument. if the code argument is left out, this spec will be marked as pending",
      shouldText = call argAt(0)

      code = if(call arguments length > 1,
        call arguments last
      )
      
      tags = if(call arguments length == 3,
        call argAt(1)
      )

      example = ISpec Example mimic(self, shouldText, code, tags)
      self specs << example
      ISpec ispec_options exampleAdded(example)
    )
  )
)
