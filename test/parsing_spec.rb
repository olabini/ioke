include_class('ioke.lang.Runtime') { 'IokeRuntime' } unless defined?(IokeRuntime)

import Java::java.io.StringReader unless defined?(StringReader)

def parse(str)
  ioke = IokeRuntime.get_runtime()
  ioke.parse_stream(StringReader.new(str))
end

describe "parsing" do 
  describe "terminators" do 
    it "should parse a newline as a terminator" do 
      m = parse("\n").to_string
      m.should == ";\n"
    end

    it "should parse two newlines as one terminator" do 
      m = parse("\n\n").to_string
      m.should == ";\n"
    end

    it "should parse a semicolon as a terminator" do 
      m = parse(";").to_string
      m.should == ";\n"
    end

    it "should parse two semicolons as one terminator" do 
      m = parse(";;").to_string
      m.should == ";\n"
    end

    it "should parse one semicolon and one newline as one terminator" do 
      m = parse(";\n").to_string
      m.should == ";\n"
    end

    it "should parse one newline and one semicolon as one terminator" do 
      m = parse("\n;").to_string
      m.should == ";\n"
    end

    it "should parse one newline and one semicolon and one newline as one terminator" do 
      m = parse("\n;\n").to_string
      m.should == ";\n"
    end
  end

  describe "parens without preceeding message" do 
    it "should be translated into identity message" do 
      m = parse("(1)").to_string
      m.should == "(1)"
    end
  end
end
