package org.ioke

import org.specs._
import org.specs.runner.JUnit4

class MetaSpecTest extends JUnit4(MetaSpec)

object MetaSpec extends Specification {
  "meta" should {
    "have a good string representation" in {
      new Meta("abc", null).toString must be_==("Meta(abc)")
      new Meta("foo", null).toString must be_==("Meta(foo)")
      new Meta(null, null).toString must be_==("Meta(<anonymous>)")
    }

    "have a good debug representation" in {
      new Meta("abc", null).debugString must be_==("Meta(name=\"abc\")")
      new Meta("foo", null).debugString must be_==("Meta(name=\"foo\")")
      new Meta(null, null).debugString must be_==("Meta(name=null)")
    }

    "have a good equals method" in {
      val s = new iokeState
      val m = new Meta("abc", s)
      m must be_==(m)
      new Meta("abc", s) must be_==(m)
      new Meta("foo", s) mustNot be_==(m)
      new Meta("abc", new iokeState) mustNot be_==(m)

      val m2 = new Meta("abc", s)
      val func = (inp: iokeObject) => inp
      m2.cloneFunc = func

      val m3 = new Meta("abc", s)
      m3.cloneFunc = func

      m2 must be_==(m3)
      m2 mustNot be_==(m)

      val m4 = new Meta("abc", s)
      m4.performFunc = func

      val m5 = new Meta("abc", s)
      m5.performFunc = func

      m4 must be_==(m5)
      m4 mustNot be_==(m)      

      val m6 = new Meta("abc", s)
      m6.activateFunc = func

      val m7 = new Meta("abc", s)
      m7.activateFunc = func

      m6 must be_==(m7)
      m6 mustNot be_==(m)      

      val m8 = new Meta("abc", s)
      m8.compareFunc = func

      val m9 = new Meta("abc", s)
      m9.compareFunc = func

      m8 must be_==(m9)
      m8 mustNot be_==(m)      
    }

    "have a good hashcode method" in {
      "TODO" must be_==("implemented")
    }
  }
}
