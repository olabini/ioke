
Affirm do(
  ExtendedDefaultBehavior = Mixins mimic
  ExtendedDefaultBehavior should = method(
    "the base of the whole matching of Affirm",
    Affirm ShouldContext create(self)
  )
  ExtendedDefaultBehavior describe = macro(
    "takes one evaluated argument that describes what is being tested. if it's not a Text, the kind will be used in the description. the second argument should be code that will be evaluated inside a DescriptionContext, where you can use either 'describe' or 'it'.",

    describesWhat = call argAt(0)
    unless(describesWhat mimics?(Text), describesWhat = describesWhat kind)
    
    context = Affirm DescribeContext create
    context describesWhat = describesWhat

    if(self mimics?(Affirm DescribeContext),
      context surrounding = self)

    call arguments second evaluateOn(context, context)

    if(self mimics?(Affirm DescribeContext),
      self specs << [:description, context],
      Affirm specifications << context))
)
