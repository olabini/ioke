
Origin with(
  directory: "coverage-report",
  files: fn(file,
    case(file,
      #r[test/.*\Z], false,
      #r[bin/.*\Z], false,
      #/\.file_system_test_config.ik\Z/, false,
      else, true
    )
  )
)
