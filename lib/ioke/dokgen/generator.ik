
DokGen do(
  HtmlGenerator = Origin mimic do(
    generate = method(directory, +collections,

      FileSystem ensureDirectory(directory)
    )
  )
  generate = HtmlGenerator cell(:generate)
)
