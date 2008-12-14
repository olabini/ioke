
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

    copyStationaryFiles = method(dir,
      copyStationary("dokgen-style.css", dir)
      copyStationary("index.html", dir)
    )

    copyReadmeIfAvailable = method(dir,
      if(FileSystem exists?("README"),

        generateFromTemplate(Templates Readme, 
          out: "#{dir}/files/README.html", 
          content: FileSystem readFully("README"),
          basePath: "../"),

        copyStationary("README.html", "#{dir}/files"))
    )

    copyStationary = method(file, dir,
      FileSystem copyFile("#{System currentDirectory}/htmlGenerator/stationary/#{file}", dir)
    )
    
    generateFromTemplate = method(template, out:, content:, basePath:,
      FileSystem withOpenFile(out, fn(f, template generateIntoFile(f, content: content, basePath: basePath)))
    )

    generateFileFrame = method(dir, files,
      names = (files keys sort - ["<init>"]) map(fname,
        [if(#/ik$/ =~ fname,
            "#{fname[0..-4]}.html",
            "#{fname}.html"), fname])

      content = "%*[<a href=\"files/%s\">%s</a><br />\n%]" format(names)

      generateFromTemplate(Templates FileFrame, 
        out: "#{dir}/fr_file_index.html", 
        content: content),
    )
  )

  generate = method(+args, HtmlGenerator generate(*args))
)

use("dokgen/htmlGenerator/templates")
