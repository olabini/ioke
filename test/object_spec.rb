include_class('ioke.lang.IokeObject') unless defined?(IokeObject)
include_class('ioke.lang.Runtime') { 'IokeRuntime' } unless defined?(IokeRuntime)

describe IokeObject do 
  before :each do 
    @runtime = IokeRuntime.new
    @runtime.init
  end
  
  describe "findCell" do 
    it "should handle recursive mimicing with no cell" do 
      first = IokeObject.new(@runtime, "")
      second = IokeObject.new(@runtime, "")
      first.mimics(second)
      second.mimics(first)

      first.find_cell("hoho").should == @runtime.get_nul
      second.find_cell("hoho").should == @runtime.get_nul
    end

    it "should handle recursive mimicing with a cell" do 
      first = IokeObject.new(@runtime, "")
      second = IokeObject.new(@runtime, "")
      first.mimics(second)
      second.mimics(first)
      
      first.register_cell("one", second)
      second.register_cell("two", first)
      
      first.find_cell("one").should == second
      second.find_cell("one").should == second

      first.find_cell("two").should == first
      second.find_cell("two").should == first
    end
  end
end
