
DokGen do(
  Collected = [{},{},{},{}] mimic do(
    from = method(files, kinds, cells, specs {},
      newObj = self mimic
      newObj[0] = files
      newObj[1] = kinds
      newObj[2] = cells
      newObj[3] = specs
      newObj)

    collectedFiles = method([0])
    collectedKinds = method([1])
    collectedCells = method([2])
    collectedSpecs = method([3])
  )

  document = method(
    "Takes a list of command line arguments, parses these and then builds up the documentation about all data in the system",
    arguments,

    outputDir = "dok"

    combineWithSpecs = true
    specsPattern = "test/**/*_spec.ik"
    
    collected = Collected from({}, {"IokeGround" => IokeGround, "Ground" => Ground}, {})

    collect(IokeGround, collected)

    if(combineWithSpecs,
      collectSpecs(specsPattern, collected collectedSpecs, collected)
    )

    generate(outputDir, collected)
  )
)
