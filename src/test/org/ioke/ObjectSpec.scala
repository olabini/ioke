package org.ioke

import org.specs._
import org.specs.runner.JUnit4

class ObjectSpecTest extends JUnit4(ObjectSpec)

object ObjectSpec extends Specification {
  "object" should {
    "have a good string representation" in {
      val o = new iokeObject
      o.meta = new Meta("Foo", null)
      o.toString must be_==("Foo")

      new iokeObject().toString must be_==("<anonymous>")
    }

    "have a good debug representation" in {
      val o = new iokeObject
      o.meta = new Meta("Foo", null)
      o.debugString must be_==("#<Object:Foo slots=[] prototypes=[] data=null>")

      val o2 = new iokeObject
      o2.debugString must be_==("#<Object slots=[] prototypes=[] data=null>")
    }

    "have a good equals method" in {
      new iokeObject mustNot be_==(new iokeObject)

      val o = new iokeObject
      o.data = new SymbolData("foo")

      val o2 = new iokeObject
      o2.data = new SymbolData("foo2")

      val o3 = new iokeObject
      o3.data = new SymbolData("foo")

      o must be_==(o)
      o must be_==(o3)
      o mustNot be_==(o2)
    }

    "have a good hashcode method" in {
      (new iokeObject).hashCode mustNot be_==((new iokeObject).hashCode)

      val o = new iokeObject
      o.data = new SymbolData("foo")

      val o2 = new iokeObject
      o2.data = new SymbolData("foo2")

      val o3 = new iokeObject
      o3.data = new SymbolData("foo")

      o.hashCode must be_==(o.hashCode)
      o.hashCode must be_==(o3.hashCode)
      o.hashCode mustNot be_==(o2.hashCode)
    }
  }
}
