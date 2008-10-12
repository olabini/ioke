include_class('ioke.lang.Runtime') { 'IokeRuntime' } unless defined?(IokeRuntime)

import Java::java.io.StringReader unless defined?(StringReader)

def parse(str)
  ioke = IokeRuntime.get_runtime()
  ioke.parse_stream(StringReader.new(str))
end

describe "parsing" do 
  describe "parens without preceeding message" do 
    it "should be translated into identity message" do 
      m = parse("(1)").to_string
      m.should == "(internal:createNumber(1))"
    end
  end
end
