include_class('ioke.lang.Runtime') { 'IokeRuntime' } unless defined?(IokeRuntime)
include_class('ioke.lang.Text') unless defined?(Text)

import Java::java.io.StringReader unless defined?(StringReader)

def parse(str)
  ioke = IokeRuntime.get_runtime()
  ioke.parse_stream(StringReader.new(str))
end

describe "assignment" do 
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
    result.as_java_integer.should == 2
  end

  it "should work with something on the next line too" do 
    m = parse("count = count + 1\ncount println").to_string
    m.should == "=(count, count +(1)) ;\ncount println"
  end

  describe "++" do 
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
  end
end
