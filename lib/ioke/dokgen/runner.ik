use("iopt")

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

  OptionParser = IOpt mimic do(
    banner = "Usage: dokgen [options]"
    
    combineWithSpecs? = true
    outputDir = "dok"
    specsPattern = "test/**/*_spec.ik"

    on["-o", "--output-dir"] = method("Output directory", dir outputDir, 
      @outputDir = dir)

    on["--[no-]combine-specs"] = method("Combine with specs?", v, 
      @combineWithSpecs? = v)
    
    on["--spec"] = method("Specs pattern", glob specsPattern,
      @combineWithSpecs? = true
      @specsPattern = glob)
    
    on["-h", "--help"] = method("Display usage", @println. System exit)
    on["-h"] priority = -10
  )

  document = method(
    "Takes a list of command line arguments, parses these and then builds up the documentation about all data in the system",
    arguments,

    opt = OptionParser mimic
    opt parse!(arguments)
    
    collected = Collected from({}, {"Ground" => Ground}, {})

    collect(Ground, collected)

    if(opt combineWithSpecs?,
      collectSpecs(opt specsPattern, collected collectedSpecs, collected))

    generate(opt outputDir, collected)
  )
)
