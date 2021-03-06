
use("ispec")

CustomEnumerable = Origin mimic
CustomEnumerable mimic!(Mixins Enumerable)
CustomEnumerable each = macro(
  len = call arguments length

  if(len == 1,
    first = call arguments first
    first evaluateOn(call ground, "3first")
    first evaluateOn(call ground, "1second")
    first evaluateOn(call ground, "2third"),

    if(len == 2,
      lexical = LexicalBlock createFrom(call arguments, call ground)
      lexical call("3first")
      lexical call("1second")
      lexical call("2third"),

      lexical = LexicalBlock createFrom(call arguments, call ground)
      lexical call(0, "3first")
      lexical call(1, "1second")
      lexical call(2, "2third"))))

CustomEnumerable2 = Origin mimic
CustomEnumerable2 mimic!(Mixins Enumerable)
CustomEnumerable2 each = macro(
  len = call arguments length

  if(len == 1,
    first = call arguments first
    first evaluateOn(call ground, 42)
    first evaluateOn(call ground, 16)
    first evaluateOn(call ground, 17),
    if(len == 2,
      lexical = LexicalBlock createFrom(call arguments, call ground)
      lexical call(42)
      lexical call(16)
      lexical call(17),

      lexical = LexicalBlock createFrom(call arguments, call ground)
      lexical call(0, 42)
      lexical call(1, 16)
      lexical call(2, 17))))

