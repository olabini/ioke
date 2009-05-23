
use("ispec")

describe(Message,
  describe("rewrite!",
    it("should rewrite a very simple message chain")
;       msg = 'foo
;       msg rewrite!(
;         '(:x) => '(something(:x))
;       )
;       msg should == 'blah(foo)
;     )
  )
)
