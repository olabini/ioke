

ISpec = Origin mimic

use("ispec/conditions")
use("ispec/formatter")
use("ispec/reporter")
use("ispec/expectations")
use("ispec/extendedDefaultBehavior")
use("ispec/describeContext")
use("ispec/runner")

ISpec specifications = []

DefaultBehavior mimic!(ISpec ExtendedDefaultBehavior)
