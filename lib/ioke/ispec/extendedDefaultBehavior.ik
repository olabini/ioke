
ISpec do(
  ExtendedDefaultBehavior = Mixins mimic

  ExtendedDefaultBehavior should = macro(
    "the base of the whole matching of Affirm",
    ISpec ShouldContext create(cell(:self), call message)
  )

  ExtendedDefaultBehavior describe = macro(
    "takes one evaluated argument that describes what is being tested. if it's not a Text, the kind will be used in the description. Optional second argument should be dict with tags describing context (at the moment {pending: true} is supported). The last argument should be code that will be evaluated inside a DescriptionContext, where you can use either 'describe' or 'it'.",
    ISpec Runner registerAtExitHook

    describesWhat = call argAt(0)

    unless(describesWhat mimics?(Text), describesWhat = (describesWhat kind split(" ") last))

    surrounding = if(self mimics?(ISpec DescribeContext),
      self,
      ISpec DescribeContext)

    tags = if(call arguments length == 3,
      call argAt(1),
      {})

    context = ISpec DescribeContext create(surrounding, describesWhat, tags)

    call arguments last evaluateOn(context, context)
  )
)
