
DokGen do(
  HtmlGenerator = Origin mimic do(
    generate = method(directory, collection,
      FileSystem ensureDirectory(directory)
      FileSystem ensureDirectory("#{directory}/files")
      FileSystem ensureDirectory("#{directory}/kinds")

      copyStationaryFiles(directory)
      copyReadmeIfAvailable(directory)

      generateFileFrame(directory, collection collectedFiles)
      generateKindFrame(directory, collection collectedKinds)
      generateCellFrame(directory, collection collectedCells)

      generateFileFiles(directory, collection collectedFiles)
      generateKindFiles(directory, collection collectedKinds, collection collectedCells)
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

    generateKindFrame = method(dir, kinds,
      allKinds = kinds keys sort map(x, [x replaceAll(" ", "/"), x])

      content = "%*[<a href=\"kinds/%s.html\">%s</a><br />\n%]" format(allKinds)
      generateFromTemplate(Templates KindFrame, 
        out: "#{dir}/fr_kind_index.html", 
        content: content)
    )

    generateCellFrame = method(dir, cells,
      cellData = []
      cells keys sort each(c, 
        xx = cells[c] sortBy(cc, [cc[0] kind, cc[3]])
        xx each(ccc,
          cellData << [ccc[0] kind replaceAll(" ", "/"), ccc[3], c asText replaceAll("<", "&lt;") replaceAll(">", "&gt;"), ccc[0] kind]))

      content = "%*[<a href=\"kinds/%s.html#C00%s\">%s (%s)</a><br />\n%]" format(cellData)
      generateFromTemplate(Templates CellFrame, 
        out: "#{dir}/fr_cell_index.html", 
        content: content)
    )

    generateKindFile = method(dir, kindName, theKind, cells,
      segments = kindName split(" ")
      beforeLinks = "../" * (segments length)
      htmlFile = "#{dir}/kinds/#{kindName replaceAll(" ", "/")}.html"

      parent = FileSystem parentOf(htmlFile)
      FileSystem ensureDirectory(parent)

      mainMimicContent = "none"
      allMimicsContent = "none"

      unless(Base == cell(:theKind),
        allMimics = cell(:theKind) mimics
        mainMimic = cell(:theKind) mimics first

        if(allMimics length > 0,
          mainMimicContent = "<a href=\"#{beforeLinks}kinds/%s.html\">%s</a>" format(cell(:mainMimic) kind replaceAll(" ", "/"), cell(:mainMimic) kind)
          allMimicsContent = "%*[<li><a href=\"#{beforeLinks}kinds/%s.html\">%s</a></li>%]" format(allMimics map(mm, [cell(:mm) kind replaceAll(" ", "/"), cell(:mm) kind]))
        )
      )
      
      inactiveCells = []
      activeCells = []

      cell(:theKind) cells each(cc,
        if(cells[cc key asText],
          vex = cells[cc key asText] find(val, cell(:theKind) == val[0])
          if((cc value cell?(:activatable)) && (cc value cell(:activatable)),
            activeCells << [cc key, cc value, vex, vex[2] argumentsCode],
            inactiveCells << [cc key, cc value, vex])))

      activeCells = activeCells sortBy(v, [v[0], v[2][3]])
      inactiveCells = inactiveCells sortBy(v, [v[0], v[2][3]])

      inactiveCellsSummary = "%*[<li><a href=\"#C00%s\">%s</a></li>\n%]" format(inactiveCells map(val, [val[2][3], val[0] asText replaceAll("<", "&lt;") replaceAll(">", "&gt;")]))
      activeCellsSummary = "%*[<li><a href=\"#C00%s\">%s(%s)</a></li>\n%]" format(activeCells map(val, [val[2][3], val[0] asText replaceAll("<", "&lt;") replaceAll(">", "&gt;"), val[3] replaceAll("<", "&lt;") replaceAll(">", "&gt;")]))

      inactiveCellsContent = "%[%s\n%]" format(inactiveCells map(ic, Templates KindFile inactiveCellData(cellName: ic[0], cellValue: ic[1] notice, cellId: ic[2][3])))


;       "generateKindFile(#{kindName}) -> #{htmlFile}" println
;       "-=-=-=-=-=-" println
;       "active" println
;       activeCells map(first) inspect println
;       "inactive" println
;       if(DefaultBehavior == cell(:theKind),
;         activeCells map(x, [x first, x[2]]) inspect println)

      generateFromTemplate(Templates KindFile,
        out: htmlFile,
        kindName: kindName,
        kindDescription: cell(:theKind) documentation || "",
        allMimics: allMimicsContent,
        mainMimic: mainMimicContent,
        inactiveCellsSummary: inactiveCellsSummary,
        activeCellsSummary: activeCellsSummary,
        inactiveCellsContent: inactiveCellsContent,
;        activeCellsContent: activeCellsContent,
        basePath: beforeLinks
      )
    )

    generateFileFile = method(dir, sourceFileName, info,
      segments = sourceFileName split("/")
      beforeLinks = "../" * (segments length)

      htmlFile = "#{dir}/files/#{htmlizeName(sourceFileName)}"
      parent = FileSystem parentOf(htmlFile)
      FileSystem ensureDirectory(parent)
      methods = []
      macros = []
      
      ;; we need to sort on both the method name, the surrounding kind and the unique ID
      ;; since we need to guarantee a ordering. 
      ;; bad things will happen if the sort starts looking at the other elements in the list
      info sortBy(x, [x[1], x[0] kind, x[3]]) each(v,
        if(v[2] kind?("DefaultMacro"), 
          macros << [v[0] kind replaceAll(" ", "/"), v[3], v[1] asText replaceAll("<", "&lt;") replaceAll(">", "&gt;"), v[0] kind],
          if(v[2] kind?("Method"), 
            methods << [v[0] kind replaceAll(" ", "/"), v[3], v[1] asText replaceAll("<", "&lt;") replaceAll(">", "&gt;"), v[0] kind])))

      methodContent = "%*[<li><a href=\"#{beforeLinks}kinds/%s.html#C00%s\">%s (%s)</a><br /></li>\n%]" format(methods)
      macroContent = "%*[<li><a href=\"#{beforeLinks}kinds/%s.html#C00%s\">%s (%s)</a><br /></li>\n%]" format(macros)

      generateFromTemplate(Templates FileFile,
        out: htmlFile,
        filePath: sourceFileName,
        simpleFileName: segments last,
        fileDate: "---fluxie---",
        methodContent: methodContent,
        macroContent: macroContent,
        syntaxContent: "",
        basePath: beforeLinks
      )
    )

    generateFileFiles = method(dir, files,
      files each(f, unless(f key == "<init>", generateFileFile(dir, f key, f value)))
    )

    generateKindFiles = method(dir, kinds, cells,
      kinds each(k, generateKindFile(dir, k key, k value, cells))
    )
  )

  generate = method(+args, HtmlGenerator generate(*args))
)

use("dokgen/htmlGenerator/templates")
