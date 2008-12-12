
DokGen do(
  HtmlGenerator = Origin mimic do(
    generate = method(directory, collection,
      FileSystem ensureDirectory(directory)
      FileSystem ensureDirectory("#{directory}/files")
      FileSystem ensureDirectory("#{directory}/kinds")

      copyStationaryFiles(directory)
      copyReadmeIfAvailable(directory)

      generateFileFrame(directory, collection collectedFiles)
      generateFileFiles(directory, collection collectedFiles)

      generateKindFrame(directory, collection collectedKinds)
      generateKindFiles(directory, collection collectedKinds, collection collectedKells)

      generateCellFrame(directory, collection collectedKells)
    )
  )

  generate = method(+args, HtmlGenerator generate(*args))
)
