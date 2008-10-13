include_class('ioke.lang.Runtime') { 'IokeRuntime' } unless defined?(IokeRuntime)

import Java::java.io.StringReader unless defined?(StringReader)

def parse(str)
  ioke = IokeRuntime.get_runtime()
  ioke.parse_stream(StringReader.new(str))
end

describe "operator" do 
  describe "<" do 
    it "should be translated correctly inside a method definition" do 
      m = parse("method(1<2)").to_string
      m.should == "method(internal:createNumber(1) <(internal:createNumber(2)))"
    end

    it "should be translated correctly inside a nested method definition" do 
      m = parse("method(method(1<2))").to_string
      m.should == "method(method(internal:createNumber(1) <(internal:createNumber(2))))"
    end

    it "should be translated correctly inside a method definition with something else" do 
      m = parse("method(n, if(1<2, n, n))").to_string
      m.should == "method(n, if(internal:createNumber(1) <(internal:createNumber(2)), n, n))"
    end
    
    it "should be translated correctly in infix" do 
      m = parse("1<2").to_string
      m.should == "internal:createNumber(1) <(internal:createNumber(2))"
    end

    it "should be translated correctly with parenthesis" do 
      m = parse("1<(2)").to_string
      m.should == "internal:createNumber(1) <(internal:createNumber(2))"

      m = parse("1 <(2)").to_string
      m.should == "internal:createNumber(1) <(internal:createNumber(2))"
    end

      it "should be translated correctly with spaces" do 
      m = parse("1 < 2").to_string
      m.should == "internal:createNumber(1) <(internal:createNumber(2))"
    end
  end

  describe "-" do 
    it "should be translated correctly in infix" do 
      m = parse("2-1").to_string
      m.should == "internal:createNumber(2) -(internal:createNumber(1))"
    end

    it "should be translated correctly with parenthesis" do 
      m = parse("2-(1)").to_string
      m.should == "internal:createNumber(2) -(internal:createNumber(1))"

      m = parse("2 -(1)").to_string
      m.should == "internal:createNumber(2) -(internal:createNumber(1))"
    end

      it "should be translated correctly with spaces" do 
      m = parse("2 - 1").to_string
      m.should == "internal:createNumber(2) -(internal:createNumber(1))"
    end
  end


  describe "+" do 
    it "should be translated correctly in infix" do 
      m = parse("2+1").to_string
      m.should == "internal:createNumber(2) +(internal:createNumber(1))"
    end

    it "should be translated correctly with parenthesis" do 
      m = parse("2+(1)").to_string
      m.should == "internal:createNumber(2) +(internal:createNumber(1))"

      m = parse("2 +(1)").to_string
      m.should == "internal:createNumber(2) +(internal:createNumber(1))"
    end

      it "should be translated correctly with spaces" do 
      m = parse("2 + 1").to_string
      m.should == "internal:createNumber(2) +(internal:createNumber(1))"
    end
  end
end
