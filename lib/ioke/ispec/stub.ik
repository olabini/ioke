ISpec Stubs = Origin mimic do(
  initialize = method(@all_stubs = {})
  
  on = method(object,
    @all_stubs[object] ||= []
  )
  
  addStub = method(object, cellName,
    on(object) << ISpec Stub mimic(cellName)
  )
  
  clear! = method(@stubs = {})
)

ISpec stubs = ISpec Stubs mimic

ISpec ExtendedDefaultBehavior do(
  stub = method("adds a stub to this object", cellName,
    ISpec stubs addStub(self, cellName)
  )
  
  stubs = method("returns all stubs for this object",
    ISpec stubs on(self)
  )
)

ISpec Stub = Origin mimic do(
  initialize = method(cellName, @cellName = cellName)
)