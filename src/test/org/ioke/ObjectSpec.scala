package org.ioke

import org.specs._
import org.specs.runner.JUnit4

class ObjectSpecTest extends JUnit4(ObjectSpec)

object ObjectSpec extends Specification {
  "object" should {
    "have a good string representation" in {
      "TODO" must be_==("implemented")
    }

    "have a good debug representation" in {
      "TODO" must be_==("implemented")
    }

    "have a good equals method" in {
      "TODO" must be_==("implemented")
    }

    "have a good hashcode method" in {
      "TODO" must be_==("implemented")
    }
  }
}
