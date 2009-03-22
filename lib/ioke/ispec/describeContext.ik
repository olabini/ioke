
ISpec do(
  DescribeContext = Origin mimic do(
    create = method(
      ISpec Runner registerAtExitHook
      newSelf = mimic
      newSelf specs = []
      newSelf)

    stackTraceAsText = method(
      if(cell?(:shouldMessage),
        "#{shouldMessage filename}:#{shouldMessage line}:#{shouldMessage position}",
        "#{code filename}:#{code line}:#{code position}")
    )

    fullName = method(
      "returns the name of this context, prepended with the surrounding names",
      if(cell?(:surrounding),
        "#{surrounding fullName} #{describesWhat}",
        describesWhat))

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
      specs each(n,
        insideSuccess = if(n first == :description,
          n second run(reporter),
          ISpec runTest(self, n second, n third, reporter))
        if(success, success = insideSuccess))
      success
    )

    it = macro(
      "takes one text argument, and one optional code argument. if the code argument is left out, this spec will be marked as pending",
      shouldText = call argAt(0)
      if(call arguments length == 1,
          self specs << [:pending, shouldText],
          self specs << [:test, shouldText, call arguments second])
      ISpec ispec_options exampleAdded(self)
    )
  )
)
