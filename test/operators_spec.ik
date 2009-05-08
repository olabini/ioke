
use("ispec")

parse = method(str,
  Message fromText(str) code)

describe("operator",
  describe("parsing", 
    describe("@", 
      it("should be parsed correctly empty", 
        m = parse("@")
        m should == "@"
      )

      it("should be parsed correctly with arguments", 
        m = parse("@(foo)")
        m should == "@(foo)"
      )
      
      it("should be parsed correctly directly in front of another identifier", 
        m = parse("@abc")
        m should == "@ abc"
      )

      it("should be parsed correctly directly in front of another identifier with space", 
        m = parse("@ abc")
        m should == "@ abc"
      )
    )

    describe("@@", 
      it("should be parsed correctly empty", 
        m = parse("@@")
        m should == "@@"
      )

      it("should be parsed correctly with arguments", 
        m = parse("@@(foo)")
        m should == "@@(foo)"
      )
      
      it("should be parsed correctly directly in front of another identifier", 
        m = parse("@@abc")
        m should == "@@ abc"
      )

      it("should be parsed correctly directly in front of another identifier with space", 
        m = parse("@@ abc")
        m should == "@@ abc"
      )
    )
    
    describe("<=>", 
      it("should be translated correctly inside a method definition", 
        m = parse("method(1<=>2)")
        m should == "method(1 <=>(2))"
      )

      it("should be translated correctly inside a nested method definition", 
        m = parse("method(method(1<=>2))")
        m should == "method(method(1 <=>(2)))"
      )

      it("should be translated correctly inside a method definition with something else", 
        m = parse("method(n, if(1<=>2, n, n))")
        m should == "method(n, if(1 <=>(2), n, n))"
      )
      
      it("should be translated correctly in infix", 
        m = parse("1<=>2")
        m should == "1 <=>(2)"
      )

      it("should be translated correctly with parenthesis", 
        m = parse("1<=>(2)")
        m should == "1 <=>(2)"

        m = parse("1 <=>(2)")
        m should == "1 <=>(2)"
      )

      it("should be translated correctly with spaces", 
        m = parse("1 <=> 2")
        m should == "1 <=>(2)"
      )
    )

    describe("<", 
      it("should be translated correctly inside a method definition", 
        m = parse("method(1<2)")
        m should == "method(1 <(2))"
      )

      it("should be translated correctly inside a nested method definition", 
        m = parse("method(method(1<2))")
        m should == "method(method(1 <(2)))"
      )

      it("should be translated correctly inside a method definition with something else", 
        m = parse("method(n, if(1<2, n, n))")
        m should == "method(n, if(1 <(2), n, n))"
      )
      
      it("should be translated correctly in infix", 
        m = parse("1<2")
        m should == "1 <(2)"
      )

      it("should be translated correctly in infix, starting with letter", 
        m = parse("a<2")
        m should == "a <(2)"
      )

      it("should be translated correctly with parenthesis", 
        m = parse("1<(2)")
        m should == "1 <(2)"

        m = parse("1 <(2)")
        m should == "1 <(2)"
      )

      it("should be translated correctly with spaces", 
        m = parse("1 < 2")
        m should == "1 <(2)"
      )
    )

    describe(">", 
      it("should be translated correctly inside a method definition", 
        m = parse("method(1>2)")
        m should == "method(1 >(2))"
      )

      it("should be translated correctly inside a nested method definition", 
        m = parse("method(method(1>2))")
        m should == "method(method(1 >(2)))"
      )

      it("should be translated correctly inside a method definition with something else", 
        m = parse("method(n, if(1>2, n, n))")
        m should == "method(n, if(1 >(2), n, n))"
      )
      
      it("should be translated correctly in infix", 
        m = parse("1>2")
        m should == "1 >(2)"
      )

      it("should be translated correctly with parenthesis", 
        m = parse("1>(2)")
        m should == "1 >(2)"

        m = parse("1 >(2)")
        m should == "1 >(2)"
      )

      it("should be translated correctly with spaces", 
        m = parse("1 > 2")
        m should == "1 >(2)"
      )
    )

    describe("<=", 
      it("should be translated correctly inside a method definition", 
        m = parse("method(1<=2)")
        m should == "method(1 <=(2))"
      )

      it("should be translated correctly inside a nested method definition", 
        m = parse("method(method(1<=2))")
        m should == "method(method(1 <=(2)))"
      )

      it("should be translated correctly inside a method definition with something else", 
        m = parse("method(n, if(1<=2, n, n))")
        m should == "method(n, if(1 <=(2), n, n))"
      )
      
      it("should be translated correctly in infix", 
        m = parse("1<=2")
        m should == "1 <=(2)"
      )

      it("should be translated correctly with parenthesis", 
        m = parse("1<=(2)")
        m should == "1 <=(2)"

        m = parse("1 <=(2)")
        m should == "1 <=(2)"
      )

      it("should be translated correctly with spaces", 
        m = parse("1 <= 2")
        m should == "1 <=(2)"
      )
    )
    
    describe(">=", 
      it("should be translated correctly inside a method definition", 
        m = parse("method(1>=2)")
        m should == "method(1 >=(2))"
      )

      it("should be translated correctly inside a nested method definition", 
        m = parse("method(method(1>=2))")
        m should == "method(method(1 >=(2)))"
      )

      it("should be translated correctly inside a method definition with something else", 
        m = parse("method(n, if(1>=2, n, n))")
        m should == "method(n, if(1 >=(2), n, n))"
      )
      
      it("should be translated correctly in infix", 
        m = parse("1>=2")
        m should == "1 >=(2)"
      )

      it("should be translated correctly with parenthesis", 
        m = parse("1>=(2)")
        m should == "1 >=(2)"

        m = parse("1 >=(2)")
        m should == "1 >=(2)"
      )

      it("should be translated correctly with spaces", 
        m = parse("1 >= 2")
        m should == "1 >=(2)"
      )
    )

    describe("!=", 
      it("should be translated correctly inside a method definition", 
        m = parse("method(1!=2)")
        m should == "method(1 !=(2))"
      )

      it("should be translated correctly inside a nested method definition", 
        m = parse("method(method(1!=2))")
        m should == "method(method(1 !=(2)))"
      )

      it("should be translated correctly inside a method definition with something else", 
        m = parse("method(n, if(1!=2, n, n))")
        m should == "method(n, if(1 !=(2), n, n))"
      )
      
      it("should be translated correctly in infix", 
        m = parse("1!=2")
        m should == "1 !=(2)"
      )

      it("should be translated correctly with parenthesis", 
        m = parse("1!=(2)")
        m should == "1 !=(2)"

        m = parse("1 !=(2)")
        m should == "1 !=(2)"
      )

      it("should be translated correctly with spaces", 
        m = parse("1 != 2")
        m should == "1 !=(2)"
      )
    )


    describe("==", 
      it("should be translated correctly inside a method definition", 
        m = parse("method(1==2)")
        m should == "method(1 ==(2))"
      )

      it("should be translated correctly inside a nested method definition", 
        m = parse("method(method(1==2))")
        m should == "method(method(1 ==(2)))"
      )

      it("should be translated correctly inside a method definition with something else", 
        m = parse("method(n, if(1==2, n, n))")
        m should == "method(n, if(1 ==(2), n, n))"
      )
      
      it("should be translated correctly in infix", 
        m = parse("1==2")
        m should == "1 ==(2)"
      )

      it("should be translated correctly with parenthesis", 
        m = parse("1==(2)")
        m should == "1 ==(2)"

        m = parse("1 ==(2)")
        m should == "1 ==(2)"
      )

      it("should be translated correctly with spaces", 
        m = parse("1 == 2")
        m should == "1 ==(2)"
      )
    )

    describe("===", 
      it("should be translated correctly inside a method definition", 
        m = parse("method(1===2)")
        m should == "method(1 ===(2))"
      )

      it("should be translated correctly inside a nested method definition", 
        m = parse("method(method(1===2))")
        m should == "method(method(1 ===(2)))"
      )

      it("should be translated correctly inside a method definition with something else", 
        m = parse("method(n, if(1===2, n, n))")
        m should == "method(n, if(1 ===(2), n, n))"
      )
      
      it("should be translated correctly in infix", 
        m = parse("1===2")
        m should == "1 ===(2)"
      )

      it("should be translated correctly with parenthesis", 
        m = parse("1===(2)")
        m should == "1 ===(2)"

        m = parse("1 ===(2)")
        m should == "1 ===(2)"
      )

      it("should be translated correctly with spaces", 
        m = parse("1 === 2")
        m should == "1 ===(2)"
      )
    )

    describe("=~", 
      it("should be translated correctly inside a method definition", 
        m = parse("method(1=~2)")
        m should == "method(1 =~(2))"
      )

      it("should be translated correctly inside a nested method definition", 
        m = parse("method(method(1=~2))")
        m should == "method(method(1 =~(2)))"
      )

      it("should be translated correctly inside a method definition with something else", 
        m = parse("method(n, if(1=~2, n, n))")
        m should == "method(n, if(1 =~(2), n, n))"
      )
      
      it("should be translated correctly in infix", 
        m = parse("1=~2")
        m should == "1 =~(2)"
      )

      it("should be translated correctly with parenthesis", 
        m = parse("1=~(2)")
        m should == "1 =~(2)"

        m = parse("1 =~(2)")
        m should == "1 =~(2)"
      )

      it("should be translated correctly with spaces", 
        m = parse("1 =~ 2")
        m should == "1 =~(2)"
      )
    )

    describe("!~", 
      it("should be translated correctly inside a method definition", 
        m = parse("method(1!~2)")
        m should == "method(1 !~(2))"
      )

      it("should be translated correctly inside a nested method definition", 
        m = parse("method(method(1!~2))")
        m should == "method(method(1 !~(2)))"
      )

      it("should be translated correctly inside a method definition with something else", 
        m = parse("method(n, if(1!~2, n, n))")
        m should == "method(n, if(1 !~(2), n, n))"
      )
      
      it("should be translated correctly in infix", 
        m = parse("1!~2")
        m should == "1 !~(2)"
      )

      it("should be translated correctly with parenthesis", 
        m = parse("1!~(2)")
        m should == "1 !~(2)"

        m = parse("1 !~(2)")
        m should == "1 !~(2)"
      )

      it("should be translated correctly with spaces", 
        m = parse("1 !~ 2")
        m should == "1 !~(2)"
      )
    )
    
    
    describe("unary -", 
      it("should parse correctly for a simple case", 
        m = parse("-1")
        m should == "-(1)"
      )

      it("should parse correctly for a simple case with message s) after", 
        m = parse("-1 println")
        m should == "-(1) println"
      )

      it("should parse correctly for a simple case with message s) after and parenthesis", 
        m = parse("-(1) println")
        m should == "-(1) println"
      )
      
      it("should parse correctly for a larger number", 
        m = parse("-12342353453")
        m should == "-(12342353453)"
      )

      it("should parse correctly several times over", 
        m = parse("- -(1)")
        m should == "-(-(1))"
      )
    )
    
    describe("unary binary operators", 
      it("should work for a simple expression", 
        m = parse("map(*2)")
        m should == "map(*(2))"
      )

      it("should work for a more complicated expression", 
        m = parse("map(*4+5-13/3)")
        m should == "map(*(4) +(5) -(13 /(3)))"
      )
    )
    
    describe("-", 
      it("should be translated correctly in infix", 
        m = parse("2-1")
        m should == "2 -(1)"
      )

      it("should be translated correctly with parenthesis", 
        m = parse("2-(1)")
        m should == "2 -(1)"

        m = parse("2 -(1)")
        m should == "2 -(1)"
      )

      it("should be translated correctly with spaces", 
        m = parse("2 - 1")
        m should == "2 -(1)"
      )
    )

    describe("+", 
      it("should be translated correctly in infix", 
        m = parse("2+1")
        m should == "2 +(1)"
      )

      it("should be translated correctly with parenthesis", 
        m = parse("2+(1)")
        m should == "2 +(1)"

        m = parse("2 +(1)")
        m should == "2 +(1)"
      )

      it("should be translated correctly with spaces", 
        m = parse("2 + 1")
        m should == "2 +(1)"
      )

      it("should work correctly when given as an argument with newlines",
        m = parse("[1,2] fold(
+
)") should == "[](1, 2) fold(+)"
      )
    )

    describe("*", 
      it("should be translated correctly in infix", 
        m = parse("2*1")
        m should == "2 *(1)"
      )

      it("should be translated correctly with parenthesis", 
        m = parse("2*(1)")
        m should == "2 *(1)"

        m = parse("2 *(1)")
        m should == "2 *(1)"
      )

      it("should be translated correctly with spaces", 
        m = parse("2 * 1")
        m should == "2 *(1)"
      )
    )

    describe("**", 
      it("should be translated correctly in infix", 
        m = parse("2**1")
        m should == "2 **(1)"
      )

      it("should be translated correctly with parenthesis", 
        m = parse("2**(1)")
        m should == "2 **(1)"

        m = parse("2 **(1)")
        m should == "2 **(1)"
      )

      it("should be translated correctly with spaces", 
        m = parse("2 ** 1")
        m should == "2 **(1)"
      )
    )

    describe("/", 
      it("should be translated correctly in infix", 
        m = parse("2/1")
        m should == "2 /(1)"
      )

      it("should be translated correctly with parenthesis", 
        m = parse("2/(1)")
        m should == "2 /(1)"

        m = parse("2 /(1)")
        m should == "2 /(1)"
      )

      it("should be translated correctly with spaces", 
        m = parse("2 / 1")
        m should == "2 /(1)"
      )
    )
    
    describe("%", 
      it("should be translated correctly in infix", 
        m = parse("2%1")
        m should == "2 %(1)"
      )

      it("should be translated correctly with parenthesis", 
        m = parse("2%(1)")
        m should == "2 %(1)"

        m = parse("2 %(1)")
        m should == "2 %(1)"
      )

      it("should be translated correctly with spaces", 
        m = parse("2 % 1")
        m should == "2 %(1)"
      )
    )

    
    describe("=>", 
      it("should be correctly translated in infix", 
        m = parse("2=>1")
        m should == "2 =>(1)"

        m = parse("\"foo\"=>\"bar\"")
        m should == "\"foo\" =>(\"bar\")"
      )

      it("should be translated correctly with parenthesis", 
        m = parse("2=>(1)")
        m should == "2 =>(1)"

        m = parse("2 =>(1)")
        m should == "2 =>(1)"

        m = parse("\"foo\"=>(\"bar\")")
        m should == "\"foo\" =>(\"bar\")"

        m = parse("\"foo\" =>(\"bar\")")
        m should == "\"foo\" =>(\"bar\")"
      )

      it("should be translated correctly with spaces", 
        m = parse("2 => 1")
        m should == "2 =>(1)"

        m = parse("\"foo\" => \"bar\"")
        m should == "\"foo\" =>(\"bar\")"
      )

      it("should be translated correctly when chained", 
        m = parse("2 => 1 => 0")
        m should == "2 =>(1) =>(0)"

        m = parse("\"foo\" => \"bar\" => \"quux\"")
        m should == "\"foo\" =>(\"bar\") =>(\"quux\")"
      )
    )

    describe("..", 
      it("should be correctly translated in infix", 
        m = parse("2..1")
        m should == "2 ..(1)"

        m = parse("\"foo\"..\"bar\"")
        m should == "\"foo\" ..(\"bar\")"
      )

      it("should be translated correctly with parenthesis", 
        m = parse("2..(1)")
        m should == "2 ..(1)"

        m = parse("2 ..(1)")
        m should == "2 ..(1)"

        m = parse("\"foo\"..(\"bar\")")
        m should == "\"foo\" ..(\"bar\")"

        m = parse("\"foo\" ..(\"bar\")")
        m should == "\"foo\" ..(\"bar\")"
      )

      it("should be translated correctly with spaces", 
        m = parse("2 .. 1")
        m should == "2 ..(1)"

        m = parse("\"foo\" .. \"bar\"")
        m should == "\"foo\" ..(\"bar\")"
      )

      it("should be translated correctly when chained", 
        m = parse("2 .. 1 .. 0")
        m should == "2 ..(1) ..(0)"

        m = parse("\"foo\" .. \"bar\" .. \"quux\"")
        m should == "\"foo\" ..(\"bar\") ..(\"quux\")"
      )
    )

    describe("...", 
      it("should be correctly translated in infix", 
        m = parse("2...1")
        m should == "2 ...(1)"

        m = parse("\"foo\"...\"bar\"")
        m should == "\"foo\" ...(\"bar\")"
      )

      it("should be translated correctly with parenthesis", 
        m = parse("2...(1)")
        m should == "2 ...(1)"

        m = parse("2 ...(1)")
        m should == "2 ...(1)"

        m = parse("\"foo\"...(\"bar\")")
        m should == "\"foo\" ...(\"bar\")"

        m = parse("\"foo\" ...(\"bar\")")
        m should == "\"foo\" ...(\"bar\")"
      )

      it("should be translated correctly with spaces", 
        m = parse("2 ... 1")
        m should == "2 ...(1)"

        m = parse("\"foo\" ... \"bar\"")
        m should == "\"foo\" ...(\"bar\")"
      )

      it("should be translated correctly when chained", 
        m = parse("2 ... 1 ... 0")
        m should == "2 ...(1) ...(0)"

        m = parse("\"foo\" ... \"bar\" ... \"quux\"")
        m should == "\"foo\" ...(\"bar\") ...(\"quux\")"
      )
    )

    describe("<<", 
      it("should be correctly translated in infix", 
        m = parse("2<<1")
        m should == "2 <<(1)"

        m = parse("\"foo\"<<\"bar\"")
        m should == "\"foo\" <<(\"bar\")"
      )

      it("should be translated correctly with parenthesis", 
        m = parse("2<<(1)")
        m should == "2 <<(1)"

        m = parse("2 <<(1)")
        m should == "2 <<(1)"

        m = parse("\"foo\"<<(\"bar\")")
        m should == "\"foo\" <<(\"bar\")"

        m = parse("\"foo\" <<(\"bar\")")
        m should == "\"foo\" <<(\"bar\")"
      )

      it("should be translated correctly with spaces", 
        m = parse("2 << 1")
        m should == "2 <<(1)"

        m = parse("\"foo\" << \"bar\"")
        m should == "\"foo\" <<(\"bar\")"
      )

      it("should be translated correctly when chained", 
        m = parse("2 << 1 << 0")
        m should == "2 <<(1) <<(0)"

        m = parse("\"foo\" << \"bar\" << \"quux\"")
        m should == "\"foo\" <<(\"bar\") <<(\"quux\")"
      )
    )

    
    describe(">>", 
      it("should be correctly translated in infix", 
        m = parse("2>>1")
        m should == "2 >>(1)"

        m = parse("\"foo\">>\"bar\"")
        m should == "\"foo\" >>(\"bar\")"
      )

      it("should be translated correctly with parenthesis", 
        m = parse("2>>(1)")
        m should == "2 >>(1)"

        m = parse("2 >>(1)")
        m should == "2 >>(1)"

        m = parse("\"foo\">>(\"bar\")")
        m should == "\"foo\" >>(\"bar\")"

        m = parse("\"foo\" >>(\"bar\")")
        m should == "\"foo\" >>(\"bar\")"
      )

      it("should be translated correctly with spaces", 
        m = parse("2 >> 1")
        m should == "2 >>(1)"

        m = parse("\"foo\" >> \"bar\"")
        m should == "\"foo\" >>(\"bar\")"
      )

      it("should be translated correctly when chained", 
        m = parse("2 >> 1 >> 0")
        m should == "2 >>(1) >>(0)"

        m = parse("\"foo\" >> \"bar\" >> \"quux\"")
        m should == "\"foo\" >>(\"bar\") >>(\"quux\")"
      )
    )
    
    describe("&", 
      it("should be correctly translated in infix", 
        m = parse("2&1")
        m should == "2 &(1)"

        m = parse("\"foo\"&\"bar\"")
        m should == "\"foo\" &(\"bar\")"
      )

      it("should be translated correctly with parenthesis", 
        m = parse("2&(1)")
        m should == "2 &(1)"

        m = parse("2 &(1)")
        m should == "2 &(1)"

        m = parse("\"foo\"&(\"bar\")")
        m should == "\"foo\" &(\"bar\")"

        m = parse("\"foo\" &(\"bar\")")
        m should == "\"foo\" &(\"bar\")"
      )

      it("should be translated correctly with spaces", 
        m = parse("2 & 1")
        m should == "2 &(1)"

        m = parse("\"foo\" & \"bar\"")
        m should == "\"foo\" &(\"bar\")"
      )

      it("should be translated correctly when chained", 
        m = parse("2 & 1 & 0")
        m should == "2 &(1) &(0)"

        m = parse("\"foo\" & \"bar\" & \"quux\"")
        m should == "\"foo\" &(\"bar\") &(\"quux\")"
      )
    )

    describe("|", 
      it("should be correctly translated in infix", 
        m = parse("2|1")
        m should == "2 |(1)"

        m = parse("\"foo\"|\"bar\"")
        m should == "\"foo\" |(\"bar\")"
      )

      it("should be translated correctly with parenthesis", 
        m = parse("2|(1)")
        m should == "2 |(1)"

        m = parse("2 |(1)")
        m should == "2 |(1)"

        m = parse("\"foo\"|(\"bar\")")
        m should == "\"foo\" |(\"bar\")"

        m = parse("\"foo\" |(\"bar\")")
        m should == "\"foo\" |(\"bar\")"
      )

      it("should be translated correctly with spaces", 
        m = parse("2 | 1")
        m should == "2 |(1)"

        m = parse("\"foo\" | \"bar\"")
        m should == "\"foo\" |(\"bar\")"
      )

      it("should be translated correctly when chained", 
        m = parse("2 | 1 | 0")
        m should == "2 |(1) |(0)"

        m = parse("\"foo\" | \"bar\" | \"quux\"")
        m should == "\"foo\" |(\"bar\") |(\"quux\")"
      )
    )

    describe("^", 
      it("should be correctly translated in infix", 
        m = parse("2^1")
        m should == "2 ^(1)"

        m = parse("\"foo\"^\"bar\"")
        m should == "\"foo\" ^(\"bar\")"
      )

      it("should be translated correctly with parenthesis", 
        m = parse("2^(1)")
        m should == "2 ^(1)"

        m = parse("2 ^(1)")
        m should == "2 ^(1)"

        m = parse("\"foo\"^(\"bar\")")
        m should == "\"foo\" ^(\"bar\")"

        m = parse("\"foo\" ^(\"bar\")")
        m should == "\"foo\" ^(\"bar\")"
      )

      it("should be translated correctly with spaces", 
        m = parse("2 ^ 1")
        m should == "2 ^(1)"

        m = parse("\"foo\" ^ \"bar\"")
        m should == "\"foo\" ^(\"bar\")"
      )

      it("should be translated correctly when chained", 
        m = parse("2 ^ 1 ^ 0")
        m should == "2 ^(1) ^(0)"

        m = parse("\"foo\" ^ \"bar\" ^ \"quux\"")
        m should == "\"foo\" ^(\"bar\") ^(\"quux\")"
      )
    )

    describe("&&", 
      it("should be correctly translated in infix", 
        m = parse("2&&1")
        m should == "2 &&(1)"

        m = parse("\"foo\"&&\"bar\"")
        m should == "\"foo\" &&(\"bar\")"
      )

      it("should be translated correctly with parenthesis", 
        m = parse("2&&(1)")
        m should == "2 &&(1)"

        m = parse("2 &&(1)")
        m should == "2 &&(1)"

        m = parse("\"foo\"&&(\"bar\")")
        m should == "\"foo\" &&(\"bar\")"

        m = parse("\"foo\" &&(\"bar\")")
        m should == "\"foo\" &&(\"bar\")"
      )

      it("should be translated correctly with spaces", 
        m = parse("2 && 1")
        m should == "2 &&(1)"

        m = parse("\"foo\" && \"bar\"")
        m should == "\"foo\" &&(\"bar\")"
      )

      it("should be translated correctly when chained", 
        m = parse("2 && 1 && 0")
        m should == "2 &&(1) &&(0)"

        m = parse("\"foo\" && \"bar\" && \"quux\"")
        m should == "\"foo\" &&(\"bar\") &&(\"quux\")"
      )
    )

    describe("||", 
      it("should be correctly translated in infix", 
        m = parse("2||1")
        m should == "2 ||(1)"

        m = parse("\"foo\"||\"bar\"")
        m should == "\"foo\" ||(\"bar\")"
      )

      it("should be translated correctly with parenthesis", 
        m = parse("2||(1)")
        m should == "2 ||(1)"

        m = parse("2 ||(1)")
        m should == "2 ||(1)"

        m = parse("\"foo\"||(\"bar\")")
        m should == "\"foo\" ||(\"bar\")"

        m = parse("\"foo\" ||(\"bar\")")
        m should == "\"foo\" ||(\"bar\")"
      )

      it("should be translated correctly with spaces", 
        m = parse("2 || 1")
        m should == "2 ||(1)"

        m = parse("\"foo\" || \"bar\"")
        m should == "\"foo\" ||(\"bar\")"
      )

      it("should be translated correctly when chained", 
        m = parse("2 || 1 || 0")
        m should == "2 ||(1) ||(0)"

        m = parse("\"foo\" || \"bar\" || \"quux\"")
        m should == "\"foo\" ||(\"bar\") ||(\"quux\")"
      )
    )

    describe("?&", 
      it("should be correctly translated in infix", 
        m = parse("2?&1")
        m should == "2 ?&(1)"

        m = parse("\"foo\"?&\"bar\"")
        m should == "\"foo\" ?&(\"bar\")"
      )

      it("should be translated correctly with parenthesis", 
        m = parse("2?&(1)")
        m should == "2 ?&(1)"

        m = parse("2 ?&(1)")
        m should == "2 ?&(1)"

        m = parse("\"foo\"?&(\"bar\")")
        m should == "\"foo\" ?&(\"bar\")"

        m = parse("\"foo\" ?&(\"bar\")")
        m should == "\"foo\" ?&(\"bar\")"
      )

      it("should be translated correctly with spaces", 
        m = parse("2 ?& 1")
        m should == "2 ?&(1)"

        m = parse("\"foo\" ?& \"bar\"")
        m should == "\"foo\" ?&(\"bar\")"
      )

      it("should be translated correctly when chained", 
        m = parse("2 ?& 1 ?& 0")
        m should == "2 ?&(1) ?&(0)"

        m = parse("\"foo\" ?& \"bar\" ?& \"quux\"")
        m should == "\"foo\" ?&(\"bar\") ?&(\"quux\")"
      )
    )

    describe("?|", 
      it("should be correctly translated in infix", 
        m = parse("2?|1")
        m should == "2 ?|(1)"

        m = parse("\"foo\"?|\"bar\"")
        m should == "\"foo\" ?|(\"bar\")"
      )

      it("should be translated correctly with parenthesis", 
        m = parse("2?|(1)")
        m should == "2 ?|(1)"

        m = parse("2 ?|(1)")
        m should == "2 ?|(1)"

        m = parse("\"foo\"?|(\"bar\")")
        m should == "\"foo\" ?|(\"bar\")"

        m = parse("\"foo\" ?|(\"bar\")")
        m should == "\"foo\" ?|(\"bar\")"
      )

      it("should be translated correctly with spaces", 
        m = parse("2 ?| 1")
        m should == "2 ?|(1)"

        m = parse("\"foo\" ?| \"bar\"")
        m should == "\"foo\" ?|(\"bar\")"
      )

      it("should be translated correctly when chained", 
        m = parse("2 ?| 1 ?| 0")
        m should == "2 ?|(1) ?|(0)"

        m = parse("\"foo\" ?| \"bar\" ?| \"quux\"")
        m should == "\"foo\" ?|(\"bar\") ?|(\"quux\")"
      )
    )

    describe("or", 
      it("should be translated correctly with parenthesis", 
        m = parse("2 or(1)")
        m should == "2 or(1)"

        m = parse("\"foo\" or(\"bar\")")
        m should == "\"foo\" or(\"bar\")"
      )

      it("should be translated correctly with spaces", 
        m = parse("2 or 1")
        m should == "2 or(1)"

        m = parse("\"foo\" or \"bar\"")
        m should == "\"foo\" or(\"bar\")"
      )

      it("should be translated correctly when chained", 
        m = parse("2 or 1 or 0")
        m should == "2 or(1) or(0)"

        m = parse("\"foo\" or \"bar\" or \"quux\"")
        m should == "\"foo\" or(\"bar\") or(\"quux\")"
      )
    )

    describe("and", 
      it("should be translated correctly with parenthesis", 
        m = parse("2 and(1)")
        m should == "2 and(1)"

        m = parse("\"foo\" and(\"bar\")")
        m should == "\"foo\" and(\"bar\")"
      )

      it("should be translated correctly with spaces", 
        m = parse("2 and 1")
        m should == "2 and(1)"

        m = parse("\"foo\" and \"bar\"")
        m should == "\"foo\" and(\"bar\")"
      )

      it("should be translated correctly when chained", 
        m = parse("2 and 1 and 0")
        m should == "2 and(1) and(0)"

        m = parse("\"foo\" and \"bar\" and \"quux\"")
        m should == "\"foo\" and(\"bar\") and(\"quux\")"
      )
    )

    describe("!", 
      it("should work in a simple unary position", 
        m = parse("!false")
        m should == "!(false)"
      )

      it("should work in a simple unary position with space", 
        m = parse("! false")
        m should == "!(false)"
      )

      it("should work with parenthesis", 
        m = parse("!(false)")
        m should == "!(false)"
      )

      it("should work in an expression", 
        m = parse("true && !false")
        m should == "true &&(!(false))"
      )
    )

    describe("~", 
      it("should work in a simple unary position", 
        m = parse("~false")
        m should == "~(false)"
      )

      it("should work in a simple unary position with space", 
        m = parse("~ false")
        m should == "~(false)"
      )

      it("should work with parenthesis", 
        m = parse("~(false)")
        m should == "~(false)"
      )

      it("should work in an expression", 
        m = parse("true && ~false")
        m should == "true &&(~(false))"
      )

      it("should work as a binary operator", 
        m = parse("true ~ false")
        m should == "true ~(false)"
      )
    )

    describe("$", 
      it("should work in a simple unary position", 
        m = parse("$false")
        m should == "$(false)"
      )

      it("should work in a simple unary position with space", 
        m = parse("$ false")
        m should == "$(false)"
      )

      it("should work with parenthesis", 
        m = parse("$(false)")
        m should == "$(false)"
      )

      it("should work in an expression", 
        m = parse("true && $false")
        m should == "true &&($(false))"
      )

      it("should work as a binary operator", 
        m = parse("true $ false")
        m should == "true $(false)"
      )
    )

    describe("->", 
      it("should be correctly translated in infix", 
        m = parse("2->1")
        m should == "2 ->(1)"

        m = parse("\"foo\"->\"bar\"")
        m should == "\"foo\" ->(\"bar\")"
      )

      it("should be translated correctly with parenthesis", 
        m = parse("2->(1)")
        m should == "2 ->(1)"

        m = parse("2 ->(1)")
        m should == "2 ->(1)"

        m = parse("\"foo\"->(\"bar\")")
        m should == "\"foo\" ->(\"bar\")"

        m = parse("\"foo\" ->(\"bar\")")
        m should == "\"foo\" ->(\"bar\")"
      )

      it("should be translated correctly with spaces", 
        m = parse("2 -> 1")
        m should == "2 ->(1)"

        m = parse("\"foo\" -> \"bar\"")
        m should == "\"foo\" ->(\"bar\")"
      )

      it("should be translated correctly when chained", 
        m = parse("2 -> 1 -> 0")
        m should == "2 ->(1) ->(0)"

        m = parse("\"foo\" -> \"bar\" -> \"quux\"")
        m should == "\"foo\" ->(\"bar\") ->(\"quux\")"
      )
    )

    describe("+>", 
      it("should be correctly translated in infix", 
        m = parse("2+>1")
        m should == "2 +>(1)"

        m = parse("\"foo\"+>\"bar\"")
        m should == "\"foo\" +>(\"bar\")"
      )

      it("should be translated correctly with parenthesis", 
        m = parse("2+>(1)")
        m should == "2 +>(1)"

        m = parse("2 +>(1)")
        m should == "2 +>(1)"

        m = parse("\"foo\"+>(\"bar\")")
        m should == "\"foo\" +>(\"bar\")"

        m = parse("\"foo\" +>(\"bar\")")
        m should == "\"foo\" +>(\"bar\")"
      )

      it("should be translated correctly with spaces", 
        m = parse("2 +> 1")
        m should == "2 +>(1)"

        m = parse("\"foo\" +> \"bar\"")
        m should == "\"foo\" +>(\"bar\")"
      )

      it("should be translated correctly when chained", 
        m = parse("2 +> 1 +> 0")
        m should == "2 +>(1) +>(0)"

        m = parse("\"foo\" +> \"bar\" +> \"quux\"")
        m should == "\"foo\" +>(\"bar\") +>(\"quux\")"
      )
    )
    
    describe("!>", 
      it("should be correctly translated in infix", 
        m = parse("2!>1")
        m should == "2 !>(1)"

        m = parse("\"foo\"!>\"bar\"")
        m should == "\"foo\" !>(\"bar\")"
      )

      it("should be translated correctly with parenthesis", 
        m = parse("2!>(1)")
        m should == "2 !>(1)"

        m = parse("2 !>(1)")
        m should == "2 !>(1)"

        m = parse("\"foo\"!>(\"bar\")")
        m should == "\"foo\" !>(\"bar\")"

        m = parse("\"foo\" !>(\"bar\")")
        m should == "\"foo\" !>(\"bar\")"
      )

      it("should be translated correctly with spaces", 
        m = parse("2 !> 1")
        m should == "2 !>(1)"

        m = parse("\"foo\" !> \"bar\"")
        m should == "\"foo\" !>(\"bar\")"
      )

      it("should be translated correctly when chained", 
        m = parse("2 !> 1 !> 0")
        m should == "2 !>(1) !>(0)"

        m = parse("\"foo\" !> \"bar\" !> \"quux\"")
        m should == "\"foo\" !>(\"bar\") !>(\"quux\")"
      )
    )

    describe("<>", 
      it("should be correctly translated in infix", 
        m = parse("2<>1")
        m should == "2 <>(1)"

        m = parse("\"foo\"<>\"bar\"")
        m should == "\"foo\" <>(\"bar\")"
      )

      it("should be translated correctly with parenthesis", 
        m = parse("2<>(1)")
        m should == "2 <>(1)"

        m = parse("2 <>(1)")
        m should == "2 <>(1)"

        m = parse("\"foo\"<>(\"bar\")")
        m should == "\"foo\" <>(\"bar\")"

        m = parse("\"foo\" <>(\"bar\")")
        m should == "\"foo\" <>(\"bar\")"
      )

      it("should be translated correctly with spaces", 
        m = parse("2 <> 1")
        m should == "2 <>(1)"

        m = parse("\"foo\" <> \"bar\"")
        m should == "\"foo\" <>(\"bar\")"
      )

      it("should be translated correctly when chained", 
        m = parse("2 <> 1 <> 0")
        m should == "2 <>(1) <>(0)"

        m = parse("\"foo\" <> \"bar\" <> \"quux\"")
        m should == "\"foo\" <>(\"bar\") <>(\"quux\")"
      )
    )
    
    describe("&>", 
      it("should be correctly translated in infix", 
        m = parse("2&>1")
        m should == "2 &>(1)"

        m = parse("\"foo\"&>\"bar\"")
        m should == "\"foo\" &>(\"bar\")"
      )

      it("should be translated correctly with parenthesis", 
        m = parse("2&>(1)")
        m should == "2 &>(1)"

        m = parse("2 &>(1)")
        m should == "2 &>(1)"

        m = parse("\"foo\"&>(\"bar\")")
        m should == "\"foo\" &>(\"bar\")"

        m = parse("\"foo\" &>(\"bar\")")
        m should == "\"foo\" &>(\"bar\")"
      )

      it("should be translated correctly with spaces", 
        m = parse("2 &> 1")
        m should == "2 &>(1)"

        m = parse("\"foo\" &> \"bar\"")
        m should == "\"foo\" &>(\"bar\")"
      )

      it("should be translated correctly when chained", 
        m = parse("2 &> 1 &> 0")
        m should == "2 &>(1) &>(0)"

        m = parse("\"foo\" &> \"bar\" &> \"quux\"")
        m should == "\"foo\" &>(\"bar\") &>(\"quux\")"
      )
    )
    

    describe("%>", 
      it("should be correctly translated in infix", 
        m = parse("2%>1")
        m should == "2 %>(1)"

        m = parse("\"foo\"%>\"bar\"")
        m should == "\"foo\" %>(\"bar\")"
      )

      it("should be translated correctly with parenthesis", 
        m = parse("2%>(1)")
        m should == "2 %>(1)"

        m = parse("2 %>(1)")
        m should == "2 %>(1)"

        m = parse("\"foo\"%>(\"bar\")")
        m should == "\"foo\" %>(\"bar\")"

        m = parse("\"foo\" %>(\"bar\")")
        m should == "\"foo\" %>(\"bar\")"
      )

      it("should be translated correctly with spaces", 
        m = parse("2 %> 1")
        m should == "2 %>(1)"

        m = parse("\"foo\" %> \"bar\"")
        m should == "\"foo\" %>(\"bar\")"
      )

      it("should be translated correctly when chained", 
        m = parse("2 %> 1 %> 0")
        m should == "2 %>(1) %>(0)"

        m = parse("\"foo\" %> \"bar\" %> \"quux\"")
        m should == "\"foo\" %>(\"bar\") %>(\"quux\")"
      )
    )
    
    describe("#>", 
      it("should be correctly translated in infix", 
        m = parse("2#>1")
        m should == "2 #>(1)"

        m = parse("\"foo\"#>\"bar\"")
        m should == "\"foo\" #>(\"bar\")"
      )

      it("should be translated correctly with parenthesis", 
        m = parse("2#>(1)")
        m should == "2 #>(1)"

        m = parse("2 #>(1)")
        m should == "2 #>(1)"

        m = parse("\"foo\"#>(\"bar\")")
        m should == "\"foo\" #>(\"bar\")"

        m = parse("\"foo\" #>(\"bar\")")
        m should == "\"foo\" #>(\"bar\")"
      )

      it("should be translated correctly with spaces", 
        m = parse("2 #> 1")
        m should == "2 #>(1)"

        m = parse("\"foo\" #> \"bar\"")
        m should == "\"foo\" #>(\"bar\")"
      )

      it("should be translated correctly when chained", 
        m = parse("2 #> 1 #> 0")
        m should == "2 #>(1) #>(0)"

        m = parse("\"foo\" #> \"bar\" #> \"quux\"")
        m should == "\"foo\" #>(\"bar\") #>(\"quux\")"
      )
    )

    describe("@>", 
      it("should be correctly translated in infix", 
        m = parse("2@>1")
        m should == "2 @>(1)"

        m = parse("\"foo\"@>\"bar\"")
        m should == "\"foo\" @>(\"bar\")"
      )

      it("should be translated correctly with parenthesis", 
        m = parse("2@>(1)")
        m should == "2 @>(1)"

        m = parse("2 @>(1)")
        m should == "2 @>(1)"

        m = parse("\"foo\"@>(\"bar\")")
        m should == "\"foo\" @>(\"bar\")"

        m = parse("\"foo\" @>(\"bar\")")
        m should == "\"foo\" @>(\"bar\")"
      )

      it("should be translated correctly with spaces", 
        m = parse("2 @> 1")
        m should == "2 @>(1)"

        m = parse("\"foo\" @> \"bar\"")
        m should == "\"foo\" @>(\"bar\")"
      )

      it("should be translated correctly when chained", 
        m = parse("2 @> 1 @> 0")
        m should == "2 @>(1) @>(0)"

        m = parse("\"foo\" @> \"bar\" @> \"quux\"")
        m should == "\"foo\" @>(\"bar\") @>(\"quux\")"
      )
    )
    
    describe("/>", 
      it("should be correctly translated in infix", 
        m = parse("2/>1")
        m should == "2 />(1)"

        m = parse("\"foo\"/>\"bar\"")
        m should == "\"foo\" />(\"bar\")"
      )

      it("should be translated correctly with parenthesis", 
        m = parse("2/>(1)")
        m should == "2 />(1)"

        m = parse("2 />(1)")
        m should == "2 />(1)"

        m = parse("\"foo\"/>(\"bar\")")
        m should == "\"foo\" />(\"bar\")"

        m = parse("\"foo\" />(\"bar\")")
        m should == "\"foo\" />(\"bar\")"
      )

      it("should be translated correctly with spaces", 
        m = parse("2 /> 1")
        m should == "2 />(1)"

        m = parse("\"foo\" /> \"bar\"")
        m should == "\"foo\" />(\"bar\")"
      )

      it("should be translated correctly when chained", 
        m = parse("2 /> 1 /> 0")
        m should == "2 />(1) />(0)"

        m = parse("\"foo\" /> \"bar\" /> \"quux\"")
        m should == "\"foo\" />(\"bar\") />(\"quux\")"
      )
    )

    describe("*>", 
      it("should be correctly translated in infix", 
        m = parse("2*>1")
        m should == "2 *>(1)"

        m = parse("\"foo\"*>\"bar\"")
        m should == "\"foo\" *>(\"bar\")"
      )

      it("should be translated correctly with parenthesis", 
        m = parse("2*>(1)")
        m should == "2 *>(1)"

        m = parse("2 *>(1)")
        m should == "2 *>(1)"

        m = parse("\"foo\"*>(\"bar\")")
        m should == "\"foo\" *>(\"bar\")"

        m = parse("\"foo\" *>(\"bar\")")
        m should == "\"foo\" *>(\"bar\")"
      )

      it("should be translated correctly with spaces", 
        m = parse("2 *> 1")
        m should == "2 *>(1)"

        m = parse("\"foo\" *> \"bar\"")
        m should == "\"foo\" *>(\"bar\")"
      )

      it("should be translated correctly when chained", 
        m = parse("2 *> 1 *> 0")
        m should == "2 *>(1) *>(0)"

        m = parse("\"foo\" *> \"bar\" *> \"quux\"")
        m should == "\"foo\" *>(\"bar\") *>(\"quux\")"
      )
    )

    
    describe("?>", 
      it("should be correctly translated in infix", 
        m = parse("2?>1")
        m should == "2 ?>(1)"

        m = parse("\"foo\"?>\"bar\"")
        m should == "\"foo\" ?>(\"bar\")"
      )

      it("should be translated correctly with parenthesis", 
        m = parse("2?>(1)")
        m should == "2 ?>(1)"

        m = parse("2 ?>(1)")
        m should == "2 ?>(1)"

        m = parse("\"foo\"?>(\"bar\")")
        m should == "\"foo\" ?>(\"bar\")"

        m = parse("\"foo\" ?>(\"bar\")")
        m should == "\"foo\" ?>(\"bar\")"
      )

      it("should be translated correctly with spaces", 
        m = parse("2 ?> 1")
        m should == "2 ?>(1)"

        m = parse("\"foo\" ?> \"bar\"")
        m should == "\"foo\" ?>(\"bar\")"
      )

      it("should be translated correctly when chained", 
        m = parse("2 ?> 1 ?> 0")
        m should == "2 ?>(1) ?>(0)"

        m = parse("\"foo\" ?> \"bar\" ?> \"quux\"")
        m should == "\"foo\" ?>(\"bar\") ?>(\"quux\")"
      )
    )

    describe("|>", 
      it("should be correctly translated in infix", 
        m = parse("2|>1")
        m should == "2 |>(1)"

        m = parse("\"foo\"|>\"bar\"")
        m should == "\"foo\" |>(\"bar\")"
      )

      it("should be translated correctly with parenthesis", 
        m = parse("2|>(1)")
        m should == "2 |>(1)"

        m = parse("2 |>(1)")
        m should == "2 |>(1)"

        m = parse("\"foo\"|>(\"bar\")")
        m should == "\"foo\" |>(\"bar\")"

        m = parse("\"foo\" |>(\"bar\")")
        m should == "\"foo\" |>(\"bar\")"
      )

      it("should be translated correctly with spaces", 
        m = parse("2 |> 1")
        m should == "2 |>(1)"

        m = parse("\"foo\" |> \"bar\"")
        m should == "\"foo\" |>(\"bar\")"
      )

      it("should be translated correctly when chained", 
        m = parse("2 |> 1 |> 0")
        m should == "2 |>(1) |>(0)"

        m = parse("\"foo\" |> \"bar\" |> \"quux\"")
        m should == "\"foo\" |>(\"bar\") |>(\"quux\")"
      )
    )

    describe("^>", 
      it("should be correctly translated in infix", 
        m = parse("2^>1")
        m should == "2 ^>(1)"

        m = parse("\"foo\"^>\"bar\"")
        m should == "\"foo\" ^>(\"bar\")"
      )

      it("should be translated correctly with parenthesis", 
        m = parse("2^>(1)")
        m should == "2 ^>(1)"

        m = parse("2 ^>(1)")
        m should == "2 ^>(1)"

        m = parse("\"foo\"^>(\"bar\")")
        m should == "\"foo\" ^>(\"bar\")"

        m = parse("\"foo\" ^>(\"bar\")")
        m should == "\"foo\" ^>(\"bar\")"
      )

      it("should be translated correctly with spaces", 
        m = parse("2 ^> 1")
        m should == "2 ^>(1)"

        m = parse("\"foo\" ^> \"bar\"")
        m should == "\"foo\" ^>(\"bar\")"
      )

      it("should be translated correctly when chained", 
        m = parse("2 ^> 1 ^> 0")
        m should == "2 ^>(1) ^>(0)"

        m = parse("\"foo\" ^> \"bar\" ^> \"quux\"")
        m should == "\"foo\" ^>(\"bar\") ^>(\"quux\")"
      )
    )

    describe("~>", 
      it("should be correctly translated in infix", 
        m = parse("2~>1")
        m should == "2 ~>(1)"

        m = parse("\"foo\"~>\"bar\"")
        m should == "\"foo\" ~>(\"bar\")"
      )

      it("should be translated correctly with parenthesis", 
        m = parse("2~>(1)")
        m should == "2 ~>(1)"

        m = parse("2 ~>(1)")
        m should == "2 ~>(1)"

        m = parse("\"foo\"~>(\"bar\")")
        m should == "\"foo\" ~>(\"bar\")"

        m = parse("\"foo\" ~>(\"bar\")")
        m should == "\"foo\" ~>(\"bar\")"
      )

      it("should be translated correctly with spaces", 
        m = parse("2 ~> 1")
        m should == "2 ~>(1)"

        m = parse("\"foo\" ~> \"bar\"")
        m should == "\"foo\" ~>(\"bar\")"
      )

      it("should be translated correctly when chained", 
        m = parse("2 ~> 1 ~> 0")
        m should == "2 ~>(1) ~>(0)"

        m = parse("\"foo\" ~> \"bar\" ~> \"quux\"")
        m should == "\"foo\" ~>(\"bar\") ~>(\"quux\")"
      )
    )

    describe("->>", 
      it("should be correctly translated in infix", 
        m = parse("2->>1")
        m should == "2 ->>(1)"

        m = parse("\"foo\"->>\"bar\"")
        m should == "\"foo\" ->>(\"bar\")"
      )

      it("should be translated correctly with parenthesis", 
        m = parse("2->>(1)")
        m should == "2 ->>(1)"

        m = parse("2 ->>(1)")
        m should == "2 ->>(1)"

        m = parse("\"foo\"->>(\"bar\")")
        m should == "\"foo\" ->>(\"bar\")"

        m = parse("\"foo\" ->>(\"bar\")")
        m should == "\"foo\" ->>(\"bar\")"
      )

      it("should be translated correctly with spaces", 
        m = parse("2 ->> 1")
        m should == "2 ->>(1)"

        m = parse("\"foo\" ->> \"bar\"")
        m should == "\"foo\" ->>(\"bar\")"
      )

      it("should be translated correctly when chained", 
        m = parse("2 ->> 1 ->> 0")
        m should == "2 ->>(1) ->>(0)"

        m = parse("\"foo\" ->> \"bar\" ->> \"quux\"")
        m should == "\"foo\" ->>(\"bar\") ->>(\"quux\")"
      )
    )

    describe("+>>", 
      it("should be correctly translated in infix", 
        m = parse("2+>>1")
        m should == "2 +>>(1)"

        m = parse("\"foo\"+>>\"bar\"")
        m should == "\"foo\" +>>(\"bar\")"
      )

      it("should be translated correctly with parenthesis", 
        m = parse("2+>>(1)")
        m should == "2 +>>(1)"

        m = parse("2 +>>(1)")
        m should == "2 +>>(1)"

        m = parse("\"foo\"+>>(\"bar\")")
        m should == "\"foo\" +>>(\"bar\")"

        m = parse("\"foo\" +>>(\"bar\")")
        m should == "\"foo\" +>>(\"bar\")"
      )

      it("should be translated correctly with spaces", 
        m = parse("2 +>> 1")
        m should == "2 +>>(1)"

        m = parse("\"foo\" +>> \"bar\"")
        m should == "\"foo\" +>>(\"bar\")"
      )

      it("should be translated correctly when chained", 
        m = parse("2 +>> 1 +>> 0")
        m should == "2 +>>(1) +>>(0)"

        m = parse("\"foo\" +>> \"bar\" +>> \"quux\"")
        m should == "\"foo\" +>>(\"bar\") +>>(\"quux\")"
      )
    )
    
    describe("!>>", 
      it("should be correctly translated in infix", 
        m = parse("2!>>1")
        m should == "2 !>>(1)"

        m = parse("\"foo\"!>>\"bar\"")
        m should == "\"foo\" !>>(\"bar\")"
      )

      it("should be translated correctly with parenthesis", 
        m = parse("2!>>(1)")
        m should == "2 !>>(1)"

        m = parse("2 !>>(1)")
        m should == "2 !>>(1)"

        m = parse("\"foo\"!>>(\"bar\")")
        m should == "\"foo\" !>>(\"bar\")"

        m = parse("\"foo\" !>>(\"bar\")")
        m should == "\"foo\" !>>(\"bar\")"
      )

      it("should be translated correctly with spaces", 
        m = parse("2 !>> 1")
        m should == "2 !>>(1)"

        m = parse("\"foo\" !>> \"bar\"")
        m should == "\"foo\" !>>(\"bar\")"
      )

      it("should be translated correctly when chained", 
        m = parse("2 !>> 1 !>> 0")
        m should == "2 !>>(1) !>>(0)"

        m = parse("\"foo\" !>> \"bar\" !>> \"quux\"")
        m should == "\"foo\" !>>(\"bar\") !>>(\"quux\")"
      )
    )

    describe("<>>", 
      it("should be correctly translated in infix", 
        m = parse("2<>>1")
        m should == "2 <>>(1)"

        m = parse("\"foo\"<>>\"bar\"")
        m should == "\"foo\" <>>(\"bar\")"
      )

      it("should be translated correctly with parenthesis", 
        m = parse("2<>>(1)")
        m should == "2 <>>(1)"

        m = parse("2 <>>(1)")
        m should == "2 <>>(1)"

        m = parse("\"foo\"<>>(\"bar\")")
        m should == "\"foo\" <>>(\"bar\")"

        m = parse("\"foo\" <>>(\"bar\")")
        m should == "\"foo\" <>>(\"bar\")"
      )

      it("should be translated correctly with spaces", 
        m = parse("2 <>> 1")
        m should == "2 <>>(1)"

        m = parse("\"foo\" <>> \"bar\"")
        m should == "\"foo\" <>>(\"bar\")"
      )

      it("should be translated correctly when chained", 
        m = parse("2 <>> 1 <>> 0")
        m should == "2 <>>(1) <>>(0)"

        m = parse("\"foo\" <>> \"bar\" <>> \"quux\"")
        m should == "\"foo\" <>>(\"bar\") <>>(\"quux\")"
      )
    )
    
    describe("&>>", 
      it("should be correctly translated in infix", 
        m = parse("2&>>1")
        m should == "2 &>>(1)"

        m = parse("\"foo\"&>>\"bar\"")
        m should == "\"foo\" &>>(\"bar\")"
      )

      it("should be translated correctly with parenthesis", 
        m = parse("2&>>(1)")
        m should == "2 &>>(1)"

        m = parse("2 &>>(1)")
        m should == "2 &>>(1)"

        m = parse("\"foo\"&>>(\"bar\")")
        m should == "\"foo\" &>>(\"bar\")"

        m = parse("\"foo\" &>>(\"bar\")")
        m should == "\"foo\" &>>(\"bar\")"
      )

      it("should be translated correctly with spaces", 
        m = parse("2 &>> 1")
        m should == "2 &>>(1)"

        m = parse("\"foo\" &>> \"bar\"")
        m should == "\"foo\" &>>(\"bar\")"
      )

      it("should be translated correctly when chained", 
        m = parse("2 &>> 1 &>> 0")
        m should == "2 &>>(1) &>>(0)"

        m = parse("\"foo\" &>> \"bar\" &>> \"quux\"")
        m should == "\"foo\" &>>(\"bar\") &>>(\"quux\")"
      )
    )
    

    describe("%>>", 
      it("should be correctly translated in infix", 
        m = parse("2%>>1")
        m should == "2 %>>(1)"

        m = parse("\"foo\"%>>\"bar\"")
        m should == "\"foo\" %>>(\"bar\")"
      )

      it("should be translated correctly with parenthesis", 
        m = parse("2%>>(1)")
        m should == "2 %>>(1)"

        m = parse("2 %>>(1)")
        m should == "2 %>>(1)"

        m = parse("\"foo\"%>>(\"bar\")")
        m should == "\"foo\" %>>(\"bar\")"

        m = parse("\"foo\" %>>(\"bar\")")
        m should == "\"foo\" %>>(\"bar\")"
      )

      it("should be translated correctly with spaces", 
        m = parse("2 %>> 1")
        m should == "2 %>>(1)"

        m = parse("\"foo\" %>> \"bar\"")
        m should == "\"foo\" %>>(\"bar\")"
      )

      it("should be translated correctly when chained", 
        m = parse("2 %>> 1 %>> 0")
        m should == "2 %>>(1) %>>(0)"

        m = parse("\"foo\" %>> \"bar\" %>> \"quux\"")
        m should == "\"foo\" %>>(\"bar\") %>>(\"quux\")"
      )
    )
    
    describe("#>>", 
      it("should be correctly translated in infix", 
        m = parse("2#>>1")
        m should == "2 #>>(1)"

        m = parse("\"foo\"#>>\"bar\"")
        m should == "\"foo\" #>>(\"bar\")"
      )

      it("should be translated correctly with parenthesis", 
        m = parse("2#>>(1)")
        m should == "2 #>>(1)"

        m = parse("2 #>>(1)")
        m should == "2 #>>(1)"

        m = parse("\"foo\"#>>(\"bar\")")
        m should == "\"foo\" #>>(\"bar\")"

        m = parse("\"foo\" #>>(\"bar\")")
        m should == "\"foo\" #>>(\"bar\")"
      )

      it("should be translated correctly with spaces", 
        m = parse("2 #>> 1")
        m should == "2 #>>(1)"

        m = parse("\"foo\" #>> \"bar\"")
        m should == "\"foo\" #>>(\"bar\")"
      )

      it("should be translated correctly when chained", 
        m = parse("2 #>> 1 #>> 0")
        m should == "2 #>>(1) #>>(0)"

        m = parse("\"foo\" #>> \"bar\" #>> \"quux\"")
        m should == "\"foo\" #>>(\"bar\") #>>(\"quux\")"
      )
    )

    describe("@>>", 
      it("should be correctly translated in infix", 
        m = parse("2@>>1")
        m should == "2 @>>(1)"

        m = parse("\"foo\"@>>\"bar\"")
        m should == "\"foo\" @>>(\"bar\")"
      )

      it("should be translated correctly with parenthesis", 
        m = parse("2@>>(1)")
        m should == "2 @>>(1)"

        m = parse("2 @>>(1)")
        m should == "2 @>>(1)"

        m = parse("\"foo\"@>>(\"bar\")")
        m should == "\"foo\" @>>(\"bar\")"

        m = parse("\"foo\" @>>(\"bar\")")
        m should == "\"foo\" @>>(\"bar\")"
      )

      it("should be translated correctly with spaces", 
        m = parse("2 @>> 1")
        m should == "2 @>>(1)"

        m = parse("\"foo\" @>> \"bar\"")
        m should == "\"foo\" @>>(\"bar\")"
      )

      it("should be translated correctly when chained", 
        m = parse("2 @>> 1 @>> 0")
        m should == "2 @>>(1) @>>(0)"

        m = parse("\"foo\" @>> \"bar\" @>> \"quux\"")
        m should == "\"foo\" @>>(\"bar\") @>>(\"quux\")"
      )
    )
    
    describe("/>>", 
      it("should be correctly translated in infix", 
        m = parse("2/>>1")
        m should == "2 />>(1)"

        m = parse("\"foo\"/>>\"bar\"")
        m should == "\"foo\" />>(\"bar\")"
      )

      it("should be translated correctly with parenthesis", 
        m = parse("2/>>(1)")
        m should == "2 />>(1)"

        m = parse("2 />>(1)")
        m should == "2 />>(1)"

        m = parse("\"foo\"/>>(\"bar\")")
        m should == "\"foo\" />>(\"bar\")"

        m = parse("\"foo\" />>(\"bar\")")
        m should == "\"foo\" />>(\"bar\")"
      )

      it("should be translated correctly with spaces", 
        m = parse("2 />> 1")
        m should == "2 />>(1)"

        m = parse("\"foo\" />> \"bar\"")
        m should == "\"foo\" />>(\"bar\")"
      )

      it("should be translated correctly when chained", 
        m = parse("2 />> 1 />> 0")
        m should == "2 />>(1) />>(0)"

        m = parse("\"foo\" />> \"bar\" />> \"quux\"")
        m should == "\"foo\" />>(\"bar\") />>(\"quux\")"
      )
    )

    describe("*>>", 
      it("should be correctly translated in infix", 
        m = parse("2*>>1")
        m should == "2 *>>(1)"

        m = parse("\"foo\"*>>\"bar\"")
        m should == "\"foo\" *>>(\"bar\")"
      )

      it("should be translated correctly with parenthesis", 
        m = parse("2*>>(1)")
        m should == "2 *>>(1)"

        m = parse("2 *>>(1)")
        m should == "2 *>>(1)"

        m = parse("\"foo\"*>>(\"bar\")")
        m should == "\"foo\" *>>(\"bar\")"

        m = parse("\"foo\" *>>(\"bar\")")
        m should == "\"foo\" *>>(\"bar\")"
      )

      it("should be translated correctly with spaces", 
        m = parse("2 *>> 1")
        m should == "2 *>>(1)"

        m = parse("\"foo\" *>> \"bar\"")
        m should == "\"foo\" *>>(\"bar\")"
      )

      it("should be translated correctly when chained", 
        m = parse("2 *>> 1 *>> 0")
        m should == "2 *>>(1) *>>(0)"

        m = parse("\"foo\" *>> \"bar\" *>> \"quux\"")
        m should == "\"foo\" *>>(\"bar\") *>>(\"quux\")"
      )
    )

    
    describe("?>>", 
      it("should be correctly translated in infix", 
        m = parse("2?>>1")
        m should == "2 ?>>(1)"

        m = parse("\"foo\"?>>\"bar\"")
        m should == "\"foo\" ?>>(\"bar\")"
      )

      it("should be translated correctly with parenthesis", 
        m = parse("2?>>(1)")
        m should == "2 ?>>(1)"

        m = parse("2 ?>>(1)")
        m should == "2 ?>>(1)"

        m = parse("\"foo\"?>>(\"bar\")")
        m should == "\"foo\" ?>>(\"bar\")"

        m = parse("\"foo\" ?>>(\"bar\")")
        m should == "\"foo\" ?>>(\"bar\")"
      )

      it("should be translated correctly with spaces", 
        m = parse("2 ?>> 1")
        m should == "2 ?>>(1)"

        m = parse("\"foo\" ?>> \"bar\"")
        m should == "\"foo\" ?>>(\"bar\")"
      )

      it("should be translated correctly when chained", 
        m = parse("2 ?>> 1 ?>> 0")
        m should == "2 ?>>(1) ?>>(0)"

        m = parse("\"foo\" ?>> \"bar\" ?>> \"quux\"")
        m should == "\"foo\" ?>>(\"bar\") ?>>(\"quux\")"
      )
    )

    describe("|>>", 
      it("should be correctly translated in infix", 
        m = parse("2|>>1")
        m should == "2 |>>(1)"

        m = parse("\"foo\"|>>\"bar\"")
        m should == "\"foo\" |>>(\"bar\")"
      )

      it("should be translated correctly with parenthesis", 
        m = parse("2|>>(1)")
        m should == "2 |>>(1)"

        m = parse("2 |>>(1)")
        m should == "2 |>>(1)"

        m = parse("\"foo\"|>>(\"bar\")")
        m should == "\"foo\" |>>(\"bar\")"

        m = parse("\"foo\" |>>(\"bar\")")
        m should == "\"foo\" |>>(\"bar\")"
      )

      it("should be translated correctly with spaces", 
        m = parse("2 |>> 1")
        m should == "2 |>>(1)"

        m = parse("\"foo\" |>> \"bar\"")
        m should == "\"foo\" |>>(\"bar\")"
      )

      it("should be translated correctly when chained", 
        m = parse("2 |>> 1 |>> 0")
        m should == "2 |>>(1) |>>(0)"

        m = parse("\"foo\" |>> \"bar\" |>> \"quux\"")
        m should == "\"foo\" |>>(\"bar\") |>>(\"quux\")"
      )
    )

    describe("^>>", 
      it("should be correctly translated in infix", 
        m = parse("2^>>1")
        m should == "2 ^>>(1)"

        m = parse("\"foo\"^>>\"bar\"")
        m should == "\"foo\" ^>>(\"bar\")"
      )

      it("should be translated correctly with parenthesis", 
        m = parse("2^>>(1)")
        m should == "2 ^>>(1)"

        m = parse("2 ^>>(1)")
        m should == "2 ^>>(1)"

        m = parse("\"foo\"^>>(\"bar\")")
        m should == "\"foo\" ^>>(\"bar\")"

        m = parse("\"foo\" ^>>(\"bar\")")
        m should == "\"foo\" ^>>(\"bar\")"
      )

      it("should be translated correctly with spaces", 
        m = parse("2 ^>> 1")
        m should == "2 ^>>(1)"

        m = parse("\"foo\" ^>> \"bar\"")
        m should == "\"foo\" ^>>(\"bar\")"
      )

      it("should be translated correctly when chained", 
        m = parse("2 ^>> 1 ^>> 0")
        m should == "2 ^>>(1) ^>>(0)"

        m = parse("\"foo\" ^>> \"bar\" ^>> \"quux\"")
        m should == "\"foo\" ^>>(\"bar\") ^>>(\"quux\")"
      )
    )

    describe("~>>", 
      it("should be correctly translated in infix", 
        m = parse("2~>>1")
        m should == "2 ~>>(1)"

        m = parse("\"foo\"~>>\"bar\"")
        m should == "\"foo\" ~>>(\"bar\")"
      )

      it("should be translated correctly with parenthesis", 
        m = parse("2~>>(1)")
        m should == "2 ~>>(1)"

        m = parse("2 ~>>(1)")
        m should == "2 ~>>(1)"

        m = parse("\"foo\"~>>(\"bar\")")
        m should == "\"foo\" ~>>(\"bar\")"

        m = parse("\"foo\" ~>>(\"bar\")")
        m should == "\"foo\" ~>>(\"bar\")"
      )

      it("should be translated correctly with spaces", 
        m = parse("2 ~>> 1")
        m should == "2 ~>>(1)"

        m = parse("\"foo\" ~>> \"bar\"")
        m should == "\"foo\" ~>>(\"bar\")"
      )

      it("should be translated correctly when chained", 
        m = parse("2 ~>> 1 ~>> 0")
        m should == "2 ~>>(1) ~>>(0)"

        m = parse("\"foo\" ~>> \"bar\" ~>> \"quux\"")
        m should == "\"foo\" ~>>(\"bar\") ~>>(\"quux\")"
      )
    )

    describe("=>>", 
      it("should be correctly translated in infix", 
        m = parse("2=>>1")
        m should == "2 =>>(1)"

        m = parse("\"foo\"=>>\"bar\"")
        m should == "\"foo\" =>>(\"bar\")"
      )

      it("should be translated correctly with parenthesis", 
        m = parse("2=>>(1)")
        m should == "2 =>>(1)"

        m = parse("2 =>>(1)")
        m should == "2 =>>(1)"

        m = parse("\"foo\"=>>(\"bar\")")
        m should == "\"foo\" =>>(\"bar\")"

        m = parse("\"foo\" =>>(\"bar\")")
        m should == "\"foo\" =>>(\"bar\")"
      )

      it("should be translated correctly with spaces", 
        m = parse("2 =>> 1")
        m should == "2 =>>(1)"

        m = parse("\"foo\" =>> \"bar\"")
        m should == "\"foo\" =>>(\"bar\")"
      )

      it("should be translated correctly when chained", 
        m = parse("2 =>> 1 =>> 0")
        m should == "2 =>>(1) =>>(0)"

        m = parse("\"foo\" =>> \"bar\" =>> \"quux\"")
        m should == "\"foo\" =>>(\"bar\") =>>(\"quux\")"
      )
    )

    describe("**>", 
      it("should be correctly translated in infix", 
        m = parse("2**>1")
        m should == "2 **>(1)"

        m = parse("\"foo\"**>\"bar\"")
        m should == "\"foo\" **>(\"bar\")"
      )

      it("should be translated correctly with parenthesis", 
        m = parse("2**>(1)")
        m should == "2 **>(1)"

        m = parse("2 **>(1)")
        m should == "2 **>(1)"

        m = parse("\"foo\"**>(\"bar\")")
        m should == "\"foo\" **>(\"bar\")"

        m = parse("\"foo\" **>(\"bar\")")
        m should == "\"foo\" **>(\"bar\")"
      )

      it("should be translated correctly with spaces", 
        m = parse("2 **> 1")
        m should == "2 **>(1)"

        m = parse("\"foo\" **> \"bar\"")
        m should == "\"foo\" **>(\"bar\")"
      )

      it("should be translated correctly when chained", 
        m = parse("2 **> 1 **> 0")
        m should == "2 **>(1) **>(0)"

        m = parse("\"foo\" **> \"bar\" **> \"quux\"")
        m should == "\"foo\" **>(\"bar\") **>(\"quux\")"
      )
    )

    describe("**>>", 
      it("should be correctly translated in infix", 
        m = parse("2**>>1")
        m should == "2 **>>(1)"

        m = parse("\"foo\"**>>\"bar\"")
        m should == "\"foo\" **>>(\"bar\")"
      )

      it("should be translated correctly with parenthesis", 
        m = parse("2**>>(1)")
        m should == "2 **>>(1)"

        m = parse("2 **>>(1)")
        m should == "2 **>>(1)"

        m = parse("\"foo\"**>>(\"bar\")")
        m should == "\"foo\" **>>(\"bar\")"

        m = parse("\"foo\" **>>(\"bar\")")
        m should == "\"foo\" **>>(\"bar\")"
      )

      it("should be translated correctly with spaces", 
        m = parse("2 **>> 1")
        m should == "2 **>>(1)"

        m = parse("\"foo\" **>> \"bar\"")
        m should == "\"foo\" **>>(\"bar\")"
      )

      it("should be translated correctly when chained", 
        m = parse("2 **>> 1 **>> 0")
        m should == "2 **>>(1) **>>(0)"

        m = parse("\"foo\" **>> \"bar\" **>> \"quux\"")
        m should == "\"foo\" **>>(\"bar\") **>>(\"quux\")"
      )
    )

    describe("&&>", 
      it("should be correctly translated in infix", 
        m = parse("2&&>1")
        m should == "2 &&>(1)"

        m = parse("\"foo\"&&>\"bar\"")
        m should == "\"foo\" &&>(\"bar\")"
      )

      it("should be translated correctly with parenthesis", 
        m = parse("2&&>(1)")
        m should == "2 &&>(1)"

        m = parse("2 &&>(1)")
        m should == "2 &&>(1)"

        m = parse("\"foo\"&&>(\"bar\")")
        m should == "\"foo\" &&>(\"bar\")"

        m = parse("\"foo\" &&>(\"bar\")")
        m should == "\"foo\" &&>(\"bar\")"
      )

      it("should be translated correctly with spaces", 
        m = parse("2 &&> 1")
        m should == "2 &&>(1)"

        m = parse("\"foo\" &&> \"bar\"")
        m should == "\"foo\" &&>(\"bar\")"
      )

      it("should be translated correctly when chained", 
        m = parse("2 &&> 1 &&> 0")
        m should == "2 &&>(1) &&>(0)"

        m = parse("\"foo\" &&> \"bar\" &&> \"quux\"")
        m should == "\"foo\" &&>(\"bar\") &&>(\"quux\")"
      )
    )

    describe("&&>>", 
      it("should be correctly translated in infix", 
        m = parse("2&&>>1")
        m should == "2 &&>>(1)"

        m = parse("\"foo\"&&>>\"bar\"")
        m should == "\"foo\" &&>>(\"bar\")"
      )

      it("should be translated correctly with parenthesis", 
        m = parse("2&&>>(1)")
        m should == "2 &&>>(1)"

        m = parse("2 &&>>(1)")
        m should == "2 &&>>(1)"

        m = parse("\"foo\"&&>>(\"bar\")")
        m should == "\"foo\" &&>>(\"bar\")"

        m = parse("\"foo\" &&>>(\"bar\")")
        m should == "\"foo\" &&>>(\"bar\")"
      )

      it("should be translated correctly with spaces", 
        m = parse("2 &&>> 1")
        m should == "2 &&>>(1)"

        m = parse("\"foo\" &&>> \"bar\"")
        m should == "\"foo\" &&>>(\"bar\")"
      )

      it("should be translated correctly when chained", 
        m = parse("2 &&>> 1 &&>> 0")
        m should == "2 &&>>(1) &&>>(0)"

        m = parse("\"foo\" &&>> \"bar\" &&>> \"quux\"")
        m should == "\"foo\" &&>>(\"bar\") &&>>(\"quux\")"
      )
    )

    describe("||>", 
      it("should be correctly translated in infix", 
        m = parse("2||>1")
        m should == "2 ||>(1)"

        m = parse("\"foo\"||>\"bar\"")
        m should == "\"foo\" ||>(\"bar\")"
      )

      it("should be translated correctly with parenthesis", 
        m = parse("2||>(1)")
        m should == "2 ||>(1)"

        m = parse("2 ||>(1)")
        m should == "2 ||>(1)"

        m = parse("\"foo\"||>(\"bar\")")
        m should == "\"foo\" ||>(\"bar\")"

        m = parse("\"foo\" ||>(\"bar\")")
        m should == "\"foo\" ||>(\"bar\")"
      )

      it("should be translated correctly with spaces", 
        m = parse("2 ||> 1")
        m should == "2 ||>(1)"

        m = parse("\"foo\" ||> \"bar\"")
        m should == "\"foo\" ||>(\"bar\")"
      )

      it("should be translated correctly when chained", 
        m = parse("2 ||> 1 ||> 0")
        m should == "2 ||>(1) ||>(0)"

        m = parse("\"foo\" ||> \"bar\" ||> \"quux\"")
        m should == "\"foo\" ||>(\"bar\") ||>(\"quux\")"
      )
    )

    describe("||>>", 
      it("should be correctly translated in infix", 
        m = parse("2||>>1")
        m should == "2 ||>>(1)"

        m = parse("\"foo\"||>>\"bar\"")
        m should == "\"foo\" ||>>(\"bar\")"
      )

      it("should be translated correctly with parenthesis", 
        m = parse("2||>>(1)")
        m should == "2 ||>>(1)"

        m = parse("2 ||>>(1)")
        m should == "2 ||>>(1)"

        m = parse("\"foo\"||>>(\"bar\")")
        m should == "\"foo\" ||>>(\"bar\")"

        m = parse("\"foo\" ||>>(\"bar\")")
        m should == "\"foo\" ||>>(\"bar\")"
      )

      it("should be translated correctly with spaces", 
        m = parse("2 ||>> 1")
        m should == "2 ||>>(1)"

        m = parse("\"foo\" ||>> \"bar\"")
        m should == "\"foo\" ||>>(\"bar\")"
      )

      it("should be translated correctly when chained", 
        m = parse("2 ||>> 1 ||>> 0")
        m should == "2 ||>>(1) ||>>(0)"

        m = parse("\"foo\" ||>> \"bar\" ||>> \"quux\"")
        m should == "\"foo\" ||>>(\"bar\") ||>>(\"quux\")"
      )
    )

    describe("$>", 
      it("should be correctly translated in infix", 
        m = parse("2$>1")
        m should == "2 $>(1)"

        m = parse("\"foo\"$>\"bar\"")
        m should == "\"foo\" $>(\"bar\")"
      )

      it("should be translated correctly with parenthesis", 
        m = parse("2$>(1)")
        m should == "2 $>(1)"

        m = parse("2 $>(1)")
        m should == "2 $>(1)"

        m = parse("\"foo\"$>(\"bar\")")
        m should == "\"foo\" $>(\"bar\")"

        m = parse("\"foo\" $>(\"bar\")")
        m should == "\"foo\" $>(\"bar\")"
      )

      it("should be translated correctly with spaces", 
        m = parse("2 $> 1")
        m should == "2 $>(1)"

        m = parse("\"foo\" $> \"bar\"")
        m should == "\"foo\" $>(\"bar\")"
      )

      it("should be translated correctly when chained", 
        m = parse("2 $> 1 $> 0")
        m should == "2 $>(1) $>(0)"

        m = parse("\"foo\" $> \"bar\" $> \"quux\"")
        m should == "\"foo\" $>(\"bar\") $>(\"quux\")"
      )
    )

    describe("$>>", 
      it("should be correctly translated in infix", 
        m = parse("2$>>1")
        m should == "2 $>>(1)"

        m = parse("\"foo\"$>>\"bar\"")
        m should == "\"foo\" $>>(\"bar\")"
      )

      it("should be translated correctly with parenthesis", 
        m = parse("2$>>(1)")
        m should == "2 $>>(1)"

        m = parse("2 $>>(1)")
        m should == "2 $>>(1)"

        m = parse("\"foo\"$>>(\"bar\")")
        m should == "\"foo\" $>>(\"bar\")"

        m = parse("\"foo\" $>>(\"bar\")")
        m should == "\"foo\" $>>(\"bar\")"
      )

      it("should be translated correctly with spaces", 
        m = parse("2 $>> 1")
        m should == "2 $>>(1)"

        m = parse("\"foo\" $>> \"bar\"")
        m should == "\"foo\" $>>(\"bar\")"
      )

      it("should be translated correctly when chained", 
        m = parse("2 $>> 1 $>> 0")
        m should == "2 $>>(1) $>>(0)"

        m = parse("\"foo\" $>> \"bar\" $>> \"quux\"")
        m should == "\"foo\" $>>(\"bar\") $>>(\"quux\")"
      )
    )
    
    describe("<->", 
      it("should be correctly translated in infix", 
        m = parse("2<->1")
        m should == "2 <->(1)"

        m = parse("\"foo\"<->\"bar\"")
        m should == "\"foo\" <->(\"bar\")"
      )

      it("should be translated correctly with parenthesis", 
        m = parse("2<->(1)")
        m should == "2 <->(1)"

        m = parse("2 <->(1)")
        m should == "2 <->(1)"

        m = parse("\"foo\"<->(\"bar\")")
        m should == "\"foo\" <->(\"bar\")"

        m = parse("\"foo\" <->(\"bar\")")
        m should == "\"foo\" <->(\"bar\")"
      )

      it("should be translated correctly with spaces", 
        m = parse("2 <-> 1")
        m should == "2 <->(1)"

        m = parse("\"foo\" <-> \"bar\"")
        m should == "\"foo\" <->(\"bar\")"
      )

      it("should be translated correctly when chained", 
        m = parse("2 <-> 1 <-> 0")
        m should == "2 <->(1) <->(0)"

        m = parse("\"foo\" <-> \"bar\" <-> \"quux\"")
        m should == "\"foo\" <->(\"bar\") <->(\"quux\")"
      )
    )

    describe("<-", 
      it("should be correctly translated in infix", 
        m = parse("2<-1")
        m should == "2 <-(1)"

        m = parse("\"foo\"<-\"bar\"")
        m should == "\"foo\" <-(\"bar\")"
      )

      it("should be translated correctly with parenthesis", 
        m = parse("2<-(1)")
        m should == "2 <-(1)"

        m = parse("2 <-(1)")
        m should == "2 <-(1)"

        m = parse("\"foo\"<-(\"bar\")")
        m should == "\"foo\" <-(\"bar\")"

        m = parse("\"foo\" <-(\"bar\")")
        m should == "\"foo\" <-(\"bar\")"
      )

      it("should be translated correctly with spaces", 
        m = parse("2 <- 1")
        m should == "2 <-(1)"

        m = parse("\"foo\" <- \"bar\"")
        m should == "\"foo\" <-(\"bar\")"
      )

      it("should be translated correctly when chained", 
        m = parse("2 <- 1 <- 0")
        m should == "2 <-(1) <-(0)"

        m = parse("\"foo\" <- \"bar\" <- \"quux\"")
        m should == "\"foo\" <-(\"bar\") <-(\"quux\")"
      )
    )

    describe("inverted ::",
      
      it("should be correctly translated",
        m = parse("foo :: bar")
        m should == "bar ::(foo)"
      )

      it("should receive just one argument",
        o = Origin mimic
        o cell("::") = macro(call)
        (foo :: o) arguments length should == 1
      )

      it("should not fail when using other operators",
        ;; FIXME: ioke signals TooFewArguments, one missing for '>'
        ;;o = Origin mimic
        ;;x = nil
        ;;o cell(">") = lecro(n, x = n. self)
        ;;o cell("::") = macro(call)
        ;;foo :: (o > 3)
        ;;x should == 3
      )
      
    )

    describe("precedence", 
      it("should work correctly for + and *", 
        m = parse("2+3*4")
        m should == "2 +(3 *(4))"
      )

      it("should work correctly for * and +", 
        m = parse("2*3+4")
        m should == "2 *(3) +(4)"
      )

      it("should work correctly for + and * with spaces", 
        m = parse("2 + 3 * 4")
        m should == "2 +(3 *(4))"
      )

      it("should work correctly for * and + with spaces", 
        m = parse("2 * 3 + 4")
        m should == "2 *(3) +(4)"
      )

      it("should work correctly for + and /", 
        m = parse("2+3/4")
        m should == "2 +(3 /(4))"
      )

      it("should work correctly for / and +", 
        m = parse("2/3+4")
        m should == "2 /(3) +(4)"
      )

      it("should work correctly for + and / with spaces", 
        m = parse("2 + 3 / 4")
        m should == "2 +(3 /(4))"
      )

      it("should work correctly for / and + with spaces", 
        m = parse("2 / 3 + 4")
        m should == "2 /(3) +(4)"
      )

      it("should work correctly for - and *", 
        m = parse("2-3*4")
        m should == "2 -(3 *(4))"
      )

      it("should work correctly for * and -", 
        m = parse("2*3-4")
        m should == "2 *(3) -(4)"
      )

      it("should work correctly for - and * with spaces", 
        m = parse("2 - 3 * 4")
        m should == "2 -(3 *(4))"
      )

      it("should work correctly for * and - with spaces", 
        m = parse("2 * 3 - 4")
        m should == "2 *(3) -(4)"
      )

      it("should work correctly for - and /", 
        m = parse("2-3/4")
        m should == "2 -(3 /(4))"
      )

      it("should work correctly for / and -", 
        m = parse("2/3-4")
        m should == "2 /(3) -(4)"
      )

      it("should work correctly for - and / with spaces", 
        m = parse("2 - 3 / 4")
        m should == "2 -(3 /(4))"
      )

      it("should work correctly for / and - with spaces", 
        m = parse("2 / 3 - 4")
        m should == "2 /(3) -(4)"
      )
      
      it("should work correctly for unary minus", 
        m = parse("20 * -10")
        m should == "20 *(-(10))"
      )

      it("should work correctly for unary plus", 
        m = parse("20 * +10")
        m should == "20 *(+(10))"
      )
    )
  )

  describe("<=>", 
    it("should work for numbers", 
      (0<=>0) should == 0
      (0<=>1) should == -1
      (1<=>1) should == 0
      (2<=>1) should == 1
      (1<=>2) should == -1
      (2<=>2) should == 0
      (3<=>2) should == 1
      (3<=>223524534) should == -1
      (223524534<=>223524534) should == 0
      (223524534<=>2) should == 1
    )
  )

  describe("<", 
    it("should work for numbers", 
      (0<0) should be false
      (0<1) should be true
      (1<1) should be false
      (1<2) should be true
      (2<2) should be false
      (3<2) should be false
      (3<223524534) should be true
    )
  )

  describe("<=", 
    it("should work for numbers", 
      (0<=0) should be true
      (0<=1) should be true
      (1<=1) should be true
      (1<=2) should be true
      (2<=2) should be true
      (3<=2) should be false
      (3<=223524534) should be true
      (223524534<=223524534) should be true
    )
  )
  
  describe(">", 
    it("should work for numbers", 
      (0>0) should be false
      (0>1) should be false
      (1>0) should be true
      (1>1) should be false
      (2>1) should be true
      (2>2) should be false
      (3>2) should be true
      (3>223524534) should be false
      (223524534>3) should be true
      (223524534>223524534) should be false
    )
  )

  describe(">=", 
    it("should work for numbers", 
      (0>=0) should be true
      (0>=1) should be false
      (1>=0) should be true
      (1>=1) should be true
      (2>=1) should be true
      (2>=2) should be true
      (3>=2) should be true
      (3>=223524534) should be false
      (223524534>=3) should be true
      (223524534>=223524534) should be true
    )
  )

  describe("==", 
    it("should work for numbers", 
      (0==0) should be true
      (0==1) should be false
      (1==0) should be false
      (1==1) should be true
      (2==1) should be false
      (2==2) should be true
      (3==2) should be false
      (3==223524534) should be false
      (223524534==3) should be false
      (223524534==223524534) should be true
    )
  )

  describe("!=", 
    it("should work for numbers", 
      (0!=0) should be false
      (0!=1) should be true
      (1!=0) should be true
      (1!=1) should be false
      (2!=1) should be true
      (2!=2) should be false
      (3!=2) should be true
      (3!=223524534) should be true
      (223524534!=3) should be true
      (223524534!=223524534) should be false
    )
  )
)
