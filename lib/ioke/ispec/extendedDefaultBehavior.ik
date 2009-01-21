
ISpec do(
  ExtendedDefaultBehavior = Mixins mimic
  ExtendedDefaultBehavior should = macro(
    "the base of the whole matching of Affirm",
    ISpec ShouldContext create(cell(:self), call message)
  )
  ExtendedDefaultBehavior describe = macro(
    "takes one evaluated argument that describes what is being tested. if it's not a Text, the kind will be used in the description. the second argument should be code that will be evaluated inside a DescriptionContext, where you can use either 'describe' or 'it'.",

    describesWhat = call argAt(0)
    unless(describesWhat mimics?(Text), describesWhat = (describesWhat kind split(" ") last))
    
    context = ISpec DescribeContext create
    context describesWhat = describesWhat

    if(self mimics?(ISpec DescribeContext),
      context surrounding = self)

    call arguments second evaluateOn(context, context)

    if(self mimics?(ISpec DescribeContext),
      self specs << [:description, context],
      ISpec specifications << context))
)
