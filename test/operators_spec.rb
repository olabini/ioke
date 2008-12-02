include_class('ioke.lang.Runtime') { 'IokeRuntime' } unless defined?(IokeRuntime)

import Java::java.io.StringReader unless defined?(StringReader)
import Java::java.io.PrintWriter unless defined?(PrintWriter)
import Java::java.io.StringWriter unless defined?(StringWriter)
import Java::java.io.InputStreamReader unless defined?(InputStreamReader)
import Java::java.lang.System unless defined?(System)

def run(str, ioke)
  ioke.evaluate_stream(StringReader.new(str))
end

def parse(str)
  sw = StringWriter.new(20)
  out = PrintWriter.new(sw)

  ioke = IokeRuntime.get_runtime(out, InputStreamReader.new(System.in), out)
  ioke.parse_stream(StringReader.new(str), ioke.message, ioke.ground)
end

describe "operator" do 
  describe "<=>" do 
    it "should work for numbers" do 
      ioke = IokeRuntime.get_runtime

      run("0<=>0", ioke).data.as_java_integer.should == 0
      run("0<=>1", ioke).data.as_java_integer.should == -1
      run("1<=>1", ioke).data.as_java_integer.should == 0
      run("2<=>1", ioke).data.as_java_integer.should == 1
      run("1<=>2", ioke).data.as_java_integer.should == -1
      run("2<=>2", ioke).data.as_java_integer.should == 0
      run("3<=>2", ioke).data.as_java_integer.should == 1
      run("3<=>223524534", ioke).data.as_java_integer.should == -1
      run("223524534<=>223524534", ioke).data.as_java_integer.should == 0
      run("223524534<=>2", ioke).data.as_java_integer.should == 1
    end
  end

  describe "<" do 
    it "should work for numbers" do 
      ioke = IokeRuntime.get_runtime

      run("0<0", ioke).should == ioke.false
      run("0<1", ioke).should == ioke.true
      run("1<1", ioke).should == ioke.false
      run("1<2", ioke).should == ioke.true
      run("2<2", ioke).should == ioke.false
      run("3<2", ioke).should == ioke.false
      run("3<223524534", ioke).should == ioke.true
    end
  end

  describe "<=" do 
    it "should work for numbers" do 
      ioke = IokeRuntime.get_runtime

      run("0<=0", ioke).should == ioke.true
      run("0<=1", ioke).should == ioke.true
      run("1<=1", ioke).should == ioke.true
      run("1<=2", ioke).should == ioke.true
      run("2<=2", ioke).should == ioke.true
      run("3<=2", ioke).should == ioke.false
      run("3<=223524534", ioke).should == ioke.true
      run("223524534<=223524534", ioke).should == ioke.true
    end
  end
  
  describe ">" do 
    it "should work for numbers" do 
      ioke = IokeRuntime.get_runtime

      run("0>0", ioke).should == ioke.false
      run("0>1", ioke).should == ioke.false
      run("1>0", ioke).should == ioke.true
      run("1>1", ioke).should == ioke.false
      run("2>1", ioke).should == ioke.true
      run("2>2", ioke).should == ioke.false
      run("3>2", ioke).should == ioke.true
      run("3>223524534", ioke).should == ioke.false
      run("223524534>3", ioke).should == ioke.true
      run("223524534>223524534", ioke).should == ioke.false
    end
  end

  describe ">=" do 
    it "should work for numbers" do 
      ioke = IokeRuntime.get_runtime

      run("0>=0", ioke).should == ioke.true
      run("0>=1", ioke).should == ioke.false
      run("1>=0", ioke).should == ioke.true
      run("1>=1", ioke).should == ioke.true
      run("2>=1", ioke).should == ioke.true
      run("2>=2", ioke).should == ioke.true
      run("3>=2", ioke).should == ioke.true
      run("3>=223524534", ioke).should == ioke.false
      run("223524534>=3", ioke).should == ioke.true
      run("223524534>=223524534", ioke).should == ioke.true
    end
  end

  describe "==" do 
    it "should work for numbers" do 
      ioke = IokeRuntime.get_runtime

      run("0==0", ioke).should == ioke.true
      run("0==1", ioke).should == ioke.false
      run("1==0", ioke).should == ioke.false
      run("1==1", ioke).should == ioke.true
      run("2==1", ioke).should == ioke.false
      run("2==2", ioke).should == ioke.true
      run("3==2", ioke).should == ioke.false
      run("3==223524534", ioke).should == ioke.false
      run("223524534==3", ioke).should == ioke.false
      run("223524534==223524534", ioke).should == ioke.true
    end
  end

  describe "!=" do 
    it "should work for numbers" do 
      ioke = IokeRuntime.get_runtime

      run("0!=0", ioke).should == ioke.false
      run("0!=1", ioke).should == ioke.true
      run("1!=0", ioke).should == ioke.true
      run("1!=1", ioke).should == ioke.false
      run("2!=1", ioke).should == ioke.true
      run("2!=2", ioke).should == ioke.false
      run("3!=2", ioke).should == ioke.true
      run("3!=223524534", ioke).should == ioke.true
      run("223524534!=3", ioke).should == ioke.true
      run("223524534!=223524534", ioke).should == ioke.false
    end
  end
  
  describe "parsing" do 
    describe "@" do 
      it "should be parsed correctly empty" do 
        m = parse("@").to_string
        m.should == "@"
      end

      it "should be parsed correctly with arguments" do 
        m = parse("@(foo)").to_string
        m.should == "@(foo)"
      end
      
      it "should be parsed correctly directly in front of another identifier" do 
        m = parse("@abc").to_string
        m.should == "@ abc"
      end

      it "should be parsed correctly directly in front of another identifier with space" do 
        m = parse("@ abc").to_string
        m.should == "@ abc"
      end
    end

    describe "@@" do 
      it "should be parsed correctly empty" do 
        m = parse("@@").to_string
        m.should == "@@"
      end

      it "should be parsed correctly with arguments" do 
        m = parse("@@(foo)").to_string
        m.should == "@@(foo)"
      end
      
      it "should be parsed correctly directly in front of another identifier" do 
        m = parse("@@abc").to_string
        m.should == "@@ abc"
      end

      it "should be parsed correctly directly in front of another identifier with space" do 
        m = parse("@@ abc").to_string
        m.should == "@@ abc"
      end
    end
    
    describe "<=>" do 
      it "should be translated correctly inside a method definition" do 
        m = parse("method(1<=>2)").to_string
        m.should == "method(1 <=>(2))"
      end

      it "should be translated correctly inside a nested method definition" do 
        m = parse("method(method(1<=>2))").to_string
        m.should == "method(method(1 <=>(2)))"
      end

      it "should be translated correctly inside a method definition with something else" do 
        m = parse("method(n, if(1<=>2, n, n))").to_string
        m.should == "method(n, if(1 <=>(2), n, n))"
      end
      
      it "should be translated correctly in infix" do 
        m = parse("1<=>2").to_string
        m.should == "1 <=>(2)"
      end

      it "should be translated correctly with parenthesis" do 
        m = parse("1<=>(2)").to_string
        m.should == "1 <=>(2)"

        m = parse("1 <=>(2)").to_string
        m.should == "1 <=>(2)"
      end

      it "should be translated correctly with spaces" do 
        m = parse("1 <=> 2").to_string
        m.should == "1 <=>(2)"
      end
    end

    describe "<" do 
      it "should be translated correctly inside a method definition" do 
        m = parse("method(1<2)").to_string
        m.should == "method(1 <(2))"
      end

      it "should be translated correctly inside a nested method definition" do 
        m = parse("method(method(1<2))").to_string
        m.should == "method(method(1 <(2)))"
      end

      it "should be translated correctly inside a method definition with something else" do 
        m = parse("method(n, if(1<2, n, n))").to_string
        m.should == "method(n, if(1 <(2), n, n))"
      end
      
      it "should be translated correctly in infix" do 
        m = parse("1<2").to_string
        m.should == "1 <(2)"
      end

      it "should be translated correctly in infix, starting with letter" do 
        m = parse("a<2").to_string
        m.should == "a <(2)"
      end

      it "should be translated correctly with parenthesis" do 
        m = parse("1<(2)").to_string
        m.should == "1 <(2)"

        m = parse("1 <(2)").to_string
        m.should == "1 <(2)"
      end

      it "should be translated correctly with spaces" do 
        m = parse("1 < 2").to_string
        m.should == "1 <(2)"
      end
    end

    describe ">" do 
      it "should be translated correctly inside a method definition" do 
        m = parse("method(1>2)").to_string
        m.should == "method(1 >(2))"
      end

      it "should be translated correctly inside a nested method definition" do 
        m = parse("method(method(1>2))").to_string
        m.should == "method(method(1 >(2)))"
      end

      it "should be translated correctly inside a method definition with something else" do 
        m = parse("method(n, if(1>2, n, n))").to_string
        m.should == "method(n, if(1 >(2), n, n))"
      end
      
      it "should be translated correctly in infix" do 
        m = parse("1>2").to_string
        m.should == "1 >(2)"
      end

      it "should be translated correctly with parenthesis" do 
        m = parse("1>(2)").to_string
        m.should == "1 >(2)"

        m = parse("1 >(2)").to_string
        m.should == "1 >(2)"
      end

      it "should be translated correctly with spaces" do 
        m = parse("1 > 2").to_string
        m.should == "1 >(2)"
      end
    end

    describe "<=" do 
      it "should be translated correctly inside a method definition" do 
        m = parse("method(1<=2)").to_string
        m.should == "method(1 <=(2))"
      end

      it "should be translated correctly inside a nested method definition" do 
        m = parse("method(method(1<=2))").to_string
        m.should == "method(method(1 <=(2)))"
      end

      it "should be translated correctly inside a method definition with something else" do 
        m = parse("method(n, if(1<=2, n, n))").to_string
        m.should == "method(n, if(1 <=(2), n, n))"
      end
      
      it "should be translated correctly in infix" do 
        m = parse("1<=2").to_string
        m.should == "1 <=(2)"
      end

      it "should be translated correctly with parenthesis" do 
        m = parse("1<=(2)").to_string
        m.should == "1 <=(2)"

        m = parse("1 <=(2)").to_string
        m.should == "1 <=(2)"
      end

      it "should be translated correctly with spaces" do 
        m = parse("1 <= 2").to_string
        m.should == "1 <=(2)"
      end
    end
    
    describe ">=" do 
      it "should be translated correctly inside a method definition" do 
        m = parse("method(1>=2)").to_string
        m.should == "method(1 >=(2))"
      end

      it "should be translated correctly inside a nested method definition" do 
        m = parse("method(method(1>=2))").to_string
        m.should == "method(method(1 >=(2)))"
      end

      it "should be translated correctly inside a method definition with something else" do 
        m = parse("method(n, if(1>=2, n, n))").to_string
        m.should == "method(n, if(1 >=(2), n, n))"
      end
      
      it "should be translated correctly in infix" do 
        m = parse("1>=2").to_string
        m.should == "1 >=(2)"
      end

      it "should be translated correctly with parenthesis" do 
        m = parse("1>=(2)").to_string
        m.should == "1 >=(2)"

        m = parse("1 >=(2)").to_string
        m.should == "1 >=(2)"
      end

      it "should be translated correctly with spaces" do 
        m = parse("1 >= 2").to_string
        m.should == "1 >=(2)"
      end
    end

    describe "!=" do 
      it "should be translated correctly inside a method definition" do 
        m = parse("method(1!=2)").to_string
        m.should == "method(1 !=(2))"
      end

      it "should be translated correctly inside a nested method definition" do 
        m = parse("method(method(1!=2))").to_string
        m.should == "method(method(1 !=(2)))"
      end

      it "should be translated correctly inside a method definition with something else" do 
        m = parse("method(n, if(1!=2, n, n))").to_string
        m.should == "method(n, if(1 !=(2), n, n))"
      end
      
      it "should be translated correctly in infix" do 
        m = parse("1!=2").to_string
        m.should == "1 !=(2)"
      end

      it "should be translated correctly with parenthesis" do 
        m = parse("1!=(2)").to_string
        m.should == "1 !=(2)"

        m = parse("1 !=(2)").to_string
        m.should == "1 !=(2)"
      end

      it "should be translated correctly with spaces" do 
        m = parse("1 != 2").to_string
        m.should == "1 !=(2)"
      end
    end


    describe "==" do 
      it "should be translated correctly inside a method definition" do 
        m = parse("method(1==2)").to_string
        m.should == "method(1 ==(2))"
      end

      it "should be translated correctly inside a nested method definition" do 
        m = parse("method(method(1==2))").to_string
        m.should == "method(method(1 ==(2)))"
      end

      it "should be translated correctly inside a method definition with something else" do 
        m = parse("method(n, if(1==2, n, n))").to_string
        m.should == "method(n, if(1 ==(2), n, n))"
      end
      
      it "should be translated correctly in infix" do 
        m = parse("1==2").to_string
        m.should == "1 ==(2)"
      end

      it "should be translated correctly with parenthesis" do 
        m = parse("1==(2)").to_string
        m.should == "1 ==(2)"

        m = parse("1 ==(2)").to_string
        m.should == "1 ==(2)"
      end

      it "should be translated correctly with spaces" do 
        m = parse("1 == 2").to_string
        m.should == "1 ==(2)"
      end
    end

    describe "===" do 
      it "should be translated correctly inside a method definition" do 
        m = parse("method(1===2)").to_string
        m.should == "method(1 ===(2))"
      end

      it "should be translated correctly inside a nested method definition" do 
        m = parse("method(method(1===2))").to_string
        m.should == "method(method(1 ===(2)))"
      end

      it "should be translated correctly inside a method definition with something else" do 
        m = parse("method(n, if(1===2, n, n))").to_string
        m.should == "method(n, if(1 ===(2), n, n))"
      end
      
      it "should be translated correctly in infix" do 
        m = parse("1===2").to_string
        m.should == "1 ===(2)"
      end

      it "should be translated correctly with parenthesis" do 
        m = parse("1===(2)").to_string
        m.should == "1 ===(2)"

        m = parse("1 ===(2)").to_string
        m.should == "1 ===(2)"
      end

      it "should be translated correctly with spaces" do 
        m = parse("1 === 2").to_string
        m.should == "1 ===(2)"
      end
    end

    describe "=~" do 
      it "should be translated correctly inside a method definition" do 
        m = parse("method(1=~2)").to_string
        m.should == "method(1 =~(2))"
      end

      it "should be translated correctly inside a nested method definition" do 
        m = parse("method(method(1=~2))").to_string
        m.should == "method(method(1 =~(2)))"
      end

      it "should be translated correctly inside a method definition with something else" do 
        m = parse("method(n, if(1=~2, n, n))").to_string
        m.should == "method(n, if(1 =~(2), n, n))"
      end
      
      it "should be translated correctly in infix" do 
        m = parse("1=~2").to_string
        m.should == "1 =~(2)"
      end

      it "should be translated correctly with parenthesis" do 
        m = parse("1=~(2)").to_string
        m.should == "1 =~(2)"

        m = parse("1 =~(2)").to_string
        m.should == "1 =~(2)"
      end

      it "should be translated correctly with spaces" do 
        m = parse("1 =~ 2").to_string
        m.should == "1 =~(2)"
      end
    end

    describe "!~" do 
      it "should be translated correctly inside a method definition" do 
        m = parse("method(1!~2)").to_string
        m.should == "method(1 !~(2))"
      end

      it "should be translated correctly inside a nested method definition" do 
        m = parse("method(method(1!~2))").to_string
        m.should == "method(method(1 !~(2)))"
      end

      it "should be translated correctly inside a method definition with something else" do 
        m = parse("method(n, if(1!~2, n, n))").to_string
        m.should == "method(n, if(1 !~(2), n, n))"
      end
      
      it "should be translated correctly in infix" do 
        m = parse("1!~2").to_string
        m.should == "1 !~(2)"
      end

      it "should be translated correctly with parenthesis" do 
        m = parse("1!~(2)").to_string
        m.should == "1 !~(2)"

        m = parse("1 !~(2)").to_string
        m.should == "1 !~(2)"
      end

      it "should be translated correctly with spaces" do 
        m = parse("1 !~ 2").to_string
        m.should == "1 !~(2)"
      end
    end
    
    
    describe "unary -" do 
      it "should parse correctly for a simple case" do 
        m = parse("-1").to_string
        m.should == "-(1)"
      end

      it "should parse correctly for a simple case with message send after" do 
        m = parse("-1 println").to_string
        m.should == "-(1) println"
      end

      it "should parse correctly for a simple case with message send after and parenthesis" do 
        m = parse("-(1) println").to_string
        m.should == "-(1) println"
      end
      
      it "should parse correctly for a larger number" do 
        m = parse("-12342353453").to_string
        m.should == "-(12342353453)"
      end

      it "should parse correctly several times over" do 
        m = parse("- -(1)").to_string
        m.should == "-(-(1))"
      end
    end
    
    describe "unary binary operators" do 
      it "should work for a simple expression" do 
        m = parse("map(*2)").to_string
        m.should == "map(*(2))"
      end

      it "should work for a more complicated expression" do 
        m = parse("map(*4+5-13/3)").to_string
        m.should == "map(*(4) +(5) -(13 /(3)))"
      end
    end
    
    describe "-" do 
      it "should be translated correctly in infix" do 
        m = parse("2-1").to_string
        m.should == "2 -(1)"
      end

      it "should be translated correctly with parenthesis" do 
        m = parse("2-(1)").to_string
        m.should == "2 -(1)"

        m = parse("2 -(1)").to_string
        m.should == "2 -(1)"
      end

      it "should be translated correctly with spaces" do 
        m = parse("2 - 1").to_string
        m.should == "2 -(1)"
      end
    end

    describe "+" do 
      it "should be translated correctly in infix" do 
        m = parse("2+1").to_string
        m.should == "2 +(1)"
      end

      it "should be translated correctly with parenthesis" do 
        m = parse("2+(1)").to_string
        m.should == "2 +(1)"

        m = parse("2 +(1)").to_string
        m.should == "2 +(1)"
      end

      it "should be translated correctly with spaces" do 
        m = parse("2 + 1").to_string
        m.should == "2 +(1)"
      end
    end

    describe "*" do 
      it "should be translated correctly in infix" do 
        m = parse("2*1").to_string
        m.should == "2 *(1)"
      end

      it "should be translated correctly with parenthesis" do 
        m = parse("2*(1)").to_string
        m.should == "2 *(1)"

        m = parse("2 *(1)").to_string
        m.should == "2 *(1)"
      end

      it "should be translated correctly with spaces" do 
        m = parse("2 * 1").to_string
        m.should == "2 *(1)"
      end
    end

    describe "**" do 
      it "should be translated correctly in infix" do 
        m = parse("2**1").to_string
        m.should == "2 **(1)"
      end

      it "should be translated correctly with parenthesis" do 
        m = parse("2**(1)").to_string
        m.should == "2 **(1)"

        m = parse("2 **(1)").to_string
        m.should == "2 **(1)"
      end

      it "should be translated correctly with spaces" do 
        m = parse("2 ** 1").to_string
        m.should == "2 **(1)"
      end
    end
    
    describe "/" do 
      it "should be translated correctly in infix" do 
        m = parse("2/1").to_string
        m.should == "2 /(1)"
      end

      it "should be translated correctly with parenthesis" do 
        m = parse("2/(1)").to_string
        m.should == "2 /(1)"

        m = parse("2 /(1)").to_string
        m.should == "2 /(1)"
      end

      it "should be translated correctly with spaces" do 
        m = parse("2 / 1").to_string
        m.should == "2 /(1)"
      end
    end
    
    describe "%" do 
      it "should be translated correctly in infix" do 
        m = parse("2%1").to_string
        m.should == "2 %(1)"
      end

      it "should be translated correctly with parenthesis" do 
        m = parse("2%(1)").to_string
        m.should == "2 %(1)"

        m = parse("2 %(1)").to_string
        m.should == "2 %(1)"
      end

      it "should be translated correctly with spaces" do 
        m = parse("2 % 1").to_string
        m.should == "2 %(1)"
      end
    end

    
    describe "=>" do 
      it "should be correctly translated in infix" do 
        m = parse("2=>1").to_string
        m.should == "2 =>(1)"

        m = parse('"foo"=>"bar"').to_string
        m.should == '"foo" =>("bar")'
      end

      it "should be translated correctly with parenthesis" do 
        m = parse("2=>(1)").to_string
        m.should == "2 =>(1)"

        m = parse("2 =>(1)").to_string
        m.should == "2 =>(1)"

        m = parse('"foo"=>("bar")').to_string
        m.should == '"foo" =>("bar")'

        m = parse('"foo" =>("bar")').to_string
        m.should == '"foo" =>("bar")'
      end

      it "should be translated correctly with spaces" do 
        m = parse("2 => 1").to_string
        m.should == "2 =>(1)"

        m = parse('"foo" => "bar"').to_string
        m.should == '"foo" =>("bar")'
      end

      it "should be translated correctly when chained" do 
        m = parse("2 => 1 => 0").to_string
        m.should == "2 =>(1) =>(0)"

        m = parse('"foo" => "bar" => "quux"').to_string
        m.should == '"foo" =>("bar") =>("quux")'
      end
    end

    describe ".." do 
      it "should be correctly translated in infix" do 
        m = parse("2..1").to_string
        m.should == "2 ..(1)"

        m = parse('"foo".."bar"').to_string
        m.should == '"foo" ..("bar")'
      end

      it "should be translated correctly with parenthesis" do 
        m = parse("2..(1)").to_string
        m.should == "2 ..(1)"

        m = parse("2 ..(1)").to_string
        m.should == "2 ..(1)"

        m = parse('"foo"..("bar")').to_string
        m.should == '"foo" ..("bar")'

        m = parse('"foo" ..("bar")').to_string
        m.should == '"foo" ..("bar")'
      end

      it "should be translated correctly with spaces" do 
        m = parse("2 .. 1").to_string
        m.should == "2 ..(1)"

        m = parse('"foo" .. "bar"').to_string
        m.should == '"foo" ..("bar")'
      end

      it "should be translated correctly when chained" do 
        m = parse("2 .. 1 .. 0").to_string
        m.should == "2 ..(1) ..(0)"

        m = parse('"foo" .. "bar" .. "quux"').to_string
        m.should == '"foo" ..("bar") ..("quux")'
      end
    end

    describe "..." do 
      it "should be correctly translated in infix" do 
        m = parse("2...1").to_string
        m.should == "2 ...(1)"

        m = parse('"foo"..."bar"').to_string
        m.should == '"foo" ...("bar")'
      end

      it "should be translated correctly with parenthesis" do 
        m = parse("2...(1)").to_string
        m.should == "2 ...(1)"

        m = parse("2 ...(1)").to_string
        m.should == "2 ...(1)"

        m = parse('"foo"...("bar")').to_string
        m.should == '"foo" ...("bar")'

        m = parse('"foo" ...("bar")').to_string
        m.should == '"foo" ...("bar")'
      end

      it "should be translated correctly with spaces" do 
        m = parse("2 ... 1").to_string
        m.should == "2 ...(1)"

        m = parse('"foo" ... "bar"').to_string
        m.should == '"foo" ...("bar")'
      end

      it "should be translated correctly when chained" do 
        m = parse("2 ... 1 ... 0").to_string
        m.should == "2 ...(1) ...(0)"

        m = parse('"foo" ... "bar" ... "quux"').to_string
        m.should == '"foo" ...("bar") ...("quux")'
      end
    end

    describe "<<" do 
      it "should be correctly translated in infix" do 
        m = parse("2<<1").to_string
        m.should == "2 <<(1)"

        m = parse('"foo"<<"bar"').to_string
        m.should == '"foo" <<("bar")'
      end

      it "should be translated correctly with parenthesis" do 
        m = parse("2<<(1)").to_string
        m.should == "2 <<(1)"

        m = parse("2 <<(1)").to_string
        m.should == "2 <<(1)"

        m = parse('"foo"<<("bar")').to_string
        m.should == '"foo" <<("bar")'

        m = parse('"foo" <<("bar")').to_string
        m.should == '"foo" <<("bar")'
      end

      it "should be translated correctly with spaces" do 
        m = parse("2 << 1").to_string
        m.should == "2 <<(1)"

        m = parse('"foo" << "bar"').to_string
        m.should == '"foo" <<("bar")'
      end

      it "should be translated correctly when chained" do 
        m = parse("2 << 1 << 0").to_string
        m.should == "2 <<(1) <<(0)"

        m = parse('"foo" << "bar" << "quux"').to_string
        m.should == '"foo" <<("bar") <<("quux")'
      end
    end

    
    describe ">>" do 
      it "should be correctly translated in infix" do 
        m = parse("2>>1").to_string
        m.should == "2 >>(1)"

        m = parse('"foo">>"bar"').to_string
        m.should == '"foo" >>("bar")'
      end

      it "should be translated correctly with parenthesis" do 
        m = parse("2>>(1)").to_string
        m.should == "2 >>(1)"

        m = parse("2 >>(1)").to_string
        m.should == "2 >>(1)"

        m = parse('"foo">>("bar")').to_string
        m.should == '"foo" >>("bar")'

        m = parse('"foo" >>("bar")').to_string
        m.should == '"foo" >>("bar")'
      end

      it "should be translated correctly with spaces" do 
        m = parse("2 >> 1").to_string
        m.should == "2 >>(1)"

        m = parse('"foo" >> "bar"').to_string
        m.should == '"foo" >>("bar")'
      end

      it "should be translated correctly when chained" do 
        m = parse("2 >> 1 >> 0").to_string
        m.should == "2 >>(1) >>(0)"

        m = parse('"foo" >> "bar" >> "quux"').to_string
        m.should == '"foo" >>("bar") >>("quux")'
      end
    end
    
    describe "&" do 
      it "should be correctly translated in infix" do 
        m = parse("2&1").to_string
        m.should == "2 &(1)"

        m = parse('"foo"&"bar"').to_string
        m.should == '"foo" &("bar")'
      end

      it "should be translated correctly with parenthesis" do 
        m = parse("2&(1)").to_string
        m.should == "2 &(1)"

        m = parse("2 &(1)").to_string
        m.should == "2 &(1)"

        m = parse('"foo"&("bar")').to_string
        m.should == '"foo" &("bar")'

        m = parse('"foo" &("bar")').to_string
        m.should == '"foo" &("bar")'
      end

      it "should be translated correctly with spaces" do 
        m = parse("2 & 1").to_string
        m.should == "2 &(1)"

        m = parse('"foo" & "bar"').to_string
        m.should == '"foo" &("bar")'
      end

      it "should be translated correctly when chained" do 
        m = parse("2 & 1 & 0").to_string
        m.should == "2 &(1) &(0)"

        m = parse('"foo" & "bar" & "quux"').to_string
        m.should == '"foo" &("bar") &("quux")'
      end
    end

    describe "|" do 
      it "should be correctly translated in infix" do 
        m = parse("2|1").to_string
        m.should == "2 |(1)"

        m = parse('"foo"|"bar"').to_string
        m.should == '"foo" |("bar")'
      end

      it "should be translated correctly with parenthesis" do 
        m = parse("2|(1)").to_string
        m.should == "2 |(1)"

        m = parse("2 |(1)").to_string
        m.should == "2 |(1)"

        m = parse('"foo"|("bar")').to_string
        m.should == '"foo" |("bar")'

        m = parse('"foo" |("bar")').to_string
        m.should == '"foo" |("bar")'
      end

      it "should be translated correctly with spaces" do 
        m = parse("2 | 1").to_string
        m.should == "2 |(1)"

        m = parse('"foo" | "bar"').to_string
        m.should == '"foo" |("bar")'
      end

      it "should be translated correctly when chained" do 
        m = parse("2 | 1 | 0").to_string
        m.should == "2 |(1) |(0)"

        m = parse('"foo" | "bar" | "quux"').to_string
        m.should == '"foo" |("bar") |("quux")'
      end
    end

    describe "^" do 
      it "should be correctly translated in infix" do 
        m = parse("2^1").to_string
        m.should == "2 ^(1)"

        m = parse('"foo"^"bar"').to_string
        m.should == '"foo" ^("bar")'
      end

      it "should be translated correctly with parenthesis" do 
        m = parse("2^(1)").to_string
        m.should == "2 ^(1)"

        m = parse("2 ^(1)").to_string
        m.should == "2 ^(1)"

        m = parse('"foo"^("bar")').to_string
        m.should == '"foo" ^("bar")'

        m = parse('"foo" ^("bar")').to_string
        m.should == '"foo" ^("bar")'
      end

      it "should be translated correctly with spaces" do 
        m = parse("2 ^ 1").to_string
        m.should == "2 ^(1)"

        m = parse('"foo" ^ "bar"').to_string
        m.should == '"foo" ^("bar")'
      end

      it "should be translated correctly when chained" do 
        m = parse("2 ^ 1 ^ 0").to_string
        m.should == "2 ^(1) ^(0)"

        m = parse('"foo" ^ "bar" ^ "quux"').to_string
        m.should == '"foo" ^("bar") ^("quux")'
      end
    end

    describe "&&" do 
      it "should be correctly translated in infix" do 
        m = parse("2&&1").to_string
        m.should == "2 &&(1)"

        m = parse('"foo"&&"bar"').to_string
        m.should == '"foo" &&("bar")'
      end

      it "should be translated correctly with parenthesis" do 
        m = parse("2&&(1)").to_string
        m.should == "2 &&(1)"

        m = parse("2 &&(1)").to_string
        m.should == "2 &&(1)"

        m = parse('"foo"&&("bar")').to_string
        m.should == '"foo" &&("bar")'

        m = parse('"foo" &&("bar")').to_string
        m.should == '"foo" &&("bar")'
      end

      it "should be translated correctly with spaces" do 
        m = parse("2 && 1").to_string
        m.should == "2 &&(1)"

        m = parse('"foo" && "bar"').to_string
        m.should == '"foo" &&("bar")'
      end

      it "should be translated correctly when chained" do 
        m = parse("2 && 1 && 0").to_string
        m.should == "2 &&(1) &&(0)"

        m = parse('"foo" && "bar" && "quux"').to_string
        m.should == '"foo" &&("bar") &&("quux")'
      end
    end

    describe "||" do 
      it "should be correctly translated in infix" do 
        m = parse("2||1").to_string
        m.should == "2 ||(1)"

        m = parse('"foo"||"bar"').to_string
        m.should == '"foo" ||("bar")'
      end

      it "should be translated correctly with parenthesis" do 
        m = parse("2||(1)").to_string
        m.should == "2 ||(1)"

        m = parse("2 ||(1)").to_string
        m.should == "2 ||(1)"

        m = parse('"foo"||("bar")').to_string
        m.should == '"foo" ||("bar")'

        m = parse('"foo" ||("bar")').to_string
        m.should == '"foo" ||("bar")'
      end

      it "should be translated correctly with spaces" do 
        m = parse("2 || 1").to_string
        m.should == "2 ||(1)"

        m = parse('"foo" || "bar"').to_string
        m.should == '"foo" ||("bar")'
      end

      it "should be translated correctly when chained" do 
        m = parse("2 || 1 || 0").to_string
        m.should == "2 ||(1) ||(0)"

        m = parse('"foo" || "bar" || "quux"').to_string
        m.should == '"foo" ||("bar") ||("quux")'
      end
    end

    describe "or" do 
      it "should be translated correctly with parenthesis" do 
        m = parse("2 or(1)").to_string
        m.should == "2 or(1)"

        m = parse('"foo" or("bar")').to_string
        m.should == '"foo" or("bar")'
      end

      it "should be translated correctly with spaces" do 
        m = parse("2 or 1").to_string
        m.should == "2 or(1)"

        m = parse('"foo" or "bar"').to_string
        m.should == '"foo" or("bar")'
      end

      it "should be translated correctly when chained" do 
        m = parse("2 or 1 or 0").to_string
        m.should == "2 or(1) or(0)"

        m = parse('"foo" or "bar" or "quux"').to_string
        m.should == '"foo" or("bar") or("quux")'
      end
    end

    describe "and" do 
      it "should be translated correctly with parenthesis" do 
        m = parse("2 and(1)").to_string
        m.should == "2 and(1)"

        m = parse('"foo" and("bar")').to_string
        m.should == '"foo" and("bar")'
      end

      it "should be translated correctly with spaces" do 
        m = parse("2 and 1").to_string
        m.should == "2 and(1)"

        m = parse('"foo" and "bar"').to_string
        m.should == '"foo" and("bar")'
      end

      it "should be translated correctly when chained" do 
        m = parse("2 and 1 and 0").to_string
        m.should == "2 and(1) and(0)"

        m = parse('"foo" and "bar" and "quux"').to_string
        m.should == '"foo" and("bar") and("quux")'
      end
    end

    describe "!" do 
      it "should work in a simple unary position" do 
        m = parse("!false").to_string
        m.should == '!(false)'
      end

      it "should work in a simple unary position with space" do 
        m = parse("! false").to_string
        m.should == '!(false)'
      end

      it "should work with parenthesis" do 
        m = parse("!(false)").to_string
        m.should == '!(false)'
      end

      it "should work in an expression" do 
        m = parse("true && !false").to_string
        m.should == 'true &&(!(false))'
      end
    end

    describe "~" do 
      it "should work in a simple unary position" do 
        m = parse("~false").to_string
        m.should == '~(false)'
      end

      it "should work in a simple unary position with space" do 
        m = parse("~ false").to_string
        m.should == '~(false)'
      end

      it "should work with parenthesis" do 
        m = parse("~(false)").to_string
        m.should == '~(false)'
      end

      it "should work in an expression" do 
        m = parse("true && ~false").to_string
        m.should == 'true &&(~(false))'
      end

      it "should work as a binary operator" do 
        m = parse("true ~ false").to_string
        m.should == 'true ~(false)'
      end
    end

    describe "$" do 
      it "should work in a simple unary position" do 
        m = parse("$false").to_string
        m.should == '$(false)'
      end

      it "should work in a simple unary position with space" do 
        m = parse("$ false").to_string
        m.should == '$(false)'
      end

      it "should work with parenthesis" do 
        m = parse("$(false)").to_string
        m.should == '$(false)'
      end

      it "should work in an expression" do 
        m = parse("true && $false").to_string
        m.should == 'true &&($(false))'
      end

      it "should work as a binary operator" do 
        m = parse("true $ false").to_string
        m.should == 'true $(false)'
      end
    end

    describe "->" do 
      it "should be correctly translated in infix" do 
        m = parse("2->1").to_string
        m.should == "2 ->(1)"

        m = parse('"foo"->"bar"').to_string
        m.should == '"foo" ->("bar")'
      end

      it "should be translated correctly with parenthesis" do 
        m = parse("2->(1)").to_string
        m.should == "2 ->(1)"

        m = parse("2 ->(1)").to_string
        m.should == "2 ->(1)"

        m = parse('"foo"->("bar")').to_string
        m.should == '"foo" ->("bar")'

        m = parse('"foo" ->("bar")').to_string
        m.should == '"foo" ->("bar")'
      end

      it "should be translated correctly with spaces" do 
        m = parse("2 -> 1").to_string
        m.should == "2 ->(1)"

        m = parse('"foo" -> "bar"').to_string
        m.should == '"foo" ->("bar")'
      end

      it "should be translated correctly when chained" do 
        m = parse("2 -> 1 -> 0").to_string
        m.should == "2 ->(1) ->(0)"

        m = parse('"foo" -> "bar" -> "quux"').to_string
        m.should == '"foo" ->("bar") ->("quux")'
      end
    end

    describe "+>" do 
      it "should be correctly translated in infix" do 
        m = parse("2+>1").to_string
        m.should == "2 +>(1)"

        m = parse('"foo"+>"bar"').to_string
        m.should == '"foo" +>("bar")'
      end

      it "should be translated correctly with parenthesis" do 
        m = parse("2+>(1)").to_string
        m.should == "2 +>(1)"

        m = parse("2 +>(1)").to_string
        m.should == "2 +>(1)"

        m = parse('"foo"+>("bar")').to_string
        m.should == '"foo" +>("bar")'

        m = parse('"foo" +>("bar")').to_string
        m.should == '"foo" +>("bar")'
      end

      it "should be translated correctly with spaces" do 
        m = parse("2 +> 1").to_string
        m.should == "2 +>(1)"

        m = parse('"foo" +> "bar"').to_string
        m.should == '"foo" +>("bar")'
      end

      it "should be translated correctly when chained" do 
        m = parse("2 +> 1 +> 0").to_string
        m.should == "2 +>(1) +>(0)"

        m = parse('"foo" +> "bar" +> "quux"').to_string
        m.should == '"foo" +>("bar") +>("quux")'
      end
    end
    
    describe "!>" do 
      it "should be correctly translated in infix" do 
        m = parse("2!>1").to_string
        m.should == "2 !>(1)"

        m = parse('"foo"!>"bar"').to_string
        m.should == '"foo" !>("bar")'
      end

      it "should be translated correctly with parenthesis" do 
        m = parse("2!>(1)").to_string
        m.should == "2 !>(1)"

        m = parse("2 !>(1)").to_string
        m.should == "2 !>(1)"

        m = parse('"foo"!>("bar")').to_string
        m.should == '"foo" !>("bar")'

        m = parse('"foo" !>("bar")').to_string
        m.should == '"foo" !>("bar")'
      end

      it "should be translated correctly with spaces" do 
        m = parse("2 !> 1").to_string
        m.should == "2 !>(1)"

        m = parse('"foo" !> "bar"').to_string
        m.should == '"foo" !>("bar")'
      end

      it "should be translated correctly when chained" do 
        m = parse("2 !> 1 !> 0").to_string
        m.should == "2 !>(1) !>(0)"

        m = parse('"foo" !> "bar" !> "quux"').to_string
        m.should == '"foo" !>("bar") !>("quux")'
      end
    end

    describe "<>" do 
      it "should be correctly translated in infix" do 
        m = parse("2<>1").to_string
        m.should == "2 <>(1)"

        m = parse('"foo"<>"bar"').to_string
        m.should == '"foo" <>("bar")'
      end

      it "should be translated correctly with parenthesis" do 
        m = parse("2<>(1)").to_string
        m.should == "2 <>(1)"

        m = parse("2 <>(1)").to_string
        m.should == "2 <>(1)"

        m = parse('"foo"<>("bar")').to_string
        m.should == '"foo" <>("bar")'

        m = parse('"foo" <>("bar")').to_string
        m.should == '"foo" <>("bar")'
      end

      it "should be translated correctly with spaces" do 
        m = parse("2 <> 1").to_string
        m.should == "2 <>(1)"

        m = parse('"foo" <> "bar"').to_string
        m.should == '"foo" <>("bar")'
      end

      it "should be translated correctly when chained" do 
        m = parse("2 <> 1 <> 0").to_string
        m.should == "2 <>(1) <>(0)"

        m = parse('"foo" <> "bar" <> "quux"').to_string
        m.should == '"foo" <>("bar") <>("quux")'
      end
    end
    
    describe "&>" do 
      it "should be correctly translated in infix" do 
        m = parse("2&>1").to_string
        m.should == "2 &>(1)"

        m = parse('"foo"&>"bar"').to_string
        m.should == '"foo" &>("bar")'
      end

      it "should be translated correctly with parenthesis" do 
        m = parse("2&>(1)").to_string
        m.should == "2 &>(1)"

        m = parse("2 &>(1)").to_string
        m.should == "2 &>(1)"

        m = parse('"foo"&>("bar")').to_string
        m.should == '"foo" &>("bar")'

        m = parse('"foo" &>("bar")').to_string
        m.should == '"foo" &>("bar")'
      end

      it "should be translated correctly with spaces" do 
        m = parse("2 &> 1").to_string
        m.should == "2 &>(1)"

        m = parse('"foo" &> "bar"').to_string
        m.should == '"foo" &>("bar")'
      end

      it "should be translated correctly when chained" do 
        m = parse("2 &> 1 &> 0").to_string
        m.should == "2 &>(1) &>(0)"

        m = parse('"foo" &> "bar" &> "quux"').to_string
        m.should == '"foo" &>("bar") &>("quux")'
      end
    end
    

    describe "%>" do 
      it "should be correctly translated in infix" do 
        m = parse("2%>1").to_string
        m.should == "2 %>(1)"

        m = parse('"foo"%>"bar"').to_string
        m.should == '"foo" %>("bar")'
      end

      it "should be translated correctly with parenthesis" do 
        m = parse("2%>(1)").to_string
        m.should == "2 %>(1)"

        m = parse("2 %>(1)").to_string
        m.should == "2 %>(1)"

        m = parse('"foo"%>("bar")').to_string
        m.should == '"foo" %>("bar")'

        m = parse('"foo" %>("bar")').to_string
        m.should == '"foo" %>("bar")'
      end

      it "should be translated correctly with spaces" do 
        m = parse("2 %> 1").to_string
        m.should == "2 %>(1)"

        m = parse('"foo" %> "bar"').to_string
        m.should == '"foo" %>("bar")'
      end

      it "should be translated correctly when chained" do 
        m = parse("2 %> 1 %> 0").to_string
        m.should == "2 %>(1) %>(0)"

        m = parse('"foo" %> "bar" %> "quux"').to_string
        m.should == '"foo" %>("bar") %>("quux")'
      end
    end
    
    describe "#>" do 
      it "should be correctly translated in infix" do 
        m = parse("2#>1").to_string
        m.should == "2 #>(1)"

        m = parse('"foo"#>"bar"').to_string
        m.should == '"foo" #>("bar")'
      end

      it "should be translated correctly with parenthesis" do 
        m = parse("2#>(1)").to_string
        m.should == "2 #>(1)"

        m = parse("2 #>(1)").to_string
        m.should == "2 #>(1)"

        m = parse('"foo"#>("bar")').to_string
        m.should == '"foo" #>("bar")'

        m = parse('"foo" #>("bar")').to_string
        m.should == '"foo" #>("bar")'
      end

      it "should be translated correctly with spaces" do 
        m = parse("2 #> 1").to_string
        m.should == "2 #>(1)"

        m = parse('"foo" #> "bar"').to_string
        m.should == '"foo" #>("bar")'
      end

      it "should be translated correctly when chained" do 
        m = parse("2 #> 1 #> 0").to_string
        m.should == "2 #>(1) #>(0)"

        m = parse('"foo" #> "bar" #> "quux"').to_string
        m.should == '"foo" #>("bar") #>("quux")'
      end
    end

    describe "@>" do 
      it "should be correctly translated in infix" do 
        m = parse("2@>1").to_string
        m.should == "2 @>(1)"

        m = parse('"foo"@>"bar"').to_string
        m.should == '"foo" @>("bar")'
      end

      it "should be translated correctly with parenthesis" do 
        m = parse("2@>(1)").to_string
        m.should == "2 @>(1)"

        m = parse("2 @>(1)").to_string
        m.should == "2 @>(1)"

        m = parse('"foo"@>("bar")').to_string
        m.should == '"foo" @>("bar")'

        m = parse('"foo" @>("bar")').to_string
        m.should == '"foo" @>("bar")'
      end

      it "should be translated correctly with spaces" do 
        m = parse("2 @> 1").to_string
        m.should == "2 @>(1)"

        m = parse('"foo" @> "bar"').to_string
        m.should == '"foo" @>("bar")'
      end

      it "should be translated correctly when chained" do 
        m = parse("2 @> 1 @> 0").to_string
        m.should == "2 @>(1) @>(0)"

        m = parse('"foo" @> "bar" @> "quux"').to_string
        m.should == '"foo" @>("bar") @>("quux")'
      end
    end
    
    describe "/>" do 
      it "should be correctly translated in infix" do 
        m = parse("2/>1").to_string
        m.should == "2 />(1)"

        m = parse('"foo"/>"bar"').to_string
        m.should == '"foo" />("bar")'
      end

      it "should be translated correctly with parenthesis" do 
        m = parse("2/>(1)").to_string
        m.should == "2 />(1)"

        m = parse("2 />(1)").to_string
        m.should == "2 />(1)"

        m = parse('"foo"/>("bar")').to_string
        m.should == '"foo" />("bar")'

        m = parse('"foo" />("bar")').to_string
        m.should == '"foo" />("bar")'
      end

      it "should be translated correctly with spaces" do 
        m = parse("2 /> 1").to_string
        m.should == "2 />(1)"

        m = parse('"foo" /> "bar"').to_string
        m.should == '"foo" />("bar")'
      end

      it "should be translated correctly when chained" do 
        m = parse("2 /> 1 /> 0").to_string
        m.should == "2 />(1) />(0)"

        m = parse('"foo" /> "bar" /> "quux"').to_string
        m.should == '"foo" />("bar") />("quux")'
      end
    end

    describe "*>" do 
      it "should be correctly translated in infix" do 
        m = parse("2*>1").to_string
        m.should == "2 *>(1)"

        m = parse('"foo"*>"bar"').to_string
        m.should == '"foo" *>("bar")'
      end

      it "should be translated correctly with parenthesis" do 
        m = parse("2*>(1)").to_string
        m.should == "2 *>(1)"

        m = parse("2 *>(1)").to_string
        m.should == "2 *>(1)"

        m = parse('"foo"*>("bar")').to_string
        m.should == '"foo" *>("bar")'

        m = parse('"foo" *>("bar")').to_string
        m.should == '"foo" *>("bar")'
      end

      it "should be translated correctly with spaces" do 
        m = parse("2 *> 1").to_string
        m.should == "2 *>(1)"

        m = parse('"foo" *> "bar"').to_string
        m.should == '"foo" *>("bar")'
      end

      it "should be translated correctly when chained" do 
        m = parse("2 *> 1 *> 0").to_string
        m.should == "2 *>(1) *>(0)"

        m = parse('"foo" *> "bar" *> "quux"').to_string
        m.should == '"foo" *>("bar") *>("quux")'
      end
    end

    
    describe "?>" do 
      it "should be correctly translated in infix" do 
        m = parse("2?>1").to_string
        m.should == "2 ?>(1)"

        m = parse('"foo"?>"bar"').to_string
        m.should == '"foo" ?>("bar")'
      end

      it "should be translated correctly with parenthesis" do 
        m = parse("2?>(1)").to_string
        m.should == "2 ?>(1)"

        m = parse("2 ?>(1)").to_string
        m.should == "2 ?>(1)"

        m = parse('"foo"?>("bar")').to_string
        m.should == '"foo" ?>("bar")'

        m = parse('"foo" ?>("bar")').to_string
        m.should == '"foo" ?>("bar")'
      end

      it "should be translated correctly with spaces" do 
        m = parse("2 ?> 1").to_string
        m.should == "2 ?>(1)"

        m = parse('"foo" ?> "bar"').to_string
        m.should == '"foo" ?>("bar")'
      end

      it "should be translated correctly when chained" do 
        m = parse("2 ?> 1 ?> 0").to_string
        m.should == "2 ?>(1) ?>(0)"

        m = parse('"foo" ?> "bar" ?> "quux"').to_string
        m.should == '"foo" ?>("bar") ?>("quux")'
      end
    end

    describe "|>" do 
      it "should be correctly translated in infix" do 
        m = parse("2|>1").to_string
        m.should == "2 |>(1)"

        m = parse('"foo"|>"bar"').to_string
        m.should == '"foo" |>("bar")'
      end

      it "should be translated correctly with parenthesis" do 
        m = parse("2|>(1)").to_string
        m.should == "2 |>(1)"

        m = parse("2 |>(1)").to_string
        m.should == "2 |>(1)"

        m = parse('"foo"|>("bar")').to_string
        m.should == '"foo" |>("bar")'

        m = parse('"foo" |>("bar")').to_string
        m.should == '"foo" |>("bar")'
      end

      it "should be translated correctly with spaces" do 
        m = parse("2 |> 1").to_string
        m.should == "2 |>(1)"

        m = parse('"foo" |> "bar"').to_string
        m.should == '"foo" |>("bar")'
      end

      it "should be translated correctly when chained" do 
        m = parse("2 |> 1 |> 0").to_string
        m.should == "2 |>(1) |>(0)"

        m = parse('"foo" |> "bar" |> "quux"').to_string
        m.should == '"foo" |>("bar") |>("quux")'
      end
    end

    describe "^>" do 
      it "should be correctly translated in infix" do 
        m = parse("2^>1").to_string
        m.should == "2 ^>(1)"

        m = parse('"foo"^>"bar"').to_string
        m.should == '"foo" ^>("bar")'
      end

      it "should be translated correctly with parenthesis" do 
        m = parse("2^>(1)").to_string
        m.should == "2 ^>(1)"

        m = parse("2 ^>(1)").to_string
        m.should == "2 ^>(1)"

        m = parse('"foo"^>("bar")').to_string
        m.should == '"foo" ^>("bar")'

        m = parse('"foo" ^>("bar")').to_string
        m.should == '"foo" ^>("bar")'
      end

      it "should be translated correctly with spaces" do 
        m = parse("2 ^> 1").to_string
        m.should == "2 ^>(1)"

        m = parse('"foo" ^> "bar"').to_string
        m.should == '"foo" ^>("bar")'
      end

      it "should be translated correctly when chained" do 
        m = parse("2 ^> 1 ^> 0").to_string
        m.should == "2 ^>(1) ^>(0)"

        m = parse('"foo" ^> "bar" ^> "quux"').to_string
        m.should == '"foo" ^>("bar") ^>("quux")'
      end
    end

    describe "~>" do 
      it "should be correctly translated in infix" do 
        m = parse("2~>1").to_string
        m.should == "2 ~>(1)"

        m = parse('"foo"~>"bar"').to_string
        m.should == '"foo" ~>("bar")'
      end

      it "should be translated correctly with parenthesis" do 
        m = parse("2~>(1)").to_string
        m.should == "2 ~>(1)"

        m = parse("2 ~>(1)").to_string
        m.should == "2 ~>(1)"

        m = parse('"foo"~>("bar")').to_string
        m.should == '"foo" ~>("bar")'

        m = parse('"foo" ~>("bar")').to_string
        m.should == '"foo" ~>("bar")'
      end

      it "should be translated correctly with spaces" do 
        m = parse("2 ~> 1").to_string
        m.should == "2 ~>(1)"

        m = parse('"foo" ~> "bar"').to_string
        m.should == '"foo" ~>("bar")'
      end

      it "should be translated correctly when chained" do 
        m = parse("2 ~> 1 ~> 0").to_string
        m.should == "2 ~>(1) ~>(0)"

        m = parse('"foo" ~> "bar" ~> "quux"').to_string
        m.should == '"foo" ~>("bar") ~>("quux")'
      end
    end

