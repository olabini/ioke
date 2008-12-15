
DokGen do(
  HtmlGenerator do(
    Templates = Origin mimic
    Templates do(
      Template = Origin mimic
      Template generateIntoFile = method(file, +:krest,
        file print(self data(*krest))
      )

      Readme = Template mimic
      Readme data = Message doText("method(content:, basePath: \"./\", \"#{FileSystem readFully("#{System currentDirectory}/Readme.ik_template")}\")")

      FileFrame = Template mimic
      FileFrame data = Message doText("method(content:, basePath: \"./\", \"#{FileSystem readFully("#{System currentDirectory}/FileFrame.ik_template")}\")")

      FileFile = Template mimic
      FileFile data = Message doText("method(simpleFileName:, filePath:, fileDate:, methodContent:, macroContent:, syntaxContent:, basePath:, \"#{FileSystem readFully("#{System currentDirectory}/Filefile.ik_template")}\")")
    )
  )
)
