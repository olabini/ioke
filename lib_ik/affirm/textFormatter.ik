
Affirm TextFormatter = Origin mimic do(
  colour = method(
    "outputs text with colour if possible",
    text, colour_code,

    "#{colour_code}#{text}\e[0m")

  green   = method(text, colour(text, "\e[32m"))
  red     = method(text, colour(text, "\e[31m"))
  magenta = method(text, colour(text, "\e[35m"))
  yellow  = method(text, colour(text, "\e[33m"))
  blue    = method(text, colour(text, "\e[34m"))
)
