bottle = method(i,
  if(i == 0, return "no more bottles of beer")
  if(i == 1, return "1 bottle of beer")
  return "#{i} bottles of beer"
)

(1..99) sortBy(p, 100 - p) each(i,
  "#{bottle(i)} on the wall, " println
  "take one down, pass it around," println
  "#{bottle(i - 1)} on the wall.\n" println
)