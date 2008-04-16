package org.ioke

import scala.collection.mutable
import scala.collection.mutable.ArrayBuffer

// Tag in Io
class Meta(var name : String, val state : iokeState) {
  var cloneFunc : (iokeObject) => iokeObject = _
  var performFunc : Object = _
  var activateFunc : Object = _
  var compareFunc : Object = _

  override def toString() = "Meta(" + (if(name == null) { "<anonymous>" } else { name }) + ")"
  override def equals(other: Any) = other match {
    case that: Meta => {
      this.name == that.name &&
      this.state == that.state &&
      this.cloneFunc == that.cloneFunc &&
      this.performFunc == that.performFunc &&
      this.activateFunc == that.activateFunc &&
      this.compareFunc == that.compareFunc
    }
    case _ => false
  }

  override def hashCode() = {
    var h = 0
    if(null != name) {
      h = h + name.hashCode << 0
    }

    if(null != state) {
      h = h + state.hashCode << 0
    }

    if(null != cloneFunc) {
      h = h + cloneFunc.hashCode << 0
    }

    if(null != performFunc) {
      h = h + performFunc.hashCode << 0
    }

    if(null != activateFunc) {
      h = h + activateFunc.hashCode << 0
    }

    if(null != compareFunc) {
      h = h + compareFunc.hashCode << 0
    }
    h
  }

  def debugString() = {
    if(name == null) {
      "Meta(name=null)"
    } else {
      "Meta(name=\"" + name + "\")"
    }
  }
}
object iokeObject {
  val rawClone = (proto: iokeObject) => { 
    proto.rawClonePrimitive
  }

  def createNew(state : iokeState) = state.objectProto.CLONE

  def prototype(state: iokeState) : iokeObject = {
    val self = new iokeObject
    self.meta = newMeta(state)
    self.slots = mutable.Map()
    self.ownsSlots = true
    
    self
  }

  def newMeta(state: iokeState) : Meta = {
    val meta = new Meta("Object", state)
    meta.cloneFunc = rawClone
    meta
  }
}

class iokeObject {
  var meta : Meta = _
  var slots = mutable.Map.empty[iokeObject, iokeObject]
  var prototypes = new ArrayBuffer[iokeObject]
  var data : iokeData = _

  var hasDoneLookup = false // used to avoid slot lookup loops
  var isActivatable = false // if true, upon activation, call activate slot
  var ownsSlots = false
  var isSymbol = false
  var isLocals = false

  def CLONE() : iokeObject = {
    meta.cloneFunc(this)
  }

  def setPrototypeTo(prototype : iokeObject) : Unit = {
    prototypes.clear
    prototypes += prototype
  }

  def rawClonePrimitive() : iokeObject = {
    val self = new iokeObject
    self.meta = this.meta
    self.setPrototypeTo(this)
    self
  }

  def setSlotTo(key : iokeObject, value : iokeObject) = slots += Pair(key, value)

  override def toString() = if(meta == null) { "<anonymous>" } else { meta.name }
  override def equals(other: Any) = other match {
    case that: iokeObject => {
      if(null == data) {
        this eq that
      } else {
        data.equals(that.data)
      }
    }
    case _ => false
  }

  override def hashCode() = {
    var h = 0
    if(null == data) {
      h = super.hashCode()
    } else {
      h = data.hashCode()
    }
    h
  }

  def debugString() = {
    "#<Object" + 
    (if(null!=meta){":" + meta.name}else{""}) + 
    " slots=" + slots.mkString("[",",","]") + 
    " prototypes=" + prototypes.mkString("[",",","]") + 
    " data=" + data + ">"
  }
}
