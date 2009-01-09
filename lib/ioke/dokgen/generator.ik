
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
      generateKindFiles(directory, collection collectedKinds, collection collectedCells, collection collectedSpecs)
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
          cellData << [ccc[0] kind replaceAll(" ", "/"), ccc[3], makeTextHtmlSafe(c asText), ccc[0] kind]))

      content = "%*[<a href=\"kinds/%s.html#C00%s\">%s (%s)</a><br />\n%]" format(cellData)
      generateFromTemplate(Templates CellFrame, 
        out: "#{dir}/fr_cell_index.html", 
        content: content)
    )

    generateKindFile = method(dir, kindName, theKind, cells, specs, kindSpecs,
      segments = kindName split(" ")
      beforeLinks = "../" * (segments length)
      htmlFile = "#{dir}/kinds/#{kindName replaceAll(" ", "/")}.html"

      parent = FileSystem parentOf(htmlFile)
      FileSystem ensureDirectory(parent)

      mainMimicContent = "none"
      allMimicsContent = "none"

      unless(Base == cell(:theKind),
        allMimics = if(cell(:theKind) cell?(:mimic),
          cell(:theKind) mimics,
          [])
        mainMimic = if(cell(:theKind) cell?(:mimic),
          cell(:theKind) mimics first,
          nil)

        if(allMimics length > 0,
          mainMimicContent = "<a href=\"#{beforeLinks}kinds/%s.html\">%s</a>" format(cell(:mainMimic) kind replaceAll(" ", "/"), cell(:mainMimic) kind)
          allMimicsContent = "%*[<li><a href=\"#{beforeLinks}kinds/%s.html\">%s</a></li>%]" format(allMimics map(mm, [cell(:mm) kind replaceAll(" ", "/"), cell(:mm) kind]))
        )
      )


      names = (kindSpecs keys sort) - [kindName]
      mainSpecs = kindSpecs[kindName]
      
      kindSpecsContent = ""
      
      specIndex = 0

      if(mainSpecs,
        kindSpecsContent = "<ul style=\"list-style-type: none;\">\n#{createCellSpecsOnlyFor("K0#{specIndex++}", nil, mainSpecs)}</ul>"
      )

      names each(name,
        kindSpecsContent = "#{kindSpecsContent}\n<b>#{name}</b><br/>\n<ul style=\"list-style-type: none;\">\n#{createCellSpecsOnlyFor("K0#{specIndex++}", nil, kindSpecs[name])}</ul>"
      )

      inactiveCells = []
      activeCells = []

      cell(:theKind) cells each(cc,
        if(cells[cc key asText],
          vex = cells[cc key asText] find(val, (cell(:theKind) == val[0]) && (cell(:theKind) kind == val[0] kind))
          if((cc value cell?(:activatable)) && (cc value cell(:activatable)),
            theKey = "#{vex[0] kind} #{cc key}"
            activeCells << [cc key, cc value, vex, vex[2] argumentsCode],
            inactiveCells << [cc key, cc value, vex])))

      activeCells = activeCells sortBy(v, [v[0], v[2][3]])
      inactiveCells = inactiveCells sortBy(v, [v[0], v[2][3]])

      inactiveCellsSummary = "%*[<li><a href=\"#C00%s\">%s</a></li>\n%]" format(inactiveCells map(val, [val[2][3], makeTextHtmlSafe(val[0] asText)]))
      activeCellsSummary = "%*[<li><a href=\"#C00%s\">%s(%s)</a></li>\n%]" format(activeCells map(val, [val[2][3], makeTextHtmlSafe(val[0] asText), makeTextHtmlSafe(val[3])]))

      inactiveCellsContent = "%[%s\n%]" format(inactiveCells map(ic, Templates KindFile inactiveCellData(cellName: makeTextHtmlSafe(ic[0] asText), cellValue: ic[1] notice, cellId: ic[2][3])))
      activeCellsContent = "%[%s\n%]"   format(activeCells   map(ic, Templates KindFile activeCellData(cellName: makeTextHtmlSafe(ic[0] asText), cellDescription: ic[1] documentation, cellId: ic[2][3], cellArguments: makeTextHtmlSafe(ic[3]), cellSpecs: createCellSpecsFor(ic[2][3], ic, ic[2][4]), cellMessage: if(ic[2][2] cell?(:formattedCode), makeTextHtmlSafe(ic[2][2] formattedCode), nil))))

      generateFromTemplate(Templates KindFile,
        out: htmlFile,
        kindName: kindName,
        kindSpecs: kindSpecsContent,
        kindDescription: cell(:theKind) documentation || "",
        allMimics: allMimicsContent,
        mainMimic: mainMimicContent,
        inactiveCellsSummary: inactiveCellsSummary,
        activeCellsSummary: activeCellsSummary,
        inactiveCellsContent: inactiveCellsContent,
        activeCellsContent: activeCellsContent,
        basePath: beforeLinks
      )
    )

    createCellSpecsFor = method(cellId, data, specData,
      ks = specData keys sort
      first = true
      if(ks length > 0,
        first = ks[0] split(" ")[-1] == data[0]
      )

      ix = 0

      "%[%s\n%]" format(ks map(key,
          if(first,
            first = false
            "<ul style=\"list-style-type: none;\">\n#{createCellSpecsOnlyFor("#{cellId}#{ix++}", nil, specData[key])}</ul>",
            "<b>#{key}</b><br/>\n<ul style=\"list-style-type: none;\">\n#{createCellSpecsOnlyFor("#{cellId}#{ix++}", nil, specData[key])}</ul>"
      )))
    )

    createCellSpecsOnlyFor = method(cellId, data, specData,
      specIndex = 0
      "%[<li>- %s</li>\n%]" format(specData map(sd,
          if(sd length == 1,
            sd[0],

            result = "#{sd[0]} <span class=\"sourcecode\">
            <span class=\"source-link\">[ <a href=\"javascript:toggleSource('C00#{cellId}S#{specIndex}_source')\" id=\"l_C00#{cellId}S#{specIndex}_source\">show source</a> ]</span>
            <div id=\"C00#{cellId}S#{specIndex}_source\" class=\"dyn-source\">
<pre>
#{makeTextHtmlSafe(sd[1] formattedCode)}
</pre>
            </div>
            </span>"
            specIndex++
            result
    ))))

    makeTextHtmlSafe = method(text,
      text replaceAll("<", "&lt;") replaceAll(">", "&gt;"))

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
          macros << [v[0] kind replaceAll(" ", "/"), v[3], makeTextHtmlSafe(v[1] asText), v[0] kind],
          if(v[2] kind?("Method"), 
            methods << [v[0] kind replaceAll(" ", "/"), v[3], makeTextHtmlSafe(v[1] asText), v[0] kind])))

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

    generateKindFiles = method(dir, kinds, cells, specs,
      kinds each(k, generateKindFile(dir, k key, k value first, cells, specs, k value second))
    )
  )

  generate = method(+args, HtmlGenerator generate(*args))
)

use("dokgen/htmlGenerator/templates")
