include_class('ioke.lang.Runtime') { 'IokeRuntime' } unless defined?(IokeRuntime)
include_class('ioke.lang.exceptions.ControlFlow') unless defined?(ControlFlow)

import Java::java.io.StringReader unless defined?(StringReader)

import Java::java.io.PrintWriter unless defined?(PrintWriter)
import Java::java.io.StringWriter unless defined?(StringWriter)
import Java::java.io.InputStreamReader unless defined?(InputStreamReader)
import Java::java.lang.System unless defined?(System)

describe 'DefaultBehavior' do 
  describe "'error!'" do 
    it "should signal a Condition Error Default by default" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string(<<CODE).should == ioke.true
x = bind(
      rescue(fn(c, c)),
      error!("something"))
(x text == "something") && (x kind?("Condition Error Default"))
CODE
    end

    it "should take an existing condition" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string(<<CODE).should == ioke.true
c1 = Condition mimic
bind(
  rescue(fn(c, c == c1)),
  error!(c1))
CODE
    end

    it "should take a condition mimic and a set of keyword parameters" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string(<<CODE).should == ioke.true
cx = bind(
       rescue(fn(c, c)),
       error!(Condition, foo: "bar"))
(cx foo == "bar") && (cx != Condition)
CODE
    end

    it "should print the condition and exit when no debugger is registered" do 
      sw = StringWriter.new(20)
      err = PrintWriter.new(sw)
      
      sw2 = StringWriter.new(0)
      out = PrintWriter.new(sw2)

      ioke = IokeRuntime.get_runtime(out, InputStreamReader.new(System.in), err)

      proc do 
        ioke.evaluate_string(<<CODE).should == ioke.true
System currentDebugger = nil
error!("oh noes")
CODE
      end.should raise_error
      
      sw.to_string.should == "*** - oh noes\n"
    end

    it "should print the condition and invoke the debugger if it's registered" do 
      sw = StringWriter.new(20)
      err = PrintWriter.new(sw)
      
      sw2 = StringWriter.new(0)
      out = PrintWriter.new(sw2)

      ioke = IokeRuntime.get_runtime(out, InputStreamReader.new(System.in), err)

      ioke.evaluate_string(<<CODE).should_not == ioke.nil
debugger = Origin mimic
xx = nil
debugger invoke = method(condition, context, Ground xx = [condition, context]. invokeRestart(:abort))
System currentDebugger = debugger
bind(restart(abort, fn),
  error!("oh noes"))
xx
CODE
      sw.to_string.should == "*** - oh noes\n"
    end
  end
  
  describe "'warn!'" do 
    it "should signal a Condition Warning Default by default" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string(<<CODE).should == ioke.true
x = bind(
      rescue(fn(c, c)),
      warn!("something"))
(x text == "something") && (x kind?("Condition Warning Default"))
CODE
    end
    
    it "should take an existing condition" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string(<<CODE).should == ioke.true
c1 = Condition mimic
bind(
  rescue(fn(c, c == c1)),
  warn!(c1))
CODE
    end

    it "should take a condition mimic and a set of keyword parameters" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string(<<CODE).should == ioke.true
cx = bind(
       rescue(fn(c, c)),
       warn!(Condition, foo: "bar"))
(cx foo == "bar") && (cx != Condition)
CODE
    end
    
    it "should print something to System err if no restart or unwinding happens" do 
      sw = StringWriter.new(20)
      err = PrintWriter.new(sw)
      
      sw2 = StringWriter.new(0)
      out = PrintWriter.new(sw2)

      ioke = IokeRuntime.get_runtime(out, InputStreamReader.new(System.in), err)
      ioke.evaluate_string(<<CODE)
warn!("something")
CODE
      sw.to_string.should == "WARNING: something\n"
    end

    it "should print whatever is returned from a call to report for the condition signalled" do 
      sw = StringWriter.new(20)
      err = PrintWriter.new(sw)
      sw2 = StringWriter.new(0)
      out = PrintWriter.new(sw2)
      ioke = IokeRuntime.get_runtime(out, InputStreamReader.new(System.in), err)
      ioke.evaluate_string(<<CODE)
