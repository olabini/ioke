
IKIL definitions = []
IKIL cell(:"{}") = macro(
  call arguments[0] selected(name == :"=") each(msg,
    def = Origin mimic
    def className = msg arguments[0] name asText
    def definitionName = msg arguments[1] name
    def definition = msg arguments[1] arguments
    definitions << def
  )
)
