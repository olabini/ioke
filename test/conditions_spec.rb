include_class('ioke.lang.Runtime') { 'IokeRuntime' } unless defined?(IokeRuntime)

import Java::java.io.StringReader unless defined?(StringReader)

describe 'DefaultBehavior' do 
  describe "'restart'" do 
    it "should take an optional unevaluated name as first argument" do 
      ioke = IokeRuntime.get_runtime()
      ioke.evaluate_stream(StringReader.new(%q[restart(blub, fn) name])).data.text.should == "blub"
    end
    
    it "should return something that has kind Restart" do 
      ioke = IokeRuntime.get_runtime()
      ioke.evaluate_stream(StringReader.new(%q[restart(fn) kind])).data.text.should == "Restart"
    end

    it "should take an optional report: argument" do 
      ioke = IokeRuntime.get_runtime()
      ioke.evaluate_stream(StringReader.new(<<CODE)).should == ioke.ground.find_cell(nil, nil, "rp")
rp = fn("report" println)
restart(report: rp, fn) report
CODE
    end

    it "should take an optional test: argument" do 
      ioke = IokeRuntime.get_runtime()
      ioke.evaluate_stream(StringReader.new(<<CODE)).should == ioke.ground.find_cell(nil, nil, "t1")
t1 = fn("test" println)
restart(test: t1, fn) test
CODE
    end

    it "should take a code argument" do 
      ioke = IokeRuntime.get_runtime()
      ioke.evaluate_stream(StringReader.new(%q[restart(fn(32+43)) code call])).data.as_java_integer.should == 75
    end
  end

  describe "'bind'" do 
    it "should evaluate it's last argument and return the result of that" do 
      ioke = IokeRuntime.get_runtime()
      ioke.evaluate_stream(StringReader.new(<<CODE)).should == ioke.nil
bind()
CODE

      ioke.evaluate_stream(StringReader.new(<<CODE)).data.as_java_integer.should == 42
bind(42)
CODE

      ioke.evaluate_stream(StringReader.new(<<CODE)).data.as_java_integer.should == 22
bind(
  restart(fn),
  restart(fn),
  restart(fn),
  42+43
  10+12)
CODE
    end

    it "should fail if any argument except the last doesn't evaluate to a restart" do 
      ioke = IokeRuntime.get_runtime()
      proc do 
        ioke.evaluate_stream(StringReader.new(<<CODE))
bind(10, 10)
CODE
      end.should raise_error
    end
    
    it "should return the result of the invoked restart, if that restart is invoked"
  end
  
  describe "'findRestart'" do 
    it "should return nil if it can't find the named restart"

    it "should return the restart if found"

    it "should return the innermost restart for the name"

    it "should find the right restart when several are registered"

    it "should fail when given nil"

    it "should take a restart as argument and return it if that restart is active"
  end
  
  describe "'invokeRestart'" do 
    it "should fail if no restarts of the name is active"
    it "should invoke the innermost restart"
    it "should stay in the current context of the binding of the restart"
    it "should take arguments and pass these along to the restart"
  end
  
  describe "'computeRestarts'" do 
    
  end
end

describe "Restart" do 
  it "should have a name" do 
    ioke = IokeRuntime.get_runtime()
    ioke.evaluate_stream(StringReader.new(%q[Restart name])).should == ioke.nil
  end
  
  it "should have a report cell" do 
    ioke = IokeRuntime.get_runtime()
    ioke.evaluate_stream(StringReader.new(%q[Restart report kind])).data.text.should == "LexicalBlock"
  end

  it "should have a test cell" do 
    ioke = IokeRuntime.get_runtime()
    ioke.evaluate_stream(StringReader.new(%q[Restart test kind])).data.text.should == "LexicalBlock"
  end

  it "should have a code cell" do 
    ioke = IokeRuntime.get_runtime()
    ioke.evaluate_stream(StringReader.new(%q[Restart code kind])).data.text.should == "LexicalBlock"
  end
end