c = Condition mimic
c report = method("flurg")
warn!(c)
CODE
      sw.to_string.should == "WARNING: flurg\n"
    end
    
    it "should establish an ignore-restart" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string(<<CODE).should_not == ioke.nil
gah = nil
bind(
    rescue(fn(c, gah)),
    handle(fn(c, gah = findRestart(:ignore))),

    warn!("something"))
CODE
    end
  end
  
  describe "'signal!'" do 
    it "should take an existing condition" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string(<<CODE).should == ioke.true
c1 = Condition mimic
bind(
  rescue(fn(c, c == c1)),
  signal!(c1))
CODE
    end

    it "should take a condition mimic and a set of keyword parameters" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string(<<CODE).should == ioke.true
cx = bind(
       rescue(fn(c, c)),
       signal!(Condition, foo: "bar"))
(cx foo == "bar") && (cx != Condition)
CODE
    end
    
    it "should not execute a handler that's not applicable" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string(<<CODE).should == ioke.true
x = 1
C1 = Condition mimic
bind(
  handle(C1, fn(c, x = 42)),
  signal!("foo"))
x == 1
CODE
    end

    it "should execute one applicable handler" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string(<<CODE).should == ioke.true
x = 1
bind(
  handle(fn(c, x = 42)),
  signal!("foo"))
x == 42
CODE
    end

    it "should execute two applicable handler, among some non-applicable" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string(<<CODE).should == ioke.true
x = []
C1 = Condition mimic
bind(
  handle(C1, fn(c, x << 13)),
  bind(
    handle(fn(c, x << 15)),
    bind(
      handle(C1, fn(c, x << 17)),
      bind(
        handle(Condition, fn(c, x << 19)),
        signal!("foo")))))
x == [19, 15]
CODE
    end

    it "should not unwind the stack when invoking handlers" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string(<<CODE).should == ioke.true
x = []
bind(
  handle(fn(c, x << 2)),
  x << 1
  signal!("foo")
  x << 3
)
x == [1,2,3]
CODE
    end

    it "should only invoke handlers up to the limit of the first applicable rescue" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string(<<CODE).should == ioke.true
x = []
bind(
  handle(fn(c, x << 1)),
  handle(fn(c, x << 2)),
  rescue(fn(c, x << 3)),
  handle(fn(c, x << 4)),
  bind(
    handle(fn(c, x << 5)),
    handle(fn(c, x << 6)),
    bind(
      handle(fn(c, x << 7)),
      signal!("Foo"))))
x == [7, 6, 5, 4, 3]
CODE
    end

    it "should do nothing if no rescue has been registered for it" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string("x = 1. signal!(\"foo\"). x++. x==2").should == ioke.true
      ioke.evaluate_string(<<CODE).should == ioke.true
x = 1
C2 = Condition mimic
bind(
  rescue(C2, fn(e, x = 42)),
  x++
  signal!("something")
  x++)
x == 3
CODE
    end
    
    it "should transfer control if the condition is matched" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string(<<CODE).should == ioke.true
x = 1
bind(
  rescue(fn(e, x = 42)),
  signal!("something")
  x = 13)
x == 42
CODE
    end

    it "should transfer control to the innermost handler that matches" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string(<<CODE).should == ioke.true
x = 1
C1 = Condition mimic
C2 = Condition mimic
bind(
  rescue(C1, fn(e, x = 42)),
  bind(
    rescue(fn(e, x = 444)),
    bind(
      rescue(C2, fn(e, x = 222)),

      signal!("something"))))
x == 444
CODE
    end

    it "should invoke the handler with the signalled condition" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string(<<CODE).should == ioke.true
x = 1
bind(
  rescue(fn(e, x = e text)),
  signal!("something")
  x = 13)
x == "something"
CODE
    end

    it "should return the value of the handler from the bind of the rescue in question" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string(<<CODE).should == ioke.true
bind(
  rescue(fn(e, 42)),
  signal!("something")
  x = 13) == 42
