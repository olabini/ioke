
use("ispec")

; describe(Message,
;   describe("rewrite!",
;     it("should rewrite a very simple message chain",
;       msg = 'foo
;       msg rewrite!(
;         '(:x) => '(something(:x))
;       )
;       msg should == 'something(foo)
;     )

;     it("should rewrite a next into an argument",
;       msg = '(foo bar)
;       msg rewrite!(
;         '(:x :y) => '(:x(:y))
;       )
;       msg should == 'foo(bar)
;     )
;   )
; )
