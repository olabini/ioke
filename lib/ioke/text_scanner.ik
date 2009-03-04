TextScanner = Origin mimic do(
  initialize = method("initialize a new text scanner with a given piece of text",
    text,
    @text = text  ;"The text to be scanned"
    @position = 0 ;"The position of the scan pointer. In the initial or 'reset' position, this value is zero. In the 'terminated' position (i.e. the text has been completely scanned), this value is the length of the text"
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

  internal:scan = method("blah blah",
    pattern, matchFromHead: true, advancePointer: true, returnMatch: true,
    
    if(matchFromHead, pattern =  #/^#{pattern inspect[2..-2]}/)
    
    firstMatch = pattern match(rest)

    if(firstMatch,
      match = rest[0...(firstMatch end)]
      @position += firstMatch end
      return match,

      return nil)
  )

  internal:forcePatternToMatchFromHead = method("Takes one parameter, a regexp pattern, which it converts to match against the start of some text only. This is equivalent to starting the pattern with",
    pattern,
    #/^#{pattern inspect[2..-2]}/
  )
)