package org.ioke

import org.specs._
import org.specs.runner.JUnit4

import scala.collection.mutable.ArrayBuffer

class DataSpecTest extends JUnit4(DataSpec)

object DataSpec extends Specification {
  "iokeData" should {
    "should override clone" in {
      val v = new iokeData
      val c = v.clone
      v mustNot be(c)
    }

    "have a good string representation" in {
      new iokeData().toString must be_==("Data()")
    }

    "have a good debug representation" in {
      val d = new iokeData
      d.debugString must be_==("#<Data:" + d.hashCode +">")
    }

    "have a good equals method" in {
      val d = new iokeData
      d must be_==(d)
      d mustNot be_==(new iokeData)
    }

    "have a good hashcode method" in {
      val d = new iokeData
      d.hashCode must be_==(d.hashCode)
      d.hashCode mustNot be_==(new iokeData().hashCode)
    }
  }

  "MessageData" should {
    "have a good string representation" in {
      val state = new iokeState
      val m = new MessageData(state.sym("foo"), null, null, null)
      val m2 = new MessageData(null, null, null, null)

      m.toString must be_==("Message(foo)")
      m2.toString must be_==("Message(<anonymous>)")
    }

    "have a good debug representation" in {
      val state = new iokeState
      val m = new MessageData(state.sym("foo"), null, null, null)
      val m2 = new MessageData(null, null, null, null)
      val m3 = new MessageData(null, null, state.msg(m), null)
      val m4 = new MessageData(null, null, null, state.msg(m))

      m.debugString must be_==("#<Message name=\"foo\" args=null previous=null next=null>")
      m2.debugString must be_==("#<Message name=null args=null previous=null next=null>")
      m3.debugString must be_==("#<Message name=null args=null previous=#<Message name=\"foo\" args=null previous=null next=null> next=null>")
      m4.debugString must be_==("#<Message name=null args=null previous=null next=#<Message name=\"foo\" args=null previous=null next=null>>")
    }

    "have a good equals method" in {
      val state = new iokeState
      val m = new MessageData(state.sym("foo"), null, null, null)
      val mx = new MessageData(state.sym("foo"), null, null, null)
      val m2 = new MessageData(null, null, null, null)
      val m2x = new MessageData(null, null, null, null)
      val m3 = new MessageData(null, null, state.msg(m), null)
      val m3x = new MessageData(null, null, state.msg(m), null)
      val m4 = new MessageData(null, null, null, state.msg(m))
      val m4x = new MessageData(null, null, null, state.msg(m))
      val m5 = new MessageData(null, state.msg(m), null, null)
      val m5x = new MessageData(null, state.msg(m), null, null)

      m must be_==(m)
      m must be_==(mx)
      m mustNot be_==(m2)
      m mustNot be_==(m3)
      m mustNot be_==(m4)
      m mustNot be_==(m5)

      m2 must be_==(m2)
      m2 must be_==(m2x)
      m2 mustNot be_==(m)
      m2 mustNot be_==(m3)
      m2 mustNot be_==(m4)
      m2 mustNot be_==(m5)

      m3 must be_==(m3)
      m3 must be_==(m3x)
      m3 mustNot be_==(m)
      m3 mustNot be_==(m2)
      m3 mustNot be_==(m4)
      m3 mustNot be_==(m5)

      m4 must be_==(m4)
      m4 must be_==(m4x)
      m4 mustNot be_==(m)
      m4 mustNot be_==(m2)
      m4 mustNot be_==(m3)
      m4 mustNot be_==(m5)

      m5 must be_==(m5)
      m5 must be_==(m5x)
      m5 mustNot be_==(m)
      m5 mustNot be_==(m2)
      m5 mustNot be_==(m3)
      m5 mustNot be_==(m4)
    }

    "have a good hashcode method" in {
      val state = new iokeState
      val m = new MessageData(state.sym("foo"), null, null, null)
      val mx = new MessageData(state.sym("foo"), null, null, null)
      val m2 = new MessageData(null, null, null, null)
      val m2x = new MessageData(null, null, null, null)
      val m3 = new MessageData(null, null, state.msg(m), null)
      val m3x = new MessageData(null, null, state.msg(m), null)
      val m4 = new MessageData(null, null, null, state.msg(m))
      val m4x = new MessageData(null, null, null, state.msg(m))
      val m5 = new MessageData(null, state.msg(m), null, null)
      val m5x = new MessageData(null, state.msg(m), null, null)

      m must be_==(m)
      m must be_==(mx)
      m mustNot be_==(m2)
      m mustNot be_==(m3)
      m mustNot be_==(m4)
      m mustNot be_==(m5)

      m2 must be_==(m2)
      m2 must be_==(m2x)
      m2 mustNot be_==(m)
      m2 mustNot be_==(m3)
      m2 mustNot be_==(m4)
      m2 mustNot be_==(m5)

      m3 must be_==(m3)
      m3 must be_==(m3x)
      m3 mustNot be_==(m)
      m3 mustNot be_==(m2)
      m3 mustNot be_==(m4)
      m3 mustNot be_==(m5)

      m4 must be_==(m4)
      m4 must be_==(m4x)
      m4 mustNot be_==(m)
      m4 mustNot be_==(m2)
      m4 mustNot be_==(m3)
      m4 mustNot be_==(m5)

      m5 must be_==(m5)
      m5 must be_==(m5x)
      m5 mustNot be_==(m)
      m5 mustNot be_==(m2)
      m5 mustNot be_==(m3)
      m5 mustNot be_==(m4)
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
      val state = new iokeState
      val b = new ArrayBuffer[iokeObject]
      new ArrayData(b).toString must be_==("[]")
      b += state.sym("foo")
      new ArrayData(b).toString must be_==("[foo]")
      b += state.sym("bar")
      new ArrayData(b).toString must be_==("[foo, bar]")
    }

    "have a good debug representation" in {
      val state = new iokeState
      val b = new ArrayBuffer[iokeObject]
      new ArrayData(b).debugString must be_==("#<Array []>")
      b += state.sym("foo")
      new ArrayData(b).debugString must be_==("#<Array [\"foo\"]>")
      b += state.sym("bar")
      new ArrayData(b).debugString must be_==("#<Array [\"foo\", \"bar\"]>")
    }

    "have a good equals method" in {
      val state = new iokeState
      val b = new ArrayBuffer[iokeObject]
      val a1 = new ArrayData(b)
      val a1x = new ArrayData(b)
      val a1y = new ArrayData(new ArrayBuffer[iokeObject])
      
      val b2 = new ArrayBuffer[iokeObject]
      b2 += state.sym("foo")
      val a2 = new ArrayData(b2)
      val a2x = new ArrayData(b2)
      val b3 = new ArrayBuffer[iokeObject]
      b3 += state.sym("foo")
      val a2y = new ArrayData(b3)

      a1 must be_==(a1)
      a1 must be_==(a1x)
      a1 must be_==(a1y)
      a1 mustNot be_==(a2)
      a1 mustNot be_==(a2x)
      a1 mustNot be_==(a2y)
    }

    "have a good hashcode method" in {
      val state = new iokeState
      val b = new ArrayBuffer[iokeObject]
      val a1 = new ArrayData(b)
      val a1x = new ArrayData(b)
      val a1y = new ArrayData(new ArrayBuffer[iokeObject])
      
      val b2 = new ArrayBuffer[iokeObject]
      b2 += state.sym("foo")
      val a2 = new ArrayData(b2)
      val a2x = new ArrayData(b2)
      val b3 = new ArrayBuffer[iokeObject]
      b3 += state.sym("foo")
      val a2y = new ArrayData(b3)

      a1.hashCode must be_==(a1.hashCode)
      a1.hashCode must be_==(a1x.hashCode)
      a1.hashCode must be_==(a1y.hashCode)
      a1.hashCode mustNot be_==(a2.hashCode)
      a1.hashCode mustNot be_==(a2x.hashCode)
      a1.hashCode mustNot be_==(a2y.hashCode)
    }
  }
/*
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
*/
}
