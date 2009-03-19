
BlankSlate = Origin mimic do(
  create = method(callback,
    bs = BlankSlate mimic
    callback call(bs)
    bs removeAllMimics!
    bs
  )
)
