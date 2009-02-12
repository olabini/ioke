
use("ispec")

describe(DefaultBehavior, 
  it("should be possible to inspect all the cells in ground",
    Ground cells inspect
  )

  it("should be possible to inspect all the cells in an Origin mimic",
    Origin mimic cells(true) inspect
  )

  it("should be possible to notice all the cells in an Origin mimic",
    Origin mimic cells(true) notice
  )
  
  describe("cellDescriptionDict", 
    it("should return an empty dict for an object without cells", 
      Origin mimic cellDescriptionDict should == {}
    )

    it("should return a dict with an element for something more complicated", 
      x = Origin mimic. x foo = :bar. x cellDescriptionDict should == {foo: ":bar"}
    )

    it("should return a dict with an element for a method", 
      x = Origin mimic. x foo = method(bar). x cellDescriptionDict should == {foo: "foo:method(...)"}
    )

    it("should return a dict with more than one element", 
      x = Origin mimic. x y = 42. x z = 22. x cellDescriptionDict should == {y: "42", z: "22"}
    )
  )
  
  describe("cellSummary", 
    it("should use notice for the first line", 
      x = Origin mimic
      x uniqueHexId = "0x3FF420"
      x cellSummary[0...18] should ==  " Origin_0x3FF420:\n"
    )

    it("should use cellDescriptionDict for the data", 
      x = Origin mimic
      x uniqueHexId = "0x3FF420"
      x cellDescriptionDict = {foo: "bar"}
      x cellSummary[0...57] should == " Origin_0x3FF420:\n  foo                          = bar\n"
    )
  )
  
  describe("inspect", 
    it("should use cellSummary", 
      x = Origin mimic
      x cellSummary = "blarg"
      x inspect should == "blarg"
    )
  )

  describe("notice", 
    it("should return the kind and hex string for a simple object from Origin", 
      x = Origin mimic
      x uniqueHexId = "0x3FF420"
      x notice should == "Origin_0x3FF420"
    )
    
    it("should handle a new kind", 
      Ground Blarg = Origin mimic
      x = Blarg mimic
      x uniqueHexId = "0x3FF420"
      x notice should == "Blarg_0x3FF420"
    )
  )
)

describe(nil, 
  describe("inspect", 
    it("should return 'nil", 
      nil inspect should == "nil"
    )
  )

  describe("notice", 
    it("should return 'nil", 
      nil notice should  == "nil"
    )
  )
)

describe(true, 
  describe("inspect", 
    it("should return 'true", 
      true inspect should == "true"
    )
  )

  describe("notice", 
    it("should return 'true", 
      true notice should == "true"
    )
  )
)

describe(false, 
  describe("inspect", 
    it("should return 'false", 
      false inspect should == "false"
    )
  )

  describe("notice", 
    it("should return 'false", 
      false notice should == "false"
    )
  )
)

describe(Ground, 
  describe("notice", 
    it("should return 'Ground", 
      Ground notice should == "Ground"
    )

    it("should not return 'Ground' for a mimic", 
      Ground mimic notice should not == "Ground"
    )
  )
)

describe(Origin, 
  describe("notice", 
    it("should return 'Origin", 
      Origin notice should == "Origin"
    )

    it("should not return 'Origin' for a mimic", 
      Origin mimic notice should not == "Origin"
    )
  )
)

describe("Text", 
  describe("notice", 
    it("should return the Text inside of quotes",
      "" notice should == "\"\""
      "foo" notice should == "\"foo\""
      "foo\nbar" notice should == "\"foo\nbar\""
    )      
  )
  
  describe("inspect", 
    it("should return the Text inside of quotes",
      "" inspect should == "\"\""
      "foo" inspect should == "\"foo\""
      "foo\nbar" inspect should == "\"foo\nbar\""
    )      
  )
)

describe("Symbol", 
  describe("notice", 
    it("should return the symbol with a colon in front of it", 
      :foo notice should == ":foo"
      :x notice should == ":x"
      :AAAAAAAAAA notice should == ":AAAAAAAAAA"
    )

    it("should quote the symbol if necessary", 
      :"=" notice should == ":\"=\""
      :"" notice should == ":\"\""
    )
  )
  
  describe("inspect", 
    it("should return the symbol with a colon in front of it", 
      :foo inspect should == ":foo"
      :x inspect should == ":x"
      :AAAAAAAAAA inspect should == ":AAAAAAAAAA"
    )

    it("should quote the symbol if necessary", 
      :"=" inspect should == ":\"=\""
      :"" inspect should == ":\"\""
    )
  )
)

describe("Number", 
  describe("notice", 
    it("should return the textual representation of the number", 
      0 notice should == "0"
      22342340 notice should == "22342340"
      333391244 notice should == "333391244"
    )

    it("should return the textual representation of a negative number", 
      (-1) notice should == "-1"
      (-22342340) notice should == "-22342340"
      (-333391244) notice should == "-333391244"
    )
  )
  
  describe("inspect", 
    it("should return the textual representation of the number", 
      0 inspect should == "0"
      22342340 inspect should == "22342340"
      333391244 inspect should == "333391244"
    )

    it("should return the textual representation of a negative number", 
      (-1) inspect should == "-1"
      (-22342340) inspect should == "-22342340"
      (-333391244) inspect should == "-333391244"
    )
  )

  describe("Decimal", 
    describe("notice", 
      it("should return the textual representation of the number", 
        0.0 notice should == "0.0"
        1.0 notice should == "1.0"
        1.3434534534534263456345 notice should == "1.3434534534534263456345"
        1.000000000000000 notice should == "1.0"
        1e3 notice should == "1000.0"
        22342340.0 notice should == "22342340.0"
        333391244.0 notice should == "333391244.0"
      )

      it("should return the textual representation of a negative number", 
        (-1.0) notice should == "-1.0"
        (-22342340.0) notice should == "-22342340.0"
        (-333391244.0) notice should == "-333391244.0"
      )
    )
    
    describe("inspect", 
      it("should return the textual representation of the number", 
        0.1 inspect should == "0.1"
        22342340.1 inspect should == "22342340.1"
        333391244.1 inspect should == "333391244.1"
      )

      it("should return the textual representation of a negative number", 
        (-1.1) inspect should == "-1.1"
        (-22342340.1) inspect should == "-22342340.1"
        (-333391244.1) inspect should == "-333391244.1"
      )
    )
  )
)

describe("DefaultMethod", 
  describe("notice", 
    it("should just return a simple description without code", 
      method() notice should == "method(...)"
      method(nil) notice should == "method(...)"
      method(foo bar xxxxxx) notice should == "method(...)"
    )
    
    it("should prep) the name if there is a name available", 
      x = method(). cell(:x) notice should == "x:method(...)"
      x = method(nil). cell(:x) notice should == "x:method(...)"
      x = method(foo bar xxxxxx). cell(:x) notice should == "x:method(...)"
    )
  )
  
  describe("inspect", 
    it("should return the code inside the method", 
      method(foo bar) inspect should == "method(foo bar)"
      method(123 + 444) inspect should == "method(123 +(444))"
    )

    it("should prep) a name if there is any", 
      x = method(foo bar). cell(:x) inspect should == "x:method(foo bar)"
      x = method(123 + 444). cell(:x) inspect should == "x:method(123 +(444))"
    )

    it("should include any argument names provided", 
      method(x, foo bar) inspect should == "method(x, foo bar)"
      method(y, foo 123, 123 + 444) inspect should == "method(y, foo 123, 123 +(444))"
    )
  )
)

describe("DefaultMacro", 
  describe("notice", 
    it("should just return a simple description without code", 
      macro() notice should == "macro(...)"
      macro(nil) notice should == "macro(...)"
      macro(foo bar xxxxxx) notice should == "macro(...)"
    )

    it("should prep) the name if there is a name available", 
      x = macro(). cell(:x) notice should == "x:macro(...)"
      x = macro(nil). cell(:x) notice should == "x:macro(...)"
      x = macro(foo bar xxxxxx). cell(:x) notice should == "x:macro(...)"
    )
  )
  
  describe("inspect", 
    it("should return the code inside the macro", 
      macro(foo bar) inspect should == "macro(foo bar)"
      macro(123 + 444) inspect should == "macro(123 +(444))"
    )

    it("should prep) the name if it is available", 
      x = macro(foo bar). cell(:x) inspect should == "x:macro(foo bar)"
      x = macro(123 + 444). cell(:x) inspect should == "x:macro(123 +(444))"
    )
  )
)

describe("LexicalBlock", 
  describe("notice", 
    it("should just return a simple description without code", 
      fn() notice should == "fn(...)"
      fn(nil) notice should == "fn(...)"
      fn(foo bar xxxxxx) notice should == "fn(...)"

      fnx() notice should == "fnx(...)"
      fnx(nil) notice should == "fnx(...)"
      fnx(foo bar xxxxxx) notice should == "fnx(...)"
    )
  )
  
  describe("inspect", 
    it("should return the code inside the method", 
      fn(foo bar) inspect should == "fn(foo bar)"
      fn(123 + 444) inspect should == "fn(123 +(444))"

      fnx(foo bar) inspect should == "fnx(foo bar)"
      fnx(123 + 444) inspect should == "fnx(123 +(444))"
    )

    it("should include any argument names provided", 
      fn(x, foo bar) inspect should == "fn(x, foo bar)"
      fn(y, foo 123, 123 + 444) inspect should == "fn(y, foo 123, 123 +(444))"

      fnx(x, foo bar) inspect should == "fnx(x, foo bar)"
      fnx(y, foo 123, 123 + 444) inspect should == "fnx(y, foo 123, 123 +(444))"
    )
  )
)

