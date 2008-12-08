use("ispec")

parse = method(str,
  Message fromText(str) code)

describe("assignment",
  it("should set kind when assigned to a name with capital initial letter",
    Ground Foo = Origin mimic
    Foo kind should == "Foo")

  it("should set kind when assigned to a name inside something else",
    Ground Foo = Origin mimic
    Foo Bar = Origin mimic
    Foo Bar kind should == "Foo Bar")

  it("should not set kind when it already has a kind",
    Ground Foo = Origin mimic
    Bar = Foo
    Foo kind should == "Foo"
    Bar kind should == "Foo")
  
  it("should not set kind when assigning to something with a lower case letter",
    Ground foo = Origin mimic
    bar = foo
    foo kind should == "Origin"
    bar kind should == "Origin")

  it("should work for a simple string",
    a = "foo"
    a should == "foo")

  it("should be possible to assign a large expression to default receiver",
    a = Origin mimic
    a kind should == "Origin"
    a should not == Origin)

  it("should be possible to assign to something inside another object",
    Text a = "something"
    Text a should == "something")

  it("should work with combination of equals and plus sign",
    a = 1 + 1
    a should == 2)

  it("should work with something on the next line too",
    m = parse("count = count + 1\ncount println")
    m should == "=(count, count +(1)) .\ncount println")

  it("should work when assigning something to the empty parenthesis",
    m = parse("x = (10+20)")
    m should == "=(x, (10 +(20)))")

  it("should be possible to assign a method to +",
    m = parse("+ = method()")
    m should == "=(+, method)"

    m = parse("Ground + = method()")
    m should == "Ground =(+, method)"
  )

  it("should be possible to assign a method to =",
    m = parse("= = method()")
    m should == "=(=, method)"

    m = parse("Ground = = method()")
    m should == "Ground =(=, method)"
  )

  it("should be possible to assign a method to ..",
    m = parse(".. = method()")
    m should == "=(.., method)"

    m = parse("Ground .. = method()")
    m should == "Ground =(.., method)"
  )

  describe("+=",
    it("should parse correctly without receiver, with arguments",
      m = parse("(1) += 12")
      m should == "+=((1), 12)")
    
    it("should parse correctly with receiver without spaces and arguments", 
      m = parse("foo(1) += 12")
      m should == "+=(foo(1), 12)")

    it("should parse correctly with receiver without even more spaces and arguments",
      m = parse("foo(1)+=12")
      m should == "+=(foo(1), 12)")

    it("should parse correctly with receiver with spaces and arguments",
      m = parse("foo (1) += 12")
      m should == "+=(foo(1), 12)")
    
    it("should parse correctly with complicated expression on left hand side",
      m = parse("foo(1) += 12+13+53+(x f(123))")
      m should == "+=(foo(1), 12 +(13) +(53) +(x f(123)))")

    it("should parse correctly with complicated expression on left hand side",
      m = parse("foo(1) += 12+13+53+(x f(123))\n1")
      m should == "+=(foo(1), 12 +(13) +(53) +(x f(123))) .\n1")
  )

  describe("-=",
    it("should parse correctly without receiver, with arguments", 
      m = parse("(1) -= 12")
      m should == "-=((1), 12)")
    
    it("should parse correctly with receiver without spaces and arguments", 
      m = parse("foo(1) -= 12")
      m should == "-=(foo(1), 12)")

    it("should parse correctly with receiver without even more spaces and arguments", 
      m = parse("foo(1)-=12")
      m should == "-=(foo(1), 12)")

    it("should parse correctly with receiver with spaces and arguments", 
      m = parse("foo (1) -= 12")
      m should == "-=(foo(1), 12)")
    
    it("should parse correctly with complicated expression on left hand side", 
      m = parse("foo(1) -= 12+13+53+(x f(123))")
      m should == "-=(foo(1), 12 +(13) +(53) +(x f(123)))")

    it("should parse correctly with complicated expression on left hand side", 
      m = parse("foo(1) -= 12+13+53+(x f(123))\n1")
      m should == "-=(foo(1), 12 +(13) +(53) +(x f(123))) .\n1")
  )



  describe("/=", 
    it("should parse correctly without receiver, with arguments", 
      m = parse("(1) /= 12")
      m should == "/=((1), 12)"
    )
    
    it("should parse correctly with receiver without spaces and arguments", 
      m = parse("foo(1) /= 12")
      m should == "/=(foo(1), 12)"
    )

    it("should parse correctly with receiver without even more spaces and arguments", 
      m = parse("foo(1)/=12")
      m should == "/=(foo(1), 12)"
    )

    it("should parse correctly with receiver with spaces and arguments", 
      m = parse("foo (1) /= 12")
      m should == "/=(foo(1), 12)"
    )
    
    it("should parse correctly with complicated expression on left hand side", 
      m = parse("foo(1) /= 12+13+53+(x f(123))")
      m should == "/=(foo(1), 12 +(13) +(53) +(x f(123)))"
    )

    it("should parse correctly with complicated expression on left hand side", 
      m = parse("foo(1) /= 12+13+53+(x f(123))\n1")
      m should == "/=(foo(1), 12 +(13) +(53) +(x f(123))) .\n1"
    )
  )

  describe("*=", 
    it("should parse correctly without receiver, with arguments", 
      m = parse("(1) *= 12")
      m should == "*=((1), 12)"
    )
    
    it("should parse correctly with receiver without spaces and arguments", 
      m = parse("foo(1) *= 12")
      m should == "*=(foo(1), 12)"
    )

    it("should parse correctly with receiver without even more spaces and arguments", 
      m = parse("foo(1)*=12")
      m should == "*=(foo(1), 12)"
    )

    it("should parse correctly with receiver with spaces and arguments", 
      m = parse("foo (1) *= 12")
      m should == "*=(foo(1), 12)"
    )
    
    it("should parse correctly with complicated expression on left hand side", 
      m = parse("foo(1) *= 12+13+53+(x f(123))")
      m should == "*=(foo(1), 12 +(13) +(53) +(x f(123)))"
    )

    it("should parse correctly with complicated expression on left hand side", 
      m = parse("foo(1) *= 12+13+53+(x f(123))\n1")
      m should == "*=(foo(1), 12 +(13) +(53) +(x f(123))) .\n1"
    )
  )

  describe("**=", 
    it("should parse correctly without receiver, with arguments", 
      m = parse("(1) **= 12")
      m should == "**=((1), 12)"
    )
    
    it("should parse correctly with receiver without spaces and arguments", 
      m = parse("foo(1) **= 12")
      m should == "**=(foo(1), 12)"
    )

    it("should parse correctly with receiver without even more spaces and arguments", 
      m = parse("foo(1)**=12")
      m should == "**=(foo(1), 12)"
    )

    it("should parse correctly with receiver with spaces and arguments", 
      m = parse("foo (1) **= 12")
      m should == "**=(foo(1), 12)"
    )
    
    it("should parse correctly with complicated expression on left hand side", 
      m = parse("foo(1) **= 12+13+53+(x f(123))")
      m should == "**=(foo(1), 12 +(13) +(53) +(x f(123)))"
    )

    it("should parse correctly with complicated expression on left hand side", 
      m = parse("foo(1) **= 12+13+53+(x f(123))\n1")
      m should == "**=(foo(1), 12 +(13) +(53) +(x f(123))) .\n1"
    )
  )

  describe("%=", 
    it("should parse correctly without receiver, with arguments", 
      m = parse("(1) %= 12")
      m should == "%=((1), 12)"
    )
    
    it("should parse correctly with receiver without spaces and arguments", 
      m = parse("foo(1) %= 12")
      m should == "%=(foo(1), 12)"
    )

    it("should parse correctly with receiver without even more spaces and arguments", 
      m = parse("foo(1)%=12")
      m should == "%=(foo(1), 12)"
    )

    it("should parse correctly with receiver with spaces and arguments", 
      m = parse("foo (1) %= 12")
      m should == "%=(foo(1), 12)"
    )
    
    it("should parse correctly with complicated expression on left hand side", 
      m = parse("foo(1) %= 12+13+53+(x f(123))")
      m should == "%=(foo(1), 12 +(13) +(53) +(x f(123)))"
    )

    it("should parse correctly with complicated expression on left hand side", 
      m = parse("foo(1) %= 12+13+53+(x f(123))\n1")
      m should == "%=(foo(1), 12 +(13) +(53) +(x f(123))) .\n1"
    )
  )

  describe("&=", 
    it("should parse correctly without receiver, with arguments", 
      m = parse("(1) &= 12")
      m should == "&=((1), 12)"
    )
    
    it("should parse correctly with receiver without spaces and arguments", 
      m = parse("foo(1) &= 12")
      m should == "&=(foo(1), 12)"
    )

    it("should parse correctly with receiver without even more spaces and arguments", 
      m = parse("foo(1)&=12")
      m should == "&=(foo(1), 12)"
    )

    it("should parse correctly with receiver with spaces and arguments", 
      m = parse("foo (1) &= 12")
      m should == "&=(foo(1), 12)"
    )
    
    it("should parse correctly with complicated expression on left hand side", 
      m = parse("foo(1) &= 12+13+53+(x f(123))")
      m should == "&=(foo(1), 12 +(13) +(53) +(x f(123)))"
    )

    it("should parse correctly with complicated expression on left hand side", 
      m = parse("foo(1) &= 12+13+53+(x f(123))\n1")
      m should == "&=(foo(1), 12 +(13) +(53) +(x f(123))) .\n1"
    )
  )

  describe("&&=", 
    it("should parse correctly without receiver, with arguments", 
      m = parse("(1) &&= 12")
      m should == "&&=((1), 12)"
    )
    
    it("should parse correctly with receiver without spaces and arguments", 
      m = parse("foo(1) &&= 12")
      m should == "&&=(foo(1), 12)"
    )

    it("should parse correctly with receiver without even more spaces and arguments", 
      m = parse("foo(1)&&=12")
      m should == "&&=(foo(1), 12)"
    )

    it("should parse correctly with receiver with spaces and arguments", 
      m = parse("foo (1) &&= 12")
      m should == "&&=(foo(1), 12)"
    )
    
    it("should parse correctly with complicated expression on left hand side", 
      m = parse("foo(1) &&= 12+13+53+(x f(123))")
      m should == "&&=(foo(1), 12 +(13) +(53) +(x f(123)))"
    )

    it("should parse correctly with complicated expression on left hand side", 
      m = parse("foo(1) &&= 12+13+53+(x f(123))\n1")
      m should == "&&=(foo(1), 12 +(13) +(53) +(x f(123))) .\n1"
    )
  )

  describe("|=", 
    it("should parse correctly without receiver, with arguments", 
      m = parse("(1) |= 12")
      m should == "|=((1), 12)"
    )
    
    it("should parse correctly with receiver without spaces and arguments", 
      m = parse("foo(1) |= 12")
      m should == "|=(foo(1), 12)"
    )

    it("should parse correctly with receiver without even more spaces and arguments", 
      m = parse("foo(1)|=12")
      m should == "|=(foo(1), 12)"
    )

    it("should parse correctly with receiver with spaces and arguments", 
      m = parse("foo (1) |= 12")
      m should == "|=(foo(1), 12)"
    )
    
    it("should parse correctly with complicated expression on left hand side", 
      m = parse("foo(1) |= 12+13+53+(x f(123))")
      m should == "|=(foo(1), 12 +(13) +(53) +(x f(123)))"
    )

    it("should parse correctly with complicated expression on left hand side", 
      m = parse("foo(1) |= 12+13+53+(x f(123))\n1")
      m should == "|=(foo(1), 12 +(13) +(53) +(x f(123))) .\n1"
    )
  )

  describe("||=", 
    it("should parse correctly without receiver, with arguments", 
      m = parse("(1) ||= 12")
      m should == "||=((1), 12)"
    )
    
    it("should parse correctly with receiver without spaces and arguments", 
      m = parse("foo(1) ||= 12")
      m should == "||=(foo(1), 12)"
    )

    it("should parse correctly with receiver without even more spaces and arguments", 
      m = parse("foo(1)||=12")
      m should == "||=(foo(1), 12)"
    )

    it("should parse correctly with receiver with spaces and arguments", 
      m = parse("foo (1) ||= 12")
      m should == "||=(foo(1), 12)"
    )
    
    it("should parse correctly with complicated expression on left hand side", 
      m = parse("foo(1) ||= 12+13+53+(x f(123))")
      m should == "||=(foo(1), 12 +(13) +(53) +(x f(123)))"
    )

    it("should parse correctly with complicated expression on left hand side", 
      m = parse("foo(1) ||= 12+13+53+(x f(123))\n1")
      m should == "||=(foo(1), 12 +(13) +(53) +(x f(123))) .\n1"
    )
  )

  describe("^=", 
    it("should parse correctly without receiver, with arguments", 
      m = parse("(1) ^= 12")
      m should == "^=((1), 12)"
    )
    
    it("should parse correctly with receiver without spaces and arguments", 
      m = parse("foo(1) ^= 12")
      m should == "^=(foo(1), 12)"
    )

    it("should parse correctly with receiver without even more spaces and arguments", 
      m = parse("foo(1)^=12")
      m should == "^=(foo(1), 12)"
    )

    it("should parse correctly with receiver with spaces and arguments", 
      m = parse("foo (1) ^= 12")
      m should == "^=(foo(1), 12)"
    )
    
    it("should parse correctly with complicated expression on left hand side", 
      m = parse("foo(1) ^= 12+13+53+(x f(123))")
      m should == "^=(foo(1), 12 +(13) +(53) +(x f(123)))"
    )

    it("should parse correctly with complicated expression on left hand side", 
      m = parse("foo(1) ^= 12+13+53+(x f(123))\n1")
      m should == "^=(foo(1), 12 +(13) +(53) +(x f(123))) .\n1"
    )
  )

  describe(">>=", 
    it("should parse correctly without receiver, with arguments", 
      m = parse("(1) >>= 12")
      m should == ">>=((1), 12)"
    )
    
    it("should parse correctly with receiver without spaces and arguments", 
      m = parse("foo(1) >>= 12")
      m should == ">>=(foo(1), 12)"
    )

    it("should parse correctly with receiver without even more spaces and arguments", 
      m = parse("foo(1)>>=12")
      m should == ">>=(foo(1), 12)"
    )

    it("should parse correctly with receiver with spaces and arguments", 
      m = parse("foo (1) >>= 12")
      m should == ">>=(foo(1), 12)"
    )
    
    it("should parse correctly with complicated expression on left hand side", 
      m = parse("foo(1) >>= 12+13+53+(x f(123))")
      m should == ">>=(foo(1), 12 +(13) +(53) +(x f(123)))"
    )

    it("should parse correctly with complicated expression on left hand side", 
      m = parse("foo(1) >>= 12+13+53+(x f(123))\n1")
      m should == ">>=(foo(1), 12 +(13) +(53) +(x f(123))) .\n1"
    )
  )

  describe("<<=", 
    it("should parse correctly without receiver, with arguments", 
      m = parse("(1) <<= 12")
      m should == "<<=((1), 12)"
    )
    
    it("should parse correctly with receiver without spaces and arguments", 
      m = parse("foo(1) <<= 12")
      m should == "<<=(foo(1), 12)"
    )

    it("should parse correctly with receiver without even more spaces and arguments", 
      m = parse("foo(1)<<=12")
      m should == "<<=(foo(1), 12)"
    )

    it("should parse correctly with receiver with spaces and arguments", 
      m = parse("foo (1) <<= 12")
      m should == "<<=(foo(1), 12)"
    )
    
    it("should parse correctly with complicated expression on left hand side", 
      m = parse("foo(1) <<= 12+13+53+(x f(123))")
      m should == "<<=(foo(1), 12 +(13) +(53) +(x f(123)))"
    )

    it("should parse correctly with complicated expression on left hand side", 
      m = parse("foo(1) <<= 12+13+53+(x f(123))\n1")
      m should == "<<=(foo(1), 12 +(13) +(53) +(x f(123))) .\n1"
    )
  )
  
  describe("()=", 
    it("should parse correctly without receiver, with arguments", 
      m = parse("(1) = 12")
      m should == "=((1), 12)"
    )
    
    it("should parse correctly with receiver without spaces and arguments", 
      m = parse("foo(1) = 12")
      m should == "=(foo(1), 12)"
    )

    it("should parse correctly with receiver without even more spaces and arguments", 
      m = parse("foo(1)=12")
      m should == "=(foo(1), 12)"
    )

    it("should parse correctly with receiver with spaces and arguments", 
      m = parse("foo (1) = 12")
      m should == "=(foo(1), 12)"
    )
    
    it("should parse correctly with complicated expression on left hand side", 
      m = parse("foo(1) = 12+13+53+(x f(123))")
      m should == "=(foo(1), 12 +(13) +(53) +(x f(123)))"
    )

    it("should parse correctly with complicated expression on left hand side", 
      m = parse("foo(1) = 12+13+53+(x f(123))\n1")
      m should == "=(foo(1), 12 +(13) +(53) +(x f(123))) .\n1"
    )
  )

  describe("[]=", 
    it("should parse correctly without receiver, with arguments", 
      m = parse("[1] = 12")
      m should == "=([](1), 12)"
    )
    
    it("should parse correctly with receiver without spaces and arguments", 
      m = parse("foo[1] = 12")
      m should == "foo =([](1), 12)"
    )

    it("should parse correctly with receiver without even more spaces and arguments", 
      m = parse("foo[1]=12")
      m should == "foo =([](1), 12)"
    )

    it("should parse correctly with receiver with spaces and arguments", 
      m = parse("foo [1] = 12")
      m should == "foo =([](1), 12)"
    )
    
    it("should parse correctly with complicated expression on left hand side", 
      m = parse("foo[1] = 12+13+53+(x f(123))")
      m should == "foo =([](1), 12 +(13) +(53) +(x f(123)))"
    )

    it("should parse correctly with complicated expression on left hand side", 
      m = parse("foo[1] = 12+13+53+(x f(123))\n1")
      m should == "foo =([](1), 12 +(13) +(53) +(x f(123))) .\n1"
    )
  )

  describe("{}=", 
    it("should parse correctly without receiver, with arguments", 
      m = parse("{1} = 12")
      m should == "=({}(1), 12)"
    )
    
    it("should parse correctly with receiver without spaces and arguments", 
      m = parse("foo{1} = 12")
      m should == "foo =({}(1), 12)"
    )

    it("should parse correctly with receiver without even more spaces and arguments", 
      m = parse("foo{1}=12")
      m should == "foo =({}(1), 12)"
    )

    it("should parse correctly with receiver with spaces and arguments", 
      m = parse("foo {1} = 12")
      m should == "foo =({}(1), 12)"
    )
    
    it("should parse correctly with complicated expression on left hand side", 
      m = parse("foo{1} = 12+13+53+(x f(123))")
      m should == "foo =({}(1), 12 +(13) +(53) +(x f(123)))"
    )

    it("should parse correctly with complicated expression on left hand side", 
      m = parse("foo{1} = 12+13+53+(x f(123))\n1")
      m should == "foo =({}(1), 12 +(13) +(53) +(x f(123))) .\n1"
    )
  )
  
  describe("'++'", 
    it("should parse correctly in postfix without space", 
      m = parse("a++")
      m should == "++(a)"
    )

    it("should parse correctly with receiver in postfix without space", 
      m = parse("foo a++")
      m should == "foo ++(a)"
    )

    it("should parse correctly in method call in postfix without space", 
      m = parse("foo(a++)")
      m should == "foo(++(a))"
    )
    
    it("should parse correctly in postfix with space", 
      m = parse("a ++")
      m should == "++(a)"
    )

    it("should parse correctly with receiver in postfix with space", 
      m = parse("foo a ++")
      m should == "foo ++(a)"
    )

    it("should parse correctly in method call in postfix with space", 
      m = parse("foo(a ++)")
      m should == "foo(++(a))"
    )
    
    it("should parse correctly as message send", 
      m = parse("++(a)")
      m should == "++(a)"
    )

    it("should parse correctly with receiver as message send", 
      m = parse("foo ++(a)")
      m should == "foo ++(a)"
    )

    it("should parse correctly in method call as message send", 
      m = parse("foo(++(a))")
      m should == "foo(++(a))"
    )
    
    it("should parse correctly when combined with assignment", 
      m = parse("foo x = a++")
      m should == "foo =(x, ++(a))"
    )

    it("should parse correctly when combined with assignment and receiver", 
      m = parse("foo x = Foo a++")
      m should == "foo =(x, Foo ++(a))"
    )
    
    it("should increment number", 
      x = 0
      x++
      x should == 1
    )
  )

  describe("'--'", 
    it("should parse correctly in postfix without space", 
      m = parse("a--")
      m should == "--(a)"
    )

    it("should parse correctly with receiver in postfix without space", 
      m = parse("foo a--")
      m should == "foo --(a)"
    )

    it("should parse correctly in method call in postfix without space", 
      m = parse("foo(a--)")
      m should == "foo(--(a))"
    )
    
    it("should parse correctly in postfix with space", 
      m = parse("a --")
      m should == "--(a)"
    )

    it("should parse correctly with receiver in postfix with space", 
      m = parse("foo a --")
      m should == "foo --(a)"
    )

    it("should parse correctly in method call in postfix with space", 
      m = parse("foo(a --)")
      m should == "foo(--(a))"
    )
    
    it("should parse correctly as message send", 
      m = parse("--(a)")
      m should == "--(a)"
    )

    it("should parse correctly with receiver as message send", 
      m = parse("foo --(a)")
      m should == "foo --(a)"
    )

    it("should parse correctly in method call as message send", 
      m = parse("foo(--(a))")
      m should == "foo(--(a))"
    )
    
    it("should parse correctly when combined with assignment", 
      m = parse("foo x = a--")
      m should == "foo =(x, --(a))"
    )

    it("should parse correctly when combined with assignment and receiver", 
      m = parse("foo x = Foo a--")
      m should == "foo =(x, Foo --(a))"
    )

    it("should decrement number", 
      x = 1
      x--
      x should == 0
    )
  )
)
