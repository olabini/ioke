
DefaultBehavior Case AndCombiner = Origin with(components: [])
DefaultBehavior Case AndCombiner === = method(other,
  components all?(=== other))

DefaultBehavior Case case:and = method(+args,
  DefaultBehavior Case AndCombiner with(components: args))



DefaultBehavior Case Else = Origin mimic
DefaultBehavior Case Else === = method(other,
  true)

DefaultBehavior Case case:otherwise = method(
  DefaultBehavior Case Else)

DefaultBehavior Case case:else = method(
  DefaultBehavior Case Else)
