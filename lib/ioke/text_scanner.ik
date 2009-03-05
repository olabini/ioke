TextScanner = Origin mimic do(
  initialize = method("initialize a new text scanner with a given piece of text",
    text,
    @text = text  ;The text to be scanned

    @position = 0 ;The position of the scan pointer. In the initial or 'reset' position, this value is zero. 
                  ;In the 'terminated' position (i.e. the text has been completely scanned), 
                  ;this value is the length of the text

    @match = nil  ;The result of the last match
  )

  scan = method("Takes one parameter, a regular expression, and will check for a match starting at the current position pointer. If a match exists it will advance the position pointer to the next match and return that match",
    pattern,
    internal:scan(pattern)
  )

  search = method("Takes one parameter, a regular expression, and will check for a match anywhere after the current position pointer. If match exists it will advance the position pointer to the next match and return that match",
    pattern,
    internal:scan(pattern, matchFromHead: false)
  )

  rest = method("Returns the remainder of the text that is yet to be scanned: all the text after the pointer position",
    text[position..-1]
  )

  beforeMatch = method("Returns the text before the last match, or nil if no scanning has been performed yet",
    if(match, text[0...(position - match[0] length)], nil)
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
      return nil,

      char = rest[0..0]
      @position += 1
      char
    )
  )

  internal:scan = method("blah blah",
    pattern, matchFromHead: true, advancePointer: true, returnMatch: true,
    
    if(matchFromHead, pattern =  internal:alterPatternToMatchFromHead(pattern))
    
    @match = pattern match(rest)

    if(@match,
      fullMatch = rest[0...(@match end)]
      @position += @match end
      return fullMatch,

      return nil)
  )

  internal:alterPatternToMatchFromHead = method("Takes one parameter, a regexp pattern, which it converts to match against the start of some text only. This is equivalent to starting the pattern with ^",
    pattern,
    #/^#{pattern inspect[2..-2]}/
  )
)