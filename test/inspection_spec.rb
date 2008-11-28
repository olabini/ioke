include_class('ioke.lang.Runtime') { 'IokeRuntime' } unless defined?(IokeRuntime)

describe "DefaultBehavior" do 
  describe "'cellDescriptionDict'" do 
    it "should return an empty dict for an object without cells" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string("Origin mimic cellDescriptionDict == {}").should == ioke.true
    end

    it "should return a dict with an element for something more complicated" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string("x = Origin mimic. x foo = :bar. x cellDescriptionDict == {foo: \":bar\"}").should == ioke.true
    end

    it "should return a dict with an element for a method" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string("x = Origin mimic. x foo = method(bar). x cellDescriptionDict == {foo: \"foo:method(...)\"}").should == ioke.true
    end

    it "should return a dict with more than one element" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string("x = Origin mimic. x y = 42. x z = 22. x cellDescriptionDict == {y: \"42\", z: \"22\"}").should == ioke.true
    end
  end
  
  describe "'cellSummary'" do 
    it "should use notice for the first line"
    it "should use cellDescriptionDict for the data"
  end
  
  describe "'inspect'" do 
    it "should use cellSummary" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string(<<CODE).should == ioke.true
x = Origin mimic
x cellSummary = "blarg"
x inspect == "blarg"
CODE
    end
  end

  describe "'notice'" do 
    it "should return the kind and hex string for a simple object from Origin" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string(<<CODE).should == ioke.true
x = Origin mimic
x uniqueHexId = "0x3FF420"
x notice == "Origin_0x3FF420"
CODE
    end
    
    it "should handle a new kind" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string(<<CODE).should == ioke.true
Blarg = Origin mimic
x = Blarg mimic
x uniqueHexId = "0x3FF420"
x notice == "Blarg_0x3FF420"
CODE
    end
  end
end

describe "nil" do 
  describe "'inspect'" do 
    it "should return 'nil'" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string('nil inspect').data.text.should == "nil"
    end
  end

  describe "'notice'" do 
    it "should return 'nil'" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string('nil notice').data.text.should == "nil"
    end
  end
end

describe "true" do 
  describe "'inspect'" do 
    it "should return 'true'" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string('true inspect').data.text.should == "true"
    end
  end

  describe "'notice'" do 
    it "should return 'true'" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string('true notice').data.text.should == "true"
    end
  end
end

describe "false" do 
  describe "'inspect'" do 
    it "should return 'false'" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string('false inspect').data.text.should == "false"
    end
  end

  describe "'notice'" do 
    it "should return 'false'" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string('false notice').data.text.should == "false"
    end
  end
end

describe "Ground" do 
  describe "'notice'" do 
    it "should return 'Ground'" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string('Ground notice').data.text.should == "Ground"
    end

    it "should not return 'Ground' for a mimic" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string('Ground mimic notice').data.text.should_not == "Ground"
    end
  end
end

describe "Origin" do 
  describe "'notice'" do 
    it "should return 'Origin'" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string('Origin notice').data.text.should == "Origin"
    end

    it "should not return 'Origin' for a mimic" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string('Origin mimic notice').data.text.should_not == "Origin"
    end
  end
end

describe "Text" do 
  describe "'notice'" do 
    it "should return the Text inside of quotes" do
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string('"" notice == "\"\""').should == ioke.true
      ioke.evaluate_string('"foo" notice == "\"foo\""').should == ioke.true
      ioke.evaluate_string('"foo\nbar" notice == "\"foo\\nbar\""').should == ioke.true
    end      
  end
  
  describe "'inspect'" do 
    it "should return the Text inside of quotes" do
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string('"" inspect == "\"\""').should == ioke.true
      ioke.evaluate_string('"foo" inspect == "\"foo\""').should == ioke.true
      ioke.evaluate_string('"foo\nbar" inspect == "\"foo\\nbar\""').should == ioke.true
    end      
  end
end