CODE
    end
  end

  describe "'handle'" do 
    it "should take only one argument, and in that case catch all Conditions" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string(%q[handle(fn(e, 42)) handler call(1)]).data.as_java_integer.should == 42
      ioke.evaluate_string(%q[handle(fn) conditions == [Condition]]).should == ioke.true
    end

    it "should take one or more Conditions to catch" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string(%q[c1 = Condition mimic. c2 = Condition mimic. handle(c1, c2, fn(e, 42)) conditions == [c1, c2]]).should == ioke.true
    end
    
    it "should return something that has kind Handler" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string(%q[handle(fn) kind]).data.text.should == "Handler"
    end
  end
  
  describe "'rescue'" do 
    it "should take only one argument, and in that case catch all Conditions" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string(%q[rescue(fn(e, 42)) handler call(1)]).data.as_java_integer.should == 42
      ioke.evaluate_string(%q[rescue(fn) conditions == [Condition]]).should == ioke.true
    end

    it "should take one or more Conditions to catch" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string(%q[c1 = Condition mimic. c2 = Condition mimic. rescue(c1, c2, fn(e, 42)) conditions == [c1, c2]]).should == ioke.true
    end
    
    it "should return something that has kind Rescue" do 
      ioke = IokeRuntime.get_runtime()
      ioke.evaluate_string(%q[rescue(fn) kind]).data.text.should == "Rescue"
    end
  end
  
  describe "'restart'" do 
    it "should take an optional unevaluated name as first argument" do 
      ioke = IokeRuntime.get_runtime()
      ioke.evaluate_string(%q[restart(blub, fn) name]).data.text.should == "blub"
    end
    
    it "should return something that has kind Restart" do 
      ioke = IokeRuntime.get_runtime()
      ioke.evaluate_string(%q[restart(fn) kind]).data.text.should == "Restart"
    end

    it "should take an optional report: argument" do 
      ioke = IokeRuntime.get_runtime()
      ioke.evaluate_string(<<CODE).should == ioke.ground.find_cell(nil, nil, "rp")
rp = fn("report" println)
restart(report: rp, fn) report
CODE
    end

    it "should take an optional test: argument" do 
      ioke = IokeRuntime.get_runtime()
      ioke.evaluate_string(<<CODE).should == ioke.ground.find_cell(nil, nil, "t1")
t1 = fn("test" println)
restart(test: t1, fn) test
CODE
    end

    it "should take a code argument" do 
      ioke = IokeRuntime.get_runtime()
      ioke.evaluate_string(%q[restart(fn(32+43)) code call]).data.as_java_integer.should == 75
    end
  end

  describe "'bind'" do 
    it "should evaluate it's last argument and return the result of that" do 
      ioke = IokeRuntime.get_runtime()
      ioke.evaluate_string(<<CODE).should == ioke.nil
bind()
CODE

      ioke.evaluate_string(<<CODE).data.as_java_integer.should == 42
bind(42)
CODE

      ioke.evaluate_string(<<CODE).data.as_java_integer.should == 22
bind(
  restart(fn),
  restart(fn),
  restart(fn),
  42+43
  10+12)
CODE
    end

    it "should fail if any argument except the last doesn't evaluate to a restart" do 
      sw = StringWriter.new(20)
      out = PrintWriter.new(sw)

      ioke = IokeRuntime.get_runtime(out, InputStreamReader.new(System.in), out)
      proc do 
        ioke.evaluate_string(<<CODE)
bind(10, 10)
CODE
      end.should raise_error
    end
  end
  
  describe "'findRestart'" do 
    it "should return nil if it can't find the named restart" do 
      ioke = IokeRuntime.get_runtime

      ioke.evaluate_string(<<CODE).should == ioke.nil
findRestart(:foo)
CODE
      
      ioke.evaluate_string(<<CODE).should == ioke.nil
bind(
  restart(bar, fn),
  findRestart(:foo))
CODE
    end

    it "should return the restart if found" do 
      ioke = IokeRuntime.get_runtime
      
      ioke.evaluate_string(<<CODE).should_not == ioke.nil
bind(
  restart(foo, fn),
  findRestart(:foo))
CODE

      result = ioke.evaluate_string(<<CODE)
re = restart(foo, fn)
bind(
  re,
  findRestart(:foo))
CODE
      result.should == ioke.ground.find_cell(nil, nil, "re")
    end

    it "should return the innermost restart for the name" do 
      ioke = IokeRuntime.get_runtime

      result = ioke.evaluate_string(<<CODE)
