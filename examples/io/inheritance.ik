; Define a Dog object

Dog = Origin mimic
Dog barkPhrase = "woof!"
Dog bark = method(barkPhrase)

; Create Chihuahua subclass of Dog

Chihuahua = Dog mimic
Chihuahua barkPhrase = "yip!"

"Dog bark: #{Dog bark}" println
"Chihuahua bark: #{Chihuahua bark}" println

; make an instance
myChihuahua = Chihuahua mimic
myChihuahua barkPhrase = "¡Yo Quiero Taco Bell!"

"myChihuahua bark: #{myChihuahua bark}" println
