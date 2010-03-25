
SpanishDefaultBehavior = Reflector other:mimic(DefaultBehavior)

SpanishDefaultBehavior Origen = Origin

SpanishDefaultBehavior celda = cell(:cell)
SpanishDefaultBehavior imitación = cell(:mimic)
SpanishDefaultBehavior imita! = cell(:mimic!)
SpanishDefaultBehavior método = cell(:method)
SpanishDefaultBehavior función = cell(:fn)
SpanishDefaultBehavior haciendo = cell(:do)
SpanishDefaultBehavior con = cell(:with)
SpanishDefaultBehavior mi = method(self)

SpanishDefaultBehavior si = cell(:if)   ; conjuction, interrogative
SpanishDefaultBehavior sí = cell(:true) ; with accent its an adverb, affirmative
SpanishDefaultBehavior no = cell(:false)

SpanishDefaultBehavior imprime = Origin cell(:print)
SpanishDefaultBehavior imprimeLinea = Origin cell(:println)

DefaultBehavior mimic!(SpanishDefaultBehavior)