re1 = restart(foo, fn)
re2 = restart(foo, fn)
re3 = restart(foo, fn)
bind(
  re1,
  bind(
    re2,
    bind(
      re3,
      findRestart(:foo))))
CODE
      result.should == ioke.ground.find_cell(nil, nil, "re3")

      result = ioke.evaluate_string(<<CODE)
re1 = restart(foo, fn)
re2 = restart(foo, fn)
re3 = restart(foo, fn)
bind(
  re1,
  bind(
    re2,
    bind(
      re3,
      bind(
        restart(bar, fn),
        findRestart(:foo)))))
CODE
      result.should == ioke.ground.find_cell(nil, nil, "re3")
    end

    it "should fail when given nil" do 
      sw = StringWriter.new(20)
      out = PrintWriter.new(sw)

      ioke = IokeRuntime.get_runtime(out, InputStreamReader.new(System.in), out)
      proc do 
        ioke.evaluate_string(<<CODE)
findRestart(nil)
CODE
      end.should raise_error
      
      proc do 
        ioke.evaluate_string(<<CODE)
bind(
  restart,
  findRestart(nil))
CODE
      end.should raise_error

      proc do 
        ioke.evaluate_string(<<CODE)
bind(
  restart(foo, fn),
  findRestart(nil))
CODE
      end.should raise_error
    end

    it "should take a restart as argument and return it when that restart is active" do 
      ioke = IokeRuntime.get_runtime
      
      result = ioke.evaluate_string(<<CODE)
re = restart(foo, fn)
bind(
  restart(foo, fn),
  bind(
    re,
    bind(
      restart(foo, fn),
      findRestart(re))))
CODE
      result.should == ioke.ground.find_cell(nil, nil, "re")
    end

    it "should take a restart as argument and return nil when that restart is not active" do 
      ioke = IokeRuntime.get_runtime
      
      result = ioke.evaluate_string(<<CODE)
re = restart(foo, fn)
bind(
  restart(foo, fn),
  bind(
    restart(foo, fn),
    findRestart(re)))
CODE
      result.should == ioke.nil
    end
  end
  
  describe "'invokeRestart'" do 
    it "should fail if no restarts of the name is active" do 
      sw = StringWriter.new(20)
      out = PrintWriter.new(sw)

      ioke = IokeRuntime.get_runtime(out, InputStreamReader.new(System.in), out)
      proc do 
        ioke.evaluate_string(<<CODE)
invokeRestart(:bar)
CODE
      end.should raise_error

      proc do 
        ioke.evaluate_string(<<CODE)
bind(
  restart(foo, fn()),
  invokeRestart(:bar))
CODE
      end.should raise_error

      proc do 
        ioke.evaluate_string(<<CODE)
bind(
  restart(foo, fn()),
  bind(
    restart(foo, fn()),
    invokeRestart(:bar)))
CODE
      end.should raise_error
    end

    it "should fail if no restarts of the restart is active" do 
      ioke = IokeRuntime.get_runtime()
      proc do 
        ioke.evaluate_stream(StringReader.new(<<CODE))
re = restart(bar, fn)
invokeRestart(re)
CODE
      end.should raise_error

      proc do 
        ioke.evaluate_stream(StringReader.new(<<CODE))
re = restart(bar, fn)
bind(
  restart(foo, fn),
  invokeRestart(re))
CODE
      end.should raise_error

      proc do 
        ioke.evaluate_stream(StringReader.new(<<CODE))
re = restart(bar, fn)
bind(
  restart(foo, fn),
  bind(
    restart(foo, fn),
    invokeRestart(re)))
CODE
      end.should raise_error
    end
    
    it "should invoke a restart when given the name" do 
      ioke = IokeRuntime.get_runtime()
      ioke.evaluate_stream(StringReader.new(<<CODE)).data.as_java_integer.should == 13
x = 1
bind(
  restart(foo, fn(x = 42. 13)),
  invokeRestart(:foo)
)
CODE
      ioke.ground.find_cell(nil, nil, "x").data.as_java_integer.should == 42
    end

    it "should invoke a restart when given the restart" do 
      ioke = IokeRuntime.get_runtime()
      ioke.evaluate_stream(StringReader.new(<<CODE)).data.as_java_integer.should == 13
