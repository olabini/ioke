package org.ioke

import org.specs._
import org.specs.runner.JUnit4

class DataSpecTest extends JUnit4(DataSpec)

object DataSpec extends Specification {
  "iokeData" should {
    "should override clone" in {
      "TODO" must be_==("implemented")
    }

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

  "MessageData" should {
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

  "SymbolData" should {
    "have a good string representation" in {
      new SymbolData("foo").toString must be_==("foo")
      new SymbolData("123").toString must be_==("123")
      new SymbolData("###").toString must be_==("###")
    }

    "have a good debug representation" in {
      new SymbolData("foo").debugString must be_==("\"foo\"")
      new SymbolData("123").debugString must be_==("\"123\"")
      new SymbolData("###").debugString must be_==("\"###\"")
    }

    "have a good equals method" in {
      val s = new SymbolData("foo")
      s must be_==(s)
      new SymbolData("bar") mustNot be_==(s)
      new SymbolData("foo") must be_==(s)
    }

    "have a good hashcode method" in {
      val s = new SymbolData("foo")
      s.hashCode must be_==(s.hashCode)
      new SymbolData("bar").hashCode mustNot be_==(s.hashCode)
      new SymbolData("foo").hashCode must be_==(s.hashCode)
    }
  }

  "BufferData" should {
    "have a good string representation" in {
      new BufferData("foo").toString must be_==("foo")
      new BufferData("123").toString must be_==("123")
      new BufferData("###").toString must be_==("###")
    }

    "have a good debug representation" in {
      new BufferData("foo").debugString must be_==("Buffer(\"foo\")")
      new BufferData("123").debugString must be_==("Buffer(\"123\")")
      new BufferData("###").debugString must be_==("Buffer(\"###\")")
    }

    "have a good equals method" in {
      val s = new BufferData("foo")
      s must be_==(s)
      new BufferData("bar") mustNot be_==(s)
      new BufferData("foo") must be_==(s)
    }

    "have a good hashcode method" in {
      val s = new BufferData("foo")
      s.hashCode must be_==(s.hashCode)
      new BufferData("bar").hashCode mustNot be_==(s.hashCode)
      new BufferData("foo").hashCode must be_==(s.hashCode)
    }
  }

  "ArrayData" should {
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

  "HashData" should {
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
