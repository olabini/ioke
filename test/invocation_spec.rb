include_class('ioke.lang.Runtime') { 'IokeRuntime' } unless defined?(IokeRuntime)
include_class('ioke.lang.Symbol') { 'IokeSymbol' } unless defined?(IokeSymbol)

describe "'pass'" do 
  it "should be invoked instead of an non-existing method" do 
    ioke = IokeRuntime.get_runtime
    ioke.evaluate_string('x = Origin mimic. x pass = method(42). x bar').data.as_java_integer.should == 42
  end

  it "should get the correct name for a method" do 
    ioke = IokeRuntime.get_runtime
    result = ioke.evaluate_string('x = Origin mimic. x pass = macro(call message name). x bar')
    result.data.class.should == IokeSymbol
    result.data.text.should == "bar"
  end

  it "should get an argument if any is provided" do 
    ioke = IokeRuntime.get_runtime
    ioke.evaluate_string('x = Origin mimic. x pass = method(arg1, arg1). x bar(42) == 42').should == ioke.true
  end
  
  it "should be possible to define a pass that is a macro" do 
    ioke = IokeRuntime.get_runtime
    ioke.evaluate_string('x = Origin mimic. x pass = macro([call message name, call evaluatedArguments]). x bar(42,4+4) == [:bar, [42, 8]]').should == ioke.true
  end
end

# describe "'activate'" do 
#   it "should have specs"
# end