x = 1
re = restart(foo, fn(x = 42. 13))
bind(
  re,
  invokeRestart(re)
)
CODE
      ioke.ground.find_cell(nil, nil, "x").data.as_java_integer.should == 42
    end
    
    it "should invoke the innermost restart when given the name" do 
      ioke = IokeRuntime.get_runtime()
      ioke.evaluate_stream(StringReader.new(<<CODE)).data.as_java_integer.should == 15
x = 1
invoked = 0
bind(
  restart(foo, fn(invoked++. x = 42. 13)),
  bind(
    restart(foo, fn(invoked++. x = 43. 14)),
    bind(
      restart(foo, fn(invoked++. x = 44. 15)),
        invokeRestart(:foo))))
CODE
      ioke.ground.find_cell(nil, nil, "x").data.as_java_integer.should == 44
      ioke.ground.find_cell(nil, nil, "invoked").data.as_java_integer.should == 1
    end

    it "should invoke the right restart when given an instance" do 
      ioke = IokeRuntime.get_runtime()
      ioke.evaluate_stream(StringReader.new(<<CODE)).data.as_java_integer.should == 16
x = 1
invoked = 0
re = restart(foo, fn(invoked++. x=24. 16))
bind(
  restart(foo, fn(invoked++. x = 42. 13)),
  bind(
    re,
    bind(
      restart(foo, fn(invoked++. x = 43. 14)),
      bind(
        restart(foo, fn(invoked++. x = 44. 15)),
          invokeRestart(re)))))
CODE
      ioke.ground.find_cell(nil, nil, "x").data.as_java_integer.should == 24
      ioke.ground.find_cell(nil, nil, "invoked").data.as_java_integer.should == 1
    end

    it "should take arguments and pass these along to the restart" do 
      ioke = IokeRuntime.get_runtime()
      ioke.evaluate_stream(StringReader.new(<<CODE)).data.as_java_integer.should == 13
bind(
  restart(foo, fn(x, x)),
  invokeRestart(:foo, 13))
CODE

      ioke.evaluate_stream(StringReader.new(<<CODE)).data.as_java_integer.should == 13
bind(
  restart(foo, fn(x, y, x)),
  invokeRestart(:foo, 13, 15))
CODE

      ioke.evaluate_stream(StringReader.new(<<CODE)).data.as_java_integer.should == 15
bind(
  restart(foo, fn(x, y, y)),
  invokeRestart(:foo, 13, 15))
CODE
    end
  end
  
  describe "'computeRestarts'" do 
  end
end

describe "Restart" do 
  it "should have a name" do 
    ioke = IokeRuntime.get_runtime()
    ioke.evaluate_string(%q[Restart name]).should == ioke.nil
  end
  
  it "should have a report cell" do 
    ioke = IokeRuntime.get_runtime()
    ioke.evaluate_string(%q[Restart report kind]).data.text.should == "LexicalBlock"
  end

  it "should have a test cell" do 
    ioke = IokeRuntime.get_runtime()
    ioke.evaluate_string(%q[Restart test kind]).data.text.should == "LexicalBlock"
  end

  it "should have a code cell" do 
    ioke = IokeRuntime.get_runtime()
    ioke.evaluate_string(%q[Restart code kind]).data.text.should == "LexicalBlock"
  end
end

