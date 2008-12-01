
IIk do(
  InputMethod = Origin mimic do(
    gets = method(error!("#{self notice}#gets not implemented"))
    readable_after_eof? = false
  )

  StdioInputMethod = InputMethod mimic do(
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
      line[lineToGet])
  )

  bind(
    rescue(Condition Error Load, fn(ignored, nil)),
    
    use("readline")
    ReadlineInputMethod = InputMethod mimic do(
      mimic!(Readline)
      
      new = method(
        "returns a newly initalized readline input method",

        self mimic do(
          lineNumber = 0
          line = []
          eof? = false
      ))

      gets = method(
        if(readline("iik> ", false),
          unless(it empty?, HISTORY << it)
          line[lineNumber++] = "#{it}\n",
          
          eof? = true
          false))

      readable_after_eof? = true

      line = method(lineToGet,
        line[lineToGet])
    )
  ))
