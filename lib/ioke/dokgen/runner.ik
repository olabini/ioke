
DokGen do(
  document = method(
    "Takes a list of command line arguments, parses these and then builds up the documentation about all data in the system",
    arguments,

    outputDir = "dok"
    combineWithSpecs = false
    specsPattern = "test/**/*_spec.ik"

    ; - first collect the data in a good representation
    ; - then collect the test data if needed
    ; - then print everything out to html files

    alreadyPrinted = set()
    printObjects(" ", Ground, alreadyPrinted)
  )

  printObjects = method(indent, obj, alreadyPrinted,
    alreadyPrinted << cell(:obj)
    cell(:obj) cells each(c,
      unless(alreadyPrinted include?(c value),
        "#{indent}#{c key} : #{c value notice}" println
        printObjects(indent + " ", c value, alreadyPrinted))
      if(Ground == cell(:obj),
        "" println)
    )
  )
)
