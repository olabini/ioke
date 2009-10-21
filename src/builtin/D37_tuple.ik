
Tuple mimic!(Mixins Comparing)

Tuple Two   = Tuple mimic
Tuple Two private:initializeWith(nil, nil)
Tuple Two first  = Tuple private:accessor(0)
Tuple Two _1     = Tuple private:accessor(0)
Tuple Two second = Tuple private:accessor(1)
Tuple Two _2     = Tuple private:accessor(1)

Tuple Three = Tuple Two mimic
Tuple Three private:initializeWith(nil, nil, nil)
Tuple Three third  = Tuple private:accessor(2)
Tuple Three _3     = Tuple private:accessor(2)

Tuple Four  = Tuple Three mimic
Tuple Four private:initializeWith(nil, nil, nil, nil)
Tuple Four fourth  = Tuple private:accessor(3)
Tuple Four _4      = Tuple private:accessor(3)

Tuple Five  = Tuple Four mimic
Tuple Five private:initializeWith(nil, nil, nil, nil, nil)
Tuple Five fifth   = Tuple private:accessor(4)
Tuple Five _5      = Tuple private:accessor(4)

Tuple Six   = Tuple Five mimic
Tuple Six private:initializeWith(nil, nil, nil, nil, nil, nil)
Tuple Six sixth   = Tuple private:accessor(5)
Tuple Six _6      = Tuple private:accessor(5)

Tuple Seven = Tuple Six mimic
Tuple Seven private:initializeWith(nil, nil, nil, nil, nil, nil, nil)
Tuple Seven seventh  = Tuple private:accessor(6)
Tuple Seven _7       = Tuple private:accessor(6)

Tuple Eight = Tuple Seven mimic
Tuple Eight private:initializeWith(nil, nil, nil, nil, nil, nil, nil, nil)
Tuple Eight eighth  = Tuple private:accessor(7)
Tuple Eight _8      = Tuple private:accessor(7)

Tuple Nine  = Tuple Eight mimic
Tuple Nine private:initializeWith(nil, nil, nil, nil, nil, nil, nil, nil, nil)
Tuple Nine ninth   = Tuple private:accessor(8)
Tuple Nine _9      = Tuple private:accessor(8)

Tuple Many  = Tuple Nine mimic

