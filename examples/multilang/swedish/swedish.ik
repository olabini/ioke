SwedishDefaultBehavior = Reflector other:mimic(DefaultBehavior)

SwedishDefaultBehavior härma = cell(:mimic)
SwedishDefaultBehavior om  = cell(:if)
SwedishDefaultBehavior metod   = cell(:method)
SwedishDefaultBehavior funktion  = cell(:fn)
SwedishDefaultBehavior Ursprung    = Origin
SwedishDefaultBehavior gör    = cell(:do)
SwedishDefaultBehavior med  = cell(:with)
SwedishDefaultBehavior själv  = method(self)
SwedishDefaultBehavior skrivUt  = Origin cell(:print)
SwedishDefaultBehavior skrivUtRad = Origin cell(:println)

DefaultBehavior mimic!(SwedishDefaultBehavior)
