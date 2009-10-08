
use("ispec")

describe(DefaultBehavior,
  describe("documentation",
    it("should be correct for internal:createText",
      cell(:internal:createText) documentation should == "expects one 'strange' argument. creates a new instance of Text with the given Java String backing it."
    )

    it("should be correct for =",
      cell(:"=") documentation should == "expects two arguments, the first unevaluated, the second evaluated. assigns the result of evaluating the second argument in the context of the caller, and assigns this result to the name provided by the first argument. the first argument remains unevaluated. the result of the assignment is the value assigned to the name. if the second argument is a method-like object and it's name is not set, that name will be set to the name of the cell. TODO: add setf documentation here."
    )

    it("should be correct for asText",
      cell(:asText) documentation should == "returns a textual representation of the object called on."
    )

    it("should be correct for documentation",
      cell(:documentation) documentation should == "returns the documentation text of the object called on. anything can have a documentation text - this text will initially be nil."
    )

    it("should be correct for cell",
      cell(:cell) documentation should == "expects one evaluated text or symbol argument and returns the cell that matches that name, without activating even if it's activatable."
    )

    it("should be correct for method",
      cell(:method) documentation should == "expects any number of unevaluated arguments. if no arguments at all are given, will just return nil. creates a new method based on the arguments. this method will be evaluated using the context of the object it's called on, and thus the definition can not refer to the outside scope where the method is defined. (there are other ways of achieving this). all arguments except the last one is expected to be names of arguments that will be used in the method. there will possible be additions to the format of arguments later on - including named parameters and optional arguments. the actual code is the last argument given."
    )

    it("should be correct for use",
      cell(:use) documentation should == "takes one or more evaluated string argument. will import the files corresponding to each of the strings named based on the Ioke loading behavior that can be found in the documentation for the loadBehavior cell on System."
    )
  )
)
