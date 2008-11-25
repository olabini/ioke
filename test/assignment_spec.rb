include_class('ioke.lang.Runtime') { 'IokeRuntime' } unless defined?(IokeRuntime)
include_class('ioke.lang.Text') unless defined?(Text)

import Java::java.io.StringReader unless defined?(StringReader)

def parse(str)
  ioke = IokeRuntime.get_runtime()
  ioke.parse_stream(StringReader.new(str), ioke.message, ioke.ground)
end

describe "assignment" do 
  # kind should be the full path - where Ground is the cutoff point. skip enc
  
  it "should set kind when assigned to a name with capital initial letter" do 
    ioke = IokeRuntime.get_runtime()
    ioke.evaluate_stream(StringReader.new(%q[Foo = Origin mimic]))
    ioke.ground.find_cell(nil, nil, "Foo").find_cell(nil, nil, "kind").data.text.should == "Foo"
  end

  it "should set kind when assigned to a name inside something else" do 
    ioke = IokeRuntime.get_runtime()
    ioke.evaluate_stream(StringReader.new(%q[Foo = Origin mimic. Foo Bar = Origin mimic]))
    ioke.ground.find_cell(nil, nil, "Foo").
      find_cell(nil, nil, "Bar").
      find_cell(nil, nil, "kind").
      data.text.should == "Foo Bar"
  end

  it "should not set kind when it already has a kind" do 
    ioke = IokeRuntime.get_runtime()
    ioke.evaluate_stream(StringReader.new(%q[Foo = Origin mimic. Bar = Foo]))
    ioke.ground.find_cell(nil, nil, "Foo").find_cell(nil, nil, "kind").data.text.should == "Foo"
    ioke.ground.find_cell(nil, nil, "Bar").find_cell(nil, nil, "kind").data.text.should == "Foo"
  end
  
  it "should not set kind when assigning to something with a lower case letter" do 
    ioke = IokeRuntime.get_runtime()
    ioke.evaluate_stream(StringReader.new(%q[foo = Origin mimic. bar = foo]))
    ioke.ground.find_cell(nil, nil, "foo").find_cell(nil, nil, "kind").data.text.should == "Origin"
    ioke.ground.find_cell(nil, nil, "bar").find_cell(nil, nil, "kind").data.text.should == "Origin"
  end
    
  
  it "should work for a simple string" do 
    ioke = IokeRuntime.get_runtime()
    result = ioke.evaluate_stream(StringReader.new(%q[a = "foo"]))
    result.data.text.should == "foo"

    ioke.ground.find_cell(nil, nil, "a").should == result
  end
  
  it "should be possible to assign a large expression to default receiver" do 
    ioke = IokeRuntime.get_runtime()
    result = ioke.evaluate_stream(StringReader.new(%q[a = Origin mimic]))
    result.find_cell(nil, nil, 'kind').data.text.should == 'Origin'
    result.should_not == ioke.origin

    ioke.ground.find_cell(nil, nil, "a").should == result
  end

  it "should be possible to assign to something inside another object" do 
    ioke = IokeRuntime.get_runtime()
    result = ioke.evaluate_stream(StringReader.new(%q[Text a = "something"]))
    ioke.text.find_cell(nil, nil, "a").should == result
  end
  
  it "should work with combination of equals and plus sign" do 
    ioke = IokeRuntime.get_runtime()
    result = ioke.evaluate_stream(StringReader.new(%q[a = 1 + 1]))
    ioke.ground.find_cell(nil, nil, "a").should == result
    result.data.as_java_integer.should == 2
  end

  it "should work with something on the next line too" do 
    m = parse("count = count + 1\ncount println").to_string
    m.should == "=(count, count +(1)) .\ncount println"
  end

  it "should work when assigning something to the empty parenthesis" do 
    m = parse("x = (10+20)").to_string
    m.should == "=(x, (10 +(20)))"
  end
  
  it "should be possible to assign a method to +" do 
    m = parse("+ = method()").to_string
    m.should == "=(+, method)"

    m = parse("Ground + = method()").to_string
    m.should == "Ground =(+, method)"
  end
  
  it "should be possible to assign a method to =" do 
    m = parse("= = method()").to_string
    m.should == "=(=, method)"

    m = parse("Ground = = method()").to_string
    m.should == "Ground =(=, method)"
  end

  it "should be possible to assign a method to .." do 
    m = parse(".. = method()").to_string
    m.should == "=(.., method)"

    m = parse("Ground .. = method()").to_string
    m.should == "Ground =(.., method)"
  end
  
  describe "+=" do 
    it "should parse correctly without receiver, with arguments" do 
      m = parse("(1) += 12").to_string
      m.should == "+=((1), 12)"
    end
    
    it "should parse correctly with receiver without spaces and arguments" do 
      m = parse("foo(1) += 12").to_string
      m.should == "+=(foo(1), 12)"
    end

    it "should parse correctly with receiver without even more spaces and arguments" do 
      m = parse("foo(1)+=12").to_string
      m.should == "+=(foo(1), 12)"
    end

    it "should parse correctly with receiver with spaces and arguments" do 
      m = parse("foo (1) += 12").to_string
      m.should == "+=(foo(1), 12)"
    end
    
    it "should parse correctly with complicated expression on left hand side" do 
      m = parse("foo(1) += 12+13+53+(x f(123))").to_string
      m.should == "+=(foo(1), 12 +(13) +(53) +(x f(123)))"
    end

    it "should parse correctly with complicated expression on left hand side" do 
      m = parse("foo(1) += 12+13+53+(x f(123))\n1").to_string
      m.should == "+=(foo(1), 12 +(13) +(53) +(x f(123))) .\n1"
    end
  end

  describe "-=" do 
    it "should parse correctly without receiver, with arguments" do 
      m = parse("(1) -= 12").to_string
      m.should == "-=((1), 12)"
    end
    
    it "should parse correctly with receiver without spaces and arguments" do 
      m = parse("foo(1) -= 12").to_string
      m.should == "-=(foo(1), 12)"
    end

    it "should parse correctly with receiver without even more spaces and arguments" do 
      m = parse("foo(1)-=12").to_string
      m.should == "-=(foo(1), 12)"
    end

    it "should parse correctly with receiver with spaces and arguments" do 
      m = parse("foo (1) -= 12").to_string
      m.should == "-=(foo(1), 12)"
    end
    
    it "should parse correctly with complicated expression on left hand side" do 
      m = parse("foo(1) -= 12+13+53+(x f(123))").to_string
      m.should == "-=(foo(1), 12 +(13) +(53) +(x f(123)))"
    end

    it "should parse correctly with complicated expression on left hand side" do 
      m = parse("foo(1) -= 12+13+53+(x f(123))\n1").to_string
      m.should == "-=(foo(1), 12 +(13) +(53) +(x f(123))) .\n1"
    end
  end

  describe "/=" do 
    it "should parse correctly without receiver, with arguments" do 
      m = parse("(1) /= 12").to_string
      m.should == "/=((1), 12)"
    end
    
    it "should parse correctly with receiver without spaces and arguments" do 
      m = parse("foo(1) /= 12").to_string
      m.should == "/=(foo(1), 12)"
    end

    it "should parse correctly with receiver without even more spaces and arguments" do 
      m = parse("foo(1)/=12").to_string
      m.should == "/=(foo(1), 12)"
    end

    it "should parse correctly with receiver with spaces and arguments" do 
      m = parse("foo (1) /= 12").to_string
      m.should == "/=(foo(1), 12)"
    end
    
    it "should parse correctly with complicated expression on left hand side" do 
      m = parse("foo(1) /= 12+13+53+(x f(123))").to_string
      m.should == "/=(foo(1), 12 +(13) +(53) +(x f(123)))"
    end

    it "should parse correctly with complicated expression on left hand side" do 
      m = parse("foo(1) /= 12+13+53+(x f(123))\n1").to_string
      m.should == "/=(foo(1), 12 +(13) +(53) +(x f(123))) .\n1"
    end
  end

  describe "*=" do 
    it "should parse correctly without receiver, with arguments" do 
      m = parse("(1) *= 12").to_string
      m.should == "*=((1), 12)"
    end
    
    it "should parse correctly with receiver without spaces and arguments" do 
      m = parse("foo(1) *= 12").to_string
      m.should == "*=(foo(1), 12)"
    end

    it "should parse correctly with receiver without even more spaces and arguments" do 
      m = parse("foo(1)*=12").to_string
      m.should == "*=(foo(1), 12)"
    end

    it "should parse correctly with receiver with spaces and arguments" do 
      m = parse("foo (1) *= 12").to_string
      m.should == "*=(foo(1), 12)"
    end
    
    it "should parse correctly with complicated expression on left hand side" do 
      m = parse("foo(1) *= 12+13+53+(x f(123))").to_string
      m.should == "*=(foo(1), 12 +(13) +(53) +(x f(123)))"
    end

    it "should parse correctly with complicated expression on left hand side" do 
      m = parse("foo(1) *= 12+13+53+(x f(123))\n1").to_string
      m.should == "*=(foo(1), 12 +(13) +(53) +(x f(123))) .\n1"
    end
  end

  describe "%=" do 
    it "should parse correctly without receiver, with arguments" do 
      m = parse("(1) %= 12").to_string
      m.should == "%=((1), 12)"
    end
    
    it "should parse correctly with receiver without spaces and arguments" do 
      m = parse("foo(1) %= 12").to_string
      m.should == "%=(foo(1), 12)"
    end

    it "should parse correctly with receiver without even more spaces and arguments" do 
      m = parse("foo(1)%=12").to_string
      m.should == "%=(foo(1), 12)"
    end

    it "should parse correctly with receiver with spaces and arguments" do 
      m = parse("foo (1) %= 12").to_string
      m.should == "%=(foo(1), 12)"
    end
    
    it "should parse correctly with complicated expression on left hand side" do 
      m = parse("foo(1) %= 12+13+53+(x f(123))").to_string
      m.should == "%=(foo(1), 12 +(13) +(53) +(x f(123)))"
    end

    it "should parse correctly with complicated expression on left hand side" do 
      m = parse("foo(1) %= 12+13+53+(x f(123))\n1").to_string
      m.should == "%=(foo(1), 12 +(13) +(53) +(x f(123))) .\n1"
    end
  end

  describe "&=" do 
    it "should parse correctly without receiver, with arguments" do 
      m = parse("(1) &= 12").to_string
      m.should == "&=((1), 12)"
    end
    
    it "should parse correctly with receiver without spaces and arguments" do 
      m = parse("foo(1) &= 12").to_string
      m.should == "&=(foo(1), 12)"
    end

    it "should parse correctly with receiver without even more spaces and arguments" do 
      m = parse("foo(1)&=12").to_string
      m.should == "&=(foo(1), 12)"
    end

    it "should parse correctly with receiver with spaces and arguments" do 
      m = parse("foo (1) &= 12").to_string
      m.should == "&=(foo(1), 12)"
    end
    
    it "should parse correctly with complicated expression on left hand side" do 
      m = parse("foo(1) &= 12+13+53+(x f(123))").to_string
      m.should == "&=(foo(1), 12 +(13) +(53) +(x f(123)))"
    end

    it "should parse correctly with complicated expression on left hand side" do 
      m = parse("foo(1) &= 12+13+53+(x f(123))\n1").to_string
      m.should == "&=(foo(1), 12 +(13) +(53) +(x f(123))) .\n1"
    end
  end

  describe "&&=" do 
    it "should parse correctly without receiver, with arguments" do 
      m = parse("(1) &&= 12").to_string
      m.should == "&&=((1), 12)"
    end
    
    it "should parse correctly with receiver without spaces and arguments" do 
      m = parse("foo(1) &&= 12").to_string
      m.should == "&&=(foo(1), 12)"
    end

    it "should parse correctly with receiver without even more spaces and arguments" do 
      m = parse("foo(1)&&=12").to_string
      m.should == "&&=(foo(1), 12)"
    end

    it "should parse correctly with receiver with spaces and arguments" do 
      m = parse("foo (1) &&= 12").to_string
      m.should == "&&=(foo(1), 12)"
    end
    
    it "should parse correctly with complicated expression on left hand side" do 
      m = parse("foo(1) &&= 12+13+53+(x f(123))").to_string
      m.should == "&&=(foo(1), 12 +(13) +(53) +(x f(123)))"
    end

    it "should parse correctly with complicated expression on left hand side" do 
      m = parse("foo(1) &&= 12+13+53+(x f(123))\n1").to_string
      m.should == "&&=(foo(1), 12 +(13) +(53) +(x f(123))) .\n1"
    end
  end

  describe "|=" do 
    it "should parse correctly without receiver, with arguments" do 
      m = parse("(1) |= 12").to_string
      m.should == "|=((1), 12)"
    end
    
    it "should parse correctly with receiver without spaces and arguments" do 
      m = parse("foo(1) |= 12").to_string
      m.should == "|=(foo(1), 12)"
    end

    it "should parse correctly with receiver without even more spaces and arguments" do 
      m = parse("foo(1)|=12").to_string
      m.should == "|=(foo(1), 12)"
    end

    it "should parse correctly with receiver with spaces and arguments" do 
      m = parse("foo (1) |= 12").to_string
      m.should == "|=(foo(1), 12)"
    end
    
    it "should parse correctly with complicated expression on left hand side" do 
      m = parse("foo(1) |= 12+13+53+(x f(123))").to_string
      m.should == "|=(foo(1), 12 +(13) +(53) +(x f(123)))"
    end

    it "should parse correctly with complicated expression on left hand side" do 
      m = parse("foo(1) |= 12+13+53+(x f(123))\n1").to_string
      m.should == "|=(foo(1), 12 +(13) +(53) +(x f(123))) .\n1"
    end
  end

  describe "||=" do 
    it "should parse correctly without receiver, with arguments" do 
      m = parse("(1) ||= 12").to_string
      m.should == "||=((1), 12)"
    end
    
    it "should parse correctly with receiver without spaces and arguments" do 
      m = parse("foo(1) ||= 12").to_string
      m.should == "||=(foo(1), 12)"
    end

    it "should parse correctly with receiver without even more spaces and arguments" do 
      m = parse("foo(1)||=12").to_string
      m.should == "||=(foo(1), 12)"
    end

    it "should parse correctly with receiver with spaces and arguments" do 
      m = parse("foo (1) ||= 12").to_string
      m.should == "||=(foo(1), 12)"
    end
    
    it "should parse correctly with complicated expression on left hand side" do 
      m = parse("foo(1) ||= 12+13+53+(x f(123))").to_string
      m.should == "||=(foo(1), 12 +(13) +(53) +(x f(123)))"
    end

    it "should parse correctly with complicated expression on left hand side" do 
      m = parse("foo(1) ||= 12+13+53+(x f(123))\n1").to_string
      m.should == "||=(foo(1), 12 +(13) +(53) +(x f(123))) .\n1"
    end
  end

  describe "^=" do 
    it "should parse correctly without receiver, with arguments" do 
      m = parse("(1) ^= 12").to_string
      m.should == "^=((1), 12)"
    end
    
    it "should parse correctly with receiver without spaces and arguments" do 
      m = parse("foo(1) ^= 12").to_string
      m.should == "^=(foo(1), 12)"
    end

    it "should parse correctly with receiver without even more spaces and arguments" do 
      m = parse("foo(1)^=12").to_string
      m.should == "^=(foo(1), 12)"
    end

    it "should parse correctly with receiver with spaces and arguments" do 
      m = parse("foo (1) ^= 12").to_string
      m.should == "^=(foo(1), 12)"
    end
    
    it "should parse correctly with complicated expression on left hand side" do 
      m = parse("foo(1) ^= 12+13+53+(x f(123))").to_string
      m.should == "^=(foo(1), 12 +(13) +(53) +(x f(123)))"
    end

    it "should parse correctly with complicated expression on left hand side" do 
      m = parse("foo(1) ^= 12+13+53+(x f(123))\n1").to_string
      m.should == "^=(foo(1), 12 +(13) +(53) +(x f(123))) .\n1"
    end
  end

  describe ">>=" do 
    it "should parse correctly without receiver, with arguments" do 
      m = parse("(1) >>= 12").to_string
      m.should == ">>=((1), 12)"
    end
    
    it "should parse correctly with receiver without spaces and arguments" do 
      m = parse("foo(1) >>= 12").to_string
      m.should == ">>=(foo(1), 12)"
    end

    it "should parse correctly with receiver without even more spaces and arguments" do 
      m = parse("foo(1)>>=12").to_string
      m.should == ">>=(foo(1), 12)"
    end

    it "should parse correctly with receiver with spaces and arguments" do 
      m = parse("foo (1) >>= 12").to_string
      m.should == ">>=(foo(1), 12)"
    end
    
    it "should parse correctly with complicated expression on left hand side" do 
      m = parse("foo(1) >>= 12+13+53+(x f(123))").to_string
      m.should == ">>=(foo(1), 12 +(13) +(53) +(x f(123)))"
    end

    it "should parse correctly with complicated expression on left hand side" do 
      m = parse("foo(1) >>= 12+13+53+(x f(123))\n1").to_string
      m.should == ">>=(foo(1), 12 +(13) +(53) +(x f(123))) .\n1"
    end
  end

  describe "<<=" do 
    it "should parse correctly without receiver, with arguments" do 
      m = parse("(1) <<= 12").to_string
      m.should == "<<=((1), 12)"
    end
    
    it "should parse correctly with receiver without spaces and arguments" do 
      m = parse("foo(1) <<= 12").to_string
      m.should == "<<=(foo(1), 12)"
    end

    it "should parse correctly with receiver without even more spaces and arguments" do 
      m = parse("foo(1)<<=12").to_string
      m.should == "<<=(foo(1), 12)"
    end

    it "should parse correctly with receiver with spaces and arguments" do 
      m = parse("foo (1) <<= 12").to_string
      m.should == "<<=(foo(1), 12)"
    end
    
    it "should parse correctly with complicated expression on left hand side" do 
      m = parse("foo(1) <<= 12+13+53+(x f(123))").to_string
      m.should == "<<=(foo(1), 12 +(13) +(53) +(x f(123)))"
    end

    it "should parse correctly with complicated expression on left hand side" do 
      m = parse("foo(1) <<= 12+13+53+(x f(123))\n1").to_string
      m.should == "<<=(foo(1), 12 +(13) +(53) +(x f(123))) .\n1"
    end
  end
  
  describe "()=" do 
    it "should parse correctly without receiver, with arguments" do 
      m = parse("(1) = 12").to_string
      m.should == "=((1), 12)"
    end
    
    it "should parse correctly with receiver without spaces and arguments" do 
      m = parse("foo(1) = 12").to_string
      m.should == "=(foo(1), 12)"
    end

    it "should parse correctly with receiver without even more spaces and arguments" do 
      m = parse("foo(1)=12").to_string
      m.should == "=(foo(1), 12)"
    end

    it "should parse correctly with receiver with spaces and arguments" do 
      m = parse("foo (1) = 12").to_string
      m.should == "=(foo(1), 12)"
    end
    
    it "should parse correctly with complicated expression on left hand side" do 
      m = parse("foo(1) = 12+13+53+(x f(123))").to_string
      m.should == "=(foo(1), 12 +(13) +(53) +(x f(123)))"
    end

    it "should parse correctly with complicated expression on left hand side" do 
      m = parse("foo(1) = 12+13+53+(x f(123))\n1").to_string
      m.should == "=(foo(1), 12 +(13) +(53) +(x f(123))) .\n1"
    end
  end

  describe "[]=" do 
    it "should parse correctly without receiver, with arguments" do 
      m = parse("[1] = 12").to_string
      m.should == "=([](1), 12)"
    end
    
    it "should parse correctly with receiver without spaces and arguments" do 
      m = parse("foo[1] = 12").to_string
      m.should == "foo =([](1), 12)"
    end

    it "should parse correctly with receiver without even more spaces and arguments" do 
      m = parse("foo[1]=12").to_string
      m.should == "foo =([](1), 12)"
    end

    it "should parse correctly with receiver with spaces and arguments" do 
      m = parse("foo [1] = 12").to_string
      m.should == "foo =([](1), 12)"
    end
    
    it "should parse correctly with complicated expression on left hand side" do 
      m = parse("foo[1] = 12+13+53+(x f(123))").to_string
      m.should == "foo =([](1), 12 +(13) +(53) +(x f(123)))"
    end

    it "should parse correctly with complicated expression on left hand side" do 
      m = parse("foo[1] = 12+13+53+(x f(123))\n1").to_string
      m.should == "foo =([](1), 12 +(13) +(53) +(x f(123))) .\n1"
    end
  end

  describe "{}=" do 
    it "should parse correctly without receiver, with arguments" do 
      m = parse("{1} = 12").to_string
      m.should == "=({}(1), 12)"
    end
    
    it "should parse correctly with receiver without spaces and arguments" do 
      m = parse("foo{1} = 12").to_string
      m.should == "foo =({}(1), 12)"
    end

    it "should parse correctly with receiver without even more spaces and arguments" do 
      m = parse("foo{1}=12").to_string
      m.should == "foo =({}(1), 12)"
    end

    it "should parse correctly with receiver with spaces and arguments" do 
      m = parse("foo {1} = 12").to_string
      m.should == "foo =({}(1), 12)"
    end
    
    it "should parse correctly with complicated expression on left hand side" do 
      m = parse("foo{1} = 12+13+53+(x f(123))").to_string
      m.should == "foo =({}(1), 12 +(13) +(53) +(x f(123)))"
    end

    it "should parse correctly with complicated expression on left hand side" do 
      m = parse("foo{1} = 12+13+53+(x f(123))\n1").to_string
      m.should == "foo =({}(1), 12 +(13) +(53) +(x f(123))) .\n1"
    end
  end
  
  describe "'++'" do 
    it "should parse correctly in postfix without space" do 
      m = parse("a++").to_string
      m.should == "++(a)"
    end

    it "should parse correctly with receiver in postfix without space" do 
      m = parse("foo a++").to_string
      m.should == "foo ++(a)"
    end

    it "should parse correctly in method call in postfix without space" do 
      m = parse("foo(a++)").to_string
      m.should == "foo(++(a))"
    end
    
    it "should parse correctly in postfix with space" do 
      m = parse("a ++").to_string
      m.should == "++(a)"
    end

    it "should parse correctly with receiver in postfix with space" do 
      m = parse("foo a ++").to_string
      m.should == "foo ++(a)"
    end

    it "should parse correctly in method call in postfix with space" do 
      m = parse("foo(a ++)").to_string
      m.should == "foo(++(a))"
    end
    
    it "should parse correctly as message send" do 
      m = parse("++(a)").to_string
      m.should == "++(a)"
    end

    it "should parse correctly with receiver as message send" do 
      m = parse("foo ++(a)").to_string
      m.should == "foo ++(a)"
    end

    it "should parse correctly in method call as message send" do 
      m = parse("foo(++(a))").to_string
      m.should == "foo(++(a))"
    end
    
    it "should parse correctly when combined with assignment" do 
      m = parse("foo x = a++").to_string
      m.should == "foo =(x, ++(a))"
    end

    it "should parse correctly when combined with assignment and receiver" do 
      m = parse("foo x = Foo a++").to_string
      m.should == "foo =(x, Foo ++(a))"
    end
    
    it "should increment number" do 
      ioke = IokeRuntime.get_runtime()
      ioke.evaluate_stream(StringReader.new(%q[x = 0. x++]))
      ioke.ground.find_cell(nil, nil, "x").data.as_java_integer.should == 1
    end
  end

  describe "'--'" do 
    it "should parse correctly in postfix without space" do 
      m = parse("a--").to_string
      m.should == "--(a)"
    end

    it "should parse correctly with receiver in postfix without space" do 
      m = parse("foo a--").to_string
      m.should == "foo --(a)"
    end

    it "should parse correctly in method call in postfix without space" do 
      m = parse("foo(a--)").to_string
      m.should == "foo(--(a))"
    end
    
    it "should parse correctly in postfix with space" do 
      m = parse("a --").to_string
      m.should == "--(a)"
    end

    it "should parse correctly with receiver in postfix with space" do 
      m = parse("foo a --").to_string
      m.should == "foo --(a)"
    end

    it "should parse correctly in method call in postfix with space" do 
      m = parse("foo(a --)").to_string
      m.should == "foo(--(a))"
    end
    
    it "should parse correctly as message send" do 
      m = parse("--(a)").to_string
      m.should == "--(a)"
    end

    it "should parse correctly with receiver as message send" do 
      m = parse("foo --(a)").to_string
      m.should == "foo --(a)"
    end

    it "should parse correctly in method call as message send" do 
      m = parse("foo(--(a))").to_string
      m.should == "foo(--(a))"
    end
    
    it "should parse correctly when combined with assignment" do 
      m = parse("foo x = a--").to_string
      m.should == "foo =(x, --(a))"
    end

    it "should parse correctly when combined with assignment and receiver" do 
      m = parse("foo x = Foo a--").to_string
      m.should == "foo =(x, Foo --(a))"
    end

    it "should decrement number" do 
      ioke = IokeRuntime.get_runtime()
      ioke.evaluate_stream(StringReader.new(%q[x = 1. x--]))
      ioke.ground.find_cell(nil, nil, "x").data.as_java_integer.should == 0
    end
  end
end
