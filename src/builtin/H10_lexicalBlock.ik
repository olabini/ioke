
cell(:LexicalBlock) -> = method(other,
  outsideSelf = self
  if(cell?(:activatable) && activatable,
    fnx(arg, cell(:other) call(cell(:outsideSelf) call(arg))),
    fn(arg, cell(:other) call(cell(:outsideSelf) call(arg)))))

cell(:LexicalBlock) <- = method(other,
  outsideSelf = self
  if(cell?(:activatable) && activatable,
    fnx(arg, cell(:outsideSelf) call(cell(:other) call(arg))),
    fn(arg, cell(:outsideSelf) call(cell(:other) call(arg)))))

cell(:LexicalBlock) & = method(other,
  outsideSelf = self
  if(cell?(:activatable) && activatable,
    fnx(arg,
      res1 = cell(:outsideSelf) call(arg)
      res2 = cell(:other) call(arg)
      res1 && res2),
    fn(arg,
      res1 = cell(:outsideSelf) call(arg)
      res2 = cell(:other) call(arg)
      res1 && res2)))

cell(:LexicalBlock) | = method(other,
  outsideSelf = self
  if(cell?(:activatable) && activatable,
    fnx(arg,
      res1 = cell(:outsideSelf) call(arg)
      res2 = cell(:other) call(arg)
      res1 || res2),
    fn(arg,
      res1 = cell(:outsideSelf) call(arg)
      res2 = cell(:other) call(arg)
      res1 || res2)))

cell(:LexicalBlock) complement = method(
  outsideSelf = self
  if(cell?(:activatable) && activatable,
    fnx(arg, !(cell(:outsideSelf) call(arg))),
    fn(arg, !(cell(:outsideSelf) call(arg)))))

Sequence Iterate = Sequence mimic do(
  next? = true
  next = method(
    v = @currentValue
    @currentValue = @ cell(:code) call(*v)
    v
  )
)

cell(:LexicalBlock) iterate = method(
  "Returns an infinite sequence that will in turn yield args, self(args), self(self(args)), etc",
  +args,
  Sequence Iterate with(currentValue: args, code: self)
)
