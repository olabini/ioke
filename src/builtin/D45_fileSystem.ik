FileSystem do(
  ensureDirectory = method(
    "takes one argument that is the relative or absolute path to something that should be a directory. if it exists but isn't a directory, a condition will be signalled. if it exists, and is a directory, nothing is done, and if it doesn't exist it will be created.",
    dir,

    if(exists?(dir),
      if(file?(dir),
        bind(restart(ignore, fn()),
          error!(Condition Error IO, text: "Can't create directory #{dir}, since it already exists and is a file"))),

      createDirectory!(dir, true)
    )
  )

  readLines = method(
    "reads the full content of a file and returns a list containing each line of the file as a separate element of the list.",
    fileName,

    if(System windows?,
      readFully(filename) split("\r\n"),
      readFully(fileName) split)
  )
)
