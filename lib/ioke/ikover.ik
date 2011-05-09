
IKover = Origin mimic do(
  addCoverageData = method(data,
    @coverageData = data
  )

  processCoverage = method(
    allData = []
    coverageData each(e,
      filename = e key
      if(filename != "<init>",
        e value each(e2,
          line = e2 key
          if(line != -1,
            e2 value each(e3,
              pos = e3 key
              if(pos != -1,
                allData << [filename, line, pos, e3 value]
              )
            )
          )
        )
      )
    )
    allData sort!
    allData each(inspect println)
  )
)
