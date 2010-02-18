
IKIL generate = method(language, directory, outDirectory,
  FileSystem["#{directory}/**/*.ik"] each(name,
    use(name)
  )

  lang = case(language,
    or("-java", "-j"), Language Java,
    or("-csharp", "-c"), Language CSharp)

  definitions each(def,
    case(def definitionName,
      :IokeObject, lang createFile(def className, outDirectory, lang defineSimpleIokeObject(def className, *(def definition))),
      else, "can't handle #{def definitionName}" println
    )
  )
)
