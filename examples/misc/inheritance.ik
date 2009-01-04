; Define a Dog object

Dog = Origin mimic do(
  barkPhrase = "woof!"
  bark = method(barkPhrase))

; Create Chihuahua subclass of Dog

Chihuahua = Dog mimic do(
  barkPhrase = "yip!"
)

"Dog bark: #{Dog bark}" println
"Chihuahua bark: #{Chihuahua bark}" println

; make an instance
myChihuahua = Chihuahua mimic do(
  barkPhrase = "¡Yo Quiero Taco Bell!"
)

"myChihuahua bark: #{myChihuahua bark}" println
