package org.ioke

import org.specs._
import org.specs.runner.JUnit4

class HierarchySpecTest extends JUnit4(HierarchySpec)

object HierarchySpec extends Specification {
  "object hierarchy" should {
    "BasicObject should have BasicObject as prototype" in {
      val state = new iokeState
      state.basicObjectProto.prototypes must contain(state.basicObjectProto)
    }

    "TopLevel should have BasicObject as prototype" in {
      val state = new iokeState
      state.topLevelProto.prototypes must contain(state.basicObjectProto)
    }

    "Core should have BasicObject as prototype" in {
      val state = new iokeState
      state.coreProto.prototypes must contain(state.basicObjectProto)
    }

    "Singleton should have BasicObject as prototype" in {
      val state = new iokeState
      state.singletonProto.prototypes must contain(state.basicObjectProto)
    }

    "Object should have BasicObject as prototype" in {
      val state = new iokeState
      state.objectProto.prototypes must contain(state.basicObjectProto)
    }

    "Object should have TopLevel as prototype" in {
      val state = new iokeState
      state.objectProto.prototypes must contain(state.topLevelProto)
    }

    "Object should have Core as prototype" in {
      val state = new iokeState
      state.objectProto.prototypes must contain(state.coreProto)
    }

    "Message should have Object as prototype" in {
      val state = new iokeState
      state.messageProto.prototypes must contain(state.objectProto)
    }

    "Enumerable should have Singleton as prototype" in {
      val state = new iokeState
      state.enumerableProto.prototypes must contain(state.singletonProto)
    }

    "Sequence should have Object as prototype" in {
      val state = new iokeState
      state.sequenceProto.prototypes must contain(state.objectProto)
    }

    "Sequence should have Enumerable as prototype" in {
      val state = new iokeState
      state.sequenceProto.prototypes must contain(state.enumerableProto)
    }
    
    "MutableSequence should have Sequence as prototype" in {
      val state = new iokeState
      state.mutableSequenceProto.prototypes must contain(state.sequenceProto)
    }

    "Array should have MutableSequence as prototype" in {
      val state = new iokeState
      state.arrayProto.prototypes must contain(state.mutableSequenceProto)
    }

    "String should have MutableSequence as prototype" in {
      val state = new iokeState
      state.stringProto.prototypes must contain(state.mutableSequenceProto)
    }

    "Symbol should have Sequence as prototype" in {
      val state = new iokeState
      state.symbolProto.prototypes must contain(state.sequenceProto)
    }

    "Hash should have Object as prototype" in {
      val state = new iokeState
      state.hashProto.prototypes must contain(state.objectProto)
    }

    "Hash should have Enumerable as prototype" in {
      val state = new iokeState
      state.hashProto.prototypes must contain(state.enumerableProto)
    }
  }
}
