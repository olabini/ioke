include_class('ioke.lang.Runtime') { 'IokeRuntime' } unless defined?(IokeRuntime)
include_class('ioke.lang.Symbol') { 'IokeSymbol' } unless defined?(IokeSymbol)

import Java::java.io.StringReader unless defined?(StringReader)

describe "Symbol" do 
  it "should have the correct kind" do 
    ioke = IokeRuntime.get_runtime
    result = ioke.symbol.find_cell(nil, nil, "kind")
    result.data.text.should == 'Symbol'
  end

  it "should not be possible to mimic" do 
    ioke = IokeRuntime.get_runtime
    proc do 
      ioke.evaluate_stream(StringReader.new(":foo mimic"))
    end.should raise_error
  end
  
  it "should evaluate to itself" do 
    ioke = IokeRuntime.get_runtime()
    result = ioke.evaluate_stream(StringReader.new(<<CODE))
:foo_bar
CODE
    result.data.class.should == IokeSymbol
    result.data.text.should == "foo_bar"
  end
  
  it "should evaluate to the same instance every time referenced" do 
    ioke = IokeRuntime.get_runtime()
    result = ioke.evaluate_stream(StringReader.new(<<CODE))
:foo x = 13
:foo x
CODE
    result.data.as_java_integer.should == 13
  end
end
