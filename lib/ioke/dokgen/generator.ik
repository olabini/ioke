
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
    
    generateFromTemplate = method(template, out:, +:krest,
      FileSystem withOpenFile(out, fn(f, template generateIntoFile(f, *krest)))
    )

    generateFileFrame = method(dir, files,
      names = (files keys sort - ["<init>"]) map(fname,
        [htmlizeName(fname), fname])

      content = "%*[<a href=\"files/%s\">%s</a><br />\n%]" format(names)

      generateFromTemplate(Templates FileFrame, 
        out: "#{dir}/fr_file_index.html", 
        content: content)
    )

    htmlizeName = method(name,
      if(#/ik$/ =~ name,
        "#{name[0..-4]}.html",
        "#{name}.html"))

    generateFileFile = method(dir, sourceFileName, info,
      segments = sourceFileName split("/") length
      beforeLinks = "../" * (segments + 1)

      htmlFile = "#{dir}/files/#{htmlizeName(sourceFileName)}"
      parent = FileSystem parentOf(htmlFile)
      FileSystem ensureDirectory(parent)
      methods = []
      macros = []
      
      "" println
      "generating: " print
      sourceFileName println
      "----------------" println

      info each(v,
        if(v[2] kind?("DefaultMacro"), 
          macros << [v[0] kind replaceAll(" ", "/"), v[3], v[1], v[0] kind],
          if(v[2] kind?("Method"), 
            methods << [v[0] kind, v[3], v[1], v[0] kind])))

      methodContent = "%*[<a href=\"#{beforeLinks}kinds/%s.html#C00%s\">%s (%s)</a><br />\n%]" format(methods)
      macroContent = "%*[<a href=\"#{beforeLinks}kinds/%s.html#C00%s\">%s (%s)</a><br />\n%]" format(macros)

      methodContent println
      "++++++++++++++++++++++" println
      macroContent println

      generateFromTemplate(Templates FileFile,
        out: htmlFile,
        methodContent: methodContent,
        macroContent: macroContent,
        syntaxContent: "",
        basePath: beforeLinks
      )
    )

    generateFileFiles = method(dir, files,
      files each(f, unless(f key == "<init>", generateFileFile(dir, f key, f value)))
    )
  )

  generate = method(+args, HtmlGenerator generate(*args))
)

use("dokgen/htmlGenerator/templates")
