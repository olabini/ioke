package org.ioke

import scala.collection.mutable.ArrayBuffer

case class iokeData {
  override def clone() = iokeData()
}

case class MessageData(name : iokeObject, 
                       args : iokeObject, 
                       previous : iokeObject,
                       next : iokeObject) extends iokeData {
    var cachedResult : iokeObject = _
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
}

// mutable
case class BufferData(val value : StringBuffer) extends iokeData

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
}

case class HashData extends iokeData
