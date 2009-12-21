
use("iopt")

DokGen do(
  Options = Origin mimic do(
    create = method(
      self with(imports: [], uses: [], hasHelp?: false,
        outputDir: "dok", combineWithSpecs?: true, specsPattern: "test/**/*_spec.ik",
        collectBeforeTests: false
      )
    )

    shouldRun? = method(!hasHelp?)

    run = method(
      imports each(i, System loadPath << i)
      uses each(u, use(u))

      collected = DokGen Collected from({}, {}, {})
      if(collectBeforeTests,
        collected collectedKinds["IokeGround"] = IokeGround
        collected collectedKinds["Ground"] = Ground
        DokGen collect(IokeGround, collected)
        if(combineWithSpecs?,
          DokGen collectSpecs(specsPattern, collected collectedSpecs, collected)
        )
        ,
        DokGen collectSpecsOnly(specsPattern, collected)
      )
      DokGen generate(outputDir, collected)
    )
  )

  OptionParser = IOpt mimic do(
    create = method(
      newOP = self mimic
      newOP options = DokGen Options create
      newOP)

    banner = "Usage: dokgen [options]"

    on("-h", "--help", "Display usage.", @options hasHelp? = true)

    on("-I", "Add the specified directory to the load path before running anything", import,
      @options imports << import)

    on("-u", "Use the specified file before doing testing", ufile,
      @options uses << ufile)

    on("-o", "--output", "The directory to place generated files in. Everything in this directory will be overwritten", dir,
      @options outputDir = dir)

    on("-S", "--nospec", "Don't combine documentation with specs. This implies -t.",
      @options combineWithSpecs? = false
      @options collectBeforeTests = true
    )

    on("-s", "--specs", "Use the specified pattern to find specs to load", pattern,
      @options specsPattern = pattern)

    on("-t", "--traverse", "Collect by traversal instead of by using the specs",
      @options collectBeforeTests = true)

    order = method(argv,
      parse!(argv)
      options)

    order! = method(argv,
      order(argv)
      if(options hasHelp?, System out println(self). System exit(0))
      options)
  )

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
    "Builds up the documentation about all data in the system",

    if(dok_options shouldRun?,
      dok_options run,
      dok_options banner println
    )
  )
)
