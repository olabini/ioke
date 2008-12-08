use("ispec")

parse = method(str,
  Message fromText(str) code)

describe("assignment",
  it("should set kind when assigned to a name with capital initial letter",
    Ground Foo = Origin mimic
    Foo kind should == "Foo")

  it("should set kind when assigned to a name inside something else",
    Ground Foo = Origin mimic
    Foo Bar = Origin mimic
    Foo Bar kind should == "Foo Bar")

  it("should not set kind when it already has a kind",
    Ground Foo = Origin mimic
    Bar = Foo
    Foo kind should == "Foo"
    Bar kind should == "Foo")
  
  it("should not set kind when assigning to something with a lower case letter",
    Ground foo = Origin mimic
    bar = foo
    foo kind should == "Origin"
    bar kind should == "Origin")

  it("should work for a simple string",
    a = "foo"
    a should == "foo")

  it("should be possible to assign a large expression to default receiver",
    a = Origin mimic
    a kind should == "Origin"
    a should not == Origin)

  it("should be possible to assign to something inside another object",
    Text a = "something"
    Text a should == "something")

  it("should work with combination of equals and plus sign",
    a = 1 + 1
    a should == 2)

  it("should work with something on the next line too",
    m = parse("count = count + 1\ncount println")
    m should == "=(count, count +(1)) .\ncount println")

  it("should work when assigning something to the empty parenthesis",
    m = parse("x = (10+20)")
    m should == "=(x, (10 +(20)))")

  it("should be possible to assign a method to +",
    m = parse("+ = method()")
    m should == "=(+, method)"

    m = parse("Ground + = method()")
    m should == "Ground =(+, method)"
  )

  it("should be possible to assign a method to =",
    m = parse("= = method()")
    m should == "=(=, method)"

    m = parse("Ground = = method()")
    m should == "Ground =(=, method)"
  )

  it("should be possible to assign a method to ..",
    m = parse(".. = method()")
    m should == "=(.., method)"

    m = parse("Ground .. = method()")
    m should == "Ground =(.., method)"
  )
)
