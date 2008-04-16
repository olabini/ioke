package org.ioke

import scala.collection.mutable
import scala.collection.mutable.ArrayBuffer

// Tag in Io
class Meta(var name : String, val state : iokeState) {
  var cloneFunc : (iokeObject) => iokeObject = _
  var performFunc : Object = _
  var activateFunc : Object = _
  var compareFunc : Object = _

  def debugString() = ""
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
}
