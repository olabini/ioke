ConditionX = Origin mimic
ConditionX do(
  Restart = Origin mimic do(
    create = method(name, report, test, block, 
      r = self mimic
      r inspect println
      r name = name
      r report = report
      r test = test
      r block = block
      r inspect println
      r)
    invoke = method(
      self block call)))

DefaultBehavior restartx = method(
  "takes one required argument, one optional and two keyword arguments, report: and test:. will create a new restart with the supplied arguments. the required argument should be a lexical block that actually implements the restart in question. the optional argument should come before the other one, and is the name of the restart in question. currently this need to be a Text, but as soon as macros are in, this name will be an unevaluated argument. the report: argument should generate a Text to present to the user in an interactive session. if not provided, or nil, it will default to the name of the restart, or nil. it can be either callable that takes one argument, or a Text. the test: argument should be a predicate that returns true or false depending on if this restart is defined for the argument sent in to the predicate.",
  name,
  report:,
  test: fn(c, true),
  block nil,

  if(block nil?, block = name. name = nil)
  ConditionX Restart create(name, report, test, block))