describe("List", 
  describe("notice", 
    it("should return something within square brackets", 
      [] notice should == "[]"
    )
    
    it("should return the notice format of things inside", 
      [method, method, fn] notice should == "[method(...), method(...), fn(...)]"
    )

    it("should return the list of elements separated with , ", 
      [1, 2, :foo, "bar"] notice should == "[1, 2, :foo, \"bar\"]"
    )
  )
  
  describe("inspect", 
    it("should return something within square brackets", 
      [] inspect should == "[]"
    )
    
    it("should return the inspect format of things inside", 
      [method(nil), method(f, f b), fn(a b)] inspect should == "[method(nil), method(f, f b), fn(a b)]"
    )

    it("should return the list of elements separated with , ", 
      [1, 2, :foo, "bar"] inspect should == "[1, 2, :foo, \"bar\"]"
    )
  )
)

describe("Dict", 
  describe("notice", 
    it("should return something within curly brackets", 
      {} notice should == "{}"
    )

    it("should try to use the keyword syntax if possible", 
      result = {foo: "bar", "bar" => :foo} notice
      ((result == "{foo: \"bar\", \"bar\" => :foo}") || (result == "{\"bar\" => :foo, foo: \"bar\"}")) should be true
      {:foo => :bar} notice should == "{foo: :bar}"
    )

    it("should return the notice format of things inside", 
      {foo: method(abc foo bar)} notice should == "{foo: method(...)}"
      {method(abc foo bar) => :foo} notice should == "{method(...) => :foo}"
    )

    it("should return non-keyword things with pair syntax", 
      {1=>1} notice should == "{1 => 1}"
      {"bar"=>1} notice should == "{\"bar\" => 1}"
    )
  )
  
  describe("inspect", 
    it("should return something within curly brackets", 
      {} inspect should == "{}"
    )

    it("should try to use the keyword syntax if possible", 
      result = {foo: "bar", "bar" => :foo} inspect
      (result == "{foo: \"bar\", \"bar\" => :foo}") || (result == "{\"bar\" => :foo, foo: \"bar\"}") should be true
      {:foo => :bar} inspect should == "{foo: :bar}"
    )

    it("should return the inspect format of things inside", 
      {foo: method(abc foo bar)} inspect should == "{foo: method(abc foo bar)}"
      {method(abc foo bar) => :foo} inspect should == "{method(abc foo bar) => :foo}"
    )

    it("should return non-keyword things with pair syntax", 
      {1=>1} inspect should == "{1 => 1}"
      {"bar"=>1} inspect should == "{\"bar\" => 1}"
    )
  )
)

describe("Set", 
  describe("notice", 
    it("should return something inside of a call to set", 
      set notice should == "set()"
      set() notice should == "set()"
      set(1) notice should == "set(1)"
    )

    it("should use notice format for things inside", 
      set(method(foo bar baz)) notice should == "set(method(...))"
    )

    it("should return all the elements separated by commas", 
      val = set(1, 2, 2, 2) notice
      (val == "set(1, 2)") || (val == "set(2, 1)") should be true
    )
  )
  
  describe("inspect", 
    it("should return something inside of a call to set", 
      set inspect should == "set()"
      set() inspect should == "set()"
      set(1) inspect should == "set(1)"
    )
    
    it("should use inspect format for things inside", 
      set(method(foo bar baz)) inspect should == "set(method(foo bar baz))"
    )

    it("should return all the elements separated by commas", 
      val = set(1, 2, 2, 2) inspect. 
      (val == "set(1, 2)") || (val == "set(2, 1)") should be true
    )
  )
)

describe("Pair", 
  describe("notice", 
    it("should return it's two elements separated by => ", 
      (1 => 2) notice should == "1 => 2"
    )

    it("should use notice format for elements", 
      (method(abc foo qux) => 2) notice should == "method(...) => 2"
      (2 => method(abc foo qux)) notice should == "2 => method(...)"
    )
  )
  
  describe("inspect", 
    it("should return it's two elements separated by => ", 
      (1 => 2) inspect should == "1 => 2"
    )

    it("should use inspect format for elements", 
      (method(abc foo qux) => 2) inspect should == "method(abc foo qux) => 2"
      (2 => method(abc foo qux)) inspect should == "2 => method(abc foo qux)"
    )
  )
)

describe(System, 
  describe("notice", 
    it("should return 'System", 
      System notice should == "System"
    )

    it("should not return 'System' for a mimic", 
      System mimic notice should not == "System"
    )
  )
)

describe(Runtime, 
  describe("notice", 
    it("should return 'Runtime", 
      Runtime notice should == "Runtime"
    )

    it("should not return 'Runtime' for a mimic", 
      Runtime mimic notice should not == "Runtime"
    )
  )
)


