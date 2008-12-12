
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

    collectedFiles = {}
    collectedKinds = {"Ground" => Ground}
    collectedCells = {}
    collect(Ground, collectedFiles, collectedKinds, collectedCells)
    generate(outputDir, collectedFiles, collectedKinds, collectedCells)

;     collectedFiles keys sort each(println)
;     collectedKinds keys sort each(k, " #{k} => #{collectedKinds[k] notice}" println)
;     collectedCells keys sort each(k, collectedCells[k] sortBy(first kind) each(v, " #{k} (#{v first kind}) // #{v[3]}" println))
  )
)
