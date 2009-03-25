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
      m should == "+=(foo(1), 12 +(13) +(53 +(x f(123))))")

    it("should parse correctly with complicated expression on left hand side",
      m = parse("foo(1) += 12+13+53+(x f(123))\n1")
      m should == "+=(foo(1), 12 +(13) +(53 +(x f(123)))) .\n1")
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
      m should == "-=(foo(1), 12 +(13) +(53 +(x f(123))))")

    it("should parse correctly with complicated expression on left hand side", 
      m = parse("foo(1) -= 12+13+53+(x f(123))\n1")
      m should == "-=(foo(1), 12 +(13) +(53 +(x f(123)))) .\n1")
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
      m should == "/=(foo(1), 12 +(13) +(53 +(x f(123))))"
    )

    it("should parse correctly with complicated expression on left hand side", 
      m = parse("foo(1) /= 12+13+53+(x f(123))\n1")
      m should == "/=(foo(1), 12 +(13) +(53 +(x f(123)))) .\n1"
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
      m should == "*=(foo(1), 12 +(13) +(53 +(x f(123))))"
    )

    it("should parse correctly with complicated expression on left hand side", 
      m = parse("foo(1) *= 12+13+53+(x f(123))\n1")
      m should == "*=(foo(1), 12 +(13) +(53 +(x f(123)))) .\n1"
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
      m should == "**=(foo(1), 12 +(13) +(53 +(x f(123))))"
    )

    it("should parse correctly with complicated expression on left hand side", 
      m = parse("foo(1) **= 12+13+53+(x f(123))\n1")
      m should == "**=(foo(1), 12 +(13) +(53 +(x f(123)))) .\n1"
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
      m should == "%=(foo(1), 12 +(13) +(53 +(x f(123))))"
    )

    it("should parse correctly with complicated expression on left hand side", 
      m = parse("foo(1) %= 12+13+53+(x f(123))\n1")
      m should == "%=(foo(1), 12 +(13) +(53 +(x f(123)))) .\n1"
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
      m should == "&=(foo(1), 12 +(13) +(53 +(x f(123))))"
    )

    it("should parse correctly with complicated expression on left hand side", 
      m = parse("foo(1) &= 12+13+53+(x f(123))\n1")
      m should == "&=(foo(1), 12 +(13) +(53 +(x f(123)))) .\n1"
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
      m should == "&&=(foo(1), 12 +(13) +(53 +(x f(123))))"
    )

    it("should parse correctly with complicated expression on left hand side", 
      m = parse("foo(1) &&= 12+13+53+(x f(123))\n1")
      m should == "&&=(foo(1), 12 +(13) +(53 +(x f(123)))) .\n1"
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
      m should == "|=(foo(1), 12 +(13) +(53 +(x f(123))))"
    )

    it("should parse correctly with complicated expression on left hand side", 
      m = parse("foo(1) |= 12+13+53+(x f(123))\n1")
      m should == "|=(foo(1), 12 +(13) +(53 +(x f(123)))) .\n1"
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
      m should == "||=(foo(1), 12 +(13) +(53 +(x f(123))))"
    )

    it("should parse correctly with complicated expression on left hand side", 
      m = parse("foo(1) ||= 12+13+53+(x f(123))\n1")
      m should == "||=(foo(1), 12 +(13) +(53 +(x f(123)))) .\n1"
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
      m should == "^=(foo(1), 12 +(13) +(53 +(x f(123))))"
    )

    it("should parse correctly with complicated expression on left hand side", 
      m = parse("foo(1) ^= 12+13+53+(x f(123))\n1")
      m should == "^=(foo(1), 12 +(13) +(53 +(x f(123)))) .\n1"
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
      m should == ">>=(foo(1), 12 +(13) +(53 +(x f(123))))"
    )

    it("should parse correctly with complicated expression on left hand side", 
      m = parse("foo(1) >>= 12+13+53+(x f(123))\n1")
      m should == ">>=(foo(1), 12 +(13) +(53 +(x f(123)))) .\n1"
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
      m should == "<<=(foo(1), 12 +(13) +(53 +(x f(123))))"
    )

    it("should parse correctly with complicated expression on left hand side", 
      m = parse("foo(1) <<= 12+13+53+(x f(123))\n1")
      m should == "<<=(foo(1), 12 +(13) +(53 +(x f(123)))) .\n1"
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
      m should == "=(foo(1), 12 +(13) +(53 +(x f(123))))"
    )

    it("should parse correctly with complicated expression on left hand side", 
      m = parse("foo(1) = 12+13+53+(x f(123))\n1")
      m should == "=(foo(1), 12 +(13) +(53 +(x f(123)))) .\n1"
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
      m should == "foo =([](1), 12 +(13) +(53 +(x f(123))))"
    )

    it("should parse correctly with complicated expression on left hand side", 
      m = parse("foo[1] = 12+13+53+(x f(123))\n1")
      m should == "foo =([](1), 12 +(13) +(53 +(x f(123)))) .\n1"
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
      m should == "foo =({}(1), 12 +(13) +(53 +(x f(123))))"
    )

    it("should parse correctly with complicated expression on left hand side", 
      m = parse("foo{1} = 12+13+53+(x f(123))\n1")
      m should == "foo =({}(1), 12 +(13) +(53 +(x f(123)))) .\n1"
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

describe(DefaultBehavior,
  describe("+=",
    it("should call + and then assign the result of this call to the same name",
      x = 1
      x += 2
      x should == 3
      
      x = 42
      x += -1
      x should == 41
    )
    
    it("should work with a place",
      x = [1]
      x[0] += 2
      x[0] should == 3
    )
  )

  describe("-=",
    it("should call - and then assign the result of this call to the same name",
      x = 2
      x -= 1
      x should == 1

      x = 42
      x -= -1
      x should == 43
    )

    it("should work with a place",
      x = [42]
      x[0] -= 2
      x[0] should == 40
    )
  )

  describe("/=", 
    it("should call / and then assign the result of this call to the same name", 
      x = 12. x /= 2. x should == 6
      x = 150. x /= -2. x should == -75
    )

    it("should work with a place", 
      x = [42]. x[0] /= 2. x[0] should == 21
    )
  )

  describe("*=", 
    it("should call * and then assign the result of this call to the same name", 
      x = 12. x *= 2. x should == 24
      x = 150. x *= -2. x should == -300
    )

    it("should work with a place", 
      x = [42]. x[0] *= 2. x[0] should == 84
    )
  )

  describe("**=", 
    it("should call ** and then assign the result of this call to the same name", 
      x = 2. x **= 3. x should == 8
      x = 2. x **= 40. x should == 1099511627776
    )

    it("should work with a place", 
      x = [3]. x[0] **= 2. x[0] should == 9
    )
  )

  describe("%=", 
    it("should call % and then assign the result of this call to the same name", 
      x = 12. x %= 5. x should == 2
      x = 13. x %= 4. x should == 1
    )

    it("should work with a place", 
      x = [42]. x[0] %= 4. x[0] should == 2
    )
  )

  describe("&=", 
    it("should call & and then assign the result of this call to the same name", 
      x = 65535. x &= 1. x should == 1
      x = 8. x &= 8. x should == 8
    )

    it("should work with a place", 
      x = [65535]. x[0] &= 1. x[0] should == 1
    )
  )

  describe("&&=", 
    it("should not assign a cell if it doesn't exist", 
      xblurg &&= 42
      cell?(:xblurg) should be false
    )

    it("should not assign a cell if it is nil", 
      x = nil. x &&= 42. x should be nil
    )

    it("should not assign a cell if it is false", 
      x = false. x &&= 42. x should be false
    )

    it("should assign a cell that exist", 
      x = 43. x &&= 42. x should == 42
    )

    it("should work with a place", 
      x = [1, 3]. x[1] &&= 42.     x should == [1, 42]
      x = [2, 3]. x[2] &&= 42.     x should == [2, 3]
      x = [3, nil]. x[1] &&= 42.   x should == [3, nil]
      x = [4, false]. x[1] &&= 42. x should == [4, false]
    )
  )

  describe("|=", 
    it("should call | and then assign the result of this call to the same name", 
      x = 5. x |= 6. x should == 7
      x = 5. x |= 4. x should == 5
    )

    it("should work with a place", 
      x = [5]. x[0] |= 6. x[0] should == 7
    )
  )

  describe("||=", 
    it("should assign a cell if it doesn't exist", 
      test_double_pipe_equals ||= 42. test_double_pipe_equals should == 42
    )

    it("should assign a cell if it is nil", 
      x = nil. x ||= 42. x should == 42
    )

    it("should assign a cell if it is false", 
      x = false. x ||= 42. x should == 42
    )

    it("should not assign a cell that exist", 
      x = 43. x ||= 42. x should == 43
    )

    it("should work with a place", 
      x = [1, 3]. x[1] ||= 42.     x should == [1, 3]
      x = [2, 3]. x[2] ||= 42.     x should == [2, 3, 42]
      x = [3, nil]. x[1] ||= 42.   x should == [3, 42]
      x = [4, false]. x[1] ||= 42. x should == [4, 42]
    )
  )

  describe("^=", 
    it("should call ^ and then assign the result of this call to the same name", 
      x = 3. x ^= 5. x should == 6
      x = -2. x ^= -255. x should == 255
    )

    it("should work with a place", 
      x = [3]. x[0] ^= 5. x[0] should == 6
    )
  )

  describe("<<=", 
    it("should call << and then assign the result of this call to the same name", 
      x = 7. x <<= 2. x should == 28
      x = 9. x <<= 4. x should == 144
    )

    it("should work with a place", 
      x = [9]. x[0] <<= 4. x[0] should == 144
    )
  )

  describe(">>=", 
    it("should call >> and then assign the result of this call to the same name", 
      x = 7. x >>= 1. x should == 3
      x = 4095. x >>= 3. x should == 511
    )

    it("should work with a place", 
      x = [7]. x[0] >>= 1. x[0] should == 3
    )
  )
)
