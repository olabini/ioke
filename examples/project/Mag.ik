
project name = "Foobarius"
project author = "Ola Bini"
project homepage = "http://ioke.org/foobarius"
project loadPath = FileSystem["lib"]
project loadFiles = FileSystem["lib/foobarius.ik"]

spec files = FileSystem["test/**_spec.ik"]

specWithCover documentation = "Run all the specs with coverage reports turned on"
specWithCover = spec with(coverage: true)
