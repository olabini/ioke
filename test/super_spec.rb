include_class('ioke.lang.Runtime') { 'IokeRuntime' } unless defined?(IokeRuntime)

describe "DefaultBehavior" do 
  describe "'super'" do 
    it "should not be available if no super method is there" do 
      sw = StringWriter.new(20)
      out = PrintWriter.new(sw)

      ioke = IokeRuntime.get_runtime(out, InputStreamReader.new(System.in), out)

      begin 
        ioke.evaluate_string('method(super) call')
        true.should be_false
      rescue NativeException => cfe
        cfe.cause.value.find_cell(nil, nil, "kind").data.text.should == "Condition Error NoSuchCell"
      end
    end

    it "should return the super value if it is not method" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string('x = Origin mimic. x foo = 42. x2 = x mimic. x2 foo = method(super). x2 foo').data.as_java_integer.should == 42
    end

    it "should call the super method with the same self" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string('x = Origin mimic. x foo = method([self]). x2 = x mimic. x2 foo = method(super). x2 foo == [x2]').should == ioke.true
    end

    it "should be possible to give different arguments to super" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string('x = Origin mimic. x foo = method(+args, args). x2 = x mimic. x2 foo = method(super(1,2,3)). x2 foo == [1, 2, 3]').should == ioke.true
    end

    it "should be possible to call super several times in a row" do 
      ioke = IokeRuntime.get_runtime
      ioke.evaluate_string(<<CODE).should == ioke.true
called = [] 
x = Origin mimic
x foo = method(called << "foo1")
x2 = x mimic
x2 foo = method(called << "foo2". super)
x3 = x2 mimic
x3 foo = method(called << "foo3". super)
x3 foo
called == ["foo3", "foo2", "foo1"]
CODE
    end
  end
end
