
DefaultBehavior Case AndCombiner = Origin with(components: [])
DefaultBehavior Case AndCombiner === = method(other,
  components all?(=== other))

DefaultBehavior Case case:and = method(+args,
  DefaultBehavior Case AndCombiner with(components: args))


DefaultBehavior Case OrCombiner = Origin with(components: [])
DefaultBehavior Case OrCombiner === = method(other,
  components any?(=== other))

DefaultBehavior Case case:or = method(+args,
  DefaultBehavior Case OrCombiner with(components: args))


DefaultBehavior Case NotCombiner = Origin with(other: nil)
DefaultBehavior Case NotCombiner === = method(oo,
  unless(other === oo, true, false))

DefaultBehavior Case case:not = method(other,
  DefaultBehavior Case NotCombiner with(other: other))


DefaultBehavior Case NAndCombiner = Origin with(first: nil, components: [])
DefaultBehavior Case NAndCombiner === = method(other,
  !((self first === other) && components all?(=== other)))

DefaultBehavior Case case:nand = method(first, +args,
  DefaultBehavior Case NAndCombiner with(first: first, components: args))





DefaultBehavior Case Else = Origin mimic
DefaultBehavior Case Else === = method(other,
  true)

DefaultBehavior Case case:otherwise = method(
  DefaultBehavior Case Else)

DefaultBehavior Case case:else = method(
  DefaultBehavior Case Else)
