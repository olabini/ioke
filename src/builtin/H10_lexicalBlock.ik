
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
