package org.ioke

import org.specs._
import org.specs.runner.JUnit4

class StateSpecTest extends JUnit4(StateSpec)

object StateSpec extends Specification {
  "state" should {
    "have a reasonable string representation" in {
      new iokeState().toString must be_==("iokeState")
    }

    "have a debug representation" in {
      new iokeState().debugString must be_==("#<iokeState>")
    }
  }
}
