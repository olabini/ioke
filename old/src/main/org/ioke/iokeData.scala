package org.ioke

import scala.collection.mutable.ArrayBuffer

case class iokeData {
  override def clone() = iokeData()

  override def equals(other: Any) = other match {
    case that: iokeData => {
      this eq that
    }
    case _ => false
  }

  override def toString() = "Data()"
  def debugString() = "#<Data:" + this.hashCode + ">"

  override def hashCode() = System.identityHashCode(this)
}

object MessageData {
  val rawClone = (prototype: iokeObject) => { 
    val self = prototype.rawClonePrimitive
    self.data = prototype.data.clone
    self
  }

  def prototype(state : iokeState) : iokeObject = {
    val self = iokeObject.createNew(state)
    self.meta = newMeta(state)
    self.data = SymbolData("")
    self
  }

  def prototype_from(prototype : iokeObject) : iokeObject = {
    val self = prototype.CLONE_AS("Message")
    self.meta.cloneFunc = rawClone
//    self.meta.compareFunc = compare
    self.data = SymbolData("")
    self
  }

  def newMeta(state: iokeState) : Meta = {
    val meta = new Meta("Message", state)
    meta.cloneFunc = rawClone
//    meta.compareFunc = compare
    meta
  }
}

case class MessageData(name : iokeObject, 
                       args : iokeObject, 
                       previous : iokeObject,
                       next : iokeObject) extends iokeData {
  var cachedResult : iokeObject = _

  override def equals(other: Any) = other match {
    case that: MessageData => {
      this.name == that.name &&
      this.args == that.args &&
      this.previous == that.previous &&
      this.next == that.next
    }
    case _ => false
  }

  override def toString() = if(name == null) { "Message(<anonymous>)" } else { "Message(" + name + ")" }
  override def debugString() = "#<Message name=" + 
                         (if(name==null){"null"}else{"\""+name+"\""})+" args="+
                         (if(args==null||args.data==null){"null"}else{args.data.debugString})+" previous="+
                         (if(previous==null||previous.data==null){"null"}else{previous.data.debugString})+" next="+
                         (if(next==null||next.data==null){"null"}else{next.data.debugString})+">"

  override def hashCode() = {
    var h = 0
    if(name != null) h += 3*name.hashCode
    if(args != null) h += 5*args.hashCode
    if(previous != null) h += 7*previous.hashCode
    if(next != null) h += 11*next.hashCode

    h
  }
}


object SymbolData {
  val rawClone = (prototype: iokeObject) => { 
    val self = prototype.rawClonePrimitive
    self.data = prototype.data.clone
    self
  }

  def prototype(state : iokeState) : iokeObject = {
    val self = iokeObject.createNew(state)
    self.meta = newMeta(state)
    self.data = SymbolData("")
    self
  }

  def prototype_from(prototype : iokeObject) : iokeObject = {
    val self = prototype.CLONE_AS("Symbol")
    self.meta.cloneFunc = rawClone
//    self.meta.compareFunc = compare
    self.data = SymbolData("")
    self
  }

  def newMeta(state: iokeState) : Meta = {
    val meta = new Meta("Symbol", state)
    meta.cloneFunc = rawClone
//    meta.compareFunc = compare
    meta
  }

  def newSymbolWithString(state : iokeState, value : String) = {
    val self = state.symbolProto.CLONE
    self.data = SymbolData(value)
    self
  }
}

// immutable
case class SymbolData(var value : String) extends iokeData {
  override def clone() = SymbolData(value)

  override def toString() = value
  override def debugString() = "\"" + value + "\""
  override def equals(other: Any) = other match {
    case that: SymbolData => {
      value.equals(that.value)
    }
    case _ => false
  }

  override def hashCode() = {
    value.hashCode
  }
}

object StringData {
  val rawClone = (prototype: iokeObject) => { 
    val self = prototype.rawClonePrimitive
    self.data = prototype.data.clone
    self
  }

  def prototype(state : iokeState) : iokeObject = {
    val self = iokeObject.createNew(state)
    self.meta = newMeta(state)
    self.data = StringData(new StringBuffer)
    self
  }

  def prototype_from(prototype : iokeObject) : iokeObject = {
    val self = prototype.CLONE_AS("String")
    self.meta.cloneFunc = rawClone
//    self.meta.compareFunc = compare
    self.data = StringData(new StringBuffer)
    self
  }

  def newMeta(state: iokeState) : Meta = {
    val meta = new Meta("String", state)
    meta.cloneFunc = rawClone
//    meta.compareFunc = compare
    meta
  }
}

// mutable
case class StringData(val value : StringBuffer) extends iokeData {
  def this(value : String) = this(new StringBuffer(value))

  override def toString() = value.toString
  override def debugString() = "Buffer(\"" + value + "\")"
  override def equals(other: Any) = other match {
    case that: StringData => {
      value.toString.equals(that.value.toString)
    }
    case _ => false
  }

  override def hashCode() = {
    value.toString.hashCode
  }
}

object ArrayData {
  val rawClone = (prototype: iokeObject) => { 
    val self = prototype.rawClonePrimitive
    self.data = prototype.data.clone
    self
  }

  def prototype(state : iokeState) : iokeObject = {
    val self = iokeObject.createNew(state)
    self.meta = newMeta(state)
    self.data = ArrayData(new ArrayBuffer[iokeObject])
    self
  }

  def prototype_from(prototype : iokeObject) : iokeObject = {
    val self = prototype.CLONE_AS("Array")
    self.meta.cloneFunc = rawClone
//    self.meta.compareFunc = compare
    self.data = ArrayData(new ArrayBuffer[iokeObject])
    self
  }

  def newMeta(state: iokeState) : Meta = {
    val meta = new Meta("Array", state)
    meta.cloneFunc = rawClone
//    meta.compareFunc = compare
    meta
  }
}

case class ArrayData(val array : ArrayBuffer[iokeObject]) extends iokeData {
  override def clone() = {
    val newArray = new ArrayBuffer[iokeObject]
    newArray ++= array
    ArrayData(newArray)
  }

  override def toString() = array.mkString("[", ", ", "]")
  override def debugString() = "#<Array " + (array map((obj) => if(obj.data == null){obj.debugString}else{obj.data.debugString})).mkString("[", ", ", "]") + ">"

  override def equals(other: Any) = other match {
    case that: ArrayData => {
      array.equals(that.array)
    }
    case _ => false
  }

  override def hashCode() = {
    array.toString.hashCode
  }
}

case class HashData extends iokeData
