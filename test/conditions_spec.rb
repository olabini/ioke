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
    
  end
  
  describe "'findRestart'" do 

  end
  
  describe "'invokeRestart'" do 
    
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
