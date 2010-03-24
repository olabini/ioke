DanishDefaultBehavior = Reflector other:mimic(DefaultBehavior)

DanishDefaultBehavior efterlign = cell(:mimic)
DanishDefaultBehavior hvis = cell(:if)
DanishDefaultBehavior metode = cell(:method)
DanishDefaultBehavior funktion = cell(:fn)
DanishDefaultBehavior Oprindelse = Origin
DanishDefaultBehavior gør = cell(:do)
DanishDefaultBehavior med = cell(:with)
DanishDefaultBehavior selv = method(self)
DanishDefaultBehavior udskriv = Origin cell(:print)
DanishDefaultBehavior udskrivLinje = Origin cell(:println)

DefaultBehavior mimic!(DanishDefaultBehavior)
