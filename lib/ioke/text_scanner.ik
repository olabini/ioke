TextScanner = Origin mimic do(
  initialize = method("initialize a new text scanner with a given piece of text",
    text,
    @text = text  ;The text to be scanned

    @position = 0 ;The position of the scan pointer. In the initial or 'reset' position, this value is zero. 
                  ;In the 'terminated' position (i.e. the text has been completely scanned), 
                  ;this value is the length of the text

    @internal:matchData = nil  ;The result of the last match
    @match = nil
    @delimiter = #/\s+/ ;The pattern which describes the default delimiter between tokens
  )

  next = method("Returns the next token after the position as delimited by the default delimeter and advances the pointer",
    internal:scan(internal:alterPatternToAlsoMatchLineEnd(delimiter), matchFromPointer: false, returnPositionToMatch: true)
  )

  hasNext? = method("Returns the next token after the position as delimited by the default delimeter but does not advance the pointer",
    internal:scan(internal:alterPatternToAlsoMatchLineEnd(delimiter), advancePointer: false, matchFromPointer: false, returnPositionToMatch: true)
  )

  scan = method("Takes one parameter, a regular expression, and will check for a match starting at the current position pointer. If a match exists it will advance the position pointer to the next match and return that match",
    pattern,
    internal:scan(pattern)
  )

  positionScan = method("Takes one parameter, a regular expression, and will check for a match starting at the current position pointer. If a match exists it will advance the position pointer to the next match and return the pointer position",
    pattern,
    if(internal:scan(pattern), position, nil)
  )

  search = method("Takes one parameter, a regular expression, and will check for a match anywhere after the current position pointer. If match exists it will advance the position pointer to the next match and return that match",
    pattern,
    internal:scan(pattern, matchFromPointer: false)
  )

  positionSearch = method("Takes one parameter, a regular expression, and will check for a match anywhere after the current position pointer. If match exists it will advance the position pointer to the next match and return the pointer position",
    pattern,
    if(internal:scan(pattern, matchFromPointer: false), position, nil)
  )

  rest = method("Returns the remainder of the text that is yet to be scanned: all the text after the pointer position",
    text[position..-1]
  )

  beforeMatch = method("Returns the text before the last match, or nil if no scanning has been performed yet",
    if(match, text[0...(position - internal:matchData[0] length)], nil)
  )

  afterMatch = method("Returns the text after tha last match, or nil if no scanning has been performed yet",
    if(match, text[position..-1], nil)
  )

  textStart? = method("Returns true if the pointer position is at the start of the text (line breaks are ignored)",
    position == 0
  )

  textEnd? = method("Returns true if the pointer position is at the end of the text (line breaks are ignored)",
    position == text length
  )

  getChar = method("Return the character at the pointer position, and advance the pointer. If the pointer is at the end of the text, return nil",
    if(textEnd?,
      nil,

      char = rest[0..0]
      @position += 1
      @match = char
      char
    )
  )

  internal:scan = method("Internal scanning method used as the core of the external methods",
    pattern, matchFromPointer: true, advancePointer: true, returnPositionToMatch: false,
    
    if(matchFromPointer, pattern =  internal:alterPatternToMatchFromHead(pattern))
    
    @internal:matchData = pattern match(rest)

    if(internal:matchData,

      fullMatch           = rest[0...(internal:matchData end)]
      fromPositionToMatch = rest[0...(internal:matchData start)]

      if(advancePointer, @position += internal:matchData end)

      if(returnPositionToMatch,
        unless(fromPositionToMatch == "", 
          @match = fromPositionToMatch
          return fromPositionToMatch),

        unless(fullMatch == "", 
          @match = fullMatch
          return fullMatch)))

    @match = nil
    nil
  )

  internal:alterPatternToMatchFromHead = method("Takes one parameter, a regexp pattern, which it converts to match against the start of some text only. This is equivalent to starting the pattern with \\A",
    pattern,
    #/\A#{pattern}/
  )

  internal:alterPatternToAlsoMatchLineEnd = method("Takes one parameter, a regexp pattern, which it converts to match against the end of the text in addition to the match itself. This is equivalent to additionally matching the pattern with \\Z",
    pattern,
    #/#{pattern}|\Z/
  )
)