describe "Symbol" do 
  describe "'notice'" do 
    it "should return the symbol with a colon in front of it" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string(':foo notice == ":foo"').should == ioke.true
      ioke.evaluate_string(':x notice == ":x"').should == ioke.true
      ioke.evaluate_string(':AAAAAAAAAA notice == ":AAAAAAAAAA"').should == ioke.true
    end

    it "should quote the symbol if necessary" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string(':"=" notice == ":\"=\""').should == ioke.true
      ioke.evaluate_string(':"" notice == ":\"\""').should == ioke.true
    end
  end
  
  describe "'inspect'" do 
    it "should return the symbol with a colon in front of it" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string(':foo inspect == ":foo"').should == ioke.true
      ioke.evaluate_string(':x inspect == ":x"').should == ioke.true
      ioke.evaluate_string(':AAAAAAAAAA inspect == ":AAAAAAAAAA"').should == ioke.true
    end

    it "should quote the symbol if necessary" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string(':"=" inspect == ":\"=\""').should == ioke.true
      ioke.evaluate_string(':"" inspect == ":\"\""').should == ioke.true
    end
  end
end

describe "Number" do 
  describe "'notice'" do 
    it "should return the textual representation of the number" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string('0 notice == "0"').should == ioke.true
      ioke.evaluate_string('22342340 notice == "22342340"').should == ioke.true
      ioke.evaluate_string('333391244 notice == "333391244"').should == ioke.true
    end

    it "should return the textual representation of a negative number" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string('(-1) notice == "-1"').should == ioke.true
      ioke.evaluate_string('(-22342340) notice == "-22342340"').should == ioke.true
      ioke.evaluate_string('(-333391244) notice == "-333391244"').should == ioke.true
    end
  end
  
  describe "'inspect'" do 
    it "should return the textual representation of the number" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string('0 inspect == "0"').should == ioke.true
      ioke.evaluate_string('22342340 inspect == "22342340"').should == ioke.true
      ioke.evaluate_string('333391244 inspect == "333391244"').should == ioke.true
    end

    it "should return the textual representation of a negative number" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string('(-1) inspect == "-1"').should == ioke.true
      ioke.evaluate_string('(-22342340) inspect == "-22342340"').should == ioke.true
      ioke.evaluate_string('(-333391244) inspect == "-333391244"').should == ioke.true
    end
  end
end

describe "DefaultMethod" do 
  describe "'notice'" do 
    it "should just return a simple description without code" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string('method() notice == "method(...)"').should == ioke.true
      ioke.evaluate_string('method(nil) notice == "method(...)"').should == ioke.true
      ioke.evaluate_string('method(foo bar xxxxxx) notice == "method(...)"').should == ioke.true
    end
    
    it "should prepend the name if there is a name available" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string('x = method(). cell(:x) notice == "x:method(...)"').should == ioke.true
      ioke.evaluate_string('x = method(nil). cell(:x) notice == "x:method(...)"').should == ioke.true
      ioke.evaluate_string('x = method(foo bar xxxxxx). cell(:x) notice == "x:method(...)"').should == ioke.true
    end
  end
  
  describe "'inspect'" do 
    it "should return the code inside the method" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string('method(foo bar) inspect == "method(foo bar)"').should == ioke.true
      ioke.evaluate_string('method(123 + 444) inspect == "method(123 +(444))"').should == ioke.true
    end

    it "should prepend a name if there is any" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string('x = method(foo bar). cell(:x) inspect == "x:method(foo bar)"').should == ioke.true
      ioke.evaluate_string('x = method(123 + 444). cell(:x) inspect == "x:method(123 +(444))"').should == ioke.true
    end

    it "should include any argument names provided" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string('method(x, foo bar) inspect == "method(x, foo bar)"').should == ioke.true
      ioke.evaluate_string('method(y, foo 123, 123 + 444) inspect == "method(y, foo 123, 123 +(444))"').should == ioke.true
    end
  end
end

