
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
