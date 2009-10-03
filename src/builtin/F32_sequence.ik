IokeGround Sequence = Origin mimic
Sequence mimic!(Mixins Enumerable)

Mixins Sequenced do(
  mapped = macro(call resendToReceiver(self seq))
  collected = macro(call resendToReceiver(self seq))
  sorted = macro(call resendToReceiver(self seq))
  sortedBy = macro(call resendToReceiver(self seq))
  folded = macro(call resendToReceiver(self seq))
  injected = macro(call resendToReceiver(self seq))
  reduced = macro(call resendToReceiver(self seq))
  filtered = macro(call resendToReceiver(self seq))
  selected = macro(call resendToReceiver(self seq))
  grepped = macro(call resendToReceiver(self seq))
  zipped = macro(call resendToReceiver(self seq))
  dropped = macro(call resendToReceiver(self seq))
  droppedWhile = macro(call resendToReceiver(self seq))
  rejected = macro(call resendToReceiver(self seq))
)

Sequence Filter = Sequence mimic
Sequence Map    = Sequence mimic
Sequence Fold   = Sequence mimic
Sequence Sort   = Sequence mimic
Sequence SortBy = Sequence mimic
Sequence Zip    = Sequence mimic
Sequence Reject = Sequence mimic
Sequence Grep   = Sequence mimic
Sequence Drop   = Sequence mimic
Sequence DropWhile = Sequence mimic