describe "DefaultMacro" do 
  describe "'notice'" do 
    it "should just return a simple description without code" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string('macro() notice == "macro(...)"').should == ioke.true
      ioke.evaluate_string('macro(nil) notice == "macro(...)"').should == ioke.true
      ioke.evaluate_string('macro(foo bar xxxxxx) notice == "macro(...)"').should == ioke.true
    end

    it "should prepend the name if there is a name available" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string('x = macro(). cell(:x) notice == "x:macro(...)"').should == ioke.true
      ioke.evaluate_string('x = macro(nil). cell(:x) notice == "x:macro(...)"').should == ioke.true
      ioke.evaluate_string('x = macro(foo bar xxxxxx). cell(:x) notice == "x:macro(...)"').should == ioke.true
    end
  end
  
  describe "'inspect'" do 
    it "should return the code inside the macro" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string('macro(foo bar) inspect == "macro(foo bar)"').should == ioke.true
      ioke.evaluate_string('macro(123 + 444) inspect == "macro(123 +(444))"').should == ioke.true
    end

    it "should prepend the name if it is available" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string('x = macro(foo bar). cell(:x) inspect == "x:macro(foo bar)"').should == ioke.true
      ioke.evaluate_string('x = macro(123 + 444). cell(:x) inspect == "x:macro(123 +(444))"').should == ioke.true
    end
  end
end

describe "LexicalBlock" do 
  describe "'notice'" do 
    it "should just return a simple description without code" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string('fn() notice == "fn(...)"').should == ioke.true
      ioke.evaluate_string('fn(nil) notice == "fn(...)"').should == ioke.true
      ioke.evaluate_string('fn(foo bar xxxxxx) notice == "fn(...)"').should == ioke.true

      ioke.evaluate_string('fnx() notice == "fnx(...)"').should == ioke.true
      ioke.evaluate_string('fnx(nil) notice == "fnx(...)"').should == ioke.true
      ioke.evaluate_string('fnx(foo bar xxxxxx) notice == "fnx(...)"').should == ioke.true
    end
  end
  
  describe "'inspect'" do 
    it "should return the code inside the method" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string('fn(foo bar) inspect == "fn(foo bar)"').should == ioke.true
      ioke.evaluate_string('fn(123 + 444) inspect == "fn(123 +(444))"').should == ioke.true

      ioke.evaluate_string('fnx(foo bar) inspect == "fnx(foo bar)"').should == ioke.true
      ioke.evaluate_string('fnx(123 + 444) inspect == "fnx(123 +(444))"').should == ioke.true
    end

    it "should include any argument names provided" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string('fn(x, foo bar) inspect == "fn(x, foo bar)"').should == ioke.true
      ioke.evaluate_string('fn(y, foo 123, 123 + 444) inspect == "fn(y, foo 123, 123 +(444))"').should == ioke.true

      ioke.evaluate_string('fnx(x, foo bar) inspect == "fnx(x, foo bar)"').should == ioke.true
      ioke.evaluate_string('fnx(y, foo 123, 123 + 444) inspect == "fnx(y, foo 123, 123 +(444))"').should == ioke.true
    end
  end
end

describe "List" do 
  describe "'notice'" do 
    it "should return something within square brackets" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string('[] notice == "[]"').should == ioke.true
    end
    
    it "should return the notice format of things inside" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string('[method, method, fn] notice == "[method(...), method(...), fn(...)]"').should == ioke.true
    end

    it "should return the list of elements separated with , " do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string('[1, 2, :foo, "bar"] notice == "[1, 2, :foo, \"bar\"]"').should == ioke.true
    end
  end
  
  describe "'inspect'" do 
    it "should return something within square brackets" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string('[] inspect == "[]"').should == ioke.true
    end
    
    it "should return the inspect format of things inside" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string('[method(nil), method(f, f b), fn(a b)] inspect == "[method(nil), method(f, f b), fn(a b)]"').should == ioke.true
    end

    it "should return the list of elements separated with , " do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string('[1, 2, :foo, "bar"] inspect == "[1, 2, :foo, \"bar\"]"').should == ioke.true
    end
  end
end

