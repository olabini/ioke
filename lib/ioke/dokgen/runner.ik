
DokGen do(
  Collected = [{},{},{}] mimic do(
    from = method(files, kinds, cells, 
      newObj = self mimic
      newObj[0] = files
      newObj[1] = kinds
      newObj[2] = cells
      newObj)

    collectedFiles = method([0])
    collectedKinds = method([1])
    collectedCells = method([2]))

  document = method(
    "Takes a list of command line arguments, parses these and then builds up the documentation about all data in the system",
    arguments,

    outputDir = "dok"

    combineWithSpecs = false
    specsPattern = "test/**/*_spec.ik"

    ; - first collect the data in a good representation
    ; - then collect the test data if needed
    ; - then print everything out to html files

    collected = Collected from({}, {"Ground" => Ground}, {})

    collect(Ground, collected)

    generate(outputDir, collected)

;     collectedFiles keys sort each(println)
;     collectedKinds keys sort each(k, " #{k} => #{collectedKinds[k] notice}" println)
;     collectedCells keys sort each(k, collectedCells[k] sortBy(first kind) each(v, " #{k} (#{v first kind}) // #{v[3]}" println))
  )
)