describe "Condition" do 
  it "should have the right kind" do 
    ioke = IokeRuntime.get_runtime
    ioke.evaluate_string('Condition kind == "Condition"').should == ioke.true
  end
  
  describe "Default" do 
    it "should have the right kind" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string('Condition Default kind == "Condition Default"').should == ioke.true
    end
  end

  describe "Warning" do 
    it "should have the right kind" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string('Condition Warning kind == "Condition Warning"').should == ioke.true
    end

    describe "Default" do 
      it "should have the right kind" do 
        ioke = IokeRuntime.get_runtime
        ioke.evaluate_string('Condition Warning Default kind == "Condition Warning Default"').should == ioke.true
      end
    end
  end
   
  describe "Error" do 
    it "should have the right kind" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string('Condition Error kind == "Condition Error"').should == ioke.true
    end

    describe "Default" do 
      it "should have the right kind" do 
        ioke = IokeRuntime.get_runtime
        ioke.evaluate_string('Condition Error Default kind == "Condition Error Default"').should == ioke.true
      end
    end
    
    describe "Load" do 
      it "should have the right kind" do 
        ioke = IokeRuntime.get_runtime
        ioke.evaluate_string('Condition Error Load kind == "Condition Error Load"').should == ioke.true
      end
    end

    describe "IO" do 
      it "should have the right kind" do 
        ioke = IokeRuntime.get_runtime
        ioke.evaluate_string('Condition Error IO kind == "Condition Error IO"').should == ioke.true
      end
    end

    describe "Arithmetic" do 
      it "should have the right kind" do 
        ioke = IokeRuntime.get_runtime
        ioke.evaluate_string('Condition Error Arithmetic kind == "Condition Error Arithmetic"').should == ioke.true
      end

      describe "DivisionByZero" do 
        it "should have the right kind" do 
          ioke = IokeRuntime.get_runtime
          ioke.evaluate_string('Condition Error Arithmetic DivisionByZero kind == "Condition Error Arithmetic DivisionByZero"').should == ioke.true
        end
      end
    end
    
    describe "NoSuchCell" do 
      it "should have the right kind" do 
        ioke = IokeRuntime.get_runtime
        ioke.evaluate_string('Condition Error NoSuchCell kind == "Condition Error NoSuchCell"').should == ioke.true
      end
    end

    describe "Invocation" do 
      it "should have the right kind" do 
        ioke = IokeRuntime.get_runtime
        ioke.evaluate_string('Condition Error Invocation kind == "Condition Error Invocation"').should == ioke.true
      end

      describe "NotActivatable" do 
        it "should have the right kind" do 
          ioke = IokeRuntime.get_runtime
          ioke.evaluate_string('Condition Error Invocation NotActivatable kind == "Condition Error Invocation NotActivatable"').should == ioke.true
        end
      end

      describe "ArgumentWithoutDefaultValue" do 
        it "should have the right kind" do 
          ioke = IokeRuntime.get_runtime
          ioke.evaluate_string('Condition Error Invocation ArgumentWithoutDefaultValue kind == "Condition Error Invocation ArgumentWithoutDefaultValue"').should == ioke.true
        end
      end

      describe "TooManyArguments" do 
        it "should have the right kind" do 
          ioke = IokeRuntime.get_runtime
          ioke.evaluate_string('Condition Error Invocation TooManyArguments kind == "Condition Error Invocation TooManyArguments"').should == ioke.true
        end
      end

      describe "TooFewArguments" do 
        it "should have the right kind" do 
          ioke = IokeRuntime.get_runtime
          ioke.evaluate_string('Condition Error Invocation TooFewArguments kind == "Condition Error Invocation TooFewArguments"').should == ioke.true
        end
      end

      describe "MismatchedKeywords" do 
        it "should have the right kind" do 
          ioke = IokeRuntime.get_runtime
          ioke.evaluate_string('Condition Error Invocation MismatchedKeywords kind == "Condition Error Invocation MismatchedKeywords"').should == ioke.true
        end
      end

      describe "NotSpreadable" do 
        it "should have the right kind" do 
          ioke = IokeRuntime.get_runtime
          ioke.evaluate_string('Condition Error Invocation NotSpreadable kind == "Condition Error Invocation NotSpreadable"').should == ioke.true
        end
      end
    end
    
    describe "CantMimicOddball" do 
      it "should have the right kind" do 
        ioke = IokeRuntime.get_runtime
        ioke.evaluate_string('Condition Error CantMimicOddball kind == "Condition Error CantMimicOddball"').should == ioke.true
      end
    end

    describe "Index" do 
      it "should have the right kind" do 
        ioke = IokeRuntime.get_runtime
        ioke.evaluate_string('Condition Error Index kind == "Condition Error Index"').should == ioke.true
      end
    end

    describe "Type" do 
      it "should have the right kind" do 
        ioke = IokeRuntime.get_runtime
        ioke.evaluate_string('Condition Error Type kind == "Condition Error Type"').should == ioke.true
      end

      describe "IncorrectType" do 
        it "should have the right kind" do 
          ioke = IokeRuntime.get_runtime
          ioke.evaluate_string('Condition Error Type IncorrectType kind == "Condition Error Type IncorrectType"').should == ioke.true
        end
      end
    end
  end
end
