
ISpec = Origin mimic

use("ispec/conditions")
use("ispec/formatter")
use("ispec/reporter")
use("ispec/expectations")
use("ispec/extendedDefaultBehavior")
use("ispec/describeContext")
use("ispec/runner")

ISpec specifications = []

ISpec ispec_options = method(
  parser = ISpec Runner OptionParser create(System err, System out)
  parser order!(System programArguments)
  ISpec ispec_options = parser options)

DefaultBehavior mimic!(ISpec ExtendedDefaultBehavior)