describe "Dict" do 
  describe "'notice'" do 
    it "should return something within curly brackets" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string('{} notice == "{}"').should == ioke.true
    end

    it "should try to use the keyword syntax if possible" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string('result = {foo: "bar", "bar" => :foo} notice. (result == "{foo: \"bar\", \"bar\" => :foo}") || (result == "{\"bar\" => :foo, foo: \"bar\"}")').should == ioke.true
      ioke.evaluate_string('{:foo => :bar} notice == "{foo: :bar}"').should == ioke.true
    end

    it "should return the notice format of things inside" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string('{foo: method(abc foo bar)} notice == "{foo: method(...)}"').should == ioke.true
      ioke.evaluate_string('{method(abc foo bar) => :foo} notice == "{method(...) => :foo}"').should == ioke.true
    end

    it "should return non-keyword things with pair syntax" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string('{1=>1} notice == "{1 => 1}"').should == ioke.true
      ioke.evaluate_string('{"bar"=>1} notice == "{\"bar\" => 1}"').should == ioke.true
    end
  end
  
  describe "'inspect'" do 
    it "should return something within curly brackets" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string('{} inspect == "{}"').should == ioke.true
    end

    it "should try to use the keyword syntax if possible" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string('result = {foo: "bar", "bar" => :foo} inspect. (result == "{foo: \"bar\", \"bar\" => :foo}") || (result == "{\"bar\" => :foo, foo: \"bar\"}")').should == ioke.true
      ioke.evaluate_string('{:foo => :bar} inspect == "{foo: :bar}"').should == ioke.true
    end

    it "should return the inspect format of things inside" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string('{foo: method(abc foo bar)} inspect == "{foo: method(abc foo bar)}"').should == ioke.true
      ioke.evaluate_string('{method(abc foo bar) => :foo} inspect == "{method(abc foo bar) => :foo}"').should == ioke.true
    end

    it "should return non-keyword things with pair syntax" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string('{1=>1} inspect == "{1 => 1}"').should == ioke.true
      ioke.evaluate_string('{"bar"=>1} inspect == "{\"bar\" => 1}"').should == ioke.true
    end
  end
end

describe "Set" do 
  describe "'notice'" do 
    it "should return something inside of a call to set" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string('set notice == "set()"').should == ioke.true
      ioke.evaluate_string('set() notice == "set()"').should == ioke.true
      ioke.evaluate_string('set(1) notice == "set(1)"').should == ioke.true
    end

    it "should use notice format for things inside" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string('set(method(foo bar baz)) notice == "set(method(...))"').should == ioke.true
    end

    it "should return all the elements separated by commas" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string('val = set(1, 2, 2, 2) notice. (val == "set(1, 2)") || (val == "set(2, 1)")').should == ioke.true
    end
  end
  
  describe "'inspect'" do 
    it "should return something inside of a call to set" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string('set inspect == "set()"').should == ioke.true
      ioke.evaluate_string('set() inspect == "set()"').should == ioke.true
      ioke.evaluate_string('set(1) inspect == "set(1)"').should == ioke.true
    end
    
    it "should use inspect format for things inside" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string('set(method(foo bar baz)) inspect == "set(method(foo bar baz))"').should == ioke.true
    end

    it "should return all the elements separated by commas" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string('val = set(1, 2, 2, 2) inspect. (val == "set(1, 2)") || (val == "set(2, 1)")').should == ioke.true
    end
  end
end

describe "Pair" do 
  describe "'notice'" do 
    it "should return it's two elements separated by => " do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string('(1 => 2) notice == "1 => 2"').should == ioke.true
    end

    it "should use notice format for elements" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string('(method(abc foo qux) => 2) notice == "method(...) => 2"').should == ioke.true
      ioke.evaluate_string('(2 => method(abc foo qux)) notice == "2 => method(...)"').should == ioke.true
    end
  end
  
  describe "'inspect'" do 
    it "should return it's two elements separated by => " do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string('(1 => 2) inspect == "1 => 2"').should == ioke.true
    end

    it "should use inspect format for elements" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string('(method(abc foo qux) => 2) inspect == "method(abc foo qux) => 2"').should == ioke.true
      ioke.evaluate_string('(2 => method(abc foo qux)) inspect == "2 => method(abc foo qux)"').should == ioke.true
    end
  end
end

describe "System" do 
  describe "'notice'" do 
    it "should return 'System'" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string('System notice').data.text.should == "System"
    end

    it "should not return 'System' for a mimic" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string('System mimic notice').data.text.should_not == "System"
    end
  end
end

describe "Runtime" do 
  describe "'notice'" do 
    it "should return 'Runtime'" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string('Runtime notice').data.text.should == "Runtime"
    end

    it "should not return 'Runtime' for a mimic" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string('Runtime mimic notice').data.text.should_not == "Runtime"
    end
  end
end


