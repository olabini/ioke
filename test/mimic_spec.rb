include_class('ioke.lang.Runtime') { 'IokeRuntime' } unless defined?(IokeRuntime)
include_class('ioke.lang.exceptions.CantMimicOddballObject') unless defined?(CantMimicOddballObject)
include_class('ioke.lang.exceptions.NoSuchCellException') unless defined?(NoSuchCellException)

import Java::java.io.StringReader unless defined?(StringReader)

describe "mimicking" do 
  it "should be able to mimic Origin" do 
    ioke = IokeRuntime.get_runtime()
    result = ioke.evaluate_stream(StringReader.new(%q[Origin mimic]))
    result.java_class.name.should == 'ioke.lang.Origin'
    result.should_not == ioke.origin
  end

  it "should be able to mimic Ground" do 
    ioke = IokeRuntime.get_runtime()
    result = ioke.evaluate_stream(StringReader.new(%q[Ground mimic]))
    result.find_cell(nil,nil, 'kind').text.should == 'Ground'
    result.should_not == ioke.ground
  end

  it "should be able to mimic Base" do 
    ioke = IokeRuntime.get_runtime()
    result = ioke.evaluate_stream(StringReader.new(%q[Base mimic]))
    result.find_cell(nil,nil, 'kind').text.should == 'Base'
    result.should_not == ioke.base
  end

  it "should be able to mimic Text" do 
    ioke = IokeRuntime.get_runtime()
    result = ioke.evaluate_stream(StringReader.new(%q[Text mimic]))
    result.java_class.name.should == 'ioke.lang.Text'
    result.should_not == ioke.text
  end

  it "should not be able to mimic DefaultBehavior" do 
    ioke = IokeRuntime.get_runtime()
    proc do 
      ioke.evaluate_stream(StringReader.new(%q[DefaultBehavior mimic]))
    end.should raise_error(NoSuchCellException)
  end

  it "should not be able to mimic nil" do 
    ioke = IokeRuntime.get_runtime()

    proc do 
      ioke.evaluate_stream(StringReader.new(%q[nil mimic]))
    end.should raise_error(CantMimicOddballObject)
  end

end
