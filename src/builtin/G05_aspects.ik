
DefaultBehavior Aspects before = method(+joinPoints, matching:, except:, 
  Pointcut with(receiver: self, joinPoints: joinPoints, matching: cell(:matching), except: except, type: :before))

DefaultBehavior Aspects after = method(+joinPoints, matching:, except:, 
  Pointcut with(receiver: self, joinPoints: joinPoints, matching: cell(:matching), except: except, type: :after))

DefaultBehavior Aspects around = method(+joinPoints, matching:, except:, 
  Pointcut with(receiver: self, joinPoints: joinPoints, matching: cell(:matching), except: except, type: :around))

DefaultBehavior Aspects Pointcut = Origin mimic

DefaultBehavior Aspects Pointcut advice? = method(obj,
  cell(:obj) cell?(:kind?) && (cell(:obj) kind?("DefaultMacro") && cell(:obj) cell?(:advice))
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

  theMacro = nil
  case(type,
    :before,
    theMacro = if(cacheCall?(cell(:advice)),
      if(cacheCall?(cell(:primary)),
        macro(
          call activateValueWithCachedArguments(@@ cell(:advice))
          call activateValueWithCachedArguments(@@ cell(:primary))),
        macro(
          call activateValueWithCachedArguments(@@ cell(:advice))
          call resendToValue(@@ cell(:primary)))),
      if(cacheCall?(cell(:primary)),
        macro(
          call activateValue(@@ cell(:advice))
          call activateValueWithCachedArguments(@@ cell(:primary))),
        macro(
          call activateValue(@@ cell(:advice))
          call resendToValue(@@ cell(:primary))))),
    :after,
    theMacro = if(cacheCall?(cell(:advice)),
      if(cacheCall?(cell(:primary)),
        macro(
          result = call activateValueWithCachedArguments(@@ cell(:primary))
          call activateValueWithCachedArguments(@@ cell(:advice), aspectResult: result)
          result
          ),
        macro(
          result = call resendToValue(@@ cell(:primary))
          call activateValueWithCachedArguments(@@ cell(:advice), aspectResult: result)
          result
          )),
      if(cacheCall?(cell(:primary)),
        macro(
          result = call activateValueWithCachedArguments(@@ cell(:primary))
          call activateValue(@@ cell(:advice), aspectResult: result)
          result
          ),
        macro(
          result = call resendToValue(@@ cell(:primary))
          call activateValue(@@ cell(:advice), aspectResult: result)
          result))),
    :around,
    theMacro = if(cacheCall?(cell(:advice)),
      if(cacheCall?(cell(:primary)),
        macro(
          call activateValueWithCachedArguments(@@ cell(:advice), aspectCall: lecro(call activateValueWithCachedArguments(outerScope @@ cell(:primary))))
          ),
        macro(
          call activateValueWithCachedArguments(@@ cell(:advice), aspectCall: lecro(call resendToValue(outerScope @@ cell(:primary))))
          )),
      if(cacheCall?(cell(:primary)),
        macro(
          call activateValue(@@ cell(:advice), aspectCall: lecro(call activateValueWithCachedArguments(outerScope @@ cell(:primary))))
          ),
        macro(
          call activateValue(@@ cell(:advice), aspectCall: lecro(call resendToValue(outerScope @@ cell(:primary)))))))
  )

  cell(:theMacro) pointcut = self
  cell(:theMacro) advice = cell(:advice)
  cell(:theMacro) primary = cell(:primary)
  cell(:theMacro) documentation = cell(:primary) documentation
  if(adviceName, cell(:theMacro) adviceName = adviceName)
  if(advice?(cell(:primary)), cell(:primary) outerAdvice = cell(:theMacro))
  self cell(:receiver) cell(cellName) = cell(:theMacro)
)

DefaultBehavior Aspects Pointcut cell("<<") = method(advice,
  joins = set(*joinPoints)
  addToJoins(self cell(:matching), joins)
  removeFromJoins(self cell(:except), joins)
  joins remove!(:kind)

  joins each(cellName, addAdviceOnCell(cellName, cell(:advice)))
  self
)

DefaultBehavior Aspects Pointcut add = method(name, advice,
  joins = set(*joinPoints)
  addToJoins(self cell(:matching), joins)
  removeFromJoins(self cell(:except), joins)
  joins remove!(:kind)

  joins each(cellName, addAdviceOnCell(cellName, cell(:advice), name))
  self
)

Condition Error NoSuchAdvice = Condition Error mimic

DefaultBehavior Aspects Pointcut removeFirstNamedAdvice = method(cellName, name, 
  currVal = self cell(:receiver) cell(cellName)
  while(advice?(cell(:currVal)),
    if(cell(:currVal) cell?(:adviceName) && cell(:currVal) adviceName == name && cell(:currVal) pointcut type == self type,
      if(cell(:currVal) cell?(:outerAdvice),
        outer = cell(:currVal) cell(:outerAdvice)
        cell(:outer) primary = cell(:currVal) cell(:primary)
        if(advice?(cell(:currVal) cell(:primary)),
          cell(:currVal) cell(:primary) outerAdvice = cell(:outer)),
        self cell(:receiver) cell(cellName) = cell(:currVal) cell(:primary)
        if(advice?(cell(:currVal) cell(:primary)),
          cell(:currVal) cell(:primary) removeCell!(:outerAdvice))
      )
      return
    )
    
    currVal = cell(:currVal) cell(:primary)
  )

  bind(restart(ignore, fn),
    error!(Condition Error NoSuchAdvice, cellName: cellName, adviceName: name))
)

DefaultBehavior Aspects Pointcut removeAllNamedAdvice = method(cellName, name, 
  currVal = self cell(:receiver) cell(cellName)
  while(advice?(cell(:currVal)),
    if(cell(:currVal) cell?(:adviceName) && cell(:currVal) adviceName == name && cell(:currVal) pointcut type == self type,
      if(cell(:currVal) cell?(:outerAdvice),
        outer = cell(:currVal) cell(:outerAdvice)
        cell(:outer) primary = cell(:currVal) cell(:primary)
        if(advice?(cell(:currVal) cell(:primary)),
          cell(:currVal) cell(:primary) outerAdvice = cell(:outer)),
        self cell(:receiver) cell(cellName) = cell(:currVal) cell(:primary)
        if(advice?(cell(:currVal) cell(:primary)),
          cell(:currVal) cell(:primary) removeCell!(:outerAdvice))
      )
    )
    
    currVal = cell(:currVal) cell(:primary)
  )
)

DefaultBehavior Aspects Pointcut remove = method(name, 
  joins = set(*joinPoints)
  addToJoins(self cell(:matching), joins)
  removeFromJoins(self cell(:except), joins)
  joins remove!(:kind)

  joins each(cellName, removeFirstNamedAdvice(cellName, name))
  self
)

DefaultBehavior Aspects Pointcut removeAll = method(name, 
  joins = set(*joinPoints)
  addToJoins(self cell(:matching), joins)
  removeFromJoins(self cell(:except), joins)
  joins remove!(:kind)

  joins each(cellName, removeAllNamedAdvice(cellName, name))
  self
)