#-----    
    
    describe "->>" do 
      it "should be correctly translated in infix" do 
        m = parse("2->>1").to_string
        m.should == "2 ->>(1)"

        m = parse('"foo"->>"bar"').to_string
        m.should == '"foo" ->>("bar")'
      end

      it "should be translated correctly with parenthesis" do 
        m = parse("2->>(1)").to_string
        m.should == "2 ->>(1)"

        m = parse("2 ->>(1)").to_string
        m.should == "2 ->>(1)"

        m = parse('"foo"->>("bar")').to_string
        m.should == '"foo" ->>("bar")'

        m = parse('"foo" ->>("bar")').to_string
        m.should == '"foo" ->>("bar")'
      end

      it "should be translated correctly with spaces" do 
        m = parse("2 ->> 1").to_string
        m.should == "2 ->>(1)"

        m = parse('"foo" ->> "bar"').to_string
        m.should == '"foo" ->>("bar")'
      end

      it "should be translated correctly when chained" do 
        m = parse("2 ->> 1 ->> 0").to_string
        m.should == "2 ->>(1) ->>(0)"

        m = parse('"foo" ->> "bar" ->> "quux"').to_string
        m.should == '"foo" ->>("bar") ->>("quux")'
      end
    end

    describe "+>>" do 
      it "should be correctly translated in infix" do 
        m = parse("2+>>1").to_string
        m.should == "2 +>>(1)"

        m = parse('"foo"+>>"bar"').to_string
        m.should == '"foo" +>>("bar")'
      end

      it "should be translated correctly with parenthesis" do 
        m = parse("2+>>(1)").to_string
        m.should == "2 +>>(1)"

        m = parse("2 +>>(1)").to_string
        m.should == "2 +>>(1)"

        m = parse('"foo"+>>("bar")').to_string
        m.should == '"foo" +>>("bar")'

        m = parse('"foo" +>>("bar")').to_string
        m.should == '"foo" +>>("bar")'
      end

      it "should be translated correctly with spaces" do 
        m = parse("2 +>> 1").to_string
        m.should == "2 +>>(1)"

        m = parse('"foo" +>> "bar"').to_string
        m.should == '"foo" +>>("bar")'
      end

      it "should be translated correctly when chained" do 
        m = parse("2 +>> 1 +>> 0").to_string
        m.should == "2 +>>(1) +>>(0)"

        m = parse('"foo" +>> "bar" +>> "quux"').to_string
        m.should == '"foo" +>>("bar") +>>("quux")'
      end
    end
    
    describe "!>>" do 
      it "should be correctly translated in infix" do 
        m = parse("2!>>1").to_string
        m.should == "2 !>>(1)"

        m = parse('"foo"!>>"bar"').to_string
        m.should == '"foo" !>>("bar")'
      end

      it "should be translated correctly with parenthesis" do 
        m = parse("2!>>(1)").to_string
        m.should == "2 !>>(1)"

        m = parse("2 !>>(1)").to_string
        m.should == "2 !>>(1)"

        m = parse('"foo"!>>("bar")').to_string
        m.should == '"foo" !>>("bar")'

        m = parse('"foo" !>>("bar")').to_string
        m.should == '"foo" !>>("bar")'
      end

      it "should be translated correctly with spaces" do 
        m = parse("2 !>> 1").to_string
        m.should == "2 !>>(1)"

        m = parse('"foo" !>> "bar"').to_string
        m.should == '"foo" !>>("bar")'
      end

      it "should be translated correctly when chained" do 
        m = parse("2 !>> 1 !>> 0").to_string
        m.should == "2 !>>(1) !>>(0)"

        m = parse('"foo" !>> "bar" !>> "quux"').to_string
        m.should == '"foo" !>>("bar") !>>("quux")'
      end
    end

    describe "<>>" do 
      it "should be correctly translated in infix" do 
        m = parse("2<>>1").to_string
        m.should == "2 <>>(1)"

        m = parse('"foo"<>>"bar"').to_string
        m.should == '"foo" <>>("bar")'
      end

      it "should be translated correctly with parenthesis" do 
        m = parse("2<>>(1)").to_string
        m.should == "2 <>>(1)"

        m = parse("2 <>>(1)").to_string
        m.should == "2 <>>(1)"

        m = parse('"foo"<>>("bar")').to_string
        m.should == '"foo" <>>("bar")'

        m = parse('"foo" <>>("bar")').to_string
        m.should == '"foo" <>>("bar")'
      end

      it "should be translated correctly with spaces" do 
        m = parse("2 <>> 1").to_string
        m.should == "2 <>>(1)"

        m = parse('"foo" <>> "bar"').to_string
        m.should == '"foo" <>>("bar")'
      end

      it "should be translated correctly when chained" do 
        m = parse("2 <>> 1 <>> 0").to_string
        m.should == "2 <>>(1) <>>(0)"

        m = parse('"foo" <>> "bar" <>> "quux"').to_string
        m.should == '"foo" <>>("bar") <>>("quux")'
      end
    end
    
    describe "&>>" do 
      it "should be correctly translated in infix" do 
        m = parse("2&>>1").to_string
        m.should == "2 &>>(1)"

        m = parse('"foo"&>>"bar"').to_string
        m.should == '"foo" &>>("bar")'
      end

      it "should be translated correctly with parenthesis" do 
        m = parse("2&>>(1)").to_string
        m.should == "2 &>>(1)"

        m = parse("2 &>>(1)").to_string
        m.should == "2 &>>(1)"

        m = parse('"foo"&>>("bar")').to_string
        m.should == '"foo" &>>("bar")'

        m = parse('"foo" &>>("bar")').to_string
        m.should == '"foo" &>>("bar")'
      end

      it "should be translated correctly with spaces" do 
        m = parse("2 &>> 1").to_string
        m.should == "2 &>>(1)"

        m = parse('"foo" &>> "bar"').to_string
        m.should == '"foo" &>>("bar")'
      end

      it "should be translated correctly when chained" do 
        m = parse("2 &>> 1 &>> 0").to_string
        m.should == "2 &>>(1) &>>(0)"

        m = parse('"foo" &>> "bar" &>> "quux"').to_string
        m.should == '"foo" &>>("bar") &>>("quux")'
      end
    end
    

    describe "%>>" do 
      it "should be correctly translated in infix" do 
        m = parse("2%>>1").to_string
        m.should == "2 %>>(1)"

        m = parse('"foo"%>>"bar"').to_string
        m.should == '"foo" %>>("bar")'
      end

      it "should be translated correctly with parenthesis" do 
        m = parse("2%>>(1)").to_string
        m.should == "2 %>>(1)"

        m = parse("2 %>>(1)").to_string
        m.should == "2 %>>(1)"

        m = parse('"foo"%>>("bar")').to_string
        m.should == '"foo" %>>("bar")'

        m = parse('"foo" %>>("bar")').to_string
        m.should == '"foo" %>>("bar")'
      end

      it "should be translated correctly with spaces" do 
        m = parse("2 %>> 1").to_string
        m.should == "2 %>>(1)"

        m = parse('"foo" %>> "bar"').to_string
        m.should == '"foo" %>>("bar")'
      end

      it "should be translated correctly when chained" do 
        m = parse("2 %>> 1 %>> 0").to_string
        m.should == "2 %>>(1) %>>(0)"

        m = parse('"foo" %>> "bar" %>> "quux"').to_string
        m.should == '"foo" %>>("bar") %>>("quux")'
      end
    end
    
    describe "#>>" do 
      it "should be correctly translated in infix" do 
        m = parse("2#>>1").to_string
        m.should == "2 #>>(1)"

        m = parse('"foo"#>>"bar"').to_string
        m.should == '"foo" #>>("bar")'
      end

      it "should be translated correctly with parenthesis" do 
        m = parse("2#>>(1)").to_string
        m.should == "2 #>>(1)"

        m = parse("2 #>>(1)").to_string
        m.should == "2 #>>(1)"

        m = parse('"foo"#>>("bar")').to_string
        m.should == '"foo" #>>("bar")'

        m = parse('"foo" #>>("bar")').to_string
        m.should == '"foo" #>>("bar")'
      end

      it "should be translated correctly with spaces" do 
        m = parse("2 #>> 1").to_string
        m.should == "2 #>>(1)"

        m = parse('"foo" #>> "bar"').to_string
        m.should == '"foo" #>>("bar")'
      end

      it "should be translated correctly when chained" do 
        m = parse("2 #>> 1 #>> 0").to_string
        m.should == "2 #>>(1) #>>(0)"

        m = parse('"foo" #>> "bar" #>> "quux"').to_string
        m.should == '"foo" #>>("bar") #>>("quux")'
      end
    end

    describe "@>>" do 
      it "should be correctly translated in infix" do 
        m = parse("2@>>1").to_string
        m.should == "2 @>>(1)"

        m = parse('"foo"@>>"bar"').to_string
        m.should == '"foo" @>>("bar")'
      end

      it "should be translated correctly with parenthesis" do 
        m = parse("2@>>(1)").to_string
        m.should == "2 @>>(1)"

        m = parse("2 @>>(1)").to_string
        m.should == "2 @>>(1)"

        m = parse('"foo"@>>("bar")').to_string
        m.should == '"foo" @>>("bar")'

        m = parse('"foo" @>>("bar")').to_string
        m.should == '"foo" @>>("bar")'
      end

      it "should be translated correctly with spaces" do 
        m = parse("2 @>> 1").to_string
        m.should == "2 @>>(1)"

        m = parse('"foo" @>> "bar"').to_string
        m.should == '"foo" @>>("bar")'
      end

      it "should be translated correctly when chained" do 
        m = parse("2 @>> 1 @>> 0").to_string
        m.should == "2 @>>(1) @>>(0)"

        m = parse('"foo" @>> "bar" @>> "quux"').to_string
        m.should == '"foo" @>>("bar") @>>("quux")'
      end
    end
    
    describe "/>>" do 
      it "should be correctly translated in infix" do 
        m = parse("2/>>1").to_string
        m.should == "2 />>(1)"

        m = parse('"foo"/>>"bar"').to_string
        m.should == '"foo" />>("bar")'
      end

      it "should be translated correctly with parenthesis" do 
        m = parse("2/>>(1)").to_string
        m.should == "2 />>(1)"

        m = parse("2 />>(1)").to_string
        m.should == "2 />>(1)"

        m = parse('"foo"/>>("bar")').to_string
        m.should == '"foo" />>("bar")'

        m = parse('"foo" />>("bar")').to_string
        m.should == '"foo" />>("bar")'
      end

      it "should be translated correctly with spaces" do 
        m = parse("2 />> 1").to_string
        m.should == "2 />>(1)"

        m = parse('"foo" />> "bar"').to_string
        m.should == '"foo" />>("bar")'
      end

      it "should be translated correctly when chained" do 
        m = parse("2 />> 1 />> 0").to_string
        m.should == "2 />>(1) />>(0)"

        m = parse('"foo" />> "bar" />> "quux"').to_string
        m.should == '"foo" />>("bar") />>("quux")'
      end
    end

    describe "*>>" do 
      it "should be correctly translated in infix" do 
        m = parse("2*>>1").to_string
        m.should == "2 *>>(1)"

        m = parse('"foo"*>>"bar"').to_string
        m.should == '"foo" *>>("bar")'
      end

      it "should be translated correctly with parenthesis" do 
        m = parse("2*>>(1)").to_string
        m.should == "2 *>>(1)"

        m = parse("2 *>>(1)").to_string
        m.should == "2 *>>(1)"

        m = parse('"foo"*>>("bar")').to_string
        m.should == '"foo" *>>("bar")'

        m = parse('"foo" *>>("bar")').to_string
        m.should == '"foo" *>>("bar")'
      end

      it "should be translated correctly with spaces" do 
        m = parse("2 *>> 1").to_string
        m.should == "2 *>>(1)"

        m = parse('"foo" *>> "bar"').to_string
        m.should == '"foo" *>>("bar")'
      end

      it "should be translated correctly when chained" do 
        m = parse("2 *>> 1 *>> 0").to_string
        m.should == "2 *>>(1) *>>(0)"

        m = parse('"foo" *>> "bar" *>> "quux"').to_string
        m.should == '"foo" *>>("bar") *>>("quux")'
      end
    end

    
    describe "?>>" do 
      it "should be correctly translated in infix" do 
        m = parse("2?>>1").to_string
        m.should == "2 ?>>(1)"

        m = parse('"foo"?>>"bar"').to_string
        m.should == '"foo" ?>>("bar")'
      end

      it "should be translated correctly with parenthesis" do 
        m = parse("2?>>(1)").to_string
        m.should == "2 ?>>(1)"

        m = parse("2 ?>>(1)").to_string
        m.should == "2 ?>>(1)"

        m = parse('"foo"?>>("bar")').to_string
        m.should == '"foo" ?>>("bar")'

        m = parse('"foo" ?>>("bar")').to_string
        m.should == '"foo" ?>>("bar")'
      end

      it "should be translated correctly with spaces" do 
        m = parse("2 ?>> 1").to_string
        m.should == "2 ?>>(1)"

        m = parse('"foo" ?>> "bar"').to_string
        m.should == '"foo" ?>>("bar")'
      end

      it "should be translated correctly when chained" do 
        m = parse("2 ?>> 1 ?>> 0").to_string
        m.should == "2 ?>>(1) ?>>(0)"

        m = parse('"foo" ?>> "bar" ?>> "quux"').to_string
        m.should == '"foo" ?>>("bar") ?>>("quux")'
      end
    end

    describe "|>>" do 
      it "should be correctly translated in infix" do 
        m = parse("2|>>1").to_string
        m.should == "2 |>>(1)"

        m = parse('"foo"|>>"bar"').to_string
        m.should == '"foo" |>>("bar")'
      end

      it "should be translated correctly with parenthesis" do 
        m = parse("2|>>(1)").to_string
        m.should == "2 |>>(1)"

        m = parse("2 |>>(1)").to_string
        m.should == "2 |>>(1)"

        m = parse('"foo"|>>("bar")').to_string
        m.should == '"foo" |>>("bar")'

        m = parse('"foo" |>>("bar")').to_string
        m.should == '"foo" |>>("bar")'
      end

      it "should be translated correctly with spaces" do 
        m = parse("2 |>> 1").to_string
        m.should == "2 |>>(1)"

        m = parse('"foo" |>> "bar"').to_string
        m.should == '"foo" |>>("bar")'
      end

      it "should be translated correctly when chained" do 
        m = parse("2 |>> 1 |>> 0").to_string
        m.should == "2 |>>(1) |>>(0)"

        m = parse('"foo" |>> "bar" |>> "quux"').to_string
        m.should == '"foo" |>>("bar") |>>("quux")'
      end
    end

    describe "^>>" do 
      it "should be correctly translated in infix" do 
        m = parse("2^>>1").to_string
        m.should == "2 ^>>(1)"

        m = parse('"foo"^>>"bar"').to_string
        m.should == '"foo" ^>>("bar")'
      end

      it "should be translated correctly with parenthesis" do 
        m = parse("2^>>(1)").to_string
        m.should == "2 ^>>(1)"

        m = parse("2 ^>>(1)").to_string
        m.should == "2 ^>>(1)"

        m = parse('"foo"^>>("bar")').to_string
        m.should == '"foo" ^>>("bar")'

        m = parse('"foo" ^>>("bar")').to_string
        m.should == '"foo" ^>>("bar")'
      end

      it "should be translated correctly with spaces" do 
        m = parse("2 ^>> 1").to_string
        m.should == "2 ^>>(1)"

        m = parse('"foo" ^>> "bar"').to_string
        m.should == '"foo" ^>>("bar")'
      end

      it "should be translated correctly when chained" do 
        m = parse("2 ^>> 1 ^>> 0").to_string
        m.should == "2 ^>>(1) ^>>(0)"

        m = parse('"foo" ^>> "bar" ^>> "quux"').to_string
        m.should == '"foo" ^>>("bar") ^>>("quux")'
      end
    end

    describe "~>>" do 
      it "should be correctly translated in infix" do 
        m = parse("2~>>1").to_string
        m.should == "2 ~>>(1)"

        m = parse('"foo"~>>"bar"').to_string
        m.should == '"foo" ~>>("bar")'
      end

      it "should be translated correctly with parenthesis" do 
        m = parse("2~>>(1)").to_string
        m.should == "2 ~>>(1)"

        m = parse("2 ~>>(1)").to_string
        m.should == "2 ~>>(1)"

        m = parse('"foo"~>>("bar")').to_string
        m.should == '"foo" ~>>("bar")'

        m = parse('"foo" ~>>("bar")').to_string
        m.should == '"foo" ~>>("bar")'
      end

      it "should be translated correctly with spaces" do 
        m = parse("2 ~>> 1").to_string
        m.should == "2 ~>>(1)"

        m = parse('"foo" ~>> "bar"').to_string
        m.should == '"foo" ~>>("bar")'
      end

      it "should be translated correctly when chained" do 
        m = parse("2 ~>> 1 ~>> 0").to_string
        m.should == "2 ~>>(1) ~>>(0)"

        m = parse('"foo" ~>> "bar" ~>> "quux"').to_string
        m.should == '"foo" ~>>("bar") ~>>("quux")'
      end
    end

    describe "=>>" do 
      it "should be correctly translated in infix" do 
        m = parse("2=>>1").to_string
        m.should == "2 =>>(1)"

        m = parse('"foo"=>>"bar"').to_string
        m.should == '"foo" =>>("bar")'
      end

      it "should be translated correctly with parenthesis" do 
        m = parse("2=>>(1)").to_string
        m.should == "2 =>>(1)"

        m = parse("2 =>>(1)").to_string
        m.should == "2 =>>(1)"

        m = parse('"foo"=>>("bar")').to_string
        m.should == '"foo" =>>("bar")'

        m = parse('"foo" =>>("bar")').to_string
        m.should == '"foo" =>>("bar")'
      end

      it "should be translated correctly with spaces" do 
        m = parse("2 =>> 1").to_string
        m.should == "2 =>>(1)"

        m = parse('"foo" =>> "bar"').to_string
        m.should == '"foo" =>>("bar")'
      end

      it "should be translated correctly when chained" do 
        m = parse("2 =>> 1 =>> 0").to_string
        m.should == "2 =>>(1) =>>(0)"

        m = parse('"foo" =>> "bar" =>> "quux"').to_string
        m.should == '"foo" =>>("bar") =>>("quux")'
      end
    end

    describe "**>" do 
      it "should be correctly translated in infix" do 
        m = parse("2**>1").to_string
        m.should == "2 **>(1)"

        m = parse('"foo"**>"bar"').to_string
        m.should == '"foo" **>("bar")'
      end

      it "should be translated correctly with parenthesis" do 
        m = parse("2**>(1)").to_string
        m.should == "2 **>(1)"

        m = parse("2 **>(1)").to_string
        m.should == "2 **>(1)"

        m = parse('"foo"**>("bar")').to_string
        m.should == '"foo" **>("bar")'

        m = parse('"foo" **>("bar")').to_string
        m.should == '"foo" **>("bar")'
      end

      it "should be translated correctly with spaces" do 
        m = parse("2 **> 1").to_string
        m.should == "2 **>(1)"

        m = parse('"foo" **> "bar"').to_string
        m.should == '"foo" **>("bar")'
      end

      it "should be translated correctly when chained" do 
        m = parse("2 **> 1 **> 0").to_string
        m.should == "2 **>(1) **>(0)"

        m = parse('"foo" **> "bar" **> "quux"').to_string
        m.should == '"foo" **>("bar") **>("quux")'
      end
    end

    describe "**>>" do 
      it "should be correctly translated in infix" do 
        m = parse("2**>>1").to_string
        m.should == "2 **>>(1)"

        m = parse('"foo"**>>"bar"').to_string
        m.should == '"foo" **>>("bar")'
      end

      it "should be translated correctly with parenthesis" do 
        m = parse("2**>>(1)").to_string
        m.should == "2 **>>(1)"

        m = parse("2 **>>(1)").to_string
        m.should == "2 **>>(1)"

        m = parse('"foo"**>>("bar")').to_string
        m.should == '"foo" **>>("bar")'

        m = parse('"foo" **>>("bar")').to_string
        m.should == '"foo" **>>("bar")'
      end

      it "should be translated correctly with spaces" do 
        m = parse("2 **>> 1").to_string
        m.should == "2 **>>(1)"

        m = parse('"foo" **>> "bar"').to_string
        m.should == '"foo" **>>("bar")'
      end

      it "should be translated correctly when chained" do 
        m = parse("2 **>> 1 **>> 0").to_string
        m.should == "2 **>>(1) **>>(0)"

        m = parse('"foo" **>> "bar" **>> "quux"').to_string
        m.should == '"foo" **>>("bar") **>>("quux")'
      end
    end

    describe "&&>" do 
      it "should be correctly translated in infix" do 
        m = parse("2&&>1").to_string
        m.should == "2 &&>(1)"

        m = parse('"foo"&&>"bar"').to_string
        m.should == '"foo" &&>("bar")'
      end

      it "should be translated correctly with parenthesis" do 
        m = parse("2&&>(1)").to_string
        m.should == "2 &&>(1)"

        m = parse("2 &&>(1)").to_string
        m.should == "2 &&>(1)"

        m = parse('"foo"&&>("bar")').to_string
        m.should == '"foo" &&>("bar")'

        m = parse('"foo" &&>("bar")').to_string
        m.should == '"foo" &&>("bar")'
      end

      it "should be translated correctly with spaces" do 
        m = parse("2 &&> 1").to_string
        m.should == "2 &&>(1)"

        m = parse('"foo" &&> "bar"').to_string
        m.should == '"foo" &&>("bar")'
      end

      it "should be translated correctly when chained" do 
        m = parse("2 &&> 1 &&> 0").to_string
        m.should == "2 &&>(1) &&>(0)"

        m = parse('"foo" &&> "bar" &&> "quux"').to_string
        m.should == '"foo" &&>("bar") &&>("quux")'
      end
    end

    describe "&&>>" do 
      it "should be correctly translated in infix" do 
        m = parse("2&&>>1").to_string
        m.should == "2 &&>>(1)"

        m = parse('"foo"&&>>"bar"').to_string
        m.should == '"foo" &&>>("bar")'
      end

      it "should be translated correctly with parenthesis" do 
        m = parse("2&&>>(1)").to_string
        m.should == "2 &&>>(1)"

        m = parse("2 &&>>(1)").to_string
        m.should == "2 &&>>(1)"

        m = parse('"foo"&&>>("bar")').to_string
        m.should == '"foo" &&>>("bar")'

        m = parse('"foo" &&>>("bar")').to_string
        m.should == '"foo" &&>>("bar")'
      end

      it "should be translated correctly with spaces" do 
        m = parse("2 &&>> 1").to_string
        m.should == "2 &&>>(1)"

        m = parse('"foo" &&>> "bar"').to_string
        m.should == '"foo" &&>>("bar")'
      end

      it "should be translated correctly when chained" do 
        m = parse("2 &&>> 1 &&>> 0").to_string
        m.should == "2 &&>>(1) &&>>(0)"

        m = parse('"foo" &&>> "bar" &&>> "quux"').to_string
        m.should == '"foo" &&>>("bar") &&>>("quux")'
      end
    end

    describe "||>" do 
      it "should be correctly translated in infix" do 
        m = parse("2||>1").to_string
        m.should == "2 ||>(1)"

        m = parse('"foo"||>"bar"').to_string
        m.should == '"foo" ||>("bar")'
      end

      it "should be translated correctly with parenthesis" do 
        m = parse("2||>(1)").to_string
        m.should == "2 ||>(1)"

        m = parse("2 ||>(1)").to_string
        m.should == "2 ||>(1)"

        m = parse('"foo"||>("bar")').to_string
        m.should == '"foo" ||>("bar")'

        m = parse('"foo" ||>("bar")').to_string
        m.should == '"foo" ||>("bar")'
      end

      it "should be translated correctly with spaces" do 
        m = parse("2 ||> 1").to_string
        m.should == "2 ||>(1)"

        m = parse('"foo" ||> "bar"').to_string
        m.should == '"foo" ||>("bar")'
      end

      it "should be translated correctly when chained" do 
        m = parse("2 ||> 1 ||> 0").to_string
        m.should == "2 ||>(1) ||>(0)"

        m = parse('"foo" ||> "bar" ||> "quux"').to_string
        m.should == '"foo" ||>("bar") ||>("quux")'
      end
    end

    describe "||>>" do 
      it "should be correctly translated in infix" do 
        m = parse("2||>>1").to_string
        m.should == "2 ||>>(1)"

        m = parse('"foo"||>>"bar"').to_string
        m.should == '"foo" ||>>("bar")'
      end

      it "should be translated correctly with parenthesis" do 
        m = parse("2||>>(1)").to_string
        m.should == "2 ||>>(1)"

        m = parse("2 ||>>(1)").to_string
        m.should == "2 ||>>(1)"

        m = parse('"foo"||>>("bar")').to_string
        m.should == '"foo" ||>>("bar")'

        m = parse('"foo" ||>>("bar")').to_string
        m.should == '"foo" ||>>("bar")'
      end

      it "should be translated correctly with spaces" do 
        m = parse("2 ||>> 1").to_string
        m.should == "2 ||>>(1)"

        m = parse('"foo" ||>> "bar"').to_string
        m.should == '"foo" ||>>("bar")'
      end

      it "should be translated correctly when chained" do 
        m = parse("2 ||>> 1 ||>> 0").to_string
        m.should == "2 ||>>(1) ||>>(0)"

        m = parse('"foo" ||>> "bar" ||>> "quux"').to_string
        m.should == '"foo" ||>>("bar") ||>>("quux")'
      end
    end
    
    describe "$>" do 
      it "should be correctly translated in infix" do 
        m = parse("2$>1").to_string
        m.should == "2 $>(1)"

        m = parse('"foo"$>"bar"').to_string
        m.should == '"foo" $>("bar")'
      end

      it "should be translated correctly with parenthesis" do 
        m = parse("2$>(1)").to_string
        m.should == "2 $>(1)"

        m = parse("2 $>(1)").to_string
        m.should == "2 $>(1)"

        m = parse('"foo"$>("bar")').to_string
        m.should == '"foo" $>("bar")'

        m = parse('"foo" $>("bar")').to_string
        m.should == '"foo" $>("bar")'
      end

      it "should be translated correctly with spaces" do 
        m = parse("2 $> 1").to_string
        m.should == "2 $>(1)"

        m = parse('"foo" $> "bar"').to_string
        m.should == '"foo" $>("bar")'
      end

      it "should be translated correctly when chained" do 
        m = parse("2 $> 1 $> 0").to_string
        m.should == "2 $>(1) $>(0)"

        m = parse('"foo" $> "bar" $> "quux"').to_string
        m.should == '"foo" $>("bar") $>("quux")'
      end
    end

    describe "$>>" do 
      it "should be correctly translated in infix" do 
        m = parse("2$>>1").to_string
        m.should == "2 $>>(1)"

        m = parse('"foo"$>>"bar"').to_string
        m.should == '"foo" $>>("bar")'
      end

      it "should be translated correctly with parenthesis" do 
        m = parse("2$>>(1)").to_string
        m.should == "2 $>>(1)"

        m = parse("2 $>>(1)").to_string
        m.should == "2 $>>(1)"

        m = parse('"foo"$>>("bar")').to_string
        m.should == '"foo" $>>("bar")'

        m = parse('"foo" $>>("bar")').to_string
        m.should == '"foo" $>>("bar")'
      end

      it "should be translated correctly with spaces" do 
        m = parse("2 $>> 1").to_string
        m.should == "2 $>>(1)"

        m = parse('"foo" $>> "bar"').to_string
        m.should == '"foo" $>>("bar")'
      end

      it "should be translated correctly when chained" do 
        m = parse("2 $>> 1 $>> 0").to_string
        m.should == "2 $>>(1) $>>(0)"

        m = parse('"foo" $>> "bar" $>> "quux"').to_string
        m.should == '"foo" $>>("bar") $>>("quux")'
      end
    end
    
    describe "<->" do 
      it "should be correctly translated in infix" do 
        m = parse("2<->1").to_string
        m.should == "2 <->(1)"

        m = parse('"foo"<->"bar"').to_string
        m.should == '"foo" <->("bar")'
      end

      it "should be translated correctly with parenthesis" do 
        m = parse("2<->(1)").to_string
        m.should == "2 <->(1)"

        m = parse("2 <->(1)").to_string
        m.should == "2 <->(1)"

        m = parse('"foo"<->("bar")').to_string
        m.should == '"foo" <->("bar")'

        m = parse('"foo" <->("bar")').to_string
        m.should == '"foo" <->("bar")'
      end

      it "should be translated correctly with spaces" do 
        m = parse("2 <-> 1").to_string
        m.should == "2 <->(1)"

        m = parse('"foo" <-> "bar"').to_string
        m.should == '"foo" <->("bar")'
      end

      it "should be translated correctly when chained" do 
        m = parse("2 <-> 1 <-> 0").to_string
        m.should == "2 <->(1) <->(0)"

        m = parse('"foo" <-> "bar" <-> "quux"').to_string
        m.should == '"foo" <->("bar") <->("quux")'
      end
    end

    describe "precedence" do 
      it "should work correctly for + and *" do 
        m = parse("2+3*4").to_string
        m.should == "2 +(3 *(4))"
      end

      it "should work correctly for * and +" do 
        m = parse("2*3+4").to_string
        m.should == "2 *(3) +(4)"
      end

      it "should work correctly for + and * with spaces" do 
        m = parse("2 + 3 * 4").to_string
        m.should == "2 +(3 *(4))"
      end

      it "should work correctly for * and + with spaces" do 
        m = parse("2 * 3 + 4").to_string
        m.should == "2 *(3) +(4)"
      end

      it "should work correctly for + and /" do 
        m = parse("2+3/4").to_string
        m.should == "2 +(3 /(4))"
      end

      it "should work correctly for / and +" do 
        m = parse("2/3+4").to_string
        m.should == "2 /(3) +(4)"
      end

      it "should work correctly for + and / with spaces" do 
        m = parse("2 + 3 / 4").to_string
        m.should == "2 +(3 /(4))"
      end

      it "should work correctly for / and + with spaces" do 
        m = parse("2 / 3 + 4").to_string
        m.should == "2 /(3) +(4)"
      end

      it "should work correctly for - and *" do 
        m = parse("2-3*4").to_string
        m.should == "2 -(3 *(4))"
      end

      it "should work correctly for * and -" do 
        m = parse("2*3-4").to_string
        m.should == "2 *(3) -(4)"
      end

      it "should work correctly for - and * with spaces" do 
        m = parse("2 - 3 * 4").to_string
        m.should == "2 -(3 *(4))"
      end

      it "should work correctly for * and - with spaces" do 
        m = parse("2 * 3 - 4").to_string
        m.should == "2 *(3) -(4)"
      end

      it "should work correctly for - and /" do 
        m = parse("2-3/4").to_string
        m.should == "2 -(3 /(4))"
      end

      it "should work correctly for / and -" do 
        m = parse("2/3-4").to_string
        m.should == "2 /(3) -(4)"
      end

      it "should work correctly for - and / with spaces" do 
        m = parse("2 - 3 / 4").to_string
        m.should == "2 -(3 /(4))"
      end

      it "should work correctly for / and - with spaces" do 
        m = parse("2 / 3 - 4").to_string
        m.should == "2 /(3) -(4)"
      end
      
      it "should work correctly for unary minus" do 
        m = parse("20 * -10").to_string
        m.should == "20 *(-(10))"
      end

      it "should work correctly for unary plus" do 
        m = parse("20 * +10").to_string
        m.should == "20 *(+(10))"
      end
    end
  end
end
