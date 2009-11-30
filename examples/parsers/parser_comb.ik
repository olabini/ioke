
IParse = Origin mimic do(
  BaseParser   = Origin mimic do(
    .. = method(other,
      IParse RangeParser with(context: context, start: self, end: other, inclusive: true)
    )

    ... = method(other,
      IParse RangeParser with(context: context, start: self, end: other, inclusive: false)
    )

    | = method(other,
      IParse OrParser with(context: context, first: self, second: other)
    )

    + = method(other,
      IParse SequenceParser with(context: context, first: self, second: other)
    )

    cell(:"*") = method(
      IParse RepeatingParser with(context: context, repeat: self)
    )

    cell(:"'") = dmacro([name]
      IParse ParserParser with(context: context, name: name name)
    )

    parse = method(input,
      len = input length
      if(self match(input, 0, len) == len,
        input[0...len],
        nil)
    )
  )
  TextParser   = BaseParser mimic do(
    inspect = method("#{text inspect}")
    match = method(str, start, end,
      if((end-start) >= text length && str[start...(start + text length)] == text,
        start + text length,
        start)
    )
  )
  NumberParser = BaseParser mimic do(
    inspect = method("#{number inspect}")
    match = method(str, start, end,
      if(start < end && (str[start] - 48) == self number,
        start + 1,
        start
      )
    )
  )
  RangeParser  = BaseParser mimic do(
    inspect = method(dots = if(inclusive, "..", "..."). "#{start inspect}#{dots}#{end inspect}")
    match = method(str, start, end,
      range = if(self start mimics?(IParse NumberParser),
        if(inclusive,
          (self start number + 48)..(self end number + 48),
          (self start number + 48)...(self end number + 48)),
        if(inclusive,
          (self start text[0])..(self end text[0]),
          (self start text[0])...(self end text[0])))
      if(range === str[start],
        start + 1,
        start))
  )
  OrParser     = BaseParser mimic do(
    inspect = method("(#{first inspect} | #{second inspect})")
    match = method(str, start, end,
      val = self first match(str, start, end)
      if(val > start,
        return val,
        self second match(str, start, end))
    )
  )
  SequenceParser     = BaseParser mimic do(
    inspect = method("#{first inspect} #{second inspect}")
    match = method(str, start, end,
      newStart = start
      val = self first match(str, start, end)
      if(val > start,
        newStart = val,
        return start)
      val = self second match(str, newStart, end)
      if(newStart < end && val > start,
        return val,
        return start)
    )
  )
  RepeatingParser     = BaseParser mimic do(
    inspect = method("(#{repeat inspect})*")
    match = method(str, start, end,
      currentStart = start
      while(currentStart < end,
        res = self repeat match(str, currentStart, end)
        if(res > currentStart,
          currentStart = res,
          return currentStart))
      currentStart
    )
  )
  ParserParser        = BaseParser mimic do(
    inspect = method("#{name}")
    match = method(str, start, end,
      val = context cell(name) match(str, start, end)
      if(val > start,
        val,
        start)
    )
  )

  ParserContext = Origin mimic do(
    internal:createText   = method(raw, IParse TextParser with(context: self, text: super(raw)))
    internal:createNumber = method(raw, IParse NumberParser with(context: self, number: super(raw)))
  )
  ParserContext cell(:"'") = dmacro([name]
    IParse ParserParser with(context: self, name: name name)
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

  try1 = method(msg,
    msg rewrite:recursively(
      '(:not(internal:createNumber, internal:createText, +, .., ..., *, |, (), :x)) => '('(:x))
    ) code println
  )

  Parser = macro(
    context = ParserContext mimic
    args = call arguments
    args each(each(a,
        if(a arguments length > 1,
          a arguments[1] code println
          try1(a arguments[1])
          insertSequencers(a arguments[1])
          a arguments[1] code println
          "" println
)))
    args each(evaluateOn(context, context))
    context
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

prog = IParse Parser(program = 4 0..9) program
prog2 = IParse Parser(program = 4 "a".."f") program
prog3 = IParse Parser(program = 4 "a"..."f") program
prog4 = IParse Parser(program = 4*) program
prog5 = IParse Parser(program = (1..9)*) program
prog6 = IParse Parser(
  digit = 0..9
  program = digit*) program
prog7 = IParse Parser(
  digit = 0..9
  letter = "a".."z"
  program = digit | letter) program
prog8 = IParse Parser(program = "fluxie" 2..9) program

use("ispec")

prog parse("4A") should be nil
prog parse("41") should == "41"
prog parse("42") should == "42"
prog2 parse("4x") should be nil
prog2 parse("4a") should == "4a"
prog2 parse("4b") should == "4b"
prog2 parse("4c") should == "4c"
prog2 parse("4d") should == "4d"
prog2 parse("4e") should == "4e"
prog2 parse("4f") should == "4f"
prog2 parse("4g") should be nil
prog3 parse("4f") should be nil
prog4 parse("4") should == "4"
prog4 parse("44444444444444444444444444444444") should == "44444444444444444444444444444444"
prog4 parse("44444444444444444444444444444443") should be nil
prog5 parse("123") should == "123"
prog5 parse("1203") should be nil
prog6 parse("123") should == "123"
prog6 parse("1203") should == "1203"
prog6 parse("1203a") should be nil
prog7 parse("3") should == "3"
prog7 parse("q") should == "q"
prog7 parse("Q") should be nil
prog8 parse("fluxie1") should be nil
prog8 parse("fluxie2") should == "fluxie2"
prog8 parse("fluxie8") should == "fluxie8"
prog8 parse("fluxie22") should be nil
prog8 parse("flUxie4") should be nil
