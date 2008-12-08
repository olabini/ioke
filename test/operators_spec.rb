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
end
