package org.ioke

import org.specs._
import org.specs.runner.JUnit4

class HierarchySpecTest extends JUnit4(HierarchySpec)

object HierarchySpec extends Specification {
  "object hierarchy" should {
    "BasicObject should have BasicObject as prototype"
    "TopLevel should have BasicObject as prototype"
    "Core should have BasicObject as prototype"
    "Singleton should have BasicObject as prototype"

    "Object should have BasicObject as prototype"
    "Object should have TopLevel as prototype"
    "Object should have Core as prototype"

    "Message should have Object as prototype"

    "Enumerable should have Singleton as prototype"

    "Sequence should have Object as prototype"
    "Sequence should have Enumerable as prototype"
    
    "MutableSequence should have Sequence as prototype"

    "Array should have MutableSequence as prototype"

    "String should have MutableSequence as prototype"

    "Symbol should have Sequence as prototype"

    "Hash should have Object as prototype"
    "Hash should have Enumerable as prototype"
  }
}
