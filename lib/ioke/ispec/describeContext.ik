
ISpec do(

  DescribeContext = Origin mimic do(
    describesWhat = nil
    specs = []
    surrounding = nil
    tags = {}

    create = method(surrounding, describesWhat, tags,
      newContext = mimic
      newContext describesWhat = describesWhat
      newContext surrounding = surrounding
      newContext tags = surrounding tags merge(tags)
      newContext surrounding specs << self
      newContext
    )
    
    initialize = method(
      "created #{self}" println
      self specs = []
    )

    stackTraceAsText = method(
      if(cell?(:shouldMessage),
        "#{shouldMessage filename}:#{shouldMessage line}:#{shouldMessage position}",
        "#{code filename}:#{code line}:#{code position}")
    )

    fullName = method(
      "returns the name of this context, prepended with the surrounding names",
      [if(surrounding, surrounding fullName), describesWhat] compact join(" ")
    )

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

    it = macro(
      "takes one text argument, and one optional code argument. if the code argument is left out, this spec will be marked as pending",
      shouldText = call arguments first
      code = if(call arguments length > 1,
        call arguments last
      )
      tags = if(call arguments length == 3,
        call arguments second
      )

      example = ISpec Example mimic(self, shouldText, code, tags)
      self specs << example
      ISpec ispec_options exampleAdded(example)
    )
  )
)
