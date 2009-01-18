
DefaultBehavior Aspects before = method(+joinPoints, matching:, except:, 
  Pointcut with(receiver: self, joinPoints: joinPoints, matching: cell(:matching), except: except, type: :before))

DefaultBehavior Aspects Pointcut = Origin mimic

DefaultBehavior Aspects Pointcut advice? = method(obj,
  cell(:obj) cell?(:kind?) && (cell(:obj) kind?("LexicalMacro") && cell(:obj) cell?(:advice))
)

DefaultBehavior Aspects Pointcut cacheCall? = method(obj,
  case(cell(:obj) kind,
    "DefaultMethod", true,
    "LexicalBlock", true,
    "LexicalMacro", true,
    "DefaultMacro", true,
    "DefaultSyntax", true,
    false)
)

DefaultBehavior Aspects Pointcut addToJoins = method(matches, joins,
  case(cell(:matches),
    :any,
    self cell(:receiver) cellNames(true, Origin) each(cn, joins << cn),
    :anyFromSelf,
    self cell(:receiver) cellNames(false) each(cn, joins << cn),
    or(Regexp, LexicalBlock),
    self cell(:receiver) cellNames(true, Origin) grep(cell(:matches), cn, joins << cn),
    List,
    matches each(m, addToJoins(m, joins))
  )
)

DefaultBehavior Aspects Pointcut removeFromJoins = method(excepts, joins,
  case(cell(:excepts),
    or(Regexp, LexicalBlock),
    toRemove = joins grep(cell(:excepts))
    toRemove each(tr, joins remove!(tr)),
    List,
    excepts each(ex, removeFromJoins(ex, joins)),
    Symbol,
    joins remove!(excepts)
  )
)

DefaultBehavior Aspects Pointcut addAdviceOnCell = method(cellName, advice, adviceName nil,
  primary = if(self cell(:receiver) cell?(cellName), 
    self cell(:receiver) cell(cellName), 
    macro(
      bind(restart(useValue, fn(newValue, newValue)),
        error!(Condition Error NoSuchCell, message: call message, context: call ground, receiver: call receiver, cellName: call message name))
    )
  )

  theLecro = nil
  case(type,
    :before,
    theLecro = if(cacheCall?(cell(:advice)),
      if(cacheCall?(cell(:primary)),
        lecro(
          call activateValueWithCachedArguments(cell(:advice))
          call activateValueWithCachedArguments(cell(:primary))),
        lecro(
          call activateValueWithCachedArguments(cell(:advice))
          call resendToValue(cell(:primary)))),
      if(cacheCall?(cell(:primary)),
        lecro(
          call activateValue(cell(:advice))
          call activateValueWithCachedArguments(cell(:primary))),
        lecro(
          call activateValue(cell(:advice))
          call resendToValue(cell(:primary)))))
  )

  cell(:theLecro) pointCut = self
  cell(:theLecro) primary = cell(:primary)
  cell(:theLecro) documentation = cell(:primary) documentation
  if(adviceName, cell(:theLecro) adviceName = adviceName)
  if(advice?(cell(:primary)), cell(:primary) outerAdvice = cell(:theLecro))
  self cell(:receiver) cell(cellName) = cell(:theLecro)
)

DefaultBehavior Aspects Pointcut cell("<<") = method(advice,
  joins = set(*joinPoints)
  addToJoins(self cell(:matching), joins)
  removeFromJoins(self cell(:except), joins)
  joins remove!(:kind)

  joins each(cellName, addAdviceOnCell(cell(:cellName), cell(:advice)))
  self
)

DefaultBehavior Aspects Pointcut add = method(name, advice,
  joins = set(*joinPoints)
  addToJoins(self cell(:matching), joins)
  removeFromJoins(self cell(:except), joins)
  joins remove!(:kind)

  joins each(cellName, addAdviceOnCell(cell(:cellName), cell(:advice), name))
  self
)