describe(Mixins,
  describe(Mixins Enumerable,
    describe("sort",
      it("should return a sorted list based on all the entries",
        set(4,4,2,1,4,23,6,4,7,21) sort should == [1, 2, 4, 6, 7, 21, 23]
      )
    )

    describe("asList",
      it("should return a list from a list",
        [1,2,3] asList should == [1,2,3]
      )

      it("should return a list based on all things yielded to each",
        CustomEnumerable asList should == ["3first", "1second", "2third"]
      )
    )

    describe("asTuple",
      it("should return a tuple from a list",
        [1,2,3] asTuple should == tuple(1,2,3)
      )

      it("should return a tuple based on all things yielded to each",
        CustomEnumerable asTuple should == tuple("3first", "1second", "2third")
      )
    )

    describe("map",
      it("should return an empty list for an empty enumerable",
        [] map(x, x+2) should == []
        {} map(x, x+2) should == []
        set map(x, x+2) should == []
      )

      it("should return the same list for something that only returns itself",
        [1, 2, 3] map(x, x) should == [1, 2, 3]
      )

      it("should take one argument and apply the inside",
        [1, 2, 3] map(+2) should == [3, 4, 5]
        [1, 2, 3] map(. 1) should == [1, 1, 1]
      )

      it("should take two arguments and apply the code with the argument name bound",
        [1, 2, 3] map(x, x+3) should == [4, 5, 6]
        [1, 2, 3] map(x, 1) should == [1, 1, 1]
      )

      it("should be able to destructure on the argument name",
        [[1,2], [2,3], [4,5]] map((x,y), [x+1, y-1]) should == [[2,1], [3,2], [5,4]]
      )

      it("should be able to destructure and ignore the rest of something",
        [[1,2,9,10], [2,3,11,12], [4,5,13,14]] map((x,y,_), cell?(:"_") should not be true. [x, y]) should == [[1,2], [2,3], [4,5]]
      )

      it("should be able to destructure and ignore in the middle of the pattern without binding anything",
        [[1,2,9], [2,3,11], [4,5,13]] map((x,_,y), cell?(:"_") should not be true. [x, y]) should == [[1,9], [2,11], [4,13]]
      )

      it("should be able to destructure and ignore several times in the middle of the pattern without binding anything",
        [[1,2,9,10,11], [2,3,11,12,13], [4,5,13,14,15]] map((x,_,y,_,q), cell?(:"_") should not be true. [x, y, q]) should == [[1,9,11], [2,11,13], [4,13,15]]
      )

      it("should be able to destructure recursively",
        [[[:x, :y, :z], [:q, :r, :p]], [[:b, :c, :d], [:i, :j, :k]], [[:i, :j, :k], [:i2, :j3, :k4]]] map(
          (v, (v2, _, v3)), cell?(:"_") should be false. [v, v2, v3]) should == [[[:x, :y, :z], :q, :p], [[:b, :c, :d], :i, :k], [[:i, :j, :k], :i2, :k4]]
      )

      it("should report a destructuring match error if destructuring doesn't add upp",
        fn([[1,2], [3,4], [4,5]] map((q,p,r), nil)) should signal(Condition Error DestructuringMismatch)
        fn([[1,2], [3,4], [4,5]] map((q), nil)) should signal(Condition Error DestructuringMismatch)
        fn([[1,2], [3,4], [4,5]] map((q,_,r), nil)) should signal(Condition Error DestructuringMismatch)
     )

      it("should report a destructuring match error if recursive destructuring doesn't add upp",
        fn([[[1,2],[1,2]], [[3,4],[1,2]], [[1,2],[4,5]]] map((q,(p)), nil)) should signal(Condition Error DestructuringMismatch)
        fn([[[1,2],[1,2]], [[3,4],[1,2]], [[1,2],[4,5]]] map((q,(p,r,f)), nil)) should signal(Condition Error DestructuringMismatch)
        fn([[[1,2],[1,2]], [[3,4],[1,2]], [[1,2],[4,5]]] map((q,(p,_,f)), nil)) should signal(Condition Error DestructuringMismatch)
      )
    )

    describe("map:set",
      it("should return an empty set for an empty enumerable",
        [] map:set(x, x+2) should == set
        {} map:set(x, x+2) should == set
        set map:set(x, x+2) should == set
      )

      it("should return the same set for something that only returns itself",
        [1, 2, 3] map:set(x, x) should == set(1, 2, 3)
      )

      it("should take one argument and apply the inside",
        [1, 2, 3] map:set(+2) should == set(3, 4, 5)
        [1, 2, 3] map:set(. 1) should == set(1)
      )

      it("should take two arguments and apply the code with the argument name bound",
        [1, 2, 3] map:set(x, x+3) should == set(4, 5, 6)
        [1, 2, 3] map:set(x, 1) should == set(1)
      )

      it("should be able to destructure on the argument name",
        [[1,2], [2,3], [4,5]] map:set((x,y), [x+1, y-1]) should == set([2,1], [3,2], [5,4])
      )

      it("should be able to destructure and ignore the rest of something",
        [[1,2,9,10], [2,3,11,12], [4,5,13,14]] map:set((x,y,_), cell?(:"_") should not be true. [x, y]) should == set([1,2], [2,3], [4,5])
      )

      it("should be able to destructure and ignore in the middle of the pattern without binding anything",
        [[1,2,9], [2,3,11], [4,5,13]] map:set((x,_,y), cell?(:"_") should not be true. [x, y]) should == set([1,9], [2,11], [4,13])
      )

      it("should be able to destructure and ignore several times in the middle of the pattern without binding anything",
        [[1,2,9,10,11], [2,3,11,12,13], [4,5,13,14,15]] map:set((x,_,y,_,q), cell?(:"_") should not be true. [x, y, q]) should == set([1,9,11], [2,11,13], [4,13,15])
      )

      it("should be able to destructure recursively",
        [[[:x, :y, :z], [:q, :r, :p]], [[:b, :c, :d], [:i, :j, :k]], [[:i, :j, :k], [:i2, :j3, :k4]]] map:set(
          (v, (v2, _, v3)), cell?(:"_") should be false. [v, v2, v3]) should == set([[:x, :y, :z], :q, :p], [[:b, :c, :d], :i, :k], [[:i, :j, :k], :i2, :k4])
      )

      it("should report a destructuring match error if destructuring doesn't add upp",
        fn([[1,2], [3,4], [4,5]] map:set((q,p,r), nil)) should signal(Condition Error DestructuringMismatch)
        fn([[1,2], [3,4], [4,5]] map:set((q), nil)) should signal(Condition Error DestructuringMismatch)
        fn([[1,2], [3,4], [4,5]] map:set((q,_,r), nil)) should signal(Condition Error DestructuringMismatch)
     )

      it("should report a destructuring match error if recursive destructuring doesn't add upp",
        fn([[[1,2],[1,2]], [[3,4],[1,2]], [[1,2],[4,5]]] map:set((q,(p)), nil)) should signal(Condition Error DestructuringMismatch)
        fn([[[1,2],[1,2]], [[3,4],[1,2]], [[1,2],[4,5]]] map:set((q,(p,r,f)), nil)) should signal(Condition Error DestructuringMismatch)
        fn([[[1,2],[1,2]], [[3,4],[1,2]], [[1,2],[4,5]]] map:set((q,(p,_,f)), nil)) should signal(Condition Error DestructuringMismatch)
      )
    )

    describe("map:dict",
      it("should return an empty dict for an empty enumerable",
        [] map:dict(x, x+2) should == dict
        {} map:dict(x, x+2) should == dict
        set map:dict(x, x+2) should == dict
      )

      it("should return the same dict for something that only returns itself",
        [1, 2, 3] map:dict(x, x=>x) should == dict(1=>1, 2=>2, 3=>3)
      )

      it("should take one argument and apply the inside",
        [1, 2, 3] map:dict(=>2) should == dict(1=>2, 2=>2, 3=>2)
        [1, 2, 3] map:dict(. 1=>1) should == dict(1=>1)
      )

      it("should take two arguments and apply the code with the argument name bound",
        [1, 2, 3] map:dict(x, x=>x+3) should == dict(1=>4, 2=>5, 3=>6)
        [1, 2, 3] map:dict(x, x=>1) should == dict(1=>1, 2=>1, 3=>1)
        [1, 2, 3] map:dict(x, x) should == dict(1=>nil, 2=>nil, 3=>nil)
      )

      it("should be able to destructure on the argument name",
        [[1,2], [2,3], [4,5]] map:dict((x,y), [x+1, y-1]) should == {[2,1] => nil, [3,2] => nil, [5,4] => nil}
      )

      it("should be able to destructure and ignore the rest of something",
        [[1,2,9,10], [2,3,11,12], [4,5,13,14]] map:dict((x,y,_), cell?(:"_") should not be true. [x, y]) should == {[1,2] => nil, [2,3] => nil, [4,5] => nil}
      )

      it("should be able to destructure and ignore in the middle of the pattern without binding anything",
        [[1,2,9], [2,3,11], [4,5,13]] map:dict((x,_,y), cell?(:"_") should not be true. [x, y]) should == {[1,9] => nil, [2,11] => nil, [4,13] => nil}
      )

      it("should be able to destructure and ignore several times in the middle of the pattern without binding anything",
        [[1,2,9,10,11], [2,3,11,12,13], [4,5,13,14,15]] map:dict((x,_,y,_,q), cell?(:"_") should not be true. [x, y, q]) should == {[1,9,11] => nil, [2,11,13] => nil, [4,13,15] => nil}
      )

      it("should be able to destructure recursively",
        [[[:x, :y, :z], [:q, :r, :p]], [[:b, :c, :d], [:i, :j, :k]], [[:i, :j, :k], [:i2, :j3, :k4]]] map:dict(
          (v, (v2, _, v3)), cell?(:"_") should be false. [v, v2, v3]) should == {[[:x, :y, :z], :q, :p] => nil, [[:b, :c, :d], :i, :k] => nil, [[:i, :j, :k], :i2, :k4] => nil}
      )

      it("should report a destructuring match error if destructuring doesn't add upp",
        fn([[1,2], [3,4], [4,5]] map:dict((q,p,r), nil)) should signal(Condition Error DestructuringMismatch)
        fn([[1,2], [3,4], [4,5]] map:dict((q), nil)) should signal(Condition Error DestructuringMismatch)
        fn([[1,2], [3,4], [4,5]] map:dict((q,_,r), nil)) should signal(Condition Error DestructuringMismatch)
     )

      it("should report a destructuring match error if recursive destructuring doesn't add upp",
        fn([[[1,2],[1,2]], [[3,4],[1,2]], [[1,2],[4,5]]] map:dict((q,(p)), nil)) should signal(Condition Error DestructuringMismatch)
        fn([[[1,2],[1,2]], [[3,4],[1,2]], [[1,2],[4,5]]] map:dict((q,(p,r,f)), nil)) should signal(Condition Error DestructuringMismatch)
        fn([[[1,2],[1,2]], [[3,4],[1,2]], [[1,2],[4,5]]] map:dict((q,(p,_,f)), nil)) should signal(Condition Error DestructuringMismatch)
      )
    )

    describe("mapFn",
      it("should take zero arguments and just return the elements in a list",
        [1, 2, 3] mapFn should == [1, 2, 3]
        CustomEnumerable mapFn should == ["3first", "1second", "2third"]
      )

      it("should take one lexical block argument and apply that to each element, and return the result in a list",
        x = fn(arg, arg+2). [1, 2, 3] mapFn(x) should == [3, 4, 5]
        x = fn(arg, arg[0..2])
        CustomEnumerable mapFn(x) should == ["3fi", "1se", "2th"]
      )

      it("should take several lexical blocks and chain them together",
        x = fn(arg, arg+2). x2 = fn(arg, arg*2). [1, 2, 3] mapFn(x, x2) should == [6, 8, 10]
        x = fn(arg, arg[0..2])
        x2 = fn(arg, arg + "flurg")
        CustomEnumerable mapFn(x, x2) should == ["3fiflurg", "1seflurg", "2thflurg"]
      )
    )

    describe("mapFn:dict",
      it("should take zero arguments and just return the elements in a dict",
        [1, 2, 3] mapFn:dict should == {1 => nil,  2 => nil, 3 => nil}
        CustomEnumerable mapFn:dict should == {"3first" => nil, "1second" => nil, "2third" => nil}
      )

      it("should take one lexical block argument and apply that to each element, and return the result in a dict",
        x = fn(arg, arg => arg + 2). [1, 2, 3] mapFn:dict(x) should == {1 => 3, 2 => 4, 3 => 5}
        x = fn(arg, arg[0..2] => arg[0..0])
        CustomEnumerable mapFn:dict(x) should == {"3fi" => "3" , "1se" => "1", "2th" => "2"}
      )

      it("should take several lexical blocks and chain them together",
        x = fn(arg, arg => arg+2). x2 = fn(arg, arg value => arg key). [1, 2, 3] mapFn:dict(x, x2) should == {3 => 1, 4 => 2, 5 => 3}
        x = fn(arg, arg[0..2])
        x2 = fn(arg, arg  => "flurg")
        CustomEnumerable mapFn:dict(x, x2) should == {"3fi" => "flurg", "1se" => "flurg", "2th" => "flurg"}
      )
    )

    describe("mapFn:set",
      it("should take zero arguments and just return the elements in a set",
        [1, 2, 3] mapFn:set should == #{1, 2, 3}
        CustomEnumerable mapFn:set should == #{"3first", "1second", "2third"}
      )

      it("should take one lexical block argument and apply that to each element, and return the result in a set",
        x = fn(arg, arg+2). [1, 2, 3] mapFn:set(x) should == #{3, 4, 5}
        x = fn(arg, arg[0..2])
        CustomEnumerable mapFn:set(x) should == #{"3fi", "1se", "2th"}
      )

      it("should take several lexical blocks and chain them together",
        x = fn(arg, arg+2). x2 = fn(arg, arg*2). [1, 2, 3] mapFn:set(x, x2) should == #{6, 8, 10}
        x = fn(arg, arg[0..2])
        x2 = fn(arg, arg + "flurg")
        CustomEnumerable mapFn:set(x, x2) should == #{"3fiflurg", "1seflurg", "2thflurg"}
      )
    )

    describe("collect",
      it("should return an empty list for an empty enumerable",
        [] collect(x, x+2) should == []
        {} collect(x, x+2) should == []
        set collect(x, x+2) should == []
      )

      it("should return the same list for something that only returns itself",
        [1, 2, 3] collect(x, x) should == [1, 2, 3]
      )

      it("should take one argument and apply the inside",
        [1, 2, 3] collect(+2) should == [3, 4, 5]
        [1, 2, 3] collect(. 1) should == [1, 1, 1]
      )

      it("should take two arguments and apply the code with the argument name bound",
        [1, 2, 3] collect(x, x+3) should == [4, 5, 6]
        [1, 2, 3] collect(x, 1) should == [1, 1, 1]
      )

      it("should be able to destructure on the argument name",
        [[1,2], [2,3], [4,5]] collect((x,y), [x+1, y-1]) should == [[2,1], [3,2], [5,4]]
      )

      it("should be able to destructure and ignore the rest of something",
        [[1,2,9,10], [2,3,11,12], [4,5,13,14]] collect((x,y,_), cell?(:"_") should not be true. [x, y]) should == [[1,2], [2,3], [4,5]]
      )

      it("should be able to destructure and ignore in the middle of the pattern without binding anything",
        [[1,2,9], [2,3,11], [4,5,13]] collect((x,_,y), cell?(:"_") should not be true. [x, y]) should == [[1,9], [2,11], [4,13]]
      )

      it("should be able to destructure and ignore several times in the middle of the pattern without binding anything",
        [[1,2,9,10,11], [2,3,11,12,13], [4,5,13,14,15]] collect((x,_,y,_,q), cell?(:"_") should not be true. [x, y, q]) should == [[1,9,11], [2,11,13], [4,13,15]]
      )

      it("should be able to destructure recursively",
        [[[:x, :y, :z], [:q, :r, :p]], [[:b, :c, :d], [:i, :j, :k]], [[:i, :j, :k], [:i2, :j3, :k4]]] collect(
          (v, (v2, _, v3)), cell?(:"_") should be false. [v, v2, v3]) should == [[[:x, :y, :z], :q, :p], [[:b, :c, :d], :i, :k], [[:i, :j, :k], :i2, :k4]]
      )

      it("should report a destructuring match error if destructuring doesn't add upp",
        fn([[1,2], [3,4], [4,5]] collect((q,p,r), nil)) should signal(Condition Error DestructuringMismatch)
        fn([[1,2], [3,4], [4,5]] collect((q), nil)) should signal(Condition Error DestructuringMismatch)
        fn([[1,2], [3,4], [4,5]] collect((q,_,r), nil)) should signal(Condition Error DestructuringMismatch)
      )

      it("should report a destructuring match error if recursive destructuring doesn't add upp",
        fn([[[1,2],[1,2]], [[3,4],[1,2]], [[1,2],[4,5]]] collect((q,(p)), nil)) should signal(Condition Error DestructuringMismatch)
        fn([[[1,2],[1,2]], [[3,4],[1,2]], [[1,2],[4,5]]] collect((q,(p,r,f)), nil)) should signal(Condition Error DestructuringMismatch)
        fn([[[1,2],[1,2]], [[3,4],[1,2]], [[1,2],[4,5]]] collect((q,(p,_,f)), nil)) should signal(Condition Error DestructuringMismatch)
      )
    )

    describe("collect:set",
      it("should return an empty set for an empty enumerable",
        [] collect:set(x, x+2) should == set
        {} collect:set(x, x+2) should == set
        set collect:set(x, x+2) should == set
      )

      it("should return the same set for something that only returns itself",
        [1, 2, 3] collect:set(x, x) should == set(1, 2, 3)
      )

      it("should take one argument and apply the inside",
        [1, 2, 3] collect:set(+2) should == set(3, 4, 5)
        [1, 2, 3] collect:set(. 1) should == set(1)
      )

      it("should take two arguments and apply the code with the argument name bound",
        [1, 2, 3] collect:set(x, x+3) should == set(4, 5, 6)
        [1, 2, 3] collect:set(x, 1) should == set(1)
      )

      it("should be able to destructure on the argument name",
        [[1,2], [2,3], [4,5]] collect:set((x,y), [x+1, y-1]) should == set([2,1], [3,2], [5,4])
      )

      it("should be able to destructure and ignore the rest of something",
        [[1,2,9,10], [2,3,11,12], [4,5,13,14]] collect:set((x,y,_), cell?(:"_") should not be true. [x, y]) should == set([1,2], [2,3], [4,5])
      )

      it("should be able to destructure and ignore in the middle of the pattern without binding anything",
        [[1,2,9], [2,3,11], [4,5,13]] collect:set((x,_,y), cell?(:"_") should not be true. [x, y]) should == set([1,9], [2,11], [4,13])
      )

      it("should be able to destructure and ignore several times in the middle of the pattern without binding anything",
        [[1,2,9,10,11], [2,3,11,12,13], [4,5,13,14,15]] collect:set((x,_,y,_,q), cell?(:"_") should not be true. [x, y, q]) should == set([1,9,11], [2,11,13], [4,13,15])
      )

      it("should be able to destructure recursively",
        [[[:x, :y, :z], [:q, :r, :p]], [[:b, :c, :d], [:i, :j, :k]], [[:i, :j, :k], [:i2, :j3, :k4]]] collect:set(
          (v, (v2, _, v3)), cell?(:"_") should be false. [v, v2, v3]) should == set([[:x, :y, :z], :q, :p], [[:b, :c, :d], :i, :k], [[:i, :j, :k], :i2, :k4])
      )

      it("should report a destructuring match error if destructuring doesn't add upp",
        fn([[1,2], [3,4], [4,5]] collect:set((q,p,r), nil)) should signal(Condition Error DestructuringMismatch)
        fn([[1,2], [3,4], [4,5]] collect:set((q), nil)) should signal(Condition Error DestructuringMismatch)
        fn([[1,2], [3,4], [4,5]] collect:set((q,_,r), nil)) should signal(Condition Error DestructuringMismatch)
     )

      it("should report a destructuring match error if recursive destructuring doesn't add upp",
        fn([[[1,2],[1,2]], [[3,4],[1,2]], [[1,2],[4,5]]] collect:set((q,(p)), nil)) should signal(Condition Error DestructuringMismatch)
        fn([[[1,2],[1,2]], [[3,4],[1,2]], [[1,2],[4,5]]] collect:set((q,(p,r,f)), nil)) should signal(Condition Error DestructuringMismatch)
        fn([[[1,2],[1,2]], [[3,4],[1,2]], [[1,2],[4,5]]] collect:set((q,(p,_,f)), nil)) should signal(Condition Error DestructuringMismatch)
      )
    )

    describe("collect:dict",
      it("should return an empty dict for an empty enumerable",
        [] collect:dict(x, x+2) should == dict
        {} collect:dict(x, x+2) should == dict
        set collect:dict(x, x+2) should == dict
      )

      it("should return the same dict for something that only returns itself",
        [1, 2, 3] collect:dict(x, x=>x) should == dict(1=>1, 2=>2, 3=>3)
      )

      it("should take one argument and apply the inside",
        [1, 2, 3] collect:dict(=>2) should == dict(1=>2, 2=>2, 3=>2)
        [1, 2, 3] collect:dict(. 1=>1) should == dict(1=>1)
      )

      it("should take two arguments and apply the code with the argument name bound",
        [1, 2, 3] collect:dict(x, x=>x+3) should == dict(1=>4, 2=>5, 3=>6)
        [1, 2, 3] collect:dict(x, x=>1) should == dict(1=>1, 2=>1, 3=>1)
        [1, 2, 3] collect:dict(x, x) should == dict(1=>nil, 2=>nil, 3=>nil)
      )

      it("should be able to destructure on the argument name",
        [[1,2], [2,3], [4,5]] collect:dict((x,y), [x+1, y-1]) should == {[2,1] => nil, [3,2] => nil, [5,4] => nil}
      )

      it("should be able to destructure and ignore the rest of something",
        [[1,2,9,10], [2,3,11,12], [4,5,13,14]] collect:dict((x,y,_), cell?(:"_") should not be true. [x, y]) should == {[1,2] => nil, [2,3] => nil, [4,5] => nil}
      )

      it("should be able to destructure and ignore in the middle of the pattern without binding anything",
        [[1,2,9], [2,3,11], [4,5,13]] collect:dict((x,_,y), cell?(:"_") should not be true. [x, y]) should == {[1,9] => nil, [2,11] => nil, [4,13] => nil}
      )

      it("should be able to destructure and ignore several times in the middle of the pattern without binding anything",
        [[1,2,9,10,11], [2,3,11,12,13], [4,5,13,14,15]] collect:dict((x,_,y,_,q), cell?(:"_") should not be true. [x, y, q]) should == {[1,9,11] => nil, [2,11,13] => nil, [4,13,15] => nil}
      )

      it("should be able to destructure recursively",
        [[[:x, :y, :z], [:q, :r, :p]], [[:b, :c, :d], [:i, :j, :k]], [[:i, :j, :k], [:i2, :j3, :k4]]] collect:dict(
          (v, (v2, _, v3)), cell?(:"_") should be false. [v, v2, v3]) should == {[[:x, :y, :z], :q, :p] => nil, [[:b, :c, :d], :i, :k] => nil, [[:i, :j, :k], :i2, :k4] => nil}
      )

      it("should report a destructuring match error if destructuring doesn't add upp",
        fn([[1,2], [3,4], [4,5]] collect:dict((q,p,r), nil)) should signal(Condition Error DestructuringMismatch)
        fn([[1,2], [3,4], [4,5]] collect:dict((q), nil)) should signal(Condition Error DestructuringMismatch)
        fn([[1,2], [3,4], [4,5]] collect:dict((q,_,r), nil)) should signal(Condition Error DestructuringMismatch)
     )

      it("should report a destructuring match error if recursive destructuring doesn't add upp",
        fn([[[1,2],[1,2]], [[3,4],[1,2]], [[1,2],[4,5]]] collect:dict((q,(p)), nil)) should signal(Condition Error DestructuringMismatch)
        fn([[[1,2],[1,2]], [[3,4],[1,2]], [[1,2],[4,5]]] collect:dict((q,(p,r,f)), nil)) should signal(Condition Error DestructuringMismatch)
        fn([[[1,2],[1,2]], [[3,4],[1,2]], [[1,2],[4,5]]] collect:dict((q,(p,_,f)), nil)) should signal(Condition Error DestructuringMismatch)
      )
    )

    describe("collectFn",
      it("should take zero arguments and just return the elements in a list",
        [1, 2, 3] collectFn should == [1, 2, 3]
        CustomEnumerable collectFn should == ["3first", "1second", "2third"]
      )

      it("should take one lexical block argument and apply that to each element, and return the result in a list",
        x = fn(arg, arg+2). [1, 2, 3] collectFn(x) should == [3, 4, 5]
        x = fn(arg, arg[0..2])
        CustomEnumerable collectFn(x) should == ["3fi", "1se", "2th"]
      )

      it("should take several lexical blocks and chain them together",
        x = fn(arg, arg+2). x2 = fn(arg, arg*2). [1, 2, 3] collectFn(x, x2) should == [6, 8, 10]
        x = fn(arg, arg[0..2])
        x2 = fn(arg, arg + "flurg")
        CustomEnumerable collectFn(x, x2) should == ["3fiflurg", "1seflurg", "2thflurg"]
      )
    )

    describe("collectFn:dict",
      it("should take zero arguments and just return the elements in a dict",
        [1, 2, 3] collectFn:dict should == {1 => nil,  2 => nil, 3 => nil}
        CustomEnumerable collectFn:dict should == {"3first" => nil, "1second" => nil, "2third" => nil}
      )

      it("should take one lexical block argument and apply that to each element, and return the result in a dict",
        x = fn(arg, arg => arg + 2). [1, 2, 3] collectFn:dict(x) should == {1 => 3, 2 => 4, 3 => 5}
        x = fn(arg, arg[0..2] => arg[0..0])
        CustomEnumerable collectFn:dict(x) should == {"3fi" => "3" , "1se" => "1", "2th" => "2"}
      )

      it("should take several lexical blocks and chain them together",
        x = fn(arg, arg => arg+2). x2 = fn(arg, arg value => arg key). [1, 2, 3] collectFn:dict(x, x2) should == {3 => 1, 4 => 2, 5 => 3}
        x = fn(arg, arg[0..2])
        x2 = fn(arg, arg  => "flurg")
        CustomEnumerable collectFn:dict(x, x2) should == {"3fi" => "flurg", "1se" => "flurg", "2th" => "flurg"}
      )
    )

    describe("collectFn:set",
      it("should take zero arguments and just return the elements in a set",
        [1, 2, 3] collectFn:set should == #{1, 2, 3}
        CustomEnumerable collectFn:set should == #{"3first", "1second", "2third"}
      )

      it("should take one lexical block argument and apply that to each element, and return the result in a set",
        x = fn(arg, arg+2). [1, 2, 3] collectFn:set(x) should == #{3, 4, 5}
        x = fn(arg, arg[0..2])
        CustomEnumerable collectFn:set(x) should == #{"3fi", "1se", "2th"}
      )

      it("should take several lexical blocks and chain them together",
        x = fn(arg, arg+2). x2 = fn(arg, arg*2). [1, 2, 3] collectFn:set(x, x2) should == #{6, 8, 10}
        x = fn(arg, arg[0..2])
        x2 = fn(arg, arg + "flurg")
        CustomEnumerable collectFn:set(x, x2) should == #{"3fiflurg", "1seflurg", "2thflurg"}
      )
    )

    describe("any?",
      it("should take zero arguments and just check if any of the values are true",
        [1,2,3] any?
        [nil,false,nil] any? should be false
        [nil,false,true] any? should be true
        CustomEnumerable any? should be true
      )

      it("should take one argument that is a predicate that is applied to each element in the enumeration",
        [1,2,3] any?(==2) should be true
        [nil,false,nil] any?(nil?) should be true
        [nil,false,true] any?(==2) should be false
        CustomEnumerable any?(!= "foo") should be true
      )

      it("should take two arguments that will be turned into a lexical block and applied",
        [1,2,3] any?(x, x==2) should be true
        [nil,false,nil] any?(x, x nil?) should be true
        [nil,false,true] any?(x, x==2) should be false
        CustomEnumerable any?(x, x != "foo") should be true
      )

      it("should be able to destructure on the argument name",
        result = []
        [[1,2], [2,3], [4,5]] any?((x,y), result << [x+1, y-1]. nil)
        result should == [[2,1], [3,2], [5,4]]
      )

      it("should be able to destructure and ignore the rest of something",
        result = []
        [[1,2,9,10], [2,3,11,12], [4,5,13,14]] any?((x,y,_), cell?(:"_") should not be true. result << [x, y]. nil)
        result should == [[1,2], [2,3], [4,5]]
      )

      it("should be able to destructure and ignore in the middle of the pattern without binding anything",
        result = []
        [[1,2,9], [2,3,11], [4,5,13]] any?((x,_,y), cell?(:"_") should not be true. result << [x, y]. nil) 
        result should == [[1,9], [2,11], [4,13]]
      )

      it("should be able to destructure and ignore several times in the middle of the pattern without binding anything",
        result = []
        [[1,2,9,10,11], [2,3,11,12,13], [4,5,13,14,15]] any?((x,_,y,_,q), cell?(:"_") should not be true. result << [x, y, q]. nil) 
        result should == [[1,9,11], [2,11,13], [4,13,15]]
      )

      it("should be able to destructure recursively",
        result = []
        [[[:x, :y, :z], [:q, :r, :p]], [[:b, :c, :d], [:i, :j, :k]], [[:i, :j, :k], [:i2, :j3, :k4]]] any?(
          (v, (v2, _, v3)), cell?(:"_") should be false. result << [v, v2, v3]. nil) 
        result should == [[[:x, :y, :z], :q, :p], [[:b, :c, :d], :i, :k], [[:i, :j, :k], :i2, :k4]]
      )

      it("should report a destructuring match error if destructuring doesn't add upp",
        fn([[1,2], [3,4], [4,5]] any?((q,p,r), nil)) should signal(Condition Error DestructuringMismatch)
        fn([[1,2], [3,4], [4,5]] any?((q), nil)) should signal(Condition Error DestructuringMismatch)
        fn([[1,2], [3,4], [4,5]] any?((q,_,r), nil)) should signal(Condition Error DestructuringMismatch)
      )

      it("should report a destructuring match error if recursive destructuring doesn't add upp",
        fn([[[1,2],[1,2]], [[3,4],[1,2]], [[1,2],[4,5]]] any?((q,(p)), nil)) should signal(Condition Error DestructuringMismatch)
        fn([[[1,2],[1,2]], [[3,4],[1,2]], [[1,2],[4,5]]] any?((q,(p,r,f)), nil)) should signal(Condition Error DestructuringMismatch)
        fn([[[1,2],[1,2]], [[3,4],[1,2]], [[1,2],[4,5]]] any?((q,(p,_,f)), nil)) should signal(Condition Error DestructuringMismatch)
      )
    )

    describe("none?",
      it("should take zero arguments and just check if any of the values are true, and then return false",
        [1,2,3] none? should be false
        [nil,false,nil] none? should be true
        [nil,false,true] none? should be false
        CustomEnumerable none? should be false
      )

      it("should take one argument that is a predicate that is applied to each element in the enumeration",
        [1,2,3] none?(==2) should be false
        [nil,false,nil] none?(nil?) should be false
        [nil,false,true] none?(==2) should be true
        CustomEnumerable none?(!= "foo") should be false
      )

      it("should take two arguments that will be turned into a lexical block and applied",
        [1,2,3] none?(x, x==2) should be false
        [nil,false,nil] none?(x, x nil?) should be false
        [nil,false,true] none?(x, x==2) should be true
        CustomEnumerable none?(x, x != "foo") should be false
      )

      it("should be able to destructure on the argument name",
        result = []
        [[1,2], [2,3], [4,5]] none?((x,y), result << [x+1, y-1]. nil)
        result should == [[2,1], [3,2], [5,4]]
      )

      it("should be able to destructure and ignore the rest of something",
        result = []
        [[1,2,9,10], [2,3,11,12], [4,5,13,14]] none?((x,y,_), cell?(:"_") should not be true. result << [x, y]. nil)
        result should == [[1,2], [2,3], [4,5]]
      )

      it("should be able to destructure and ignore in the middle of the pattern without binding anything",
        result = []
        [[1,2,9], [2,3,11], [4,5,13]] none?((x,_,y), cell?(:"_") should not be true. result << [x, y]. nil) 
        result should == [[1,9], [2,11], [4,13]]
      )

      it("should be able to destructure and ignore several times in the middle of the pattern without binding anything",
        result = []
        [[1,2,9,10,11], [2,3,11,12,13], [4,5,13,14,15]] none?((x,_,y,_,q), cell?(:"_") should not be true. result << [x, y, q]. nil) 
        result should == [[1,9,11], [2,11,13], [4,13,15]]
      )

      it("should be able to destructure recursively",
        result = []
        [[[:x, :y, :z], [:q, :r, :p]], [[:b, :c, :d], [:i, :j, :k]], [[:i, :j, :k], [:i2, :j3, :k4]]] none?(
          (v, (v2, _, v3)), cell?(:"_") should be false. result << [v, v2, v3]. nil) 
        result should == [[[:x, :y, :z], :q, :p], [[:b, :c, :d], :i, :k], [[:i, :j, :k], :i2, :k4]]
      )

      it("should report a destructuring match error if destructuring doesn't add upp",
        fn([[1,2], [3,4], [4,5]] none?((q,p,r), nil)) should signal(Condition Error DestructuringMismatch)
        fn([[1,2], [3,4], [4,5]] none?((q), nil)) should signal(Condition Error DestructuringMismatch)
        fn([[1,2], [3,4], [4,5]] none?((q,_,r), nil)) should signal(Condition Error DestructuringMismatch)
      )

      it("should report a destructuring match error if recursive destructuring doesn't add upp",
        fn([[[1,2],[1,2]], [[3,4],[1,2]], [[1,2],[4,5]]] none?((q,(p)), nil)) should signal(Condition Error DestructuringMismatch)
        fn([[[1,2],[1,2]], [[3,4],[1,2]], [[1,2],[4,5]]] none?((q,(p,r,f)), nil)) should signal(Condition Error DestructuringMismatch)
        fn([[[1,2],[1,2]], [[3,4],[1,2]], [[1,2],[4,5]]] none?((q,(p,_,f)), nil)) should signal(Condition Error DestructuringMismatch)
      )
    )

    describe("some",
      it("should take zero arguments and just check if any of the values are true, and then return it",
        [1,2,3] some should == 1
        [nil,false,nil] some should be false
        [nil,false,true] some should be true
        CustomEnumerable some should == "3first"
      )

      it("should take one argument that is a predicate that is applied to each element in the enumeration",
        [1,2,3] some(==2 && 3) should == 3
        [nil,false,nil] some(nil? && 42) should == 42
        [nil,false,true] some(==2 && 3) should be false
        CustomEnumerable some(!= "foo" && "blarg") should == "blarg"
      )

      it("should take two arguments that will be turned into a lexical block and applied",
        [1,2,3] some(x, x==2 && 3) should == 3
        [nil,false,nil] some(x, x nil? && 42) should == 42
        [nil,false,true] some(x, x==2 && 3) should be false
        CustomEnumerable some(x, x != "foo" && "blarg") should == "blarg"
      )

      it("should be able to destructure on the argument name",
        result = []
        [[1,2], [2,3], [4,5]] some((x,y), result << [x+1, y-1]. nil)
        result should == [[2,1], [3,2], [5,4]]
      )

      it("should be able to destructure and ignore the rest of something",
        result = []
        [[1,2,9,10], [2,3,11,12], [4,5,13,14]] some((x,y,_), cell?(:"_") should not be true. result << [x, y]. nil)
        result should == [[1,2], [2,3], [4,5]]
      )

      it("should be able to destructure and ignore in the middle of the pattern without binding anything",
        result = []
        [[1,2,9], [2,3,11], [4,5,13]] some((x,_,y), cell?(:"_") should not be true. result << [x, y]. nil) 
        result should == [[1,9], [2,11], [4,13]]
      )

      it("should be able to destructure and ignore several times in the middle of the pattern without binding anything",
        result = []
        [[1,2,9,10,11], [2,3,11,12,13], [4,5,13,14,15]] some((x,_,y,_,q), cell?(:"_") should not be true. result << [x, y, q]. nil) 
        result should == [[1,9,11], [2,11,13], [4,13,15]]
      )

      it("should be able to destructure recursively",
        result = []
        [[[:x, :y, :z], [:q, :r, :p]], [[:b, :c, :d], [:i, :j, :k]], [[:i, :j, :k], [:i2, :j3, :k4]]] some(
          (v, (v2, _, v3)), cell?(:"_") should be false. result << [v, v2, v3]. nil) 
        result should == [[[:x, :y, :z], :q, :p], [[:b, :c, :d], :i, :k], [[:i, :j, :k], :i2, :k4]]
      )

      it("should report a destructuring match error if destructuring doesn't add upp",
        fn([[1,2], [3,4], [4,5]] some((q,p,r), nil)) should signal(Condition Error DestructuringMismatch)
        fn([[1,2], [3,4], [4,5]] some((q), nil)) should signal(Condition Error DestructuringMismatch)
        fn([[1,2], [3,4], [4,5]] some((q,_,r), nil)) should signal(Condition Error DestructuringMismatch)
      )

      it("should report a destructuring match error if recursive destructuring doesn't add upp",
        fn([[[1,2],[1,2]], [[3,4],[1,2]], [[1,2],[4,5]]] some((q,(p)), nil)) should signal(Condition Error DestructuringMismatch)
        fn([[[1,2],[1,2]], [[3,4],[1,2]], [[1,2],[4,5]]] some((q,(p,r,f)), nil)) should signal(Condition Error DestructuringMismatch)
        fn([[[1,2],[1,2]], [[3,4],[1,2]], [[1,2],[4,5]]] some((q,(p,_,f)), nil)) should signal(Condition Error DestructuringMismatch)
      )
    )

    describe("find",
      it("should take zero arguments and just check if any of the values are true, and then return it",
        [1,2,3] find should == 1
        [nil,false,nil] find should be nil
        [nil,false,true] find should be true
        CustomEnumerable find should == "3first"
      )

      it("should take one argument that is a predicate that is applied to each element in the enumeration",
        [1,2,3] find(==2) should == 2
        [nil,false,nil] find(nil?) should be nil
        [nil,false,true] find(==2) should be nil
        CustomEnumerable find(!= "foo") should == "3first"
      )

      it("should take two arguments that will be turned into a lexical block and applied",
        [1,2,3] find(x, x==2) should == 2
        [nil,false,nil] find(x, x nil?) should be nil
        [nil,false,true] find(x, x==2) should be nil
        CustomEnumerable find(x, x != "foo") should == "3first"
      )

      it("should be able to destructure on the argument name",
        result = []
        [[1,2], [2,3], [4,5]] find((x,y), result << [x+1, y-1]. nil)
        result should == [[2,1], [3,2], [5,4]]
      )

      it("should be able to destructure and ignore the rest of something",
        result = []
        [[1,2,9,10], [2,3,11,12], [4,5,13,14]] find((x,y,_), cell?(:"_") should not be true. result << [x, y]. nil)
        result should == [[1,2], [2,3], [4,5]]
      )

      it("should be able to destructure and ignore in the middle of the pattern without binding anything",
        result = []
        [[1,2,9], [2,3,11], [4,5,13]] find((x,_,y), cell?(:"_") should not be true. result << [x, y]. nil) 
        result should == [[1,9], [2,11], [4,13]]
      )

      it("should be able to destructure and ignore several times in the middle of the pattern without binding anything",
        result = []
        [[1,2,9,10,11], [2,3,11,12,13], [4,5,13,14,15]] find((x,_,y,_,q), cell?(:"_") should not be true. result << [x, y, q]. nil) 
        result should == [[1,9,11], [2,11,13], [4,13,15]]
      )

      it("should be able to destructure recursively",
        result = []
        [[[:x, :y, :z], [:q, :r, :p]], [[:b, :c, :d], [:i, :j, :k]], [[:i, :j, :k], [:i2, :j3, :k4]]] find(
          (v, (v2, _, v3)), cell?(:"_") should be false. result << [v, v2, v3]. nil) 
        result should == [[[:x, :y, :z], :q, :p], [[:b, :c, :d], :i, :k], [[:i, :j, :k], :i2, :k4]]
      )

      it("should report a destructuring match error if destructuring doesn't add upp",
        fn([[1,2], [3,4], [4,5]] find((q,p,r), nil)) should signal(Condition Error DestructuringMismatch)
        fn([[1,2], [3,4], [4,5]] find((q), nil)) should signal(Condition Error DestructuringMismatch)
        fn([[1,2], [3,4], [4,5]] find((q,_,r), nil)) should signal(Condition Error DestructuringMismatch)
      )

      it("should report a destructuring match error if recursive destructuring doesn't add upp",
        fn([[[1,2],[1,2]], [[3,4],[1,2]], [[1,2],[4,5]]] find((q,(p)), nil)) should signal(Condition Error DestructuringMismatch)
        fn([[[1,2],[1,2]], [[3,4],[1,2]], [[1,2],[4,5]]] find((q,(p,r,f)), nil)) should signal(Condition Error DestructuringMismatch)
        fn([[[1,2],[1,2]], [[3,4],[1,2]], [[1,2],[4,5]]] find((q,(p,_,f)), nil)) should signal(Condition Error DestructuringMismatch)
      )
    )

    describe("detect",
      it("should take zero arguments and just check if any of the values are true, and then return it",
        [1,2,3] detect should == 1
        [nil,false,nil] detect should be nil
        [nil,false,true] detect should be true
        CustomEnumerable detect should == "3first"
      )

      it("should take one argument that is a predicate that is applied to each element in the enumeration",
        [1,2,3] detect(==2) should == 2
        [nil,false,nil] detect(nil?) should be nil
        [nil,false,true] detect(==2) should be nil
        CustomEnumerable detect(!= "foo") should == "3first"
      )

      it("should take two arguments that will be turned into a lexical block and applied",
        [1,2,3] detect(x, x==2) should == 2
        [nil,false,nil] detect(x, x nil?) should be nil
        [nil,false,true] detect(x, x==2) should be nil
        CustomEnumerable detect(x, x != "foo") should == "3first"
      )

      it("should be able to destructure on the argument name",
        result = []
        [[1,2], [2,3], [4,5]] detect((x,y), result << [x+1, y-1]. nil)
        result should == [[2,1], [3,2], [5,4]]
      )

      it("should be able to destructure and ignore the rest of something",
        result = []
        [[1,2,9,10], [2,3,11,12], [4,5,13,14]] detect((x,y,_), cell?(:"_") should not be true. result << [x, y]. nil)
        result should == [[1,2], [2,3], [4,5]]
      )

      it("should be able to destructure and ignore in the middle of the pattern without binding anything",
        result = []
        [[1,2,9], [2,3,11], [4,5,13]] detect((x,_,y), cell?(:"_") should not be true. result << [x, y]. nil) 
        result should == [[1,9], [2,11], [4,13]]
      )

      it("should be able to destructure and ignore several times in the middle of the pattern without binding anything",
        result = []
        [[1,2,9,10,11], [2,3,11,12,13], [4,5,13,14,15]] detect((x,_,y,_,q), cell?(:"_") should not be true. result << [x, y, q]. nil) 
        result should == [[1,9,11], [2,11,13], [4,13,15]]
      )

      it("should be able to destructure recursively",
        result = []
        [[[:x, :y, :z], [:q, :r, :p]], [[:b, :c, :d], [:i, :j, :k]], [[:i, :j, :k], [:i2, :j3, :k4]]] detect(
          (v, (v2, _, v3)), cell?(:"_") should be false. result << [v, v2, v3]. nil) 
        result should == [[[:x, :y, :z], :q, :p], [[:b, :c, :d], :i, :k], [[:i, :j, :k], :i2, :k4]]
      )

      it("should report a destructuring match error if destructuring doesn't add upp",
        fn([[1,2], [3,4], [4,5]] detect((q,p,r), nil)) should signal(Condition Error DestructuringMismatch)
        fn([[1,2], [3,4], [4,5]] detect((q), nil)) should signal(Condition Error DestructuringMismatch)
        fn([[1,2], [3,4], [4,5]] detect((q,_,r), nil)) should signal(Condition Error DestructuringMismatch)
      )

      it("should report a destructuring match error if recursive destructuring doesn't add upp",
        fn([[[1,2],[1,2]], [[3,4],[1,2]], [[1,2],[4,5]]] detect((q,(p)), nil)) should signal(Condition Error DestructuringMismatch)
        fn([[[1,2],[1,2]], [[3,4],[1,2]], [[1,2],[4,5]]] detect((q,(p,r,f)), nil)) should signal(Condition Error DestructuringMismatch)
        fn([[[1,2],[1,2]], [[3,4],[1,2]], [[1,2],[4,5]]] detect((q,(p,_,f)), nil)) should signal(Condition Error DestructuringMismatch)
      )
    )


    describe("inject",
      ;; inject needs: a start value, an argument name, a sum argument name, and code
      ;; versions:

      ;; inject(+)                                  => inject(    sum,    x,    sum    +(x))
      ;; inject(x, + x)                             => inject(    sumArg, x,    sumArg +(x))
      ;; inject(sumArg, xArg, sumArg + xArg)        => inject(    sumArg, xArg, sumArg + xArg)
      ;; inject("", sumArg, xArg, sumArg + xArg)    => inject("", sumArg, xArg, sumArg +(xArg))

      it("should take one argument that is a message chain and apply that on the sum, with the current arg as argument",
        [1,2,3] inject(+) should == 6
        [1,2,3] inject(*(5) -) should == 12
        CustomEnumerable2 inject(-) should == 9
      )

      it("should take two arguments that is an argument name and a message chain and apply that on the sum",
        [1,2,3] inject(x, + x*2) should == 11
        [1,2,3] inject(x, *(5) - x) should == 12
        CustomEnumerable2 inject(x, - x) should == 9
      )

      it("should take three arguments that is the sum name, the argument name and code to apply",
        [1,2,3] inject(sum, x, sum + x*2) should == 11
        [1,2,3] inject(sum, x, sum *(5) - x) should == 12
        CustomEnumerable2 inject(sum, x, sum - x) should == 9
      )

      it("should take four arguments that is the initial value, the sum name, the argument name and code to apply",
        [1,2,3] inject(13, sum, x, sum + x*2) should == 25
        [1,2,3] inject(1, sum, x, sum *(5) - x) should == 87
        CustomEnumerable2 inject(100, sum, x, sum - x) should == 25
      )

      it("should be able to destructure on the argument name",
        result = []
        [[1,2], [2,3], [4,5]] inject(fluxie, (x,y), result << [x+1, y-1]. nil)
        result should == [[3,2], [5,4]]
      )

      it("should be able to destructure and ignore the rest of something",
        result = []
        [[1,2,9,10], [2,3,11,12], [4,5,13,14]] inject(fluxie, (x,y,_), cell?(:"_") should not be true. result << [x, y]. nil)
        result should == [[2,3], [4,5]]
      )

      it("should be able to destructure and ignore in the middle of the pattern without binding anything",
        result = []
        [[1,2,9], [2,3,11], [4,5,13]] inject(fluxie, (x,_,y), cell?(:"_") should not be true. result << [x, y]. nil) 
        result should == [[2,11], [4,13]]
      )

      it("should be able to destructure and ignore several times in the middle of the pattern without binding anything",
        result = []
        [[1,2,9,10,11], [2,3,11,12,13], [4,5,13,14,15]] inject(fluxie, (x,_,y,_,q), cell?(:"_") should not be true. result << [x, y, q]. nil) 
        result should == [[2,11,13], [4,13,15]]
      )

      it("should be able to destructure recursively",
        result = []
        [[[:x, :y, :z], [:q, :r, :p]], [[:b, :c, :d], [:i, :j, :k]], [[:i, :j, :k], [:i2, :j3, :k4]]] inject(fluxie, 
          (v, (v2, _, v3)), cell?(:"_") should be false. result << [v, v2, v3]. nil) 
        result should == [[[:b, :c, :d], :i, :k], [[:i, :j, :k], :i2, :k4]]
      )

      it("should report a destructuring match error if destructuring doesn't add upp",
        fn([[1,2], [3,4], [4,5]] inject(fluxie, (q,p,r), nil)) should signal(Condition Error DestructuringMismatch)
        fn([[1,2], [3,4], [4,5]] inject(fluxie, (q), nil)) should signal(Condition Error DestructuringMismatch)
        fn([[1,2], [3,4], [4,5]] inject(fluxie, (q,_,r), nil)) should signal(Condition Error DestructuringMismatch)
      )

      it("should report a destructuring match error if recursive destructuring doesn't add upp",
        fn([[[1,2],[1,2]], [[3,4],[1,2]], [[1,2],[4,5]]] inject(fluxie, (q,(p)), nil)) should signal(Condition Error DestructuringMismatch)
        fn([[[1,2],[1,2]], [[3,4],[1,2]], [[1,2],[4,5]]] inject(fluxie, (q,(p,r,f)), nil)) should signal(Condition Error DestructuringMismatch)
        fn([[[1,2],[1,2]], [[3,4],[1,2]], [[1,2],[4,5]]] inject(fluxie, (q,(p,_,f)), nil)) should signal(Condition Error DestructuringMismatch)
      )

      it("should be able to destructure on the argument name",
        result = []
        [[1,2], [2,3], [4,5]] inject(nil, fluxie, (x,y), result << [x+1, y-1]. nil)
        result should == [[2,1], [3,2], [5,4]]
      )

      it("should be able to destructure and ignore the rest of something",
        result = []
        [[1,2,9,10], [2,3,11,12], [4,5,13,14]] inject(nil, fluxie, (x,y,_), cell?(:"_") should not be true. result << [x, y]. nil)
        result should == [[1,2], [2,3], [4,5]]
      )

      it("should be able to destructure and ignore in the middle of the pattern without binding anything",
        result = []
        [[1,2,9], [2,3,11], [4,5,13]] inject(nil, fluxie, (x,_,y), cell?(:"_") should not be true. result << [x, y]. nil) 
        result should == [[1,9], [2,11], [4,13]]
      )

      it("should be able to destructure and ignore several times in the middle of the pattern without binding anything",
        result = []
        [[1,2,9,10,11], [2,3,11,12,13], [4,5,13,14,15]] inject(nil, fluxie, (x,_,y,_,q), cell?(:"_") should not be true. result << [x, y, q]. nil) 
        result should == [[1,9,11], [2,11,13], [4,13,15]]
      )

      it("should be able to destructure recursively",
        result = []
        [[[:x, :y, :z], [:q, :r, :p]], [[:b, :c, :d], [:i, :j, :k]], [[:i, :j, :k], [:i2, :j3, :k4]]] inject(nil, fluxie, 
          (v, (v2, _, v3)), cell?(:"_") should be false. result << [v, v2, v3]. nil) 
        result should == [[[:x, :y, :z], :q, :p], [[:b, :c, :d], :i, :k], [[:i, :j, :k], :i2, :k4]]
      )

      it("should report a destructuring match error if destructuring doesn't add upp",
        fn([[1,2], [3,4], [4,5]] inject(nil, fluxie, (q,p,r), nil)) should signal(Condition Error DestructuringMismatch)
        fn([[1,2], [3,4], [4,5]] inject(nil, fluxie, (q), nil)) should signal(Condition Error DestructuringMismatch)
        fn([[1,2], [3,4], [4,5]] inject(nil, fluxie, (q,_,r), nil)) should signal(Condition Error DestructuringMismatch)
      )

      it("should report a destructuring match error if recursive destructuring doesn't add upp",
        fn([[[1,2],[1,2]], [[3,4],[1,2]], [[1,2],[4,5]]] inject(nil, fluxie, (q,(p)), nil)) should signal(Condition Error DestructuringMismatch)
        fn([[[1,2],[1,2]], [[3,4],[1,2]], [[1,2],[4,5]]] inject(nil, fluxie, (q,(p,r,f)), nil)) should signal(Condition Error DestructuringMismatch)
        fn([[[1,2],[1,2]], [[3,4],[1,2]], [[1,2],[4,5]]] inject(nil, fluxie, (q,(p,_,f)), nil)) should signal(Condition Error DestructuringMismatch)
      )
    )

    describe("reduce",
      ;; reduce needs: a start value, an argument name, a sum argument name, and code
      ;; versions:

      ;; reduce(+)                                  => reduce(    sum,    x,    sum    +(x))
      ;; reduce(x, + x)                             => reduce(    sumArg, x,    sumArg +(x))
      ;; reduce(sumArg, xArg, sumArg + xArg)        => reduce(    sumArg, xArg, sumArg + xArg)
      ;; reduce("", sumArg, xArg, sumArg + xArg)    => reduce("", sumArg, xArg, sumArg +(xArg))

      it("should take one argument that is a message chain and apply that on the sum, with the current arg as argument",
        [1,2,3] reduce(+) should == 6
        [1,2,3] reduce(*(5) -) should == 12
        CustomEnumerable2 reduce(-) should == 9
      )

      it("should take two arguments that is an argument name and a message chain and apply that on the sum",
        [1,2,3] reduce(x, + x*2) should == 11
        [1,2,3] reduce(x, *(5) - x) should == 12
        CustomEnumerable2 reduce(x, - x) should == 9
      )

      it("should take three arguments that is the sum name, the argument name and code to apply",
        [1,2,3] reduce(sum, x, sum + x*2) should == 11
        [1,2,3] reduce(sum, x, sum *(5) - x) should == 12
        CustomEnumerable2 reduce(sum, x, sum - x) should == 9
      )

      it("should take four arguments that is the initial value, the sum name, the argument name and code to apply",
        [1,2,3] reduce(13, sum, x, sum + x*2) should == 25
        [1,2,3] reduce(1, sum, x, sum *(5) - x) should == 87
        CustomEnumerable2 reduce(100, sum, x, sum - x) should == 25
      )

      it("should be able to destructure on the argument name",
        result = []
        [[1,2], [2,3], [4,5]] reduce(fluxie, (x,y), result << [x+1, y-1]. nil)
        result should == [[3,2], [5,4]]
      )

      it("should be able to destructure and ignore the rest of something",
        result = []
        [[1,2,9,10], [2,3,11,12], [4,5,13,14]] reduce(fluxie, (x,y,_), cell?(:"_") should not be true. result << [x, y]. nil)
        result should == [[2,3], [4,5]]
      )

      it("should be able to destructure and ignore in the middle of the pattern without binding anything",
        result = []
        [[1,2,9], [2,3,11], [4,5,13]] reduce(fluxie, (x,_,y), cell?(:"_") should not be true. result << [x, y]. nil) 
        result should == [[2,11], [4,13]]
      )

      it("should be able to destructure and ignore several times in the middle of the pattern without binding anything",
        result = []
        [[1,2,9,10,11], [2,3,11,12,13], [4,5,13,14,15]] reduce(fluxie, (x,_,y,_,q), cell?(:"_") should not be true. result << [x, y, q]. nil) 
        result should == [[2,11,13], [4,13,15]]
      )

      it("should be able to destructure recursively",
        result = []
        [[[:x, :y, :z], [:q, :r, :p]], [[:b, :c, :d], [:i, :j, :k]], [[:i, :j, :k], [:i2, :j3, :k4]]] reduce(fluxie, 
          (v, (v2, _, v3)), cell?(:"_") should be false. result << [v, v2, v3]. nil) 
        result should == [[[:b, :c, :d], :i, :k], [[:i, :j, :k], :i2, :k4]]
      )

      it("should report a destructuring match error if destructuring doesn't add upp",
        fn([[1,2], [3,4], [4,5]] reduce(fluxie, (q,p,r), nil)) should signal(Condition Error DestructuringMismatch)
        fn([[1,2], [3,4], [4,5]] reduce(fluxie, (q), nil)) should signal(Condition Error DestructuringMismatch)
        fn([[1,2], [3,4], [4,5]] reduce(fluxie, (q,_,r), nil)) should signal(Condition Error DestructuringMismatch)
      )

      it("should report a destructuring match error if recursive destructuring doesn't add upp",
        fn([[[1,2],[1,2]], [[3,4],[1,2]], [[1,2],[4,5]]] reduce(fluxie, (q,(p)), nil)) should signal(Condition Error DestructuringMismatch)
        fn([[[1,2],[1,2]], [[3,4],[1,2]], [[1,2],[4,5]]] reduce(fluxie, (q,(p,r,f)), nil)) should signal(Condition Error DestructuringMismatch)
        fn([[[1,2],[1,2]], [[3,4],[1,2]], [[1,2],[4,5]]] reduce(fluxie, (q,(p,_,f)), nil)) should signal(Condition Error DestructuringMismatch)
      )

      it("should be able to destructure on the argument name",
        result = []
        [[1,2], [2,3], [4,5]] reduce(nil, fluxie, (x,y), result << [x+1, y-1]. nil)
        result should == [[2,1], [3,2], [5,4]]
      )

      it("should be able to destructure and ignore the rest of something",
        result = []
        [[1,2,9,10], [2,3,11,12], [4,5,13,14]] reduce(nil, fluxie, (x,y,_), cell?(:"_") should not be true. result << [x, y]. nil)
        result should == [[1,2], [2,3], [4,5]]
      )

      it("should be able to destructure and ignore in the middle of the pattern without binding anything",
        result = []
        [[1,2,9], [2,3,11], [4,5,13]] reduce(nil, fluxie, (x,_,y), cell?(:"_") should not be true. result << [x, y]. nil) 
        result should == [[1,9], [2,11], [4,13]]
      )

      it("should be able to destructure and ignore several times in the middle of the pattern without binding anything",
        result = []
        [[1,2,9,10,11], [2,3,11,12,13], [4,5,13,14,15]] reduce(nil, fluxie, (x,_,y,_,q), cell?(:"_") should not be true. result << [x, y, q]. nil) 
        result should == [[1,9,11], [2,11,13], [4,13,15]]
      )

      it("should be able to destructure recursively",
        result = []
        [[[:x, :y, :z], [:q, :r, :p]], [[:b, :c, :d], [:i, :j, :k]], [[:i, :j, :k], [:i2, :j3, :k4]]] reduce(nil, fluxie, 
          (v, (v2, _, v3)), cell?(:"_") should be false. result << [v, v2, v3]. nil) 
        result should == [[[:x, :y, :z], :q, :p], [[:b, :c, :d], :i, :k], [[:i, :j, :k], :i2, :k4]]
      )

      it("should report a destructuring match error if destructuring doesn't add upp",
        fn([[1,2], [3,4], [4,5]] reduce(nil, fluxie, (q,p,r), nil)) should signal(Condition Error DestructuringMismatch)
        fn([[1,2], [3,4], [4,5]] reduce(nil, fluxie, (q), nil)) should signal(Condition Error DestructuringMismatch)
        fn([[1,2], [3,4], [4,5]] reduce(nil, fluxie, (q,_,r), nil)) should signal(Condition Error DestructuringMismatch)
      )

      it("should report a destructuring match error if recursive destructuring doesn't add upp",
        fn([[[1,2],[1,2]], [[3,4],[1,2]], [[1,2],[4,5]]] reduce(nil, fluxie, (q,(p)), nil)) should signal(Condition Error DestructuringMismatch)
        fn([[[1,2],[1,2]], [[3,4],[1,2]], [[1,2],[4,5]]] reduce(nil, fluxie, (q,(p,r,f)), nil)) should signal(Condition Error DestructuringMismatch)
        fn([[[1,2],[1,2]], [[3,4],[1,2]], [[1,2],[4,5]]] reduce(nil, fluxie, (q,(p,_,f)), nil)) should signal(Condition Error DestructuringMismatch)
      )
    )

    describe("fold",
      ;; fold needs: a start value, an argument name, a sum argument name, and code
      ;; versions:

      ;; fold(+)                                  => fold(    sum,    x,    sum    +(x))
      ;; fold(x, + x)                             => fold(    sumArg, x,    sumArg +(x))
      ;; fold(sumArg, xArg, sumArg + xArg)        => fold(    sumArg, xArg, sumArg + xArg)
      ;; fold("", sumArg, xArg, sumArg + xArg)    => fold("", sumArg, xArg, sumArg +(xArg))

      it("should take one argument that is a message chain and apply that on the sum, with the current arg as argument",
        [1,2,3] fold(+) should == 6
        [1,2,3] fold(*(5) -) should == 12
        CustomEnumerable2 fold(-) should == 9
      )

      it("should take two arguments that is an argument name and a message chain and apply that on the sum",
        [1,2,3] fold(x, + x*2) should == 11
        [1,2,3] fold(x, *(5) - x) should == 12
        CustomEnumerable2 fold(x, - x) should == 9
      )

      it("should take three arguments that is the sum name, the argument name and code to apply",
        [1,2,3] fold(sum, x, sum + x*2) should == 11
        [1,2,3] fold(sum, x, sum *(5) - x) should == 12
        CustomEnumerable2 fold(sum, x, sum - x) should == 9
      )

      it("should take four arguments that is the initial value, the sum name, the argument name and code to apply",
        [1,2,3] fold(13, sum, x, sum + x*2) should == 25
        [1,2,3] fold(1, sum, x, sum *(5) - x) should == 87
        CustomEnumerable2 fold(100, sum, x, sum - x) should == 25
      )

      it("should be able to destructure on the argument name",
        result = []
        [[1,2], [2,3], [4,5]] fold(fluxie, (x,y), result << [x+1, y-1]. nil)
        result should == [[3,2], [5,4]]
      )

      it("should be able to destructure and ignore the rest of something",
        result = []
        [[1,2,9,10], [2,3,11,12], [4,5,13,14]] fold(fluxie, (x,y,_), cell?(:"_") should not be true. result << [x, y]. nil)
        result should == [[2,3], [4,5]]
      )

      it("should be able to destructure and ignore in the middle of the pattern without binding anything",
        result = []
        [[1,2,9], [2,3,11], [4,5,13]] fold(fluxie, (x,_,y), cell?(:"_") should not be true. result << [x, y]. nil) 
        result should == [[2,11], [4,13]]
      )

      it("should be able to destructure and ignore several times in the middle of the pattern without binding anything",
        result = []
        [[1,2,9,10,11], [2,3,11,12,13], [4,5,13,14,15]] fold(fluxie, (x,_,y,_,q), cell?(:"_") should not be true. result << [x, y, q]. nil) 
        result should == [[2,11,13], [4,13,15]]
      )

      it("should be able to destructure recursively",
        result = []
        [[[:x, :y, :z], [:q, :r, :p]], [[:b, :c, :d], [:i, :j, :k]], [[:i, :j, :k], [:i2, :j3, :k4]]] fold(fluxie, 
          (v, (v2, _, v3)), cell?(:"_") should be false. result << [v, v2, v3]. nil) 
        result should == [[[:b, :c, :d], :i, :k], [[:i, :j, :k], :i2, :k4]]
      )

      it("should report a destructuring match error if destructuring doesn't add upp",
        fn([[1,2], [3,4], [4,5]] fold(fluxie, (q,p,r), nil)) should signal(Condition Error DestructuringMismatch)
        fn([[1,2], [3,4], [4,5]] fold(fluxie, (q), nil)) should signal(Condition Error DestructuringMismatch)
        fn([[1,2], [3,4], [4,5]] fold(fluxie, (q,_,r), nil)) should signal(Condition Error DestructuringMismatch)
      )

      it("should report a destructuring match error if recursive destructuring doesn't add upp",
        fn([[[1,2],[1,2]], [[3,4],[1,2]], [[1,2],[4,5]]] fold(fluxie, (q,(p)), nil)) should signal(Condition Error DestructuringMismatch)
        fn([[[1,2],[1,2]], [[3,4],[1,2]], [[1,2],[4,5]]] fold(fluxie, (q,(p,r,f)), nil)) should signal(Condition Error DestructuringMismatch)
        fn([[[1,2],[1,2]], [[3,4],[1,2]], [[1,2],[4,5]]] fold(fluxie, (q,(p,_,f)), nil)) should signal(Condition Error DestructuringMismatch)
      )

      it("should be able to destructure on the argument name",
        result = []
        [[1,2], [2,3], [4,5]] fold(nil, fluxie, (x,y), result << [x+1, y-1]. nil)
        result should == [[2,1], [3,2], [5,4]]
      )

      it("should be able to destructure and ignore the rest of something",
        result = []
        [[1,2,9,10], [2,3,11,12], [4,5,13,14]] fold(nil, fluxie, (x,y,_), cell?(:"_") should not be true. result << [x, y]. nil)
        result should == [[1,2], [2,3], [4,5]]
      )

      it("should be able to destructure and ignore in the middle of the pattern without binding anything",
        result = []
        [[1,2,9], [2,3,11], [4,5,13]] fold(nil, fluxie, (x,_,y), cell?(:"_") should not be true. result << [x, y]. nil) 
        result should == [[1,9], [2,11], [4,13]]
      )

      it("should be able to destructure and ignore several times in the middle of the pattern without binding anything",
        result = []
        [[1,2,9,10,11], [2,3,11,12,13], [4,5,13,14,15]] fold(nil, fluxie, (x,_,y,_,q), cell?(:"_") should not be true. result << [x, y, q]. nil) 
        result should == [[1,9,11], [2,11,13], [4,13,15]]
      )

      it("should be able to destructure recursively",
        result = []
        [[[:x, :y, :z], [:q, :r, :p]], [[:b, :c, :d], [:i, :j, :k]], [[:i, :j, :k], [:i2, :j3, :k4]]] fold(nil, fluxie, 
          (v, (v2, _, v3)), cell?(:"_") should be false. result << [v, v2, v3]. nil) 
        result should == [[[:x, :y, :z], :q, :p], [[:b, :c, :d], :i, :k], [[:i, :j, :k], :i2, :k4]]
      )

      it("should report a destructuring match error if destructuring doesn't add upp",
        fn([[1,2], [3,4], [4,5]] fold(nil, fluxie, (q,p,r), nil)) should signal(Condition Error DestructuringMismatch)
        fn([[1,2], [3,4], [4,5]] fold(nil, fluxie, (q), nil)) should signal(Condition Error DestructuringMismatch)
        fn([[1,2], [3,4], [4,5]] fold(nil, fluxie, (q,_,r), nil)) should signal(Condition Error DestructuringMismatch)
      )

      it("should report a destructuring match error if recursive destructuring doesn't add upp",
        fn([[[1,2],[1,2]], [[3,4],[1,2]], [[1,2],[4,5]]] fold(nil, fluxie, (q,(p)), nil)) should signal(Condition Error DestructuringMismatch)
        fn([[[1,2],[1,2]], [[3,4],[1,2]], [[1,2],[4,5]]] fold(nil, fluxie, (q,(p,r,f)), nil)) should signal(Condition Error DestructuringMismatch)
        fn([[[1,2],[1,2]], [[3,4],[1,2]], [[1,2],[4,5]]] fold(nil, fluxie, (q,(p,_,f)), nil)) should signal(Condition Error DestructuringMismatch)
      )
    )

    describe("flatMap",
      it("should return a correct flattened list",
        [1,2,3] flatMap(x, [x]) should == [1,2,3]
        [1,2,3] flatMap(x, [x, x+10, x+20]) should == [1,11,21,2,12,22,3,13,23]
        [4,5,6] flatMap(x, [x+20, x+10, x]) should == [24,14,4,25,15,5,26,16,6]
      )

      it("should be able to destructure on the argument name",
        [[1,2], [2,3], [4,5]] flatMap((x,y), [x+1, y-1]) should == [2,1, 3,2, 5,4]
      )

      it("should be able to destructure and ignore the rest of something",
        [[1,2,9,10], [2,3,11,12], [4,5,13,14]] flatMap((x,y,_), cell?(:"_") should not be true. [x, y]) should == [1,2, 2,3, 4,5]
      )

      it("should be able to destructure and ignore in the middle of the pattern without binding anything",
        [[1,2,9], [2,3,11], [4,5,13]] flatMap((x,_,y), cell?(:"_") should not be true. [x, y]) should == [1,9, 2,11, 4,13]
      )

      it("should be able to destructure and ignore several times in the middle of the pattern without binding anything",
        [[1,2,9,10,11], [2,3,11,12,13], [4,5,13,14,15]] flatMap((x,_,y,_,q), cell?(:"_") should not be true. [x, y, q]) should == [1,9,11, 2,11,13, 4,13,15]
      )

      it("should be able to destructure recursively",
        [[[:x, :y, :z], [:q, :r, :p]], [[:b, :c, :d], [:i, :j, :k]], [[:i, :j, :k], [:i2, :j3, :k4]]] flatMap(
          (v, (v2, _, v3)), cell?(:"_") should be false. [v, v2, v3]) should == [[:x, :y, :z], :q, :p, [:b, :c, :d], :i, :k, [:i, :j, :k], :i2, :k4]
      )

      it("should report a destructuring match error if destructuring doesn't add upp",
        fn([[1,2], [3,4], [4,5]] flatMap((q,p,r), nil)) should signal(Condition Error DestructuringMismatch)
        fn([[1,2], [3,4], [4,5]] flatMap((q), nil)) should signal(Condition Error DestructuringMismatch)
        fn([[1,2], [3,4], [4,5]] flatMap((q,_,r), nil)) should signal(Condition Error DestructuringMismatch)
     )

      it("should report a destructuring match error if recursive destructuring doesn't add upp",
        fn([[[1,2],[1,2]], [[3,4],[1,2]], [[1,2],[4,5]]] flatMap((q,(p)), nil)) should signal(Condition Error DestructuringMismatch)
        fn([[[1,2],[1,2]], [[3,4],[1,2]], [[1,2],[4,5]]] flatMap((q,(p,r,f)), nil)) should signal(Condition Error DestructuringMismatch)
        fn([[[1,2],[1,2]], [[3,4],[1,2]], [[1,2],[4,5]]] flatMap((q,(p,_,f)), nil)) should signal(Condition Error DestructuringMismatch)
      )
    )

    describe("flatMap:set",
      it("should return a correct flattened set",
        [1,2,3] flatMap:set(x, set(x)) should == set(1,2,3)
        [1,2,3] flatMap:set(x, set(x, x+10, x+20)) should == set(1,11,21,2,12,22,3,13,23)
        [4,5,6] flatMap:set(x, set(x+20, x+10, x)) should == set(24,14,4,25,15,5,26,16,6)
      )

      it("should be able to destructure on the argument name",
        [[1,2], [2,3], [4,5]] flatMap:set((x,y), set(x+1, y-1)) should == set(2,1, 3,2, 5,4)
      )

      it("should be able to destructure and ignore the rest of something",
        [[1,2,9,10], [2,3,11,12], [4,5,13,14]] flatMap:set((x,y,_), cell?(:"_") should not be true. set(x, y)) should == set(1,2, 2,3, 4,5)
      )

      it("should be able to destructure and ignore in the middle of the pattern without binding anything",
        [[1,2,9], [2,3,11], [4,5,13]] flatMap:set((x,_,y), cell?(:"_") should not be true. set(x, y)) should == set(1,9, 2,11, 4,13)
      )

      it("should be able to destructure and ignore several times in the middle of the pattern without binding anything",
        [[1,2,9,10,11], [2,3,11,12,13], [4,5,13,14,15]] flatMap:set((x,_,y,_,q), cell?(:"_") should not be true. set(x, y, q)) should == set(1,9,11, 2,11,13, 4,13,15)
      )

      it("should be able to destructure recursively",
        [[[:x, :y, :z], [:q, :r, :p]], [[:b, :c, :d], [:i, :j, :k]], [[:i, :j, :k], [:i2, :j3, :k4]]] flatMap:set(
          (v, (v2, _, v3)), cell?(:"_") should be false. set(v, v2, v3)) should == set([:x, :y, :z], :q, :p, [:b, :c, :d], :i, :k, [:i, :j, :k], :i2, :k4)
      )

      it("should report a destructuring match error if destructuring doesn't add upp",
        fn([[1,2], [3,4], [4,5]] flatMap:set((q,p,r), nil)) should signal(Condition Error DestructuringMismatch)
        fn([[1,2], [3,4], [4,5]] flatMap:set((q), nil)) should signal(Condition Error DestructuringMismatch)
        fn([[1,2], [3,4], [4,5]] flatMap:set((q,_,r), nil)) should signal(Condition Error DestructuringMismatch)
     )

      it("should report a destructuring match error if recursive destructuring doesn't add upp",
        fn([[[1,2],[1,2]], [[3,4],[1,2]], [[1,2],[4,5]]] flatMap:set((q,(p)), nil)) should signal(Condition Error DestructuringMismatch)
        fn([[[1,2],[1,2]], [[3,4],[1,2]], [[1,2],[4,5]]] flatMap:set((q,(p,r,f)), nil)) should signal(Condition Error DestructuringMismatch)
        fn([[[1,2],[1,2]], [[3,4],[1,2]], [[1,2],[4,5]]] flatMap:set((q,(p,_,f)), nil)) should signal(Condition Error DestructuringMismatch)
      )
    )

    describe("flatMap:dict",
      it("should return a correct flattened dict",
        [1,2,3] flatMap:dict(x, dict(x=>x+2)) should == dict(1=>3,2=>4,3=>5)
        [1,2,3] flatMap:dict(x, dict(x=>nil, (x+10)=>nil, (x+20)=>nil)) should == dict(1=>nil,11=>nil,21=>nil,2=>nil,12=>nil,22=>nil,3=>nil,13=>nil,23=>nil)
        [4,5,6] flatMap:dict(x, dict((x+20)=>nil, (x+10)=>nil, x=>nil)) should == dict(24=>nil,14=>nil,4=>nil,25=>nil,15=>nil,5=>nil,26=>nil,16=>nil,6=>nil)
      )

      it("should be able to destructure on the argument name",
        [[1,2], [2,3], [4,5]] flatMap:dict((x,y), dict([x+1, y-1] => nil)) should == {[2,1] => nil, [3,2] => nil, [5,4] => nil}
      )

      it("should be able to destructure and ignore the rest of something",
        [[1,2,9,10], [2,3,11,12], [4,5,13,14]] flatMap:dict((x,y,_), cell?(:"_") should not be true. dict([x, y]=>nil)) should == {[1,2] => nil, [2,3] => nil, [4,5] => nil}
      )

      it("should be able to destructure and ignore in the middle of the pattern without binding anything",
        [[1,2,9], [2,3,11], [4,5,13]] flatMap:dict((x,_,y), cell?(:"_") should not be true. dict([x, y]=>nil)) should == {[1,9] => nil, [2,11] => nil, [4,13] => nil}
      )

      it("should be able to destructure and ignore several times in the middle of the pattern without binding anything",
        [[1,2,9,10,11], [2,3,11,12,13], [4,5,13,14,15]] flatMap:dict((x,_,y,_,q), cell?(:"_") should not be true. dict([x, y, q]=>nil)) should == {[1,9,11] => nil, [2,11,13] => nil, [4,13,15] => nil}
      )

      it("should be able to destructure recursively",
        [[[:x, :y, :z], [:q, :r, :p]], [[:b, :c, :d], [:i, :j, :k]], [[:i, :j, :k], [:i2, :j3, :k4]]] flatMap:dict(
          (v, (v2, _, v3)), cell?(:"_") should be false. dict([v, v2, v3]=>nil)) should == {[[:x, :y, :z], :q, :p] => nil, [[:b, :c, :d], :i, :k] => nil, [[:i, :j, :k], :i2, :k4] => nil}
      )

      it("should report a destructuring match error if destructuring doesn't add upp",
        fn([[1,2], [3,4], [4,5]] flatMap:dict((q,p,r), nil)) should signal(Condition Error DestructuringMismatch)
        fn([[1,2], [3,4], [4,5]] flatMap:dict((q), nil)) should signal(Condition Error DestructuringMismatch)
        fn([[1,2], [3,4], [4,5]] flatMap:dict((q,_,r), nil)) should signal(Condition Error DestructuringMismatch)
     )

      it("should report a destructuring match error if recursive destructuring doesn't add upp",
        fn([[[1,2],[1,2]], [[3,4],[1,2]], [[1,2],[4,5]]] flatMap:dict((q,(p)), nil)) should signal(Condition Error DestructuringMismatch)
        fn([[[1,2],[1,2]], [[3,4],[1,2]], [[1,2],[4,5]]] flatMap:dict((q,(p,r,f)), nil)) should signal(Condition Error DestructuringMismatch)
        fn([[[1,2],[1,2]], [[3,4],[1,2]], [[1,2],[4,5]]] flatMap:dict((q,(p,_,f)), nil)) should signal(Condition Error DestructuringMismatch)
      )
    )

    describe("select",
      it("should take zero arguments and return a list with only the true values",
        [1,2,3] select should == [1,2,3]
        [nil,false,nil] select should == []
        [nil,false,true] select should == [true]
        CustomEnumerable select should == CustomEnumerable asList
      )

      it("should take one argument that ends up being a predicate and return a list of the values that is true",
        [1,2,3] select(>1) should == [2,3]
        [nil,false,nil] select(nil?) should == [nil, nil]
        [nil,false,true] select(==2) should == []
        CustomEnumerable select([0...1] != "1") should == ["3first", "2third"]
      )

      it("should take two arguments that ends up being a predicate and return a list of the values that is true",
        [1,2,3] select(x, x>1) should == [2,3]
        [nil,false,nil] select(x, x nil?) should == [nil, nil]
        [nil,false,true] select(x, x==2) should == []
        CustomEnumerable select(x, x != "2third") should == ["3first", "1second"]
      )

      it("should be able to destructure on the argument name",
        result = []
        [[1,2], [2,3], [4,5]] select((x,y), result << [x+1, y-1])
        result should == [[2,1], [3,2], [5,4]]
      )

      it("should be able to destructure and ignore the rest of something",
        result = []
        [[1,2,9,10], [2,3,11,12], [4,5,13,14]] select((x,y,_), cell?(:"_") should not be true. result << [x, y])
        result should == [[1,2], [2,3], [4,5]]
      )

      it("should be able to destructure and ignore in the middle of the pattern without binding anything",
        result = []
        [[1,2,9], [2,3,11], [4,5,13]] select((x,_,y), cell?(:"_") should not be true. result << [x, y]) 
        result should == [[1,9], [2,11], [4,13]]
      )

      it("should be able to destructure and ignore several times in the middle of the pattern without binding anything",
        result = []
        [[1,2,9,10,11], [2,3,11,12,13], [4,5,13,14,15]] select((x,_,y,_,q), cell?(:"_") should not be true. result << [x, y, q]) 
        result should == [[1,9,11], [2,11,13], [4,13,15]]
      )

      it("should be able to destructure recursively",
        result = []
        [[[:x, :y, :z], [:q, :r, :p]], [[:b, :c, :d], [:i, :j, :k]], [[:i, :j, :k], [:i2, :j3, :k4]]] select(
          (v, (v2, _, v3)), cell?(:"_") should be false. result << [v, v2, v3]) 
        result should == [[[:x, :y, :z], :q, :p], [[:b, :c, :d], :i, :k], [[:i, :j, :k], :i2, :k4]]
      )

      it("should report a destructuring match error if destructuring doesn't add upp",
        fn([[1,2], [3,4], [4,5]] select((q,p,r), nil)) should signal(Condition Error DestructuringMismatch)
        fn([[1,2], [3,4], [4,5]] select((q), nil)) should signal(Condition Error DestructuringMismatch)
        fn([[1,2], [3,4], [4,5]] select((q,_,r), nil)) should signal(Condition Error DestructuringMismatch)
      )

      it("should report a destructuring match error if recursive destructuring doesn't add upp",
        fn([[[1,2],[1,2]], [[3,4],[1,2]], [[1,2],[4,5]]] select((q,(p)), nil)) should signal(Condition Error DestructuringMismatch)
        fn([[[1,2],[1,2]], [[3,4],[1,2]], [[1,2],[4,5]]] select((q,(p,r,f)), nil)) should signal(Condition Error DestructuringMismatch)
        fn([[[1,2],[1,2]], [[3,4],[1,2]], [[1,2],[4,5]]] select((q,(p,_,f)), nil)) should signal(Condition Error DestructuringMismatch)
      )
    )

    describe("select:dict",
      it("should take zero arguments and return a dict with only the true values",
        [1,2,3] select:dict should == {1 => nil, 2 => nil, 3 => nil}
        [nil,false,nil] select:dict should == {}
        [nil,false,true] select:dict should == {true => nil}
        {nil => 42, true => 55, blah: 222} select:dict should == {nil => 42, true => 55, blah: 222}
        CustomEnumerable select:dict should == {"3first" => nil, "2third" => nil, "1second" => nil}
      )

      it("should take one argument that ends up being a predicate and return a dict of the values that is true",
        [1,2,3] select:dict(>1) should == {2 => nil, 3 => nil}
        [nil,false,nil] select:dict(nil?) should == {nil => nil}
        [nil,false,true] select:dict(==2) should == {}
        {foo: 42, bar: 2324, quux: 42} select:dict(value == 42) should == {foo: 42, quux: 42}
        CustomEnumerable select:dict([0...1] != "1") should == {"3first" => nil, "2third" => nil}
      )

      it("should take two arguments that ends up being a predicate and return a dict of the values that is true",
        [1,2,3] select:dict(x, x>1) should == {2 => nil, 3 => nil}
        [nil,false,nil] select:dict(x, x nil?) should == {nil => nil}
        [nil,false,true] select:dict(x, x==2) should == {}
        {foo: 42, bar: 2324, quux: 42} select:dict(x, x value == 42) should == {foo: 42, quux: 42}
        CustomEnumerable select:dict(x, x != "2third") should == {"3first" => nil, "1second" => nil}
      )

      it("should be able to destructure on the argument name",
        result = []
        [[1,2], [2,3], [4,5]] select:dict((x,y), result << [x+1, y-1])
        result should == [[2,1], [3,2], [5,4]]
      )

      it("should be able to destructure and ignore the rest of something",
        result = []
        [[1,2,9,10], [2,3,11,12], [4,5,13,14]] select:dict((x,y,_), cell?(:"_") should not be true. result << [x, y])
        result should == [[1,2], [2,3], [4,5]]
      )

      it("should be able to destructure and ignore in the middle of the pattern without binding anything",
        result = []
        [[1,2,9], [2,3,11], [4,5,13]] select:dict((x,_,y), cell?(:"_") should not be true. result << [x, y]) 
        result should == [[1,9], [2,11], [4,13]]
      )

      it("should be able to destructure and ignore several times in the middle of the pattern without binding anything",
        result = []
        [[1,2,9,10,11], [2,3,11,12,13], [4,5,13,14,15]] select:dict((x,_,y,_,q), cell?(:"_") should not be true. result << [x, y, q]) 
        result should == [[1,9,11], [2,11,13], [4,13,15]]
      )

      it("should be able to destructure recursively",
        result = []
        [[[:x, :y, :z], [:q, :r, :p]], [[:b, :c, :d], [:i, :j, :k]], [[:i, :j, :k], [:i2, :j3, :k4]]] select:dict(
          (v, (v2, _, v3)), cell?(:"_") should be false. result << [v, v2, v3]) 
        result should == [[[:x, :y, :z], :q, :p], [[:b, :c, :d], :i, :k], [[:i, :j, :k], :i2, :k4]]
      )

      it("should report a destructuring match error if destructuring doesn't add upp",
        fn([[1,2], [3,4], [4,5]] select:dict((q,p,r), nil)) should signal(Condition Error DestructuringMismatch)
        fn([[1,2], [3,4], [4,5]] select:dict((q), nil)) should signal(Condition Error DestructuringMismatch)
        fn([[1,2], [3,4], [4,5]] select:dict((q,_,r), nil)) should signal(Condition Error DestructuringMismatch)
      )

      it("should report a destructuring match error if recursive destructuring doesn't add upp",
        fn([[[1,2],[1,2]], [[3,4],[1,2]], [[1,2],[4,5]]] select:dict((q,(p)), nil)) should signal(Condition Error DestructuringMismatch)
        fn([[[1,2],[1,2]], [[3,4],[1,2]], [[1,2],[4,5]]] select:dict((q,(p,r,f)), nil)) should signal(Condition Error DestructuringMismatch)
        fn([[[1,2],[1,2]], [[3,4],[1,2]], [[1,2],[4,5]]] select:dict((q,(p,_,f)), nil)) should signal(Condition Error DestructuringMismatch)
      )
    )

    describe("select:set",
      it("should take zero arguments and return a set with only the true values",
        [1,2,3] select:set should == #{1,2,3}
        [nil,false,nil] select:set should == #{}
        [nil,false,true] select:set should == #{true}
        CustomEnumerable select:set should == set(*(CustomEnumerable asList))
      )

      it("should take one argument that ends up being a predicate and return a set of the values that is true",
        [1,2,3] select:set(>1) should == #{2,3}
        [nil,false,nil] select:set(nil?) should == #{nil}
        [nil,false,true] select:set(==2) should == #{}
        CustomEnumerable select:set([0...1] != "1") should == #{"3first", "2third"}
      )

      it("should take two arguments that ends up being a predicate and return a set of the values that is true",
        [1,2,3] select:set(x, x>1) should == #{2,3}
        [nil,false,nil] select:set(x, x nil?) should == #{nil}
        [nil,false,true] select:set(x, x==2) should == #{}
        CustomEnumerable select:set(x, x != "2third") should == #{"3first", "1second"}
      )

      it("should be able to destructure on the argument name",
        result = []
        [[1,2], [2,3], [4,5]] select:set((x,y), result << [x+1, y-1])
        result should == [[2,1], [3,2], [5,4]]
      )

      it("should be able to destructure and ignore the rest of something",
        result = []
        [[1,2,9,10], [2,3,11,12], [4,5,13,14]] select:set((x,y,_), cell?(:"_") should not be true. result << [x, y])
        result should == [[1,2], [2,3], [4,5]]
      )

      it("should be able to destructure and ignore in the middle of the pattern without binding anything",
        result = []
        [[1,2,9], [2,3,11], [4,5,13]] select:set((x,_,y), cell?(:"_") should not be true. result << [x, y]) 
        result should == [[1,9], [2,11], [4,13]]
      )

      it("should be able to destructure and ignore several times in the middle of the pattern without binding anything",
        result = []
        [[1,2,9,10,11], [2,3,11,12,13], [4,5,13,14,15]] select:set((x,_,y,_,q), cell?(:"_") should not be true. result << [x, y, q]) 
        result should == [[1,9,11], [2,11,13], [4,13,15]]
      )

      it("should be able to destructure recursively",
        result = []
        [[[:x, :y, :z], [:q, :r, :p]], [[:b, :c, :d], [:i, :j, :k]], [[:i, :j, :k], [:i2, :j3, :k4]]] select:set(
          (v, (v2, _, v3)), cell?(:"_") should be false. result << [v, v2, v3]) 
        result should == [[[:x, :y, :z], :q, :p], [[:b, :c, :d], :i, :k], [[:i, :j, :k], :i2, :k4]]
      )

      it("should report a destructuring match error if destructuring doesn't add upp",
        fn([[1,2], [3,4], [4,5]] select:set((q,p,r), nil)) should signal(Condition Error DestructuringMismatch)
        fn([[1,2], [3,4], [4,5]] select:set((q), nil)) should signal(Condition Error DestructuringMismatch)
        fn([[1,2], [3,4], [4,5]] select:set((q,_,r), nil)) should signal(Condition Error DestructuringMismatch)
      )

      it("should report a destructuring match error if recursive destructuring doesn't add upp",
        fn([[[1,2],[1,2]], [[3,4],[1,2]], [[1,2],[4,5]]] select:set((q,(p)), nil)) should signal(Condition Error DestructuringMismatch)
        fn([[[1,2],[1,2]], [[3,4],[1,2]], [[1,2],[4,5]]] select:set((q,(p,r,f)), nil)) should signal(Condition Error DestructuringMismatch)
        fn([[[1,2],[1,2]], [[3,4],[1,2]], [[1,2],[4,5]]] select:set((q,(p,_,f)), nil)) should signal(Condition Error DestructuringMismatch)
      )
    )

    describe("findAll",
      it("should take zero arguments and return a list with only the true values",
        [1,2,3] findAll should == [1,2,3]
        [nil,false,nil] findAll should == []
        [nil,false,true] findAll should == [true]
        CustomEnumerable findAll should == CustomEnumerable asList
      )

      it("should take one argument that ends up being a predicate and return a list of the values that is true",
        [1,2,3] findAll(>1) should == [2,3]
        [nil,false,nil] findAll(nil?) should == [nil, nil]
        [nil,false,true] findAll(==2) should == []
        CustomEnumerable findAll([0...1] != "1") should == ["3first", "2third"]
      )

      it("should take two arguments that ends up being a predicate and return a list of the values that is true",
        [1,2,3] findAll(x, x>1) should == [2,3]
        [nil,false,nil] findAll(x, x nil?) should == [nil, nil]
        [nil,false,true] findAll(x, x==2) should == []
        CustomEnumerable findAll(x, x != "2third") should == ["3first", "1second"]
      )

      it("should be able to destructure on the argument name",
        result = []
        [[1,2], [2,3], [4,5]] findAll((x,y), result << [x+1, y-1])
        result should == [[2,1], [3,2], [5,4]]
      )

      it("should be able to destructure and ignore the rest of something",
        result = []
        [[1,2,9,10], [2,3,11,12], [4,5,13,14]] findAll((x,y,_), cell?(:"_") should not be true. result << [x, y])
        result should == [[1,2], [2,3], [4,5]]
      )

      it("should be able to destructure and ignore in the middle of the pattern without binding anything",
        result = []
        [[1,2,9], [2,3,11], [4,5,13]] findAll((x,_,y), cell?(:"_") should not be true. result << [x, y]) 
        result should == [[1,9], [2,11], [4,13]]
      )

      it("should be able to destructure and ignore several times in the middle of the pattern without binding anything",
        result = []
        [[1,2,9,10,11], [2,3,11,12,13], [4,5,13,14,15]] findAll((x,_,y,_,q), cell?(:"_") should not be true. result << [x, y, q]) 
        result should == [[1,9,11], [2,11,13], [4,13,15]]
      )

      it("should be able to destructure recursively",
        result = []
        [[[:x, :y, :z], [:q, :r, :p]], [[:b, :c, :d], [:i, :j, :k]], [[:i, :j, :k], [:i2, :j3, :k4]]] findAll(
          (v, (v2, _, v3)), cell?(:"_") should be false. result << [v, v2, v3]) 
        result should == [[[:x, :y, :z], :q, :p], [[:b, :c, :d], :i, :k], [[:i, :j, :k], :i2, :k4]]
      )

      it("should report a destructuring match error if destructuring doesn't add upp",
        fn([[1,2], [3,4], [4,5]] findAll((q,p,r), nil)) should signal(Condition Error DestructuringMismatch)
        fn([[1,2], [3,4], [4,5]] findAll((q), nil)) should signal(Condition Error DestructuringMismatch)
        fn([[1,2], [3,4], [4,5]] findAll((q,_,r), nil)) should signal(Condition Error DestructuringMismatch)
      )

      it("should report a destructuring match error if recursive destructuring doesn't add upp",
        fn([[[1,2],[1,2]], [[3,4],[1,2]], [[1,2],[4,5]]] findAll((q,(p)), nil)) should signal(Condition Error DestructuringMismatch)
        fn([[[1,2],[1,2]], [[3,4],[1,2]], [[1,2],[4,5]]] findAll((q,(p,r,f)), nil)) should signal(Condition Error DestructuringMismatch)
        fn([[[1,2],[1,2]], [[3,4],[1,2]], [[1,2],[4,5]]] findAll((q,(p,_,f)), nil)) should signal(Condition Error DestructuringMismatch)
      )
    )

    describe("findAll:dict",
      it("should take zero arguments and return a dict with only the true values",
        [1,2,3] findAll:dict should == {1 => nil, 2 => nil, 3 => nil}
        [nil,false,nil] findAll:dict should == {}
        [nil,false,true] findAll:dict should == {true => nil}
        {nil => 42, true => 55, blah: 222} findAll:dict should == {nil => 42, true => 55, blah: 222}
        CustomEnumerable findAll:dict should == {"3first" => nil, "2third" => nil, "1second" => nil}
      )

      it("should take one argument that ends up being a predicate and return a dict of the values that is true",
        [1,2,3] findAll:dict(>1) should == {2 => nil, 3 => nil}
        [nil,false,nil] findAll:dict(nil?) should == {nil => nil}
        [nil,false,true] findAll:dict(==2) should == {}
        {foo: 42, bar: 2324, quux: 42} findAll:dict(value == 42) should == {foo: 42, quux: 42}
        CustomEnumerable findAll:dict([0...1] != "1") should == {"3first" => nil, "2third" => nil}
      )

      it("should take two arguments that ends up being a predicate and return a dict of the values that is true",
        [1,2,3] findAll:dict(x, x>1) should == {2 => nil, 3 => nil}
        [nil,false,nil] findAll:dict(x, x nil?) should == {nil => nil}
        [nil,false,true] findAll:dict(x, x==2) should == {}
        {foo: 42, bar: 2324, quux: 42} findAll:dict(x, x value == 42) should == {foo: 42, quux: 42}
        CustomEnumerable findAll:dict(x, x != "2third") should == {"3first" => nil, "1second" => nil}
      )

      it("should be able to destructure on the argument name",
        result = []
        [[1,2], [2,3], [4,5]] findAll:dict((x,y), result << [x+1, y-1])
        result should == [[2,1], [3,2], [5,4]]
      )

      it("should be able to destructure and ignore the rest of something",
        result = []
        [[1,2,9,10], [2,3,11,12], [4,5,13,14]] findAll:dict((x,y,_), cell?(:"_") should not be true. result << [x, y])
        result should == [[1,2], [2,3], [4,5]]
      )

      it("should be able to destructure and ignore in the middle of the pattern without binding anything",
        result = []
        [[1,2,9], [2,3,11], [4,5,13]] findAll:dict((x,_,y), cell?(:"_") should not be true. result << [x, y]) 
        result should == [[1,9], [2,11], [4,13]]
      )

      it("should be able to destructure and ignore several times in the middle of the pattern without binding anything",
        result = []
        [[1,2,9,10,11], [2,3,11,12,13], [4,5,13,14,15]] findAll:dict((x,_,y,_,q), cell?(:"_") should not be true. result << [x, y, q]) 
        result should == [[1,9,11], [2,11,13], [4,13,15]]
      )

      it("should be able to destructure recursively",
        result = []
        [[[:x, :y, :z], [:q, :r, :p]], [[:b, :c, :d], [:i, :j, :k]], [[:i, :j, :k], [:i2, :j3, :k4]]] findAll:dict(
          (v, (v2, _, v3)), cell?(:"_") should be false. result << [v, v2, v3]) 
        result should == [[[:x, :y, :z], :q, :p], [[:b, :c, :d], :i, :k], [[:i, :j, :k], :i2, :k4]]
      )

      it("should report a destructuring match error if destructuring doesn't add upp",
        fn([[1,2], [3,4], [4,5]] findAll:dict((q,p,r), nil)) should signal(Condition Error DestructuringMismatch)
        fn([[1,2], [3,4], [4,5]] findAll:dict((q), nil)) should signal(Condition Error DestructuringMismatch)
        fn([[1,2], [3,4], [4,5]] findAll:dict((q,_,r), nil)) should signal(Condition Error DestructuringMismatch)
      )

      it("should report a destructuring match error if recursive destructuring doesn't add upp",
        fn([[[1,2],[1,2]], [[3,4],[1,2]], [[1,2],[4,5]]] findAll:dict((q,(p)), nil)) should signal(Condition Error DestructuringMismatch)
        fn([[[1,2],[1,2]], [[3,4],[1,2]], [[1,2],[4,5]]] findAll:dict((q,(p,r,f)), nil)) should signal(Condition Error DestructuringMismatch)
        fn([[[1,2],[1,2]], [[3,4],[1,2]], [[1,2],[4,5]]] findAll:dict((q,(p,_,f)), nil)) should signal(Condition Error DestructuringMismatch)
      )
    )

    describe("findAll:set",
      it("should take zero arguments and return a set with only the true values",
        [1,2,3] findAll:set should == #{1,2,3}
        [nil,false,nil] findAll:set should == #{}
        [nil,false,true] findAll:set should == #{true}
        CustomEnumerable findAll:set should == set(*(CustomEnumerable asList))
      )

      it("should take one argument that ends up being a predicate and return a set of the values that is true",
        [1,2,3] findAll:set(>1) should == #{2,3}
        [nil,false,nil] findAll:set(nil?) should == #{nil}
        [nil,false,true] findAll:set(==2) should == #{}
        CustomEnumerable findAll:set([0...1] != "1") should == #{"3first", "2third"}
      )

      it("should take two arguments that ends up being a predicate and return a set of the values that is true",
        [1,2,3] findAll:set(x, x>1) should == #{2,3}
        [nil,false,nil] findAll:set(x, x nil?) should == #{nil}
        [nil,false,true] findAll:set(x, x==2) should == #{}
        CustomEnumerable findAll:set(x, x != "2third") should == #{"3first", "1second"}
      )

      it("should be able to destructure on the argument name",
        result = []
        [[1,2], [2,3], [4,5]] findAll:set((x,y), result << [x+1, y-1])
        result should == [[2,1], [3,2], [5,4]]
      )

      it("should be able to destructure and ignore the rest of something",
        result = []
        [[1,2,9,10], [2,3,11,12], [4,5,13,14]] findAll:set((x,y,_), cell?(:"_") should not be true. result << [x, y])
        result should == [[1,2], [2,3], [4,5]]
      )

      it("should be able to destructure and ignore in the middle of the pattern without binding anything",
        result = []
        [[1,2,9], [2,3,11], [4,5,13]] findAll:set((x,_,y), cell?(:"_") should not be true. result << [x, y]) 
        result should == [[1,9], [2,11], [4,13]]
      )

      it("should be able to destructure and ignore several times in the middle of the pattern without binding anything",
        result = []
        [[1,2,9,10,11], [2,3,11,12,13], [4,5,13,14,15]] findAll:set((x,_,y,_,q), cell?(:"_") should not be true. result << [x, y, q]) 
        result should == [[1,9,11], [2,11,13], [4,13,15]]
      )

      it("should be able to destructure recursively",
        result = []
        [[[:x, :y, :z], [:q, :r, :p]], [[:b, :c, :d], [:i, :j, :k]], [[:i, :j, :k], [:i2, :j3, :k4]]] findAll:set(
          (v, (v2, _, v3)), cell?(:"_") should be false. result << [v, v2, v3]) 
        result should == [[[:x, :y, :z], :q, :p], [[:b, :c, :d], :i, :k], [[:i, :j, :k], :i2, :k4]]
      )

      it("should report a destructuring match error if destructuring doesn't add upp",
        fn([[1,2], [3,4], [4,5]] findAll:set((q,p,r), nil)) should signal(Condition Error DestructuringMismatch)
        fn([[1,2], [3,4], [4,5]] findAll:set((q), nil)) should signal(Condition Error DestructuringMismatch)
        fn([[1,2], [3,4], [4,5]] findAll:set((q,_,r), nil)) should signal(Condition Error DestructuringMismatch)
      )

      it("should report a destructuring match error if recursive destructuring doesn't add upp",
        fn([[[1,2],[1,2]], [[3,4],[1,2]], [[1,2],[4,5]]] findAll:set((q,(p)), nil)) should signal(Condition Error DestructuringMismatch)
        fn([[[1,2],[1,2]], [[3,4],[1,2]], [[1,2],[4,5]]] findAll:set((q,(p,r,f)), nil)) should signal(Condition Error DestructuringMismatch)
        fn([[[1,2],[1,2]], [[3,4],[1,2]], [[1,2],[4,5]]] findAll:set((q,(p,_,f)), nil)) should signal(Condition Error DestructuringMismatch)
      )
    )

    describe("filter",
      it("should take zero arguments and return a list with only the true values",
        [1,2,3] filter should == [1,2,3]
        [nil,false,nil] filter should == []
        [nil,false,true] filter should == [true]
        CustomEnumerable filter should == CustomEnumerable asList
      )

      it("should take one argument that ends up being a predicate and return a list of the values that is true",
        [1,2,3] filter(>1) should == [2,3]
        [nil,false,nil] filter(nil?) should == [nil, nil]
        [nil,false,true] filter(==2) should == []
        CustomEnumerable filter([0...1] != "1") should == ["3first", "2third"]
      )

      it("should take two arguments that ends up being a predicate and return a list of the values that is true",
        [1,2,3] filter(x, x>1) should == [2,3]
        [nil,false,nil] filter(x, x nil?) should == [nil, nil]
        [nil,false,true] filter(x, x==2) should == []
        CustomEnumerable filter(x, x != "2third") should == ["3first", "1second"]
      )

      it("should be able to destructure on the argument name",
        result = []
        [[1,2], [2,3], [4,5]] filter((x,y), result << [x+1, y-1])
        result should == [[2,1], [3,2], [5,4]]
      )

      it("should be able to destructure and ignore the rest of something",
        result = []
        [[1,2,9,10], [2,3,11,12], [4,5,13,14]] filter((x,y,_), cell?(:"_") should not be true. result << [x, y])
        result should == [[1,2], [2,3], [4,5]]
      )

      it("should be able to destructure and ignore in the middle of the pattern without binding anything",
        result = []
        [[1,2,9], [2,3,11], [4,5,13]] filter((x,_,y), cell?(:"_") should not be true. result << [x, y]) 
        result should == [[1,9], [2,11], [4,13]]
      )

      it("should be able to destructure and ignore several times in the middle of the pattern without binding anything",
        result = []
        [[1,2,9,10,11], [2,3,11,12,13], [4,5,13,14,15]] filter((x,_,y,_,q), cell?(:"_") should not be true. result << [x, y, q]) 
        result should == [[1,9,11], [2,11,13], [4,13,15]]
      )

      it("should be able to destructure recursively",
        result = []
        [[[:x, :y, :z], [:q, :r, :p]], [[:b, :c, :d], [:i, :j, :k]], [[:i, :j, :k], [:i2, :j3, :k4]]] filter(
          (v, (v2, _, v3)), cell?(:"_") should be false. result << [v, v2, v3]) 
        result should == [[[:x, :y, :z], :q, :p], [[:b, :c, :d], :i, :k], [[:i, :j, :k], :i2, :k4]]
      )

      it("should report a destructuring match error if destructuring doesn't add upp",
        fn([[1,2], [3,4], [4,5]] filter((q,p,r), nil)) should signal(Condition Error DestructuringMismatch)
        fn([[1,2], [3,4], [4,5]] filter((q), nil)) should signal(Condition Error DestructuringMismatch)
        fn([[1,2], [3,4], [4,5]] filter((q,_,r), nil)) should signal(Condition Error DestructuringMismatch)
      )

      it("should report a destructuring match error if recursive destructuring doesn't add upp",
        fn([[[1,2],[1,2]], [[3,4],[1,2]], [[1,2],[4,5]]] filter((q,(p)), nil)) should signal(Condition Error DestructuringMismatch)
        fn([[[1,2],[1,2]], [[3,4],[1,2]], [[1,2],[4,5]]] filter((q,(p,r,f)), nil)) should signal(Condition Error DestructuringMismatch)
        fn([[[1,2],[1,2]], [[3,4],[1,2]], [[1,2],[4,5]]] filter((q,(p,_,f)), nil)) should signal(Condition Error DestructuringMismatch)
      )
    )

    describe("filter:dict",
      it("should take zero arguments and return a dict with only the true values",
        [1,2,3] filter:dict should == {1 => nil, 2 => nil, 3 => nil}
        [nil,false,nil] filter:dict should == {}
        [nil,false,true] filter:dict should == {true => nil}
        {nil => 42, true => 55, blah: 222} filter:dict should == {nil => 42, true => 55, blah: 222}
        CustomEnumerable filter:dict should == {"3first" => nil, "2third" => nil, "1second" => nil}
      )

      it("should take one argument that ends up being a predicate and return a dict of the values that is true",
        [1,2,3] filter:dict(>1) should == {2 => nil, 3 => nil}
        [nil,false,nil] filter:dict(nil?) should == {nil => nil}
        [nil,false,true] filter:dict(==2) should == {}
        {foo: 42, bar: 2324, quux: 42} filter:dict(value == 42) should == {foo: 42, quux: 42}
        CustomEnumerable filter:dict([0...1] != "1") should == {"3first" => nil, "2third" => nil}
      )

      it("should take two arguments that ends up being a predicate and return a dict of the values that is true",
        [1,2,3] filter:dict(x, x>1) should == {2 => nil, 3 => nil}
        [nil,false,nil] filter:dict(x, x nil?) should == {nil => nil}
        [nil,false,true] filter:dict(x, x==2) should == {}
        {foo: 42, bar: 2324, quux: 42} filter:dict(x, x value == 42) should == {foo: 42, quux: 42}
        CustomEnumerable filter:dict(x, x != "2third") should == {"3first" => nil, "1second" => nil}
      )

      it("should be able to destructure on the argument name",
        result = []
        [[1,2], [2,3], [4,5]] filter:dict((x,y), result << [x+1, y-1])
        result should == [[2,1], [3,2], [5,4]]
      )

      it("should be able to destructure and ignore the rest of something",
        result = []
        [[1,2,9,10], [2,3,11,12], [4,5,13,14]] filter:dict((x,y,_), cell?(:"_") should not be true. result << [x, y])
        result should == [[1,2], [2,3], [4,5]]
      )

      it("should be able to destructure and ignore in the middle of the pattern without binding anything",
        result = []
        [[1,2,9], [2,3,11], [4,5,13]] filter:dict((x,_,y), cell?(:"_") should not be true. result << [x, y]) 
        result should == [[1,9], [2,11], [4,13]]
      )

      it("should be able to destructure and ignore several times in the middle of the pattern without binding anything",
        result = []
        [[1,2,9,10,11], [2,3,11,12,13], [4,5,13,14,15]] filter:dict((x,_,y,_,q), cell?(:"_") should not be true. result << [x, y, q]) 
        result should == [[1,9,11], [2,11,13], [4,13,15]]
      )

      it("should be able to destructure recursively",
        result = []
        [[[:x, :y, :z], [:q, :r, :p]], [[:b, :c, :d], [:i, :j, :k]], [[:i, :j, :k], [:i2, :j3, :k4]]] filter:dict(
          (v, (v2, _, v3)), cell?(:"_") should be false. result << [v, v2, v3]) 
        result should == [[[:x, :y, :z], :q, :p], [[:b, :c, :d], :i, :k], [[:i, :j, :k], :i2, :k4]]
      )

      it("should report a destructuring match error if destructuring doesn't add upp",
        fn([[1,2], [3,4], [4,5]] filter:dict((q,p,r), nil)) should signal(Condition Error DestructuringMismatch)
        fn([[1,2], [3,4], [4,5]] filter:dict((q), nil)) should signal(Condition Error DestructuringMismatch)
        fn([[1,2], [3,4], [4,5]] filter:dict((q,_,r), nil)) should signal(Condition Error DestructuringMismatch)
      )

      it("should report a destructuring match error if recursive destructuring doesn't add upp",
        fn([[[1,2],[1,2]], [[3,4],[1,2]], [[1,2],[4,5]]] filter:dict((q,(p)), nil)) should signal(Condition Error DestructuringMismatch)
        fn([[[1,2],[1,2]], [[3,4],[1,2]], [[1,2],[4,5]]] filter:dict((q,(p,r,f)), nil)) should signal(Condition Error DestructuringMismatch)
        fn([[[1,2],[1,2]], [[3,4],[1,2]], [[1,2],[4,5]]] filter:dict((q,(p,_,f)), nil)) should signal(Condition Error DestructuringMismatch)
      )
    )

    describe("filter:set",
      it("should take zero arguments and return a set with only the true values",
        [1,2,3] filter:set should == #{1,2,3}
        [nil,false,nil] filter:set should == #{}
        [nil,false,true] filter:set should == #{true}
        CustomEnumerable filter:set should == set(*(CustomEnumerable asList))
      )

      it("should take one argument that ends up being a predicate and return a set of the values that is true",
        [1,2,3] filter:set(>1) should == #{2,3}
        [nil,false,nil] filter:set(nil?) should == #{nil}
        [nil,false,true] filter:set(==2) should == #{}
        CustomEnumerable filter:set([0...1] != "1") should == #{"3first", "2third"}
      )

      it("should take two arguments that ends up being a predicate and return a set of the values that is true",
        [1,2,3] filter:set(x, x>1) should == #{2,3}
        [nil,false,nil] filter:set(x, x nil?) should == #{nil}
        [nil,false,true] filter:set(x, x==2) should == #{}
        CustomEnumerable filter:set(x, x != "2third") should == #{"3first", "1second"}
      )

      it("should be able to destructure on the argument name",
        result = []
        [[1,2], [2,3], [4,5]] filter:set((x,y), result << [x+1, y-1])
        result should == [[2,1], [3,2], [5,4]]
      )

      it("should be able to destructure and ignore the rest of something",
        result = []
        [[1,2,9,10], [2,3,11,12], [4,5,13,14]] filter:set((x,y,_), cell?(:"_") should not be true. result << [x, y])
        result should == [[1,2], [2,3], [4,5]]
      )

      it("should be able to destructure and ignore in the middle of the pattern without binding anything",
        result = []
        [[1,2,9], [2,3,11], [4,5,13]] filter:set((x,_,y), cell?(:"_") should not be true. result << [x, y]) 
        result should == [[1,9], [2,11], [4,13]]
      )

      it("should be able to destructure and ignore several times in the middle of the pattern without binding anything",
        result = []
        [[1,2,9,10,11], [2,3,11,12,13], [4,5,13,14,15]] filter:set((x,_,y,_,q), cell?(:"_") should not be true. result << [x, y, q]) 
        result should == [[1,9,11], [2,11,13], [4,13,15]]
      )

      it("should be able to destructure recursively",
        result = []
        [[[:x, :y, :z], [:q, :r, :p]], [[:b, :c, :d], [:i, :j, :k]], [[:i, :j, :k], [:i2, :j3, :k4]]] filter:set(
          (v, (v2, _, v3)), cell?(:"_") should be false. result << [v, v2, v3]) 
        result should == [[[:x, :y, :z], :q, :p], [[:b, :c, :d], :i, :k], [[:i, :j, :k], :i2, :k4]]
      )

      it("should report a destructuring match error if destructuring doesn't add upp",
        fn([[1,2], [3,4], [4,5]] filter:set((q,p,r), nil)) should signal(Condition Error DestructuringMismatch)
        fn([[1,2], [3,4], [4,5]] filter:set((q), nil)) should signal(Condition Error DestructuringMismatch)
        fn([[1,2], [3,4], [4,5]] filter:set((q,_,r), nil)) should signal(Condition Error DestructuringMismatch)
      )

      it("should report a destructuring match error if recursive destructuring doesn't add upp",
        fn([[[1,2],[1,2]], [[3,4],[1,2]], [[1,2],[4,5]]] filter:set((q,(p)), nil)) should signal(Condition Error DestructuringMismatch)
        fn([[[1,2],[1,2]], [[3,4],[1,2]], [[1,2],[4,5]]] filter:set((q,(p,r,f)), nil)) should signal(Condition Error DestructuringMismatch)
        fn([[[1,2],[1,2]], [[3,4],[1,2]], [[1,2],[4,5]]] filter:set((q,(p,_,f)), nil)) should signal(Condition Error DestructuringMismatch)
      )
    )

    describe("all?",
      it("should take zero arguments and just check if all of the values are true",
        [1,2,3] all? should be true
        [nil,false,nil] all? should be false
        [nil,false,true] all? should be false
        CustomEnumerable all? should be true
      )

      it("should take one argument that is a predicate that is applied to each element in the enumeration",
        [1,2,3] all?(==2) should be false
        [1,2,3] all?(>0) should be true
        [nil,false,nil] all?(nil?) should be false
        [nil,false,true] all?(==2) should be false
        CustomEnumerable all?(!= "foo") should be true
      )

      it("should take two arguments that will be turned into a lexical block and applied",
        [1,2,3] all?(x, x==2) should be false
        [1,2,3] all?(x, x<4) should be true
        [nil,false,nil] all?(x, x nil?) should be false
        [nil,nil,nil] all?(x, x nil?) should be true
        [nil,false,true] all?(x, x==2) should be false
        CustomEnumerable all?(x, x != "foo") should be true
      )

      it("should be able to destructure on the argument name",
        result = []
        [[1,2], [2,3], [4,5]] all?((x,y), result << [x+1, y-1])
        result should == [[2,1], [3,2], [5,4]]
      )

      it("should be able to destructure and ignore the rest of something",
        result = []
        [[1,2,9,10], [2,3,11,12], [4,5,13,14]] all?((x,y,_), cell?(:"_") should not be true. result << [x, y])
        result should == [[1,2], [2,3], [4,5]]
      )

      it("should be able to destructure and ignore in the middle of the pattern without binding anything",
        result = []
        [[1,2,9], [2,3,11], [4,5,13]] all?((x,_,y), cell?(:"_") should not be true. result << [x, y]) 
        result should == [[1,9], [2,11], [4,13]]
      )

      it("should be able to destructure and ignore several times in the middle of the pattern without binding anything",
        result = []
        [[1,2,9,10,11], [2,3,11,12,13], [4,5,13,14,15]] all?((x,_,y,_,q), cell?(:"_") should not be true. result << [x, y, q]) 
        result should == [[1,9,11], [2,11,13], [4,13,15]]
      )

      it("should be able to destructure recursively",
        result = []
        [[[:x, :y, :z], [:q, :r, :p]], [[:b, :c, :d], [:i, :j, :k]], [[:i, :j, :k], [:i2, :j3, :k4]]] all?(
          (v, (v2, _, v3)), cell?(:"_") should be false. result << [v, v2, v3]) 
        result should == [[[:x, :y, :z], :q, :p], [[:b, :c, :d], :i, :k], [[:i, :j, :k], :i2, :k4]]
      )

      it("should report a destructuring match error if destructuring doesn't add upp",
        fn([[1,2], [3,4], [4,5]] all?((q,p,r), nil)) should signal(Condition Error DestructuringMismatch)
        fn([[1,2], [3,4], [4,5]] all?((q), nil)) should signal(Condition Error DestructuringMismatch)
        fn([[1,2], [3,4], [4,5]] all?((q,_,r), nil)) should signal(Condition Error DestructuringMismatch)
      )

      it("should report a destructuring match error if recursive destructuring doesn't add upp",
        fn([[[1,2],[1,2]], [[3,4],[1,2]], [[1,2],[4,5]]] all?((q,(p)), nil)) should signal(Condition Error DestructuringMismatch)
        fn([[[1,2],[1,2]], [[3,4],[1,2]], [[1,2],[4,5]]] all?((q,(p,r,f)), nil)) should signal(Condition Error DestructuringMismatch)
        fn([[[1,2],[1,2]], [[3,4],[1,2]], [[1,2],[4,5]]] all?((q,(p,_,f)), nil)) should signal(Condition Error DestructuringMismatch)
      )
    )

    describe("count",
      it("should take zero arguments and return how many elements there are",
        [1,2,3] count should == 3
        [nil,false] count should == 2
        [nil,false,true] count should == 3
        CustomEnumerable count should == 3
      )

      it("should take one element that is a predicate, and return how many matches it",
        [1,2,3] count(>1) should == 2
        [nil,false,nil] count(nil?) should == 2
        [nil,false,true] count(==2) should == 0
        CustomEnumerable count([0...1] != "1") should == 2
      )

      it("should take two elements that turn into a lexical block and returns how many matches it",
        [1,2,3] count(x, x>1) should == 2
        [nil,false,nil] count(x, x nil?) should == 2
        [nil,false,true] count(x, x==2) should == 0
        CustomEnumerable count(x, x != "2third") should == 2
      )

      it("should be able to destructure on the argument name",
        result = []
        [[1,2], [2,3], [4,5]] count((x,y), result << [x+1, y-1])
        result should == [[2,1], [3,2], [5,4]]
      )

      it("should be able to destructure and ignore the rest of something",
        result = []
        [[1,2,9,10], [2,3,11,12], [4,5,13,14]] count((x,y,_), cell?(:"_") should not be true. result << [x, y])
        result should == [[1,2], [2,3], [4,5]]
      )

      it("should be able to destructure and ignore in the middle of the pattern without binding anything",
        result = []
        [[1,2,9], [2,3,11], [4,5,13]] count((x,_,y), cell?(:"_") should not be true. result << [x, y]) 
        result should == [[1,9], [2,11], [4,13]]
      )

      it("should be able to destructure and ignore several times in the middle of the pattern without binding anything",
        result = []
        [[1,2,9,10,11], [2,3,11,12,13], [4,5,13,14,15]] count((x,_,y,_,q), cell?(:"_") should not be true. result << [x, y, q]) 
        result should == [[1,9,11], [2,11,13], [4,13,15]]
      )

      it("should be able to destructure recursively",
        result = []
        [[[:x, :y, :z], [:q, :r, :p]], [[:b, :c, :d], [:i, :j, :k]], [[:i, :j, :k], [:i2, :j3, :k4]]] count(
          (v, (v2, _, v3)), cell?(:"_") should be false. result << [v, v2, v3]) 
        result should == [[[:x, :y, :z], :q, :p], [[:b, :c, :d], :i, :k], [[:i, :j, :k], :i2, :k4]]
      )

      it("should report a destructuring match error if destructuring doesn't add upp",
        fn([[1,2], [3,4], [4,5]] count((q,p,r), nil)) should signal(Condition Error DestructuringMismatch)
        fn([[1,2], [3,4], [4,5]] count((q), nil)) should signal(Condition Error DestructuringMismatch)
        fn([[1,2], [3,4], [4,5]] count((q,_,r), nil)) should signal(Condition Error DestructuringMismatch)
      )

      it("should report a destructuring match error if recursive destructuring doesn't add upp",
        fn([[[1,2],[1,2]], [[3,4],[1,2]], [[1,2],[4,5]]] count((q,(p)), nil)) should signal(Condition Error DestructuringMismatch)
        fn([[[1,2],[1,2]], [[3,4],[1,2]], [[1,2],[4,5]]] count((q,(p,r,f)), nil)) should signal(Condition Error DestructuringMismatch)
        fn([[[1,2],[1,2]], [[3,4],[1,2]], [[1,2],[4,5]]] count((q,(p,_,f)), nil)) should signal(Condition Error DestructuringMismatch)
      )
    )

    describe("reject",
      it("should take one argument that ends up being a predicate and return a list of the values that is false",
        [1,2,3] reject(>1) should == [1]
        [nil,false,nil] reject(nil?) should == [false]
        [nil,false,true] reject(==2) should == [nil,false,true]
        CustomEnumerable reject([0...1] == "1") should == ["3first", "2third"]
      )

      it("should take two arguments that ends up being a predicate and return a list of the values that is false",
        [1,2,3] reject(x, x>1) should == [1]
        [nil,false,nil] reject(x, x nil?) should == [false]
        [nil,false,true] reject(x, x==2) should == [nil,false,true]
        CustomEnumerable reject(x, x == "2third") should == ["3first", "1second"]
      )

      it("should be able to destructure on the argument name",
        result = []
        [[1,2], [2,3], [4,5]] reject((x,y), result << [x+1, y-1])
        result should == [[2,1], [3,2], [5,4]]
      )

      it("should be able to destructure and ignore the rest of something",
        result = []
        [[1,2,9,10], [2,3,11,12], [4,5,13,14]] reject((x,y,_), cell?(:"_") should not be true. result << [x, y])
        result should == [[1,2], [2,3], [4,5]]
      )

      it("should be able to destructure and ignore in the middle of the pattern without binding anything",
        result = []
        [[1,2,9], [2,3,11], [4,5,13]] reject((x,_,y), cell?(:"_") should not be true. result << [x, y]) 
        result should == [[1,9], [2,11], [4,13]]
      )

      it("should be able to destructure and ignore several times in the middle of the pattern without binding anything",
        result = []
        [[1,2,9,10,11], [2,3,11,12,13], [4,5,13,14,15]] reject((x,_,y,_,q), cell?(:"_") should not be true. result << [x, y, q]) 
        result should == [[1,9,11], [2,11,13], [4,13,15]]
      )

      it("should be able to destructure recursively",
        result = []
        [[[:x, :y, :z], [:q, :r, :p]], [[:b, :c, :d], [:i, :j, :k]], [[:i, :j, :k], [:i2, :j3, :k4]]] reject(
          (v, (v2, _, v3)), cell?(:"_") should be false. result << [v, v2, v3]) 
        result should == [[[:x, :y, :z], :q, :p], [[:b, :c, :d], :i, :k], [[:i, :j, :k], :i2, :k4]]
      )

      it("should report a destructuring match error if destructuring doesn't add upp",
        fn([[1,2], [3,4], [4,5]] reject((q,p,r), nil)) should signal(Condition Error DestructuringMismatch)
        fn([[1,2], [3,4], [4,5]] reject((q), nil)) should signal(Condition Error DestructuringMismatch)
        fn([[1,2], [3,4], [4,5]] reject((q,_,r), nil)) should signal(Condition Error DestructuringMismatch)
      )

      it("should report a destructuring match error if recursive destructuring doesn't add upp",
        fn([[[1,2],[1,2]], [[3,4],[1,2]], [[1,2],[4,5]]] reject((q,(p)), nil)) should signal(Condition Error DestructuringMismatch)
        fn([[[1,2],[1,2]], [[3,4],[1,2]], [[1,2],[4,5]]] reject((q,(p,r,f)), nil)) should signal(Condition Error DestructuringMismatch)
        fn([[[1,2],[1,2]], [[3,4],[1,2]], [[1,2],[4,5]]] reject((q,(p,_,f)), nil)) should signal(Condition Error DestructuringMismatch)
      )
    )

    describe("reject:dict",
      it("should take one argument that ends up being a predicate and return a dict of the values that is false",
        [1,2,3] reject:dict(>1) should == {1 => nil}
        [nil,false,nil] reject:dict(nil?) should == {false => nil}
        [nil,false,true] reject:dict(==2) should == {nil => nil,false => nil,true => nil}
        {:foo => 42, 2 => 55} reject:dict(key == 2) should == {:foo => 42}
        CustomEnumerable reject:dict([0...1] == "1") should == {"3first" => nil, "2third" => nil}
      )

      it("should take two arguments that ends up being a predicate and return a dict of the values that is false",
        [1,2,3] reject:dict(x, x>1) should == {1 => nil}
        [nil,false,nil] reject:dict(x, x nil?) should == {false => nil}
        [nil,false,true] reject:dict(x, x==2) should == {nil => nil,false => nil,true => nil}
        {:foo => 42, 2 => 55} reject:dict(x, x key == 2) should == {:foo => 42}
        CustomEnumerable reject:dict(x, x == "2third") should == {"3first" => nil, "1second" => nil}
      )

      it("should be able to destructure on the argument name",
        result = []
        [[1,2], [2,3], [4,5]] reject:dict((x,y), result << [x+1, y-1])
        result should == [[2,1], [3,2], [5,4]]
      )

      it("should be able to destructure and ignore the rest of something",
        result = []
        [[1,2,9,10], [2,3,11,12], [4,5,13,14]] reject:dict((x,y,_), cell?(:"_") should not be true. result << [x, y])
        result should == [[1,2], [2,3], [4,5]]
      )

      it("should be able to destructure and ignore in the middle of the pattern without binding anything",
        result = []
        [[1,2,9], [2,3,11], [4,5,13]] reject:dict((x,_,y), cell?(:"_") should not be true. result << [x, y]) 
        result should == [[1,9], [2,11], [4,13]]
      )

      it("should be able to destructure and ignore several times in the middle of the pattern without binding anything",
        result = []
        [[1,2,9,10,11], [2,3,11,12,13], [4,5,13,14,15]] reject:dict((x,_,y,_,q), cell?(:"_") should not be true. result << [x, y, q]) 
        result should == [[1,9,11], [2,11,13], [4,13,15]]
      )

      it("should be able to destructure recursively",
        result = []
        [[[:x, :y, :z], [:q, :r, :p]], [[:b, :c, :d], [:i, :j, :k]], [[:i, :j, :k], [:i2, :j3, :k4]]] reject:dict(
          (v, (v2, _, v3)), cell?(:"_") should be false. result << [v, v2, v3]) 
        result should == [[[:x, :y, :z], :q, :p], [[:b, :c, :d], :i, :k], [[:i, :j, :k], :i2, :k4]]
      )

      it("should report a destructuring match error if destructuring doesn't add upp",
        fn([[1,2], [3,4], [4,5]] reject:dict((q,p,r), nil)) should signal(Condition Error DestructuringMismatch)
        fn([[1,2], [3,4], [4,5]] reject:dict((q), nil)) should signal(Condition Error DestructuringMismatch)
        fn([[1,2], [3,4], [4,5]] reject:dict((q,_,r), nil)) should signal(Condition Error DestructuringMismatch)
      )

      it("should report a destructuring match error if recursive destructuring doesn't add upp",
        fn([[[1,2],[1,2]], [[3,4],[1,2]], [[1,2],[4,5]]] reject:dict((q,(p)), nil)) should signal(Condition Error DestructuringMismatch)
        fn([[[1,2],[1,2]], [[3,4],[1,2]], [[1,2],[4,5]]] reject:dict((q,(p,r,f)), nil)) should signal(Condition Error DestructuringMismatch)
        fn([[[1,2],[1,2]], [[3,4],[1,2]], [[1,2],[4,5]]] reject:dict((q,(p,_,f)), nil)) should signal(Condition Error DestructuringMismatch)
      )
    )

    describe("reject:set",
      it("should take one argument that ends up being a predicate and return a list of the values that is false",
        [1,2,3] reject:set(>1) should == #{1}
        [nil,false,nil] reject:set(nil?) should == #{false}
        [nil,false,true] reject:set(==2) should == #{nil,false,true}
        CustomEnumerable reject:set([0...1] == "1") should == #{"3first", "2third"}
      )

      it("should take two arguments that ends up being a predicate and return a list of the values that is false",
        [1,2,3] reject:set(x, x>1) should == #{1}
        [nil,false,nil] reject:set(x, x nil?) should == #{false}
        [nil,false,true] reject:set(x, x==2) should == #{nil,false,true}
        CustomEnumerable reject:set(x, x == "2third") should == #{"3first", "1second"}
      )

      it("should be able to destructure on the argument name",
        result = []
        [[1,2], [2,3], [4,5]] reject:set((x,y), result << [x+1, y-1])
        result should == [[2,1], [3,2], [5,4]]
      )

      it("should be able to destructure and ignore the rest of something",
        result = []
        [[1,2,9,10], [2,3,11,12], [4,5,13,14]] reject:set((x,y,_), cell?(:"_") should not be true. result << [x, y])
        result should == [[1,2], [2,3], [4,5]]
      )

      it("should be able to destructure and ignore in the middle of the pattern without binding anything",
        result = []
        [[1,2,9], [2,3,11], [4,5,13]] reject:set((x,_,y), cell?(:"_") should not be true. result << [x, y]) 
        result should == [[1,9], [2,11], [4,13]]
      )

      it("should be able to destructure and ignore several times in the middle of the pattern without binding anything",
        result = []
        [[1,2,9,10,11], [2,3,11,12,13], [4,5,13,14,15]] reject:set((x,_,y,_,q), cell?(:"_") should not be true. result << [x, y, q]) 
        result should == [[1,9,11], [2,11,13], [4,13,15]]
      )

      it("should be able to destructure recursively",
        result = []
        [[[:x, :y, :z], [:q, :r, :p]], [[:b, :c, :d], [:i, :j, :k]], [[:i, :j, :k], [:i2, :j3, :k4]]] reject:set(
          (v, (v2, _, v3)), cell?(:"_") should be false. result << [v, v2, v3]) 
        result should == [[[:x, :y, :z], :q, :p], [[:b, :c, :d], :i, :k], [[:i, :j, :k], :i2, :k4]]
      )

      it("should report a destructuring match error if destructuring doesn't add upp",
        fn([[1,2], [3,4], [4,5]] reject:set((q,p,r), nil)) should signal(Condition Error DestructuringMismatch)
        fn([[1,2], [3,4], [4,5]] reject:set((q), nil)) should signal(Condition Error DestructuringMismatch)
        fn([[1,2], [3,4], [4,5]] reject:set((q,_,r), nil)) should signal(Condition Error DestructuringMismatch)
      )

      it("should report a destructuring match error if recursive destructuring doesn't add upp",
        fn([[[1,2],[1,2]], [[3,4],[1,2]], [[1,2],[4,5]]] reject:set((q,(p)), nil)) should signal(Condition Error DestructuringMismatch)
        fn([[[1,2],[1,2]], [[3,4],[1,2]], [[1,2],[4,5]]] reject:set((q,(p,r,f)), nil)) should signal(Condition Error DestructuringMismatch)
        fn([[[1,2],[1,2]], [[3,4],[1,2]], [[1,2],[4,5]]] reject:set((q,(p,_,f)), nil)) should signal(Condition Error DestructuringMismatch)
      )
    )

    describe("first",
      it("should return nil for an empty collection",
        set first should be nil
      )

      it("should take an optional argument of how many to return",
        set first(0) should == []
        set first(1) should == []
        set first(2) should == []
      )

      it("should return the first element for a non-empty collection",
        set(42) first should == 42
        CustomEnumerable first should == "3first"
      )

      it("should return the first n elements for a non-empty collection",
        set(42) first(0) should == []
        set(42) first(1) should == [42]
        set(42) first(2) should == [42]
        [42, 44, 46] first(2) should == [42, 44]
        set(42, 44, 46) first(3) sort should == [42, 44, 46]
        CustomEnumerable first(2) should == ["3first", "1second"]
      )
    )

    describe("first:dict",
      it("should take an argument of how many to return",
        set first:dict(0) should == {}
        set first:dict(1) should == {}
        set first:dict(2) should == {}
      )

      it("should return the first n elements for a non-empty collection",
        set(42) first:dict(0) should == {}
        set(42) first:dict(1) should == {42 => nil}
        set(42) first:dict(2) should == {42 => nil}
        [42, 44, 46] first:dict(2) should == {42 => nil, 44 => nil}
        set(42, 44, 46) first:dict(3) should == {42 => nil, 44 => nil, 46 => nil}
        {foo: 42, bar: 66} first:dict(0) should == {}
        {foo: 42, bar: 66} first:dict(2) should == {foo: 42, bar: 66}
        {foo: 42, bar: 66} first:dict(3) should == {foo: 42, bar: 66}
        CustomEnumerable first:dict(2) should == {"3first" => nil, "1second" => nil}
      )
    )

    describe("first:set",
      it("should take an argument of how many to return",
        set first:set(0) should == #{}
        set first:set(1) should == #{}
        set first:set(2) should == #{}
      )

      it("should return the first n elements for a non-empty collection",
        set(42) first:set(0) should == #{}
        set(42) first:set(1) should == #{42}
        set(42) first:set(2) should == #{42}
        [42, 44, 46] first:set(2) should == #{42, 44}
        set(42, 44, 46) first:set(3) should == #{42, 44, 46}
        CustomEnumerable first:set(2) should == #{"3first", "1second"}
      )
    )

    describe("one?",
      it("should take zero arguments and just check if exactly one of the values are true, and then return true",
        [1,2,3] one? should be false
        [nil,false,nil] one? should be false
        [nil,false,true] one? should be true
        CustomEnumerable one? should be false
      )

      it("should take one argument that is a predicate that is applied to each element in the enumeration",
        [1,2,3] one?(==2) should be true
        [nil,false,nil] one?(nil?) should be false
        [nil,false,true] one?(==2) should be false
        CustomEnumerable one?(== "3first") should be true
      )

      it("should take two arguments that will be turned into a lexical block and applied",
        [1,2,3] one?(x, x==2) should be true
        [nil,false,nil] one?(x, x nil?) should be false
        [nil,false,true] one?(x, x==2) should be false
        CustomEnumerable one?(x, x == "3first") should be true
      )

      it("should be able to destructure on the argument name",
        result = []
        [[1,2], [2,3], [4,5]] one?((x,y), result << [x+1, y-1]. nil)
        result should == [[2,1], [3,2], [5,4]]
      )

      it("should be able to destructure and ignore the rest of something",
        result = []
        [[1,2,9,10], [2,3,11,12], [4,5,13,14]] one?((x,y,_), cell?(:"_") should not be true. result << [x, y]. nil)
        result should == [[1,2], [2,3], [4,5]]
      )

      it("should be able to destructure and ignore in the middle of the pattern without binding anything",
        result = []
        [[1,2,9], [2,3,11], [4,5,13]] one?((x,_,y), cell?(:"_") should not be true. result << [x, y]. nil) 
        result should == [[1,9], [2,11], [4,13]]
      )

      it("should be able to destructure and ignore several times in the middle of the pattern without binding anything",
        result = []
        [[1,2,9,10,11], [2,3,11,12,13], [4,5,13,14,15]] one?((x,_,y,_,q), cell?(:"_") should not be true. result << [x, y, q]. nil) 
        result should == [[1,9,11], [2,11,13], [4,13,15]]
      )

      it("should be able to destructure recursively",
        result = []
        [[[:x, :y, :z], [:q, :r, :p]], [[:b, :c, :d], [:i, :j, :k]], [[:i, :j, :k], [:i2, :j3, :k4]]] one?(
          (v, (v2, _, v3)), cell?(:"_") should be false. result << [v, v2, v3]. nil) 
        result should == [[[:x, :y, :z], :q, :p], [[:b, :c, :d], :i, :k], [[:i, :j, :k], :i2, :k4]]
      )

      it("should report a destructuring match error if destructuring doesn't add upp",
        fn([[1,2], [3,4], [4,5]] one?((q,p,r), nil)) should signal(Condition Error DestructuringMismatch)
        fn([[1,2], [3,4], [4,5]] one?((q), nil)) should signal(Condition Error DestructuringMismatch)
        fn([[1,2], [3,4], [4,5]] one?((q,_,r), nil)) should signal(Condition Error DestructuringMismatch)
      )

      it("should report a destructuring match error if recursive destructuring doesn't add upp",
        fn([[[1,2],[1,2]], [[3,4],[1,2]], [[1,2],[4,5]]] one?((q,(p)), nil)) should signal(Condition Error DestructuringMismatch)
        fn([[[1,2],[1,2]], [[3,4],[1,2]], [[1,2],[4,5]]] one?((q,(p,r,f)), nil)) should signal(Condition Error DestructuringMismatch)
        fn([[[1,2],[1,2]], [[3,4],[1,2]], [[1,2],[4,5]]] one?((q,(p,_,f)), nil)) should signal(Condition Error DestructuringMismatch)
      )
    )

    describe("findIndex",
      it("should take zero arguments and just check if any of the values are true, and then return the index of it",
        [1,2,3] findIndex should == 0
        [nil,false,nil] findIndex should be nil
        [nil,false,true] findIndex should == 2
        CustomEnumerable findIndex should == 0
      )

      it("should take one argument that is a predicate that is applied to each element in the enumeration",
        [1,2,3] findIndex(==2) should == 1
        [nil,false,nil] findIndex(nil?) should == 0
        [nil,false,true] findIndex(==2) should be nil
        CustomEnumerable findIndex(!= "foo") should == 0
      )

      it("should take two arguments that will be turned into a lexical block and applied",
        [1,2,3] findIndex(x, x==2) should == 1
        [nil,false,nil] findIndex(x, x nil?) should == 0
        [nil,false,true] findIndex(x, x==2) should be nil
        CustomEnumerable findIndex(x, x != "foo") should == 0
      )

      it("should be able to destructure on the argument name",
        result = []
        [[1,2], [2,3], [4,5]] findIndex((x,y), result << [x+1, y-1]. nil)
        result should == [[2,1], [3,2], [5,4]]
      )

      it("should be able to destructure and ignore the rest of something",
        result = []
        [[1,2,9,10], [2,3,11,12], [4,5,13,14]] findIndex((x,y,_), cell?(:"_") should not be true. result << [x, y]. nil)
        result should == [[1,2], [2,3], [4,5]]
      )

      it("should be able to destructure and ignore in the middle of the pattern without binding anything",
        result = []
        [[1,2,9], [2,3,11], [4,5,13]] findIndex((x,_,y), cell?(:"_") should not be true. result << [x, y]. nil) 
        result should == [[1,9], [2,11], [4,13]]
      )

      it("should be able to destructure and ignore several times in the middle of the pattern without binding anything",
        result = []
        [[1,2,9,10,11], [2,3,11,12,13], [4,5,13,14,15]] findIndex((x,_,y,_,q), cell?(:"_") should not be true. result << [x, y, q]. nil) 
        result should == [[1,9,11], [2,11,13], [4,13,15]]
      )

      it("should be able to destructure recursively",
        result = []
        [[[:x, :y, :z], [:q, :r, :p]], [[:b, :c, :d], [:i, :j, :k]], [[:i, :j, :k], [:i2, :j3, :k4]]] findIndex(
          (v, (v2, _, v3)), cell?(:"_") should be false. result << [v, v2, v3]. nil) 
        result should == [[[:x, :y, :z], :q, :p], [[:b, :c, :d], :i, :k], [[:i, :j, :k], :i2, :k4]]
      )

      it("should report a destructuring match error if destructuring doesn't add upp",
        fn([[1,2], [3,4], [4,5]] findIndex((q,p,r), nil)) should signal(Condition Error DestructuringMismatch)
        fn([[1,2], [3,4], [4,5]] findIndex((q), nil)) should signal(Condition Error DestructuringMismatch)
        fn([[1,2], [3,4], [4,5]] findIndex((q,_,r), nil)) should signal(Condition Error DestructuringMismatch)
      )

      it("should report a destructuring match error if recursive destructuring doesn't add upp",
        fn([[[1,2],[1,2]], [[3,4],[1,2]], [[1,2],[4,5]]] findIndex((q,(p)), nil)) should signal(Condition Error DestructuringMismatch)
        fn([[[1,2],[1,2]], [[3,4],[1,2]], [[1,2],[4,5]]] findIndex((q,(p,r,f)), nil)) should signal(Condition Error DestructuringMismatch)
        fn([[[1,2],[1,2]], [[3,4],[1,2]], [[1,2],[4,5]]] findIndex((q,(p,_,f)), nil)) should signal(Condition Error DestructuringMismatch)
      )
    )

    describe("partition",
      it("should take zero arguments and just divide all the true and false values",
        [1,2,3] partition should == [[1,2,3],[]]
        [nil,false,nil] partition should == [[], [nil, false, nil]]
        [nil,false,true] partition should == [[true], [nil, false]]
        CustomEnumerable partition should == [["3first", "1second", "2third"], []]
      )

      it("should take one argument that is a predicate that is applied to each element in the enumeration",
        [1,2,3] partition(==2) should == [[2], [1,3]]
        [nil,false,nil] partition(nil?) should  == [[nil,nil], [false]]
        [nil,false,true] partition(==2) should == [[], [nil, false, true]]
        CustomEnumerable partition(!= "foo") should == [["3first", "1second", "2third"], []]
      )

      it("should take two arguments that will be turned into a lexical block and applied",
        [1,2,3] partition(x, x==2) should == [[2], [1,3]]
        [nil,false,nil] partition(x, x nil?) should == [[nil,nil], [false]]
        [nil,false,true] partition(x, x==2) should == [[], [nil, false, true]]
        CustomEnumerable partition(x, x != "foo") should == [["3first", "1second", "2third"], []]
      )

      it("should be able to destructure on the argument name",
        result = []
        [[1,2], [2,3], [4,5]] partition((x,y), result << [x+1, y-1])
        result should == [[2,1], [3,2], [5,4]]
      )

      it("should be able to destructure and ignore the rest of something",
        result = []
        [[1,2,9,10], [2,3,11,12], [4,5,13,14]] partition((x,y,_), cell?(:"_") should not be true. result << [x, y])
        result should == [[1,2], [2,3], [4,5]]
      )

      it("should be able to destructure and ignore in the middle of the pattern without binding anything",
        result = []
        [[1,2,9], [2,3,11], [4,5,13]] partition((x,_,y), cell?(:"_") should not be true. result << [x, y]) 
        result should == [[1,9], [2,11], [4,13]]
      )

      it("should be able to destructure and ignore several times in the middle of the pattern without binding anything",
        result = []
        [[1,2,9,10,11], [2,3,11,12,13], [4,5,13,14,15]] partition((x,_,y,_,q), cell?(:"_") should not be true. result << [x, y, q]) 
        result should == [[1,9,11], [2,11,13], [4,13,15]]
      )

      it("should be able to destructure recursively",
        result = []
        [[[:x, :y, :z], [:q, :r, :p]], [[:b, :c, :d], [:i, :j, :k]], [[:i, :j, :k], [:i2, :j3, :k4]]] partition(
          (v, (v2, _, v3)), cell?(:"_") should be false. result << [v, v2, v3]) 
        result should == [[[:x, :y, :z], :q, :p], [[:b, :c, :d], :i, :k], [[:i, :j, :k], :i2, :k4]]
      )

      it("should report a destructuring match error if destructuring doesn't add upp",
        fn([[1,2], [3,4], [4,5]] partition((q,p,r), nil)) should signal(Condition Error DestructuringMismatch)
        fn([[1,2], [3,4], [4,5]] partition((q), nil)) should signal(Condition Error DestructuringMismatch)
        fn([[1,2], [3,4], [4,5]] partition((q,_,r), nil)) should signal(Condition Error DestructuringMismatch)
      )

      it("should report a destructuring match error if recursive destructuring doesn't add upp",
        fn([[[1,2],[1,2]], [[3,4],[1,2]], [[1,2],[4,5]]] partition((q,(p)), nil)) should signal(Condition Error DestructuringMismatch)
        fn([[[1,2],[1,2]], [[3,4],[1,2]], [[1,2],[4,5]]] partition((q,(p,r,f)), nil)) should signal(Condition Error DestructuringMismatch)
        fn([[[1,2],[1,2]], [[3,4],[1,2]], [[1,2],[4,5]]] partition((q,(p,_,f)), nil)) should signal(Condition Error DestructuringMismatch)
      )
    )

    describe("partition:dict",
      it("should take zero arguments and just divide all the true and false values",
        [1,2,3] partition:dict should == [{1=>nil,2=>nil,3=>nil},{}]
        [nil,false,nil] partition:dict should == [{}, {nil=>nil, false=>nil}]
        [nil,false,true] partition:dict should == [{true=>nil}, {nil=>nil, false=>nil}]
        {foo: 42, bar: 55} partition:dict should == [{foo: 42, bar: 55}, {}]
        CustomEnumerable partition:dict should == [{"3first"=>nil, "1second"=>nil, "2third"=>nil}, {}]
      )

      it("should take one argument that is a predicate that is applied to each element in the enumeration",
        [1,2,3] partition:dict(==2) should == [{2=>nil}, {1=>nil,3=>nil}]
        [nil,false,nil] partition:dict(nil?) should  == [{nil=>nil}, {false=>nil}]
        [nil,false,true] partition:dict(==2) should == [{}, {nil=>nil, false=>nil, true=>nil}]
        {foo: 42, bar: 55} partition:dict(value == 55) should == [{bar: 55}, {foo: 42}]
        CustomEnumerable partition:dict(!= "foo") should == [{"3first"=>nil, "1second"=>nil, "2third"=>nil}, {}]
      )

      it("should take two arguments that will be turned into a lexical block and applied",
        [1,2,3] partition:dict(x, x==2) should == [{2=>nil}, {1=>nil,3=>nil}]
        [nil,false,nil] partition:dict(x, x nil?) should == [{nil=>nil}, {false=>nil}]
        [nil,false,true] partition:dict(x, x==2) should == [{}, {nil=>nil, false=>nil, true=>nil}]
        {foo: 42, bar: 55} partition:dict(x, x value == 55) should == [{bar: 55}, {foo: 42}]
        CustomEnumerable partition:dict(x, x != "foo") should == [{"3first"=>nil, "1second"=>nil, "2third"=>nil}, {}]
      )

      it("should be able to destructure on the argument name",
        result = []
        [[1,2], [2,3], [4,5]] partition:dict((x,y), result << [x+1, y-1])
        result should == [[2,1], [3,2], [5,4]]
      )

      it("should be able to destructure and ignore the rest of something",
        result = []
        [[1,2,9,10], [2,3,11,12], [4,5,13,14]] partition:dict((x,y,_), cell?(:"_") should not be true. result << [x, y])
        result should == [[1,2], [2,3], [4,5]]
      )

      it("should be able to destructure and ignore in the middle of the pattern without binding anything",
        result = []
        [[1,2,9], [2,3,11], [4,5,13]] partition:dict((x,_,y), cell?(:"_") should not be true. result << [x, y]) 
        result should == [[1,9], [2,11], [4,13]]
      )

      it("should be able to destructure and ignore several times in the middle of the pattern without binding anything",
        result = []
        [[1,2,9,10,11], [2,3,11,12,13], [4,5,13,14,15]] partition:dict((x,_,y,_,q), cell?(:"_") should not be true. result << [x, y, q]) 
        result should == [[1,9,11], [2,11,13], [4,13,15]]
      )

      it("should be able to destructure recursively",
        result = []
        [[[:x, :y, :z], [:q, :r, :p]], [[:b, :c, :d], [:i, :j, :k]], [[:i, :j, :k], [:i2, :j3, :k4]]] partition:dict(
          (v, (v2, _, v3)), cell?(:"_") should be false. result << [v, v2, v3]) 
        result should == [[[:x, :y, :z], :q, :p], [[:b, :c, :d], :i, :k], [[:i, :j, :k], :i2, :k4]]
      )

      it("should report a destructuring match error if destructuring doesn't add upp",
        fn([[1,2], [3,4], [4,5]] partition:dict((q,p,r), nil)) should signal(Condition Error DestructuringMismatch)
        fn([[1,2], [3,4], [4,5]] partition:dict((q), nil)) should signal(Condition Error DestructuringMismatch)
        fn([[1,2], [3,4], [4,5]] partition:dict((q,_,r), nil)) should signal(Condition Error DestructuringMismatch)
      )

      it("should report a destructuring match error if recursive destructuring doesn't add upp",
        fn([[[1,2],[1,2]], [[3,4],[1,2]], [[1,2],[4,5]]] partition:dict((q,(p)), nil)) should signal(Condition Error DestructuringMismatch)
        fn([[[1,2],[1,2]], [[3,4],[1,2]], [[1,2],[4,5]]] partition:dict((q,(p,r,f)), nil)) should signal(Condition Error DestructuringMismatch)
        fn([[[1,2],[1,2]], [[3,4],[1,2]], [[1,2],[4,5]]] partition:dict((q,(p,_,f)), nil)) should signal(Condition Error DestructuringMismatch)
      )
    )

    describe("partition:set",
      it("should take zero arguments and just divide all the true and false values",
        [1,2,3] partition:set should == [set(1,2,3),set()]
        [nil,false,nil] partition:set should == [set(), set(nil, false)]
        [nil,false,true] partition:set should == [set(true), set(nil, false)]
        CustomEnumerable partition:set should == [set("3first", "1second", "2third"), set()]
      )

      it("should take one argument that is a predicate that is applied to each element in the enumeration",
        [1,2,3] partition:set(==2) should == [#{2}, #{1,3}]
        [nil,false,nil] partition:set(nil?) should  == [#{nil}, #{false}]
        [nil,false,true] partition:set(==2) should == [#{}, #{nil, false, true}]
        CustomEnumerable partition:set(!= "foo") should == [#{"3first", "1second", "2third"}, #{}]
      )

      it("should take two arguments that will be turned into a lexical block and applied",
        [1,2,3] partition:set(x, x==2) should == [#{2}, #{1,3}]
        [nil,false,nil] partition:set(x, x nil?) should == [#{nil}, #{false}]
        [nil,false,true] partition:set(x, x==2) should == [#{}, #{nil, false, true}]
        CustomEnumerable partition:set(x, x != "foo") should == [#{"3first", "1second", "2third"}, #{}]
      )

      it("should be able to destructure on the argument name",
        result = []
        [[1,2], [2,3], [4,5]] partition:set((x,y), result << [x+1, y-1])
        result should == [[2,1], [3,2], [5,4]]
      )

      it("should be able to destructure and ignore the rest of something",
        result = []
        [[1,2,9,10], [2,3,11,12], [4,5,13,14]] partition:set((x,y,_), cell?(:"_") should not be true. result << [x, y])
        result should == [[1,2], [2,3], [4,5]]
      )

      it("should be able to destructure and ignore in the middle of the pattern without binding anything",
        result = []
        [[1,2,9], [2,3,11], [4,5,13]] partition:set((x,_,y), cell?(:"_") should not be true. result << [x, y]) 
        result should == [[1,9], [2,11], [4,13]]
      )

      it("should be able to destructure and ignore several times in the middle of the pattern without binding anything",
        result = []
        [[1,2,9,10,11], [2,3,11,12,13], [4,5,13,14,15]] partition:set((x,_,y,_,q), cell?(:"_") should not be true. result << [x, y, q]) 
        result should == [[1,9,11], [2,11,13], [4,13,15]]
      )

      it("should be able to destructure recursively",
        result = []
        [[[:x, :y, :z], [:q, :r, :p]], [[:b, :c, :d], [:i, :j, :k]], [[:i, :j, :k], [:i2, :j3, :k4]]] partition:set(
          (v, (v2, _, v3)), cell?(:"_") should be false. result << [v, v2, v3]) 
        result should == [[[:x, :y, :z], :q, :p], [[:b, :c, :d], :i, :k], [[:i, :j, :k], :i2, :k4]]
      )

      it("should report a destructuring match error if destructuring doesn't add upp",
        fn([[1,2], [3,4], [4,5]] partition:set((q,p,r), nil)) should signal(Condition Error DestructuringMismatch)
        fn([[1,2], [3,4], [4,5]] partition:set((q), nil)) should signal(Condition Error DestructuringMismatch)
        fn([[1,2], [3,4], [4,5]] partition:set((q,_,r), nil)) should signal(Condition Error DestructuringMismatch)
      )

      it("should report a destructuring match error if recursive destructuring doesn't add upp",
        fn([[[1,2],[1,2]], [[3,4],[1,2]], [[1,2],[4,5]]] partition:set((q,(p)), nil)) should signal(Condition Error DestructuringMismatch)
        fn([[[1,2],[1,2]], [[3,4],[1,2]], [[1,2],[4,5]]] partition:set((q,(p,r,f)), nil)) should signal(Condition Error DestructuringMismatch)
        fn([[[1,2],[1,2]], [[3,4],[1,2]], [[1,2],[4,5]]] partition:set((q,(p,_,f)), nil)) should signal(Condition Error DestructuringMismatch)
      )
    )

    describe("include?",
      it("should return true if the element is in the enumeration",
        [1,2,3] include?(2) should be true
        CustomEnumerable include?("1second") should be true
      )

      it("should return false if the element is not in the enumeration",
        [1,2,3] include?(0) should be false
        CustomEnumerable include?("2second") should be false
      )
    )

    describe("member?",
      it("should return true if the element is in the enumeration",
        [1,2,3] member?(2) should be true
        CustomEnumerable member?("1second") should be true
      )

      it("should return false if the element is not in the enumeration",
        [1,2,3] member?(0) should be false
        CustomEnumerable member?("2second") should be false
      )
    )

    describe("take",
      it("should return a list with as many elements as requested",
        [1,2,3] take(0) should == []
        [1,2,3] take(1) should == [1]
        [1,2,3] take(2) should == [1,2]
        [1,2,3] take(3) should == [1,2,3]
        CustomEnumerable take(2) should == ["3first", "1second"]
      )

      it("should not take more elements than the length of the collection",
        [1,2,3] take(4) should == [1,2,3]
        [1,2,3] take(10) should == [1,2,3]
        CustomEnumerable take(200) should == ["3first", "1second", "2third"]
      )
    )

    describe("take:dict",
      it("should return a dict with as many elements as requested",
        [1,2,3] take:dict(0) should == {}
        [1,2,3] take:dict(1) should == {1 => nil}
        [1,2,3] take:dict(2) should == {1 => nil, 2 => nil}
        [1,2,3] take:dict(3) should == {1 => nil, 2 => nil, 3 => nil}
        {foo: 42, bar: 66} take:dict(0) should == {}
        {foo: 42, bar: 66} take:dict(2) should == {foo: 42, bar: 66}
        CustomEnumerable take:dict(2) should == {"3first" => nil, "1second" => nil}
      )

      it("should not take more elements than the length of the collection",
        [1,2,3] take:dict(4) should == {1 => nil, 2 => nil, 3 => nil}
        [1,2,3] take:dict(10) should == {1 => nil, 2 => nil, 3 => nil}
        CustomEnumerable take:dict(200) should == {"3first" => nil, "1second" => nil, "2third" => nil}
      )
    )

    describe("take:set",
      it("should return a set with as many elements as requested",
        [1,2,3] take:set(0) should == #{}
        [1,2,3] take:set(1) should == #{1}
        [1,2,3] take:set(2) should == #{1,2}
        [1,2,3] take:set(3) should == #{1,2,3}
        CustomEnumerable take:set(2) should == #{"3first", "1second"}
      )

      it("should not take more elements than the length of the collection",
        [1,2,3] take:set(4) should == #{1,2,3}
        [1,2,3] take:set(10) should == #{1,2,3}
        CustomEnumerable take:set(200) should == #{"3first", "1second", "2third"}
      )
    )

    describe("takeWhile",
      it("should take zero arguments and return everything up until the point where a value is false",
        [1,2,3] takeWhile should == [1,2,3]
        [1,2,nil,false] takeWhile should == [1,2]
        [1,2,false,3,4,nil,false] takeWhile should == [1,2]
        CustomEnumerable takeWhile should == ["3first", "1second", "2third"]
      )

      it("should take one argument and apply it as a message chain, return a list with all elements until the block returns false",
        [1,2,3] takeWhile(<3) should == [1,2]
        [1,2,3] takeWhile(!=2) should == [1]
        CustomEnumerable takeWhile(!="2third") should == ["3first", "1second"]
      )

      it("should take two arguments and apply the lexical block created from it, and return a list with all elements until the block returns false",
        [1,2,3] takeWhile(x, x<3) should == [1,2]
        [1,2,3] takeWhile(x, x != 2) should == [1]
        CustomEnumerable takeWhile(x, x != "2third") should == ["3first", "1second"]
      )

      it("should be able to destructure on the argument name",
        result = []
        [[1,2], [2,3], [4,5]] takeWhile((x,y), result << [x+1, y-1])
        result should == [[2,1], [3,2], [5,4]]
      )

      it("should be able to destructure and ignore the rest of something",
        result = []
        [[1,2,9,10], [2,3,11,12], [4,5,13,14]] takeWhile((x,y,_), cell?(:"_") should not be true. result << [x, y])
        result should == [[1,2], [2,3], [4,5]]
      )

      it("should be able to destructure and ignore in the middle of the pattern without binding anything",
        result = []
        [[1,2,9], [2,3,11], [4,5,13]] takeWhile((x,_,y), cell?(:"_") should not be true. result << [x, y]) 
        result should == [[1,9], [2,11], [4,13]]
      )

      it("should be able to destructure and ignore several times in the middle of the pattern without binding anything",
        result = []
        [[1,2,9,10,11], [2,3,11,12,13], [4,5,13,14,15]] takeWhile((x,_,y,_,q), cell?(:"_") should not be true. result << [x, y, q]) 
        result should == [[1,9,11], [2,11,13], [4,13,15]]
      )

      it("should be able to destructure recursively",
        result = []
        [[[:x, :y, :z], [:q, :r, :p]], [[:b, :c, :d], [:i, :j, :k]], [[:i, :j, :k], [:i2, :j3, :k4]]] takeWhile(
          (v, (v2, _, v3)), cell?(:"_") should be false. result << [v, v2, v3]) 
        result should == [[[:x, :y, :z], :q, :p], [[:b, :c, :d], :i, :k], [[:i, :j, :k], :i2, :k4]]
      )

      it("should report a destructuring match error if destructuring doesn't add upp",
        fn([[1,2], [3,4], [4,5]] takeWhile((q,p,r), nil)) should signal(Condition Error DestructuringMismatch)
        fn([[1,2], [3,4], [4,5]] takeWhile((q), nil)) should signal(Condition Error DestructuringMismatch)
        fn([[1,2], [3,4], [4,5]] takeWhile((q,_,r), nil)) should signal(Condition Error DestructuringMismatch)
      )

      it("should report a destructuring match error if recursive destructuring doesn't add upp",
        fn([[[1,2],[1,2]], [[3,4],[1,2]], [[1,2],[4,5]]] takeWhile((q,(p)), nil)) should signal(Condition Error DestructuringMismatch)
        fn([[[1,2],[1,2]], [[3,4],[1,2]], [[1,2],[4,5]]] takeWhile((q,(p,r,f)), nil)) should signal(Condition Error DestructuringMismatch)
        fn([[[1,2],[1,2]], [[3,4],[1,2]], [[1,2],[4,5]]] takeWhile((q,(p,_,f)), nil)) should signal(Condition Error DestructuringMismatch)
      )
    )

    describe("takeWhile:dict",
      it("should take zero arguments and return everything up until the point where a value is false",
        [1,2,3] takeWhile:dict should == {1=>nil,2=>nil,3=>nil}
        [1,2,nil,false] takeWhile:dict should == {1=>nil,2=>nil}
        [1,2,false,3,4,nil,false] takeWhile:dict should == {1=>nil,2=>nil}
        {foo: 42, bar: 55} takeWhile:dict should == {foo: 42, bar: 55}
        CustomEnumerable takeWhile:dict should == {"3first"=>nil, "1second"=>nil, "2third"=>nil}
      )

      it("should take one argument and apply it as a message chain, return a list with all elements until the block returns false",
        [1,2,3] takeWhile:dict(<3) should == {1=>nil,2=>nil}
        [1,2,3] takeWhile:dict(!=2) should == {1=>nil}
        [:foo => 42, :bar => 55, :quux => 1242] takeWhile:dict(value < 56) should == {foo: 42, bar: 55}
        CustomEnumerable takeWhile:dict(!="2third") should == {"3first"=>nil, "1second"=>nil}
      )

      it("should take two arguments and apply the lexical block created from it, and return a list with all elements until the block returns false",
        [1,2,3] takeWhile:dict(x, x<3) should == {1=>nil,2=>nil}
        [1,2,3] takeWhile:dict(x, x != 2) should == {1=>nil}
        [:foo => 42, :bar => 55, :quux => 1242] takeWhile:dict(x, x value < 56) should == {foo: 42, bar: 55}
        CustomEnumerable takeWhile:dict(x, x != "2third") should == {"3first"=>nil, "1second"=>nil}
      )

      it("should be able to destructure on the argument name",
        result = []
        [[1,2], [2,3], [4,5]] takeWhile:dict((x,y), result << [x+1, y-1])
        result should == [[2,1], [3,2], [5,4]]
      )

      it("should be able to destructure and ignore the rest of something",
        result = []
        [[1,2,9,10], [2,3,11,12], [4,5,13,14]] takeWhile:dict((x,y,_), cell?(:"_") should not be true. result << [x, y])
        result should == [[1,2], [2,3], [4,5]]
      )

      it("should be able to destructure and ignore in the middle of the pattern without binding anything",
        result = []
        [[1,2,9], [2,3,11], [4,5,13]] takeWhile:dict((x,_,y), cell?(:"_") should not be true. result << [x, y]) 
        result should == [[1,9], [2,11], [4,13]]
      )

      it("should be able to destructure and ignore several times in the middle of the pattern without binding anything",
        result = []
        [[1,2,9,10,11], [2,3,11,12,13], [4,5,13,14,15]] takeWhile:dict((x,_,y,_,q), cell?(:"_") should not be true. result << [x, y, q]) 
        result should == [[1,9,11], [2,11,13], [4,13,15]]
      )

      it("should be able to destructure recursively",
        result = []
        [[[:x, :y, :z], [:q, :r, :p]], [[:b, :c, :d], [:i, :j, :k]], [[:i, :j, :k], [:i2, :j3, :k4]]] takeWhile:dict(
          (v, (v2, _, v3)), cell?(:"_") should be false. result << [v, v2, v3]) 
        result should == [[[:x, :y, :z], :q, :p], [[:b, :c, :d], :i, :k], [[:i, :j, :k], :i2, :k4]]
      )

      it("should report a destructuring match error if destructuring doesn't add upp",
        fn([[1,2], [3,4], [4,5]] takeWhile:dict((q,p,r), nil)) should signal(Condition Error DestructuringMismatch)
        fn([[1,2], [3,4], [4,5]] takeWhile:dict((q), nil)) should signal(Condition Error DestructuringMismatch)
        fn([[1,2], [3,4], [4,5]] takeWhile:dict((q,_,r), nil)) should signal(Condition Error DestructuringMismatch)
      )

      it("should report a destructuring match error if recursive destructuring doesn't add upp",
        fn([[[1,2],[1,2]], [[3,4],[1,2]], [[1,2],[4,5]]] takeWhile:dict((q,(p)), nil)) should signal(Condition Error DestructuringMismatch)
        fn([[[1,2],[1,2]], [[3,4],[1,2]], [[1,2],[4,5]]] takeWhile:dict((q,(p,r,f)), nil)) should signal(Condition Error DestructuringMismatch)
        fn([[[1,2],[1,2]], [[3,4],[1,2]], [[1,2],[4,5]]] takeWhile:dict((q,(p,_,f)), nil)) should signal(Condition Error DestructuringMismatch)
      )
    )

    describe("takeWhile:set",
      it("should take zero arguments and return everything up until the point where a value is false",
        [1,2,3] takeWhile:set should == #{1,2,3}
        [1,2,nil,false] takeWhile:set should == #{1,2}
        [1,2,false,3,4,nil,false] takeWhile:set should == #{1,2}
        CustomEnumerable takeWhile:set should == #{"3first", "1second", "2third"}
      )

      it("should take one argument and apply it as a message chain, return a list with all elements until the block returns false",
        [1,2,3] takeWhile:set(<3) should == #{1,2}
        [1,2,3] takeWhile:set(!=2) should == #{1}
        CustomEnumerable takeWhile:set(!="2third") should == #{"3first", "1second"}
      )

      it("should take two arguments and apply the lexical block created from it, and return a list with all elements until the block returns false",
        [1,2,3] takeWhile:set(x, x<3) should == #{1,2}
        [1,2,3] takeWhile:set(x, x != 2) should == #{1}
        CustomEnumerable takeWhile:set(x, x != "2third") should == #{"3first", "1second"}
      )

      it("should be able to destructure on the argument name",
        result = []
        [[1,2], [2,3], [4,5]] takeWhile:set((x,y), result << [x+1, y-1])
        result should == [[2,1], [3,2], [5,4]]
      )

      it("should be able to destructure and ignore the rest of something",
        result = []
        [[1,2,9,10], [2,3,11,12], [4,5,13,14]] takeWhile:set((x,y,_), cell?(:"_") should not be true. result << [x, y])
        result should == [[1,2], [2,3], [4,5]]
      )

      it("should be able to destructure and ignore in the middle of the pattern without binding anything",
        result = []
        [[1,2,9], [2,3,11], [4,5,13]] takeWhile:set((x,_,y), cell?(:"_") should not be true. result << [x, y]) 
        result should == [[1,9], [2,11], [4,13]]
      )

      it("should be able to destructure and ignore several times in the middle of the pattern without binding anything",
        result = []
        [[1,2,9,10,11], [2,3,11,12,13], [4,5,13,14,15]] takeWhile:set((x,_,y,_,q), cell?(:"_") should not be true. result << [x, y, q]) 
        result should == [[1,9,11], [2,11,13], [4,13,15]]
      )

      it("should be able to destructure recursively",
        result = []
        [[[:x, :y, :z], [:q, :r, :p]], [[:b, :c, :d], [:i, :j, :k]], [[:i, :j, :k], [:i2, :j3, :k4]]] takeWhile:set(
          (v, (v2, _, v3)), cell?(:"_") should be false. result << [v, v2, v3]) 
        result should == [[[:x, :y, :z], :q, :p], [[:b, :c, :d], :i, :k], [[:i, :j, :k], :i2, :k4]]
      )

      it("should report a destructuring match error if destructuring doesn't add upp",
        fn([[1,2], [3,4], [4,5]] takeWhile:set((q,p,r), nil)) should signal(Condition Error DestructuringMismatch)
        fn([[1,2], [3,4], [4,5]] takeWhile:set((q), nil)) should signal(Condition Error DestructuringMismatch)
        fn([[1,2], [3,4], [4,5]] takeWhile:set((q,_,r), nil)) should signal(Condition Error DestructuringMismatch)
      )

      it("should report a destructuring match error if recursive destructuring doesn't add upp",
        fn([[[1,2],[1,2]], [[3,4],[1,2]], [[1,2],[4,5]]] takeWhile:set((q,(p)), nil)) should signal(Condition Error DestructuringMismatch)
        fn([[[1,2],[1,2]], [[3,4],[1,2]], [[1,2],[4,5]]] takeWhile:set((q,(p,r,f)), nil)) should signal(Condition Error DestructuringMismatch)
        fn([[[1,2],[1,2]], [[3,4],[1,2]], [[1,2],[4,5]]] takeWhile:set((q,(p,_,f)), nil)) should signal(Condition Error DestructuringMismatch)
      )
    )

    describe("drop",
      it("should return a list without as many elements as requested",
        [1,2,3] drop(0) should == [1,2,3]
        [1,2,3] drop(1) should == [2,3]
        [1,2,3] drop(2) should == [3]
        [1,2,3] drop(3) should == []
        CustomEnumerable drop(2) should == ["2third"]
      )

      it("should not drop more elements than the length of the collection",
        [1,2,3] drop(4) should == []
        [1,2,3] drop(10) should == []
        CustomEnumerable drop(200) should == []
      )
    )

    describe("drop:dict",
      it("should return a dict without as many elements as requested",
        [1,2,3] drop:dict(0) should == {1 => nil, 2 => nil, 3 => nil}
        [1,2,3] drop:dict(1) should == {2 => nil, 3 => nil}
        [1,2,3] drop:dict(2) should == {3 => nil}
        [1,2,3] drop:dict(3) should == {}
        [:foo => 42, :bar => 55, :quux => 2323] drop:dict(0) should == {:foo => 42, :bar => 55, :quux => 2323}
        [:foo => 42, :bar => 55, :quux => 2323] drop:dict(1) should == {:bar => 55, :quux => 2323}
        [:foo => 42, :bar => 55, :quux => 2323] drop:dict(2) should == {:quux => 2323}
        CustomEnumerable drop:dict(2) should == {"2third" => nil}
      )

      it("should not drop more elements than the length of the collection",
        [1,2,3] drop:dict(4) should == {}
        [1,2,3] drop:dict(10) should == {}
        CustomEnumerable drop:dict(200) should == {}
      )
    )

    describe("drop:set",
      it("should return a set without as many elements as requested",
        [1,2,3] drop:set(0) should == #{1,2,3}
        [1,2,3] drop:set(1) should == #{2,3}
        [1,2,3] drop:set(2) should == #{3}
        [1,2,3] drop:set(3) should == #{}
        CustomEnumerable drop:set(2) should == #{"2third"}
      )

      it("should not drop more elements than the length of the collection",
        [1,2,3] drop:set(4) should == #{}
        [1,2,3] drop:set(10) should == #{}
        CustomEnumerable drop:set(200) should == #{}
      )
    )

    describe("dropWhile",
      it("should take zero arguments and return everything after the point where a value is true",
        [1,2,3] dropWhile should == []
        [1,2,nil,false] dropWhile should == [nil,false]
        [1,2,false,3,4,nil,false] dropWhile should == [false,3,4,nil,false]
        CustomEnumerable dropWhile should == []
      )

      it("should take one argument and apply it as a message chain, return a list with all elements after the block returns false",
        [1,2,3] dropWhile(<3) should == [3]
        [1,2,3] dropWhile(!=2) should == [2,3]
        CustomEnumerable dropWhile(!="2third") should == ["2third"]
      )

      it("should take two arguments and apply the lexical block created from it, and return a list with all elements after the block returns false",
        [1,2,3] dropWhile(x, x<3) should == [3]
        [1,2,3] dropWhile(x, x != 2) should == [2,3]
        CustomEnumerable dropWhile(x, x != "2third") should == ["2third"]
      )

      it("should be able to destructure on the argument name",
        result = []
        [[1,2], [2,3], [4,5]] dropWhile((x,y), result << [x+1, y-1])
        result should == [[2,1], [3,2], [5,4]]
      )

      it("should be able to destructure and ignore the rest of something",
        result = []
        [[1,2,9,10], [2,3,11,12], [4,5,13,14]] dropWhile((x,y,_), cell?(:"_") should not be true. result << [x, y])
        result should == [[1,2], [2,3], [4,5]]
      )

      it("should be able to destructure and ignore in the middle of the pattern without binding anything",
        result = []
        [[1,2,9], [2,3,11], [4,5,13]] dropWhile((x,_,y), cell?(:"_") should not be true. result << [x, y]) 
        result should == [[1,9], [2,11], [4,13]]
      )

      it("should be able to destructure and ignore several times in the middle of the pattern without binding anything",
        result = []
        [[1,2,9,10,11], [2,3,11,12,13], [4,5,13,14,15]] dropWhile((x,_,y,_,q), cell?(:"_") should not be true. result << [x, y, q]) 
        result should == [[1,9,11], [2,11,13], [4,13,15]]
      )

      it("should be able to destructure recursively",
        result = []
        [[[:x, :y, :z], [:q, :r, :p]], [[:b, :c, :d], [:i, :j, :k]], [[:i, :j, :k], [:i2, :j3, :k4]]] dropWhile(
          (v, (v2, _, v3)), cell?(:"_") should be false. result << [v, v2, v3]) 
        result should == [[[:x, :y, :z], :q, :p], [[:b, :c, :d], :i, :k], [[:i, :j, :k], :i2, :k4]]
      )

      it("should report a destructuring match error if destructuring doesn't add upp",
        fn([[1,2], [3,4], [4,5]] dropWhile((q,p,r), nil)) should signal(Condition Error DestructuringMismatch)
        fn([[1,2], [3,4], [4,5]] dropWhile((q), nil)) should signal(Condition Error DestructuringMismatch)
        fn([[1,2], [3,4], [4,5]] dropWhile((q,_,r), nil)) should signal(Condition Error DestructuringMismatch)
      )

      it("should report a destructuring match error if recursive destructuring doesn't add upp",
        fn([[[1,2],[1,2]], [[3,4],[1,2]], [[1,2],[4,5]]] dropWhile((q,(p)), nil)) should signal(Condition Error DestructuringMismatch)
        fn([[[1,2],[1,2]], [[3,4],[1,2]], [[1,2],[4,5]]] dropWhile((q,(p,r,f)), nil)) should signal(Condition Error DestructuringMismatch)
        fn([[[1,2],[1,2]], [[3,4],[1,2]], [[1,2],[4,5]]] dropWhile((q,(p,_,f)), nil)) should signal(Condition Error DestructuringMismatch)
      )
    )

    describe("dropWhile:dict",
      it("should take zero arguments and return everything after the point where a value is true",
        [1,2,3] dropWhile:dict should == {}
        [1,2,nil,false] dropWhile:dict should == {nil => nil, false => nil}
        [1,2,false,3,4,nil,false] dropWhile:dict should == {false => nil, 3 => nil ,4 => nil, nil => nil}
        [:foo => 42, :bar => 55, :quux => 1242] takeWhile:dict should == {foo: 42, bar: 55, quux: 1242}
        CustomEnumerable dropWhile:dict should == {}
      )

      it("should take one argument and apply it as a message chain, return a dict with all elements after the block returns false",
        [1,2,3] dropWhile:dict(<3) should == {3 => nil}
        [1,2,3] dropWhile:dict(!=2) should == {2 => nil, 3 => nil}
        [:foo => 42, :bar => 55, :quux => 1242] dropWhile:dict(value < 56) should == {quux: 1242}
        CustomEnumerable dropWhile:dict(!="2third") should == {"2third" => nil}
      )

      it("should take two arguments and apply the lexical block created from it, and return a dict with all elements after the block returns false",
        [1,2,3] dropWhile:dict(x, x<3) should == {3 => nil}
        [1,2,3] dropWhile:dict(x, x != 2) should == {2 => nil, 3 => nil}
        [:foo => 42, :bar => 55, :quux => 1242] dropWhile:dict(x, x value < 56) should == {quux: 1242}
        CustomEnumerable dropWhile:dict(x, x != "2third") should == {"2third" => nil}
      )

      it("should be able to destructure on the argument name",
        result = []
        [[1,2], [2,3], [4,5]] dropWhile:dict((x,y), result << [x+1, y-1])
        result should == [[2,1], [3,2], [5,4]]
      )

      it("should be able to destructure and ignore the rest of something",
        result = []
        [[1,2,9,10], [2,3,11,12], [4,5,13,14]] dropWhile:dict((x,y,_), cell?(:"_") should not be true. result << [x, y])
        result should == [[1,2], [2,3], [4,5]]
      )

      it("should be able to destructure and ignore in the middle of the pattern without binding anything",
        result = []
        [[1,2,9], [2,3,11], [4,5,13]] dropWhile:dict((x,_,y), cell?(:"_") should not be true. result << [x, y]) 
        result should == [[1,9], [2,11], [4,13]]
      )

      it("should be able to destructure and ignore several times in the middle of the pattern without binding anything",
        result = []
        [[1,2,9,10,11], [2,3,11,12,13], [4,5,13,14,15]] dropWhile:dict((x,_,y,_,q), cell?(:"_") should not be true. result << [x, y, q]) 
        result should == [[1,9,11], [2,11,13], [4,13,15]]
      )

      it("should be able to destructure recursively",
        result = []
        [[[:x, :y, :z], [:q, :r, :p]], [[:b, :c, :d], [:i, :j, :k]], [[:i, :j, :k], [:i2, :j3, :k4]]] dropWhile:dict(
          (v, (v2, _, v3)), cell?(:"_") should be false. result << [v, v2, v3]) 
        result should == [[[:x, :y, :z], :q, :p], [[:b, :c, :d], :i, :k], [[:i, :j, :k], :i2, :k4]]
      )

      it("should report a destructuring match error if destructuring doesn't add upp",
        fn([[1,2], [3,4], [4,5]] dropWhile:dict((q,p,r), nil)) should signal(Condition Error DestructuringMismatch)
        fn([[1,2], [3,4], [4,5]] dropWhile:dict((q), nil)) should signal(Condition Error DestructuringMismatch)
        fn([[1,2], [3,4], [4,5]] dropWhile:dict((q,_,r), nil)) should signal(Condition Error DestructuringMismatch)
      )

      it("should report a destructuring match error if recursive destructuring doesn't add upp",
        fn([[[1,2],[1,2]], [[3,4],[1,2]], [[1,2],[4,5]]] dropWhile:dict((q,(p)), nil)) should signal(Condition Error DestructuringMismatch)
        fn([[[1,2],[1,2]], [[3,4],[1,2]], [[1,2],[4,5]]] dropWhile:dict((q,(p,r,f)), nil)) should signal(Condition Error DestructuringMismatch)
        fn([[[1,2],[1,2]], [[3,4],[1,2]], [[1,2],[4,5]]] dropWhile:dict((q,(p,_,f)), nil)) should signal(Condition Error DestructuringMismatch)
      )
    )

    describe("dropWhile:set",
      it("should take zero arguments and return everything after the point where a value is true",
        [1,2,3] dropWhile:set should == #{}
        [1,2,nil,false] dropWhile:set should == #{nil,false}
        [1,2,false,3,4,nil,false] dropWhile:set should == #{false,3,4,nil}
        CustomEnumerable dropWhile:set should == #{}
      )

      it("should take one argument and apply it as a message chain, return a set with all elements after the block returns false",
        [1,2,3] dropWhile:set(<3) should == #{3}
        [1,2,3] dropWhile:set(!=2) should == #{2,3}
        CustomEnumerable dropWhile:set(!="2third") should == #{"2third"}
      )

      it("should take two arguments and apply the lexical block created from it, and return a set with all elements after the block returns false",
        [1,2,3] dropWhile:set(x, x<3) should == #{3}
        [1,2,3] dropWhile:set(x, x != 2) should == #{2,3}
        CustomEnumerable dropWhile:set(x, x != "2third") should == #{"2third"}
      )

      it("should be able to destructure on the argument name",
        result = []
        [[1,2], [2,3], [4,5]] dropWhile:set((x,y), result << [x+1, y-1])
        result should == [[2,1], [3,2], [5,4]]
      )

      it("should be able to destructure and ignore the rest of something",
        result = []
        [[1,2,9,10], [2,3,11,12], [4,5,13,14]] dropWhile:set((x,y,_), cell?(:"_") should not be true. result << [x, y])
        result should == [[1,2], [2,3], [4,5]]
      )

      it("should be able to destructure and ignore in the middle of the pattern without binding anything",
        result = []
        [[1,2,9], [2,3,11], [4,5,13]] dropWhile:set((x,_,y), cell?(:"_") should not be true. result << [x, y]) 
        result should == [[1,9], [2,11], [4,13]]
      )

      it("should be able to destructure and ignore several times in the middle of the pattern without binding anything",
        result = []
        [[1,2,9,10,11], [2,3,11,12,13], [4,5,13,14,15]] dropWhile:set((x,_,y,_,q), cell?(:"_") should not be true. result << [x, y, q]) 
        result should == [[1,9,11], [2,11,13], [4,13,15]]
      )

      it("should be able to destructure recursively",
        result = []
        [[[:x, :y, :z], [:q, :r, :p]], [[:b, :c, :d], [:i, :j, :k]], [[:i, :j, :k], [:i2, :j3, :k4]]] dropWhile:set(
          (v, (v2, _, v3)), cell?(:"_") should be false. result << [v, v2, v3]) 
        result should == [[[:x, :y, :z], :q, :p], [[:b, :c, :d], :i, :k], [[:i, :j, :k], :i2, :k4]]
      )

      it("should report a destructuring match error if destructuring doesn't add upp",
        fn([[1,2], [3,4], [4,5]] dropWhile:set((q,p,r), nil)) should signal(Condition Error DestructuringMismatch)
        fn([[1,2], [3,4], [4,5]] dropWhile:set((q), nil)) should signal(Condition Error DestructuringMismatch)
        fn([[1,2], [3,4], [4,5]] dropWhile:set((q,_,r), nil)) should signal(Condition Error DestructuringMismatch)
      )

      it("should report a destructuring match error if recursive destructuring doesn't add upp",
        fn([[[1,2],[1,2]], [[3,4],[1,2]], [[1,2],[4,5]]] dropWhile:set((q,(p)), nil)) should signal(Condition Error DestructuringMismatch)
        fn([[[1,2],[1,2]], [[3,4],[1,2]], [[1,2],[4,5]]] dropWhile:set((q,(p,r,f)), nil)) should signal(Condition Error DestructuringMismatch)
        fn([[[1,2],[1,2]], [[3,4],[1,2]], [[1,2],[4,5]]] dropWhile:set((q,(p,_,f)), nil)) should signal(Condition Error DestructuringMismatch)
      )
    )

    describe("cycle",
      it("should not do anything for an empty collection",
        x = 1
        [] cycle(_, x = 2) should be nil
        x should == 1
      )

      it("should repeat until stopped",
        Ground res = []
        m1 = method(
          [1,2,3] cycle(x,
            if(Ground res length == 10, return)
            Ground res << x))
        m1
        Ground res should == [1,2,3,1,2,3,1,2,3,1]
      )

      it("should only call each once",
        CustomEnumerable3 = Origin mimic
        CustomEnumerable3 mimic!(Mixins Enumerable)
        CustomEnumerable3 eachCalled = 0
        CustomEnumerable3 each = macro(
          eachCalled++
          len = call arguments length

          if(len == 1,
            first = call arguments first
            first evaluateOn(call ground, "3first")
            first evaluateOn(call ground, "1second")
            first evaluateOn(call ground, "2third"),

            lexical = LexicalBlock createFrom(call arguments, call ground)
            lexical call("3first")
            lexical call("1second")
            lexical call("2third")))

        m = method(
          iter = 0
          CustomEnumerable3 cycle(_, if(iter == 10, return). iter++))
        m
        CustomEnumerable3 eachCalled should == 1
      )

      it("should take one argument and apply it",
        Ground res = []
        m1 = method(
          [1,2,3] cycle(+1. if(Ground res length == 10, return). Ground res << "foo"))
        m1
      )

      it("should take two arguments and turn it into a lexical block to apply",
        Ground res = []
        m1 = method(
          [1,2,3] cycle(x, if(Ground res length == 10, return). Ground res << x))
        m1
        Ground res should == [1,2,3,1,2,3,1,2,3,1]
      )

      it("should be able to destructure on the argument name",
        Ground result = []
        method([[1,2], [2,3], [4,5]] cycle((x,y), Ground result << [x+1, y-1]. if(Ground result length == 4, return))) call
        result should == [[2,1], [3,2], [5,4], [2,1]]
      )

      it("should be able to destructure and ignore the rest of something",
        Ground result = []
        method([[1,2,9,10], [2,3,11,12], [4,5,13,14]] cycle((x,y,_), cell?(:"_") should not be true. Ground result << [x, y]. if(Ground result length == 4, return))) call
        result should == [[1,2], [2,3], [4,5],[1,2]]
      )

      it("should be able to destructure and ignore in the middle of the pattern without binding anything",
        Ground result = []
        method([[1,2,9], [2,3,11], [4,5,13]] cycle((x,_,y), cell?(:"_") should not be true. Ground result << [x, y]. if(Ground result length == 4, return))) call
        result should == [[1,9], [2,11], [4,13],[1,9]]
      )

      it("should be able to destructure and ignore several times in the middle of the pattern without binding anything",
        Ground result = []
        method([[1,2,9,10,11], [2,3,11,12,13], [4,5,13,14,15]] cycle((x,_,y,_,q), cell?(:"_") should not be true. Ground result << [x, y, q]. if(Ground result length == 4, return))) call
        result should == [[1,9,11], [2,11,13], [4,13,15],[1,9,11]]
      )

      it("should be able to destructure recursively",
        Ground result = []
        method([[[:x, :y, :z], [:q, :r, :p]], [[:b, :c, :d], [:i, :j, :k]], [[:i, :j, :k], [:i2, :j3, :k4]]] cycle(
            (v, (v2, _, v3)), cell?(:"_") should be false. Ground result << [v, v2, v3]. if(Ground result length == 4, return))) call
        result should == [[[:x, :y, :z], :q, :p], [[:b, :c, :d], :i, :k], [[:i, :j, :k], :i2, :k4], [[:x, :y, :z], :q, :p]]
      )

      it("should report a destructuring match error if destructuring doesn't add upp",
        fn([[1,2], [3,4], [4,5]] cycle((q,p,r), nil)) should signal(Condition Error DestructuringMismatch)
        fn([[1,2], [3,4], [4,5]] cycle((q), nil)) should signal(Condition Error DestructuringMismatch)
        fn([[1,2], [3,4], [4,5]] cycle((q,_,r), nil)) should signal(Condition Error DestructuringMismatch)
      )

      it("should report a destructuring match error if recursive destructuring doesn't add upp",
        fn([[[1,2],[1,2]], [[3,4],[1,2]], [[1,2],[4,5]]] cycle((q,(p)), nil)) should signal(Condition Error DestructuringMismatch)
        fn([[[1,2],[1,2]], [[3,4],[1,2]], [[1,2],[4,5]]] cycle((q,(p,r,f)), nil)) should signal(Condition Error DestructuringMismatch)
        fn([[[1,2],[1,2]], [[3,4],[1,2]], [[1,2],[4,5]]] cycle((q,(p,_,f)), nil)) should signal(Condition Error DestructuringMismatch)
      )
    )

    describe("sortBy",
      it("should take one argument and apply that for sorting",
        {a: 3, b: 2, c: 1} sortBy(value) should == [:c => 1, :b => 2, :a => 3]
      )

      it("should take two arguments and turn that into a lexical block and use that for sorting",
        {a: 3, b: 2, c: 1} sortBy(x, x value) should == [:c => 1, :b => 2, :a => 3]
      )

      it("should be able to destructure on the argument name",
        result = []
        [[1,2], [2,3], [4,5]] sortBy((x,y), result << [x+1, y-1])
        result should == [[2,1], [3,2], [5,4]]
      )

      it("should be able to destructure and ignore the rest of something",
        result = []
        [[1,2,9,10], [2,3,11,12], [4,5,13,14]] sortBy((x,y,_), cell?(:"_") should not be true. result << [x, y])
        result should == [[1,2], [2,3], [4,5]]
      )

      it("should be able to destructure and ignore in the middle of the pattern without binding anything",
        result = []
        [[1,2,9], [2,3,11], [4,5,13]] sortBy((x,_,y), cell?(:"_") should not be true. result << [x, y]) 
        result should == [[1,9], [2,11], [4,13]]
      )

      it("should be able to destructure and ignore several times in the middle of the pattern without binding anything",
        result = []
        [[1,2,9,10,11], [2,3,11,12,13], [4,5,13,14,15]] sortBy((x,_,y,_,q), cell?(:"_") should not be true. result << [x, y, q]) 
        result should == [[1,9,11], [2,11,13], [4,13,15]]
      )

      it("should be able to destructure recursively",
        result = []
        [[[:x, :y, :z], [:q, :r, :p]], [[:b, :c, :d], [:i, :j, :k]], [[:i, :j, :k], [:i2, :j3, :k4]]] sortBy(
          (v, (v2, _, v3)), cell?(:"_") should be false. result << [v, v2, v3]) 
        result should == [[[:x, :y, :z], :q, :p], [[:b, :c, :d], :i, :k], [[:i, :j, :k], :i2, :k4]]
      )

      it("should report a destructuring match error if destructuring doesn't add upp",
        fn([[1,2], [3,4], [4,5]] sortBy((q,p,r), nil)) should signal(Condition Error DestructuringMismatch)
        fn([[1,2], [3,4], [4,5]] sortBy((q), nil)) should signal(Condition Error DestructuringMismatch)
        fn([[1,2], [3,4], [4,5]] sortBy((q,_,r), nil)) should signal(Condition Error DestructuringMismatch)
      )

      it("should report a destructuring match error if recursive destructuring doesn't add upp",
        fn([[[1,2],[1,2]], [[3,4],[1,2]], [[1,2],[4,5]]] sortBy((q,(p)), nil)) should signal(Condition Error DestructuringMismatch)
        fn([[[1,2],[1,2]], [[3,4],[1,2]], [[1,2],[4,5]]] sortBy((q,(p,r,f)), nil)) should signal(Condition Error DestructuringMismatch)
        fn([[[1,2],[1,2]], [[3,4],[1,2]], [[1,2],[4,5]]] sortBy((q,(p,_,f)), nil)) should signal(Condition Error DestructuringMismatch)
      )
    )

    describe("zip",
      it("should take zero arguments and just zip the elements",
        [1,2,3] zip should == [[1], [2], [3]]
      )

      it("should take one argument as a list and zip the elements together",
        [1,2,3] zip([5,6,7]) should == [[1, 5], [2, 6], [3, 7]]
        [1,2,3] zip([5,6,7,8]) should == [[1, 5], [2, 6], [3, 7]]
      )

      it("should take one argument as a seq and zip the elements together",
        [1,2,3] zip([5,6,7] seq) should == [[1, 5], [2, 6], [3, 7]]
        [1,2,3] zip([5,6,7,8] seq) should == [[1, 5], [2, 6], [3, 7]]
      )

      it("should supply nils if the second list isn't long enough",
        [1,2,3] zip([5,6]) should == [[1, 5], [2, 6], [3, nil]]
      )

      it("should zip together several lists",
        [1,2,3] zip([5,6,7],[10,11,12],[15,16,17]) should == [[1,5,10,15], [2,6,11,16], [3,7,12,17]]
      )

      it("should take a fn as last argument and call that instead of returning a list",
        x = []

        [1,2,3] zip([5,6,7],
          fn(arg, x << arg)) should be nil

        x should == [[1,5],[2,6],[3,7]]
      )
    )

    describe("zip:set",
      it("should take zero arguments and just zip the elements",
        [1,2,3] zip:set should == [#{1}, #{2}, #{3}]
      )

      it("should take one argument as a list and zip the elements together",
        [1,2,3] zip:set([5,6,7]) should == [#{1, 5}, #{2, 6}, #{3, 7}]
        [1,2,3] zip:set([5,6,7,8]) should == [#{1, 5}, #{2, 6}, #{3, 7}]
      )

      it("should take one argument as a seq and zip the elements together",
        [1,2,3] zip:set([5,6,7] seq) should == [#{1, 5}, #{2, 6}, #{3, 7}]
        [1,2,3] zip:set([5,6,7,8] seq) should == [#{1, 5}, #{2, 6}, #{3, 7}]
      )

      it("should supply nils if the second list isn't long enough",
        [1,2,3] zip:set([5,6]) should == [#{1, 5}, #{2, 6}, #{3, nil}]
      )

      it("should zip together several lists",
        [1,2,3] zip:set([5,6,7],[10,11,12],[15,16,17]) should == [#{1,5,10,15}, #{2,6,11,16}, #{3,7,12,17}]
      )
    )

    describe("grep",
      it("should take one argument and return everything that matches with ===",
        [1,2,3,4,5,6,7,8,9] grep(2..5) should == [2,3,4,5]

        customObj = Origin mimic
        customObj === = method(other, (other < 3) || (other > 5))
        [1,2,3,4,5,6,7,8,9] grep(customObj) should == [1,2,6,7,8,9]
      )

      it("should take two arguments where the second argument is a message chain and return the result of calling that chain on everything that matches with ===",
        [1,2,3,4,5,6,7,8,9] grep(2..5, + 1) should == [3,4,5,6]

        customObj = Origin mimic
        customObj === = method(other, (other < 3) || (other > 5))
        [1,2,3,4,5,6,7,8,9] grep(customObj, + 1) should == [2,3,7,8,9,10]
      )

      it("should take three arguments where the second and third arguments gets turned into a lexical block to apply to all that matches with ===",
        [1,2,3,4,5,6,7,8,9] grep(2..5, x, (x + 1) asText) should == ["3","4","5","6"]

        customObj = Origin mimic
        customObj === = method(other, (other < 3) || (other > 5))
        [1,2,3,4,5,6,7,8,9] grep(customObj, x, (x+1) asText) should == ["2","3","7","8","9","10"]
      )

      it("should be able to destructure on the argument name",
        result = []
        [[1,2], [2,3], [4,5]] grep(Origin, (x,y), result << [x+1, y-1]. nil)
        result should == [[2,1], [3,2], [5,4]]
      )

      it("should be able to destructure and ignore the rest of something",
        result = []
        [[1,2,9,10], [2,3,11,12], [4,5,13,14]] grep(Origin, (x,y,_), cell?(:"_") should not be true. result << [x, y]. nil)
        result should == [[1,2], [2,3], [4,5]]
      )

      it("should be able to destructure and ignore in the middle of the pattern without binding anything",
        result = []
        [[1,2,9], [2,3,11], [4,5,13]] grep(Origin, (x,_,y), cell?(:"_") should not be true. result << [x, y]. nil) 
        result should == [[1,9], [2,11], [4,13]]
      )

      it("should be able to destructure and ignore several times in the middle of the pattern without binding anything",
        result = []
        [[1,2,9,10,11], [2,3,11,12,13], [4,5,13,14,15]] grep(Origin, (x,_,y,_,q), cell?(:"_") should not be true. result << [x, y, q]. nil) 
        result should == [[1,9,11], [2,11,13], [4,13,15]]
      )

      it("should be able to destructure recursively",
        result = []
        [[[:x, :y, :z], [:q, :r, :p]], [[:b, :c, :d], [:i, :j, :k]], [[:i, :j, :k], [:i2, :j3, :k4]]] grep(Origin, 
          (v, (v2, _, v3)), cell?(:"_") should be false. result << [v, v2, v3]. nil) 
        result should == [[[:x, :y, :z], :q, :p], [[:b, :c, :d], :i, :k], [[:i, :j, :k], :i2, :k4]]
      )

      it("should report a destructuring match error if destructuring doesn't add upp",
        fn([[1,2], [3,4], [4,5]] grep(Origin, (q,p,r), nil)) should signal(Condition Error DestructuringMismatch)
        fn([[1,2], [3,4], [4,5]] grep(Origin, (q), nil)) should signal(Condition Error DestructuringMismatch)
        fn([[1,2], [3,4], [4,5]] grep(Origin, (q,_,r), nil)) should signal(Condition Error DestructuringMismatch)
      )

      it("should report a destructuring match error if recursive destructuring doesn't add upp",
        fn([[[1,2],[1,2]], [[3,4],[1,2]], [[1,2],[4,5]]] grep(Origin, (q,(p)), nil)) should signal(Condition Error DestructuringMismatch)
        fn([[[1,2],[1,2]], [[3,4],[1,2]], [[1,2],[4,5]]] grep(Origin, (q,(p,r,f)), nil)) should signal(Condition Error DestructuringMismatch)
        fn([[[1,2],[1,2]], [[3,4],[1,2]], [[1,2],[4,5]]] grep(Origin, (q,(p,_,f)), nil)) should signal(Condition Error DestructuringMismatch)
      )
    )

    describe("grep:set",
      it("should take one argument and return everything that matches with ===",
        [1,2,3,4,5,6,7,8,9] grep:set(2..5) should == #{2,3,4,5}

        customObj = Origin mimic
        customObj === = method(other, (other < 3) || (other > 5))
        [1,2,3,4,5,6,7,8,9] grep:set(customObj) should == #{1,2,6,7,8,9}
      )

      it("should take two arguments where the second argument is a message chain and return the result of calling that chain on everything that matches with ===",
        [1,2,3,4,5,6,7,8,9] grep:set(2..5, + 1) should == #{3,4,5,6}

        customObj = Origin mimic
        customObj === = method(other, (other < 3) || (other > 5))
        [1,2,3,4,5,6,7,8,9] grep:set(customObj, + 1) should == #{2,3,7,8,9,10}
      )

      it("should take three arguments where the second and third arguments gets turned into a lexical block to apply to all that matches with ===",
        [1,2,3,4,5,6,7,8,9] grep:set(2..5, x, (x + 1) asText) should == #{"3","4","5","6"}

        customObj = Origin mimic
        customObj === = method(other, (other < 3) || (other > 5))
        [1,2,3,4,5,6,7,8,9] grep:set(customObj, x, (x+1) asText) should == #{"2","3","7","8","9","10"}
      )

      it("should be able to destructure on the argument name",
        result = []
        [[1,2], [2,3], [4,5]] grep:set(Origin, (x,y), result << [x+1, y-1]. nil)
        result should == [[2,1], [3,2], [5,4]]
      )

      it("should be able to destructure and ignore the rest of something",
        result = []
        [[1,2,9,10], [2,3,11,12], [4,5,13,14]] grep:set(Origin, (x,y,_), cell?(:"_") should not be true. result << [x, y]. nil)
        result should == [[1,2], [2,3], [4,5]]
      )

      it("should be able to destructure and ignore in the middle of the pattern without binding anything",
        result = []
        [[1,2,9], [2,3,11], [4,5,13]] grep:set(Origin, (x,_,y), cell?(:"_") should not be true. result << [x, y]. nil) 
        result should == [[1,9], [2,11], [4,13]]
      )

      it("should be able to destructure and ignore several times in the middle of the pattern without binding anything",
        result = []
        [[1,2,9,10,11], [2,3,11,12,13], [4,5,13,14,15]] grep:set(Origin, (x,_,y,_,q), cell?(:"_") should not be true. result << [x, y, q]. nil) 
        result should == [[1,9,11], [2,11,13], [4,13,15]]
      )

      it("should be able to destructure recursively",
        result = []
        [[[:x, :y, :z], [:q, :r, :p]], [[:b, :c, :d], [:i, :j, :k]], [[:i, :j, :k], [:i2, :j3, :k4]]] grep:set(Origin, 
          (v, (v2, _, v3)), cell?(:"_") should be false. result << [v, v2, v3]. nil) 
        result should == [[[:x, :y, :z], :q, :p], [[:b, :c, :d], :i, :k], [[:i, :j, :k], :i2, :k4]]
      )

      it("should report a destructuring match error if destructuring doesn't add upp",
        fn([[1,2], [3,4], [4,5]] grep:set(Origin, (q,p,r), nil)) should signal(Condition Error DestructuringMismatch)
        fn([[1,2], [3,4], [4,5]] grep:set(Origin, (q), nil)) should signal(Condition Error DestructuringMismatch)
        fn([[1,2], [3,4], [4,5]] grep:set(Origin, (q,_,r), nil)) should signal(Condition Error DestructuringMismatch)
      )

      it("should report a destructuring match error if recursive destructuring doesn't add upp",
        fn([[[1,2],[1,2]], [[3,4],[1,2]], [[1,2],[4,5]]] grep:set(Origin, (q,(p)), nil)) should signal(Condition Error DestructuringMismatch)
        fn([[[1,2],[1,2]], [[3,4],[1,2]], [[1,2],[4,5]]] grep:set(Origin, (q,(p,r,f)), nil)) should signal(Condition Error DestructuringMismatch)
        fn([[[1,2],[1,2]], [[3,4],[1,2]], [[1,2],[4,5]]] grep:set(Origin, (q,(p,_,f)), nil)) should signal(Condition Error DestructuringMismatch)
      )
    )

    describe("max",
      it("should return the maximum using the <=> operator if no arguments are given",
        [1,2,3,4] max should == 4
        set(5,6,7,153,1) max should == 153
        ["a","b","c"] max should == "c"
      )

      it("should accept a message chain, and use that to create the comparison criteria",
        [1,2,3,4] max(*(-1)) should == 1
        set(5,6,7,153,1) max(*(-1)) should == 1
        ["abc","bfooo","cc"] max(length) should == "bfooo"
      )

      it("should accept a variable name and code, and use that to create the comparison criteria",
        [1,2,3,4] max(x, 10-x) should == 1
        set(5,6,7,153,1) max(x, if(x > 100, -x, x)) should == 7
        ["abc","bfooo","cc"] max(x, x[1]) should == "bfooo"
      )

      it("should be able to destructure on the argument name",
        result = []
        [[1,2], [2,3], [4,5]] max((x,y), result << [x+1, y-1]. 1)
        result should == [[2,1], [3,2], [5,4]]
      )

      it("should be able to destructure and ignore the rest of something",
        result = []
        [[1,2,9,10], [2,3,11,12], [4,5,13,14]] max((x,y,_), cell?(:"_") should not be true. result << [x, y]. 1)
        result should == [[1,2], [2,3], [4,5]]
      )

      it("should be able to destructure and ignore in the middle of the pattern without binding anything",
        result = []
        [[1,2,9], [2,3,11], [4,5,13]] max((x,_,y), cell?(:"_") should not be true. result << [x, y]. 1) 
        result should == [[1,9], [2,11], [4,13]]
      )

      it("should be able to destructure and ignore several times in the middle of the pattern without binding anything",
        result = []
        [[1,2,9,10,11], [2,3,11,12,13], [4,5,13,14,15]] max((x,_,y,_,q), cell?(:"_") should not be true. result << [x, y, q]. 1) 
        result should == [[1,9,11], [2,11,13], [4,13,15]]
      )

      it("should be able to destructure recursively",
        result = []
        [[[:x, :y, :z], [:q, :r, :p]], [[:b, :c, :d], [:i, :j, :k]], [[:i, :j, :k], [:i2, :j3, :k4]]] max(
          (v, (v2, _, v3)), cell?(:"_") should be false. result << [v, v2, v3]. 1) 
        result should == [[[:x, :y, :z], :q, :p], [[:b, :c, :d], :i, :k], [[:i, :j, :k], :i2, :k4]]
      )

      it("should report a destructuring match error if destructuring doesn't add upp",
        fn([[1,2], [3,4], [4,5]] max((q,p,r), nil)) should signal(Condition Error DestructuringMismatch)
        fn([[1,2], [3,4], [4,5]] max((q), nil)) should signal(Condition Error DestructuringMismatch)
        fn([[1,2], [3,4], [4,5]] max((q,_,r), nil)) should signal(Condition Error DestructuringMismatch)
      )

      it("should report a destructuring match error if recursive destructuring doesn't add upp",
        fn([[[1,2],[1,2]], [[3,4],[1,2]], [[1,2],[4,5]]] max((q,(p)), nil)) should signal(Condition Error DestructuringMismatch)
        fn([[[1,2],[1,2]], [[3,4],[1,2]], [[1,2],[4,5]]] max((q,(p,r,f)), nil)) should signal(Condition Error DestructuringMismatch)
        fn([[[1,2],[1,2]], [[3,4],[1,2]], [[1,2],[4,5]]] max((q,(p,_,f)), nil)) should signal(Condition Error DestructuringMismatch)
      )
    )

    describe("min",
      it("should return the minimum using the <=> operator if no arguments are given",
        [1,2,3,4] min should == 1
        set(5,6,7,153,1) min should == 1
        ["a","b","c"] min should == "a"
      )

      it("should accept a message chain, and use that to create the comparison criteria",
        [1,2,3,4] min(*(-1)) should == 4
        set(5,6,7,153,1) min(*(-1)) should == 153
        ["abc","bfooo","cc"] min(length) should == "cc"
      )

      it("should accept a variable name and code, and use that to create the comparison criteria",
        [1,2,3,4] min(x, 10-x) should == 4
        set(5,6,7,153,1) min(x, if(x > 100, -x, x)) should == 153
        ["abc","bfooo","cc"] min(x, x[1]) should == "abc"
      )

      it("should be able to destructure on the argument name",
        result = []
        [[1,2], [2,3], [4,5]] min((x,y), result << [x+1, y-1]. 1)
        result should == [[2,1], [3,2], [5,4]]
      )

      it("should be able to destructure and ignore the rest of something",
        result = []
        [[1,2,9,10], [2,3,11,12], [4,5,13,14]] min((x,y,_), cell?(:"_") should not be true. result << [x, y]. 1)
        result should == [[1,2], [2,3], [4,5]]
      )

      it("should be able to destructure and ignore in the middle of the pattern without binding anything",
        result = []
        [[1,2,9], [2,3,11], [4,5,13]] min((x,_,y), cell?(:"_") should not be true. result << [x, y]. 1) 
        result should == [[1,9], [2,11], [4,13]]
      )

      it("should be able to destructure and ignore several times in the middle of the pattern without binding anything",
        result = []
        [[1,2,9,10,11], [2,3,11,12,13], [4,5,13,14,15]] min((x,_,y,_,q), cell?(:"_") should not be true. result << [x, y, q]. 1) 
        result should == [[1,9,11], [2,11,13], [4,13,15]]
      )

      it("should be able to destructure recursively",
        result = []
        [[[:x, :y, :z], [:q, :r, :p]], [[:b, :c, :d], [:i, :j, :k]], [[:i, :j, :k], [:i2, :j3, :k4]]] min(
          (v, (v2, _, v3)), cell?(:"_") should be false. result << [v, v2, v3]. 1) 
        result should == [[[:x, :y, :z], :q, :p], [[:b, :c, :d], :i, :k], [[:i, :j, :k], :i2, :k4]]
      )

      it("should report a destructuring match error if destructuring doesn't add upp",
        fn([[1,2], [3,4], [4,5]] min((q,p,r), nil)) should signal(Condition Error DestructuringMismatch)
        fn([[1,2], [3,4], [4,5]] min((q), nil)) should signal(Condition Error DestructuringMismatch)
        fn([[1,2], [3,4], [4,5]] min((q,_,r), nil)) should signal(Condition Error DestructuringMismatch)
      )

      it("should report a destructuring match error if recursive destructuring doesn't add upp",
        fn([[[1,2],[1,2]], [[3,4],[1,2]], [[1,2],[4,5]]] min((q,(p)), nil)) should signal(Condition Error DestructuringMismatch)
        fn([[[1,2],[1,2]], [[3,4],[1,2]], [[1,2],[4,5]]] min((q,(p,r,f)), nil)) should signal(Condition Error DestructuringMismatch)
        fn([[[1,2],[1,2]], [[3,4],[1,2]], [[1,2],[4,5]]] min((q,(p,_,f)), nil)) should signal(Condition Error DestructuringMismatch)
      )
    )

    describe("join",
      describe("with no arguments",
        it("should convert an empty list to an empty string",
           [] join should == ""
          #{} join should == ""
        )

        it("should convert a list with one element to it's equivalent as text",
          ["tempestuous turmoil"] join should == "tempestuous turmoil"
           [1] join should == "1"
          #{1} join should == "1"
        )

        it("should convert a list with multiple elements to a flat string of all its elements as text",
          ["a","man","walked","into","a","bar..."]  join should == "amanwalkedintoabar..."
           [1,2,3,4,5] join should == "12345"
        )
      )

      describe("with one argument",
        it("should convert an empty list to an empty string",
           [] join("glue") should == ""
          #{} join("glue") should == ""
        )

        it("should convert a list with one element to it's equivalent as text",
          ["tempestuous turmoil"]  join("glue") should == "tempestuous turmoil"
          #{"tempestuous turmoil"} join("glue") should == "tempestuous turmoil"
           [1] join("glue") should == "1"
          #{1} join("glue") should == "1"
        )

        it("should convert a list with multiple elements to a flat string of all its elements as text",
          ["a","man","walked","into","a","bar..."] join(" ") should == "a man walked into a bar..."
          [1,2,3,4,5] join(", ") should == "1, 2, 3, 4, 5"
          #{1,2,3} join(" ") split(" ") sort should == ["1", "2", "3"] ;;account for sets being unordered
        )
      )
    )

    describe("sum",
      it("should return nil for an empty enumerable",
        [] sum should be nil
        (1...1) sum should be nil
        #{} sum should be nil
      )

      it("should return the object in question for a one-object enumerable",
        [42] sum should == 42
        (1..1) sum should == 1
        #{5} sum should == 5
        ["str"] sum should == "str"
      )

      it("should use the + operator to sum things",
        [32, 5, 111, 464] sum should == (32+5+111+464)
        ["foo", "bar", "bax"] sum should == "foobarbax"
      )
    )

    describe("group",
      it("should return an empty dict for an empty enumerable",
        [] group should == {}
        (1...1) group should == {}
        #{} group should == {}
      )

      it("should return a dict with all distinct values as keys",
        [:abc, :cde :foo, :cde] group keys should == #{:abc, :cde, :foo}
      )

      it("should group all the same values into a list",
        [1,2,3,2,3,3,5,5,5,5,5] group should == {1 => [1], 2 => [2, 2], 3 => [3, 3, 3], 5 => [5, 5, 5, 5, 5]}
        {foo: 42, bar: 55} group should == {(:foo => 42) => [:foo => 42], (:bar => 55) => [:bar => 55]}
      )
    )

    describe("groupBy",
      it("should return an empty dict for an empty enumerable",
        [] groupBy should == {}
        (1...1) groupBy should == {}
        #{} groupBy should == {}
      )

      it("should return a dict with all distinct values as keys",
        [:abc, :cde :foo, :cde] groupBy keys should == #{:abc, :cde, :foo}
      )

      it("should group all the same values into a list",
        [1,2,3,2,3,3,5,5,5,5,5] groupBy should == {1 => [1], 2 => [2, 2], 3 => [3, 3, 3], 5 => [5, 5, 5, 5, 5]}
        {foo: 42, bar: 55} groupBy should == {(:foo => 42) => [:foo => 42], (:bar => 55) => [:bar => 55]}
      )

      it("should take one argument that is a message chain. the result of this will be the grouping factor and used as key",
        [1,2,3,2,3,3,5,5,5,5,5] groupBy(-1) should == {0 => [1], 1 => [2, 2], 2 => [3, 3, 3], 4 => [5, 5, 5, 5, 5]}
        [1,2,3,2,3,3,5,5,5,5,5] groupBy(asText) should == {"1" => [1], "2" => [2, 2], "3" => [3, 3, 3], "5" => [5, 5, 5, 5, 5]}
      )

      it("should take two arguments that is an argument name and code. the result of this will be the grouping factor and used as key",
        [1,2,3,2,3,3,5,5,5,5,5] groupBy(x, x-1) should == {0 => [1], 1 => [2, 2], 2 => [3, 3, 3], 4 => [5, 5, 5, 5, 5]}
        [1,2,3,2,3,3,5,5,5,5,5] groupBy(x, x asText) should == {"1" => [1], "2" => [2, 2], "3" => [3, 3, 3], "5" => [5, 5, 5, 5, 5]}
        [1,2,3,2,3,3,5,5,5,5,5] groupBy(x, x%2 == 0) should == {true => [2,2], false => [1,3,3,3,5,5,5,5,5]}
      )

      it("should be able to destructure on the argument name",
        result = []
        [[1,2], [2,3], [4,5]] groupBy((x,y), result << [x+1, y-1])
        result should == [[2,1], [3,2], [5,4]]
      )

      it("should be able to destructure and ignore the rest of something",
        result = []
        [[1,2,9,10], [2,3,11,12], [4,5,13,14]] groupBy((x,y,_), cell?(:"_") should not be true. result << [x, y])
        result should == [[1,2], [2,3], [4,5]]
      )

      it("should be able to destructure and ignore in the middle of the pattern without binding anything",
        result = []
        [[1,2,9], [2,3,11], [4,5,13]] groupBy((x,_,y), cell?(:"_") should not be true. result << [x, y]) 
        result should == [[1,9], [2,11], [4,13]]
      )

      it("should be able to destructure and ignore several times in the middle of the pattern without binding anything",
        result = []
        [[1,2,9,10,11], [2,3,11,12,13], [4,5,13,14,15]] groupBy((x,_,y,_,q), cell?(:"_") should not be true. result << [x, y, q]) 
        result should == [[1,9,11], [2,11,13], [4,13,15]]
      )

      it("should be able to destructure recursively",
        result = []
        [[[:x, :y, :z], [:q, :r, :p]], [[:b, :c, :d], [:i, :j, :k]], [[:i, :j, :k], [:i2, :j3, :k4]]] groupBy(
          (v, (v2, _, v3)), cell?(:"_") should be false. result << [v, v2, v3]) 
        result should == [[[:x, :y, :z], :q, :p], [[:b, :c, :d], :i, :k], [[:i, :j, :k], :i2, :k4]]
      )

      it("should report a destructuring match error if destructuring doesn't add upp",
        fn([[1,2], [3,4], [4,5]] groupBy((q,p,r), nil)) should signal(Condition Error DestructuringMismatch)
        fn([[1,2], [3,4], [4,5]] groupBy((q), nil)) should signal(Condition Error DestructuringMismatch)
        fn([[1,2], [3,4], [4,5]] groupBy((q,_,r), nil)) should signal(Condition Error DestructuringMismatch)
      )

      it("should report a destructuring match error if recursive destructuring doesn't add upp",
        fn([[[1,2],[1,2]], [[3,4],[1,2]], [[1,2],[4,5]]] groupBy((q,(p)), nil)) should signal(Condition Error DestructuringMismatch)
        fn([[[1,2],[1,2]], [[3,4],[1,2]], [[1,2],[4,5]]] groupBy((q,(p,r,f)), nil)) should signal(Condition Error DestructuringMismatch)
        fn([[[1,2],[1,2]], [[3,4],[1,2]], [[1,2],[4,5]]] groupBy((q,(p,_,f)), nil)) should signal(Condition Error DestructuringMismatch)
      )
    )

    describe("eachCons",
      it("should return the original object",
        x = [1,2,3]
        x eachCons(inspect) should be same(x)
      )

      it("should take one message chain argument and yield two items as a list to the message chain given",
        x = [1,2,3,4,5]
        res = []
        x eachCons(tap(y, res << y))
        res should == [[1,2], [2,3], [3,4], [4,5]]
      )

      it("should take a number to indicate cons size and yield those as a list to the message chain given",
        x = [1,2,3,4,5]
        res = []
        x eachCons(3, tap(y, res << y))
        res should == [[1,2,3], [2,3,4], [3,4,5]]
      )

      it("should take a number, an argument name and a message chain, and bind that argument name to the list and yield that in a new lexical scope",
        x = [1,2,3,4,5]
        res = []
        x eachCons(3, y, res << y)
        res should == [[1,2,3], [2,3,4], [3,4,5]]
      )

      it("should be able to destructure on the argument name",
        x = [1,2,3,4,5]
        res = []
        x eachCons(2, (p, q), res << [:p, p, :q, q])
        res should == [[:p, 1, :q, 2], [:p, 2, :q, 3], [:p, 3, :q, 4], [:p, 4, :q, 5]]

        x = [1,2,3,4,5,6,7,8,9]
        res = []
        x eachCons(3, (p, q, r), res << [:p, p, :q, q, :r, r])
        res should == [
          [:p, 1, :q, 2, :r, 3],
          [:p, 2, :q, 3, :r, 4],
          [:p, 3, :q, 4, :r, 5],
          [:p, 4, :q, 5, :r, 6],
          [:p, 5, :q, 6, :r, 7],
          [:p, 6, :q, 7, :r, 8],
          [:p, 7, :q, 8, :r, 9]]
      )

      it("should be able to destructure and ignore the rest of something",
        x = [1,2,3,4,5,6]
        res = []
        x eachCons(4, (p, q, _), res << [:p, p, :q, q]. cell?(:"_") should be false)
        res should == [
          [:p, 1, :q, 2],
          [:p, 2, :q, 3],
          [:p, 3, :q, 4]]
      )

      it("should be able to destructure and ignore in the middle of the pattern without binding anything",
        x = [1,2,3,4,5,6]
        res = []
        x eachCons(3, (p, _, q), res << [:p, p, :q, q]. cell?(:"_") should be false)
        res should == [
          [:p, 1, :q, 3],
          [:p, 2, :q, 4],
          [:p, 3, :q, 5],
          [:p, 4, :q, 6]]
      )

      it("should be able to destructure and ignore several times in the middle of the pattern without binding anything",
        x = [1,2,3,4,5,6,7,8,9]
        res = []
        x eachCons(5, (p, _, q, _, r), res << [:p, p, :q, q, :r, r]. cell?(:"_") should be false)
        res should == [
          [:p, 1, :q, 3, :r, 5],
          [:p, 2, :q, 4, :r, 6],
          [:p, 3, :q, 5, :r, 7],
          [:p, 4, :q, 6, :r, 8],
          [:p, 5, :q, 7, :r, 9]]
      )

      it("should be able to destructure recursively",
        x = [[:x, :y, :z], [:q, :r, :p], [:b, :c, :d], [:i, :j, :k]]
        res = []
        x eachCons(2, (v, (v2, _, v3)), res << [v, v2, v3]. cell?(:"_") should be false)
        res should == [
          [[:x, :y, :z], :q, :p],
          [[:q, :r, :p], :b, :d],
          [[:b, :c, :d], :i, :k]]
      )

      it("should report a destructuring match error if destructuring doesn't add upp",
        x = [1,2,3,4]

        fn(x eachCons(2, (q,p,r), nil)) should signal(Condition Error DestructuringMismatch)
        fn(x eachCons(2, (q), nil)) should signal(Condition Error DestructuringMismatch)
        fn(x eachCons(2, (q,_,r), nil)) should signal(Condition Error DestructuringMismatch)
      )

      it("should report a destructuring match error if recursive destructuring doesn't add upp",
        x = [[1,2],[2,3],[3,4],[4,5]]

        fn(x eachCons(2, (q,(p)), nil)) should signal(Condition Error DestructuringMismatch)
        fn(x eachCons(2, (q,(p,r,f)), nil)) should signal(Condition Error DestructuringMismatch)
        fn(x eachCons(2, (q,(p,_,f)), nil)) should signal(Condition Error DestructuringMismatch)
      )

      it("should yield a cons for each index",
        x = [1,2,3,4,5]
        res = []
        x eachCons(2, y, res << y)
        res should == [[1,2], [2,3], [3,4], [4,5]]
        
      )
    )

    describe("eachSlice",
      it("should return the original object",
        x = [1,2,3]
        x eachSlice(inspect) should be same(x)
      )

      it("should take one message chain argument and yield two items as a list to the message chain given",
        x = [1,2,3,4,5,6]
        res = []
        x eachSlice(tap(y, res << y))
        res should == [[1,2], [3,4], [5,6]]
      )

      it("should take a number to indicate cons size and yield those as a list to the message chain given",
        x = [1,2,3,4,5,6,7,8,9]
        res = []
        x eachSlice(3, tap(y, res << y))
        res should == [[1,2,3], [4,5,6], [7,8,9]]
      )

      it("should take a number, an argument name and a message chain, and bind that argument name to the list and yield that in a new lexical scope",
        x = [1,2,3,4,5,6,7,8,9]
        res = []
        x eachSlice(3, y, res << y)
        res should == [[1,2,3], [4,5,6], [7,8,9]]
      )

      it("should be able to destructure on the argument name",
        x = [1,2,3,4,5,6]
        res = []
        x eachSlice(2, (p, q), res << [:p, p, :q, q])
        res should == [[:p, 1, :q, 2], [:p, 3, :q, 4], [:p, 5, :q, 6]]

        x = [1,2,3,4,5,6,7,8,9]
        res = []
        x eachSlice(3, (p, q, r), res << [:p, p, :q, q, :r, r])
        res should == [
          [:p, 1, :q, 2, :r, 3],
          [:p, 4, :q, 5, :r, 6],
          [:p, 7, :q, 8, :r, 9]]
      )

      it("should be able to destructure and ignore the rest of something",
        x = [1,2,3,4,5,6,7,8]
        res = []
        x eachSlice(4, (p, q, _), res << [:p, p, :q, q]. cell?(:"_") should be false)
        res should == [
          [:p, 1, :q, 2],
          [:p, 5, :q, 6]]
      )

      it("should be able to destructure and ignore in the middle of the pattern without binding anything",
        x = [1,2,3,4,5,6,7,8,9]
        res = []
        x eachSlice(3, (p, _, q), res << [:p, p, :q, q]. cell?(:"_") should be false)
        res should == [
          [:p, 1, :q, 3],
          [:p, 4, :q, 6],
          [:p, 7, :q, 9]]
      )

      it("should be able to destructure and ignore several times in the middle of the pattern without binding anything",
        x = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15]
        res = []
        x eachSlice(5, (p, _, q, _, r), res << [:p, p, :q, q, :r, r]. cell?(:"_") should be false)
        res should == [
          [:p, 1, :q, 3, :r, 5],
          [:p, 6, :q, 8, :r, 10],
          [:p, 11, :q, 13, :r, 15]]
      )

      it("should be able to destructure recursively",
        x = [[:x, :y, :z], [:q, :r, :p], [:b, :c, :d], [:i, :j, :k]]
        res = []
        x eachSlice(2, (v, (v2, _, v3)), res << [v, v2, v3]. cell?(:"_") should be false)
        res should == [
          [[:x, :y, :z], :q, :p],
          [[:b, :c, :d], :i, :k]]
      )

      it("should report a destructuring match error if destructuring doesn't add upp",
        x = [1,2,3,4]

        fn(x eachSlice(2, (q,p,r), nil)) should signal(Condition Error DestructuringMismatch)
        fn(x eachSlice(2, (q), nil)) should signal(Condition Error DestructuringMismatch)
        fn(x eachSlice(2, (q,_,r), nil)) should signal(Condition Error DestructuringMismatch)
     )

      it("should report a destructuring match error if recursive destructuring doesn't add upp",
        x = [[1,2],[2,3],[3,4],[4,5]]

        fn(x eachSlice(2, (q,(p)), nil)) should signal(Condition Error DestructuringMismatch)
        fn(x eachSlice(2, (q,(p,r,f)), nil)) should signal(Condition Error DestructuringMismatch)
        fn(x eachSlice(2, (q,(p,_,f)), nil)) should signal(Condition Error DestructuringMismatch)
      )

      it("should yield a slice for each index",
        x = [1,2,3,4,5]
        res = []
        x eachSlice(2, y, res << y)
        res should == [[1,2], [3,4], [5]]
      )
    )
  )
)
