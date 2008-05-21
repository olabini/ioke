package org.ioke

import org.specs._
import org.specs.runner.JUnit4

class CoreClassesSpecTest extends JUnit4(CoreClassesSpec)

object CoreClassesSpec extends Specification {
  "BasicObject" should {
    "have a meta of the right name" in {
      new iokeState().basicObjectProto.meta.name must be_==("BasicObject")
    }

    "have a type slot of the right name" in {
      val state = new iokeState
      state.basicObjectProto.getSlot(state.sym("type")) must be_==(state.sym("BasicObject"))
    }
  }

  "TopLevel" should {
    "have a meta of the right name" in {
      new iokeState().topLevelProto.meta.name must be_==("TopLevel")
    }

    "have a type slot of the right name" in {
      val state = new iokeState
      state.topLevelProto.getSlot(state.sym("type")) must be_==(state.sym("TopLevel"))
    }
  }

  "Core" should {
    "have a meta of the right name" in {
      new iokeState().coreProto.meta.name must be_==("Core")
    }

    "have a type slot of the right name" in {
      val state = new iokeState
      state.coreProto.getSlot(state.sym("type")) must be_==(state.sym("Core"))
    }
  }

  "Singleton" should {
    "have a meta of the right name" in {
      new iokeState().singletonProto.meta.name must be_==("Singleton")
    }

    "have a type slot of the right name" in {
      val state = new iokeState
      state.singletonProto.getSlot(state.sym("type")) must be_==(state.sym("Singleton"))
    }
  }

  "Object" should {
    "have a meta of the right name" in {
      new iokeState().objectProto.meta.name must be_==("Object")
    }

    "have a type slot of the right name" in {
      val state = new iokeState
      state.objectProto.getSlot(state.sym("type")) must be_==(state.sym("Object"))
    }
  }

  "Message" should {
    "have a meta of the right name" in {
      new iokeState().messageProto.meta.name must be_==("Message")
    }

    "have a type slot of the right name" in {
      val state = new iokeState
      state.messageProto.getSlot(state.sym("type")) must be_==(state.sym("Message"))
    }
  }

  "Enumerable" should {
    "have a meta of the right name" in {
      new iokeState().enumerableProto.meta.name must be_==("Enumerable")
    }

    "have a type slot of the right name" in {
      val state = new iokeState
      state.enumerableProto.getSlot(state.sym("type")) must be_==(state.sym("Enumerable"))
    }
  }

  "Sequence" should {
    "have a meta of the right name" in {
      new iokeState().sequenceProto.meta.name must be_==("Sequence")
    }

    "have a type slot of the right name" in {
      val state = new iokeState
      state.sequenceProto.getSlot(state.sym("type")) must be_==(state.sym("Sequence"))
    }
  }

  "MutableSequence" should {
    "have a meta of the right name" in {
      new iokeState().mutableSequenceProto.meta.name must be_==("MutableSequence")
    }

    "have a type slot of the right name" in {
      val state = new iokeState
      state.mutableSequenceProto.getSlot(state.sym("type")) must be_==(state.sym("MutableSequence"))
    }
  }

  "Array" should {
    "have a meta of the right name" in {
      new iokeState().arrayProto.meta.name must be_==("Array")
    }

    "have a type slot of the right name" in {
      val state = new iokeState
      state.arrayProto.getSlot(state.sym("type")) must be_==(state.sym("Array"))
    }
  }

  "String" should {
    "have a meta of the right name" in {
      new iokeState().stringProto.meta.name must be_==("String")
    }

    "have a type slot of the right name" in {
      val state = new iokeState
      state.stringProto.getSlot(state.sym("type")) must be_==(state.sym("String"))
    }
  }

  "Symbol" should {
    "have a meta of the right name" in {
      new iokeState().symbolProto.meta.name must be_==("Symbol")
    }

    "have a type slot of the right name" in {
      val state = new iokeState
      state.symbolProto.getSlot(state.sym("type")) must be_==(state.sym("Symbol"))
    }
  }

  "Hash" should {
    "have a meta of the right name" in {
      new iokeState().hashProto.meta.name must be_==("Hash")
    }

    "have a type slot of the right name" in {
      val state = new iokeState
      state.hashProto.getSlot(state.sym("type")) must be_==(state.sym("Hash"))
    }
  }
}
