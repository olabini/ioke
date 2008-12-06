include_class('ioke.lang.Runtime') { 'IokeRuntime' } unless defined?(IokeRuntime)

import Java::java.io.StringReader unless defined?(StringReader)
import Java::java.io.PrintWriter unless defined?(PrintWriter)
import Java::java.io.StringWriter unless defined?(StringWriter)
import Java::java.io.InputStreamReader unless defined?(InputStreamReader)
import Java::java.lang.System unless defined?(System)

describe "DateTime" do 
  it "should have the correct kind" do 
    ioke = IokeRuntime.get_runtime
    result = ioke.date_time.find_cell(nil, nil, "kind")
    result.data.text.should == 'DateTime'
  end
end
