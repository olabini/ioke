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
    result.java_class.name.should == 'ioke.lang.Text'
    result.text.should == "foo"

    ioke.ground.find_cell(nil, "a").should == result
  end
  
  it "should be possible to assign a large expression to default receiver" do 
    ioke = IokeRuntime.get_runtime()
    result = ioke.evaluate_stream(StringReader.new(%q[a = Origin mimic]))
    result.java_class.name.should == 'ioke.lang.Origin'
    result.should_not == ioke.origin

    ioke.ground.find_cell(nil, "a").should == result
  end

  it "should be possible to assign to something inside another object" do 
    ioke = IokeRuntime.get_runtime()
    result = ioke.evaluate_stream(StringReader.new(%q[Text a = "something"]))
    ioke.text.find_cell(nil, "a").should == result
  end
  
  it "should work with combination of equals and plus sign" do 
    ioke = IokeRuntime.get_runtime()
    result = ioke.evaluate_stream(StringReader.new(%q[a = 1 + 1]))
    ioke.ground.find_cell(nil, "a").should == result
    result.as_java_integer.should == 2
  end

  it "should work with something on the next line too" do 
    m = parse("count = count + 1\ncount println").to_string
    m.should == "=(count, count +(internal:createNumber(1))) ; count println"
  end
end
