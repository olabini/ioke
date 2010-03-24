
DutchDefaultBehavior = Reflector other:mimic(DefaultBehavior)
 
DutchDefaultBehavior bootsNa = cell(:mimic)
DutchDefaultBehavior als = cell(:if)
DutchDefaultBehavior methode = cell(:method)
DutchDefaultBehavior functie = cell(:fn)
DutchDefaultBehavior Oorsprong = Origin
DutchDefaultBehavior doe = cell(:do)
DutchDefaultBehavior met = cell(:with)
DutchDefaultBehavior zelf = method(self)
DutchDefaultBehavior schrijf = Origin cell(:print)
DutchDefaultBehavior schrijfln = Origin cell(:println)
 
DefaultBehavior mimic!(DutchDefaultBehavior)
