include_class('ioke.lang.Runtime') { 'IokeRuntime' } unless defined?(IokeRuntime)

describe "Mixins" do 
  describe "'cell'" do 
    it "should have tests"
  end

  describe "'cell='" do 
    it "should have tests"
  end

  describe "'cells'" do 
    it "should return the cells of this object by default"
    it "should take a boolean, when given will make it return all cells in both this and it's parents objects"
  end

  describe "'cellNames'" do 
    it "should return the cell names of this object by default"
    it "should take a boolean, when given will make it return all cell names in both this and it's parents objects"
  end
end
