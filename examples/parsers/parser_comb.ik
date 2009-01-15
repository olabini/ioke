
IParse = Origin mimic do(
  BaseParser   = Origin mimic do(
    .. = method(other,
      IParse RangeParser with(start: self, end: other, inclusive: true)
    )

    ... = method(other,
      IParse RangeParser with(start: self, end: other, inclusive: false)
    )

    | = method(other,
      IParse OrParser with(first: self, second: other)
    )

    + = method(other,
      IParse SequenceParser with(first: self, second: other)
    )

    cell(:"*") = method(
      IParse RepeatingParser with(repeat: self)
    )      

    cell(:"'") = dmacro([name]
      IParse ParserParser with(name: name name)
    )      
  )
  TextParser   = BaseParser mimic do(
    inspect = method("#{text inspect}")
  )
  NumberParser = BaseParser mimic do(
    inspect = method("#{number inspect}")
  )
  RangeParser  = BaseParser mimic do(
    inspect = method(dots = if(inclusive, "..", "..."). "#{start inspect}#{dots}#{end inspect}")
  )
  OrParser     = BaseParser mimic do(
    inspect = method("(#{first inspect} | #{second inspect})")
  )

  SequenceParser     = BaseParser mimic do(
    inspect = method("#{first inspect} #{second inspect}")
  )

  RepeatingParser     = BaseParser mimic do(
    inspect = method("(#{repeat inspect})*")
  )

  ParserParser        = BaseParser mimic do(
    inspect = method("#{name}")
  )

  ParserContext = Origin mimic do(
    internal:createText   = method(raw, IParse TextParser with(text: super(raw)))
    internal:createNumber = method(raw, IParse NumberParser with(number: super(raw)))
  )
  ParserContext cell(:"'") = dmacro([name]
    IParse ParserParser with(name: name name)
  )

  isSpecialName = method(name,
    case(name,
      or(:"+", :"|", :"..", :"...", :"*", :"", :"'", #/^internal:/),
      true,
      false))

  quoteMessageName = method(msg,
    if(!isSpecialName(msg name),
        newMsg = Message from(')
        newMsg << Message fromText(msg name asText)
        newMsg -> msg next
        msg become!(newMsg)
    )
  )

  insertSequencers = method(msg,
    if(msg arguments length > 0 && !isSpecialName(msg name),
      nx = msg next
      newMsg = message("")
      newMsg << msg arguments[0]
      msg -> newMsg
      msg arguments clear!
      newMsg -> nx,

      if(msg name == :"" && msg arguments length > 0,
          insertSequencers(msg arguments[0])))

    quoteMessageName(msg)

    if(msg next,
      name = msg next name
      case(name,
        or(:"+", :"|", :"..", :"..."),
          insertSequencers(msg next arguments[0])
          insertSequencers(msg next),
        :"*",
          if(msg next arguments length > 0,
            msg next -> msg next arguments[0]
            msg next arguments clear!
            insertSequencers(msg next)
          ),
        :"",
          msg next name = :"+"
          insertSequencers(msg next arguments[0])
          insertSequencers(msg next)
          ,
        else,
          insertSequencers(msg next)
          quoteMessageName(msg)
          newMsg = '(+)
          end = nil
          current = msg next
          while(current,
            if(current name == :"|",
              end = current
              break
            )
            current = current next)
          if(end,
            end prev -> nil
            newMsg -> end)
          newMsg << msg next
          msg -> newMsg))
  )

  Parser = macro(
    context = ParserContext mimic
    args = call arguments
    args each(each(a, 
        if(a arguments length > 1, 
          insertSequencers(a arguments[1]))))
    args each(evaluateOn(context, context))
    IParse "%*[%s: %s\n%]" format(context cells map(c, [c key, c value inspect])) print
  )
)

IParse Parser(
  digit   = 0..9
  letter  = ("a".."z") | ("A".."Z")
  id      = letter (letter | digit)*
  id2     = letter* (letter | digit)
  number  = 1..9 digit*
  primary = "(" expr ")" | number | id
  term    = primary ("*" | "/") term | primary
  expr    = term    ("+" | "-") expr | term
  and     = expr "and" expr | expr
)
