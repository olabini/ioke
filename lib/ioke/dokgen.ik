
DokGen = Origin mimic

use("dokgen/collector")
use("dokgen/generator")
use("dokgen/runner")

DokGen dok_options = method(
  parser = DokGen OptionParser create
  parser order!(System programArguments)
  DokGen dok_options = parser options)

