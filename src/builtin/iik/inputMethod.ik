
IIk do(
  StdioInputMethod = Origin mimic do(
    new = method(
      "returns a newly initalized stdio input method",

      self mimic do(
        lineNumber = 0
        line = []
    ))

    gets = method(
      IIk out print("iik> ")
      line[lineNumber++] = IIk in gets
    )

    eof? = method(IIk in eof?)
    readable_after_eof? = true
    line = method(lineToGet,
      line[lineToGet]))

  bind(
    rescue(Condition Error Load, fn(ignored, nil)),

    use("readline")
    ReadlineInputMethod = Origin mimic do(
      mimic!(Readline)

      new = method(
        "returns a newly initalized readline input method",

        self mimic do(
          lineNumber = 0
          line = []
          eof? = false
          prompt = "iik> "
      ))

      gets = method(
        if(theString = readline(prompt, false),
          unless(theString empty?, HISTORY << theString)
          line[lineNumber++] = "#{theString}\n",

          eof? = true
          false))

      readable_after_eof? = true
      line = method(lineToGet,
        line[lineToGet]))))
