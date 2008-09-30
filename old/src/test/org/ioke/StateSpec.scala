package org.ioke

import org.specs._
import org.specs.runner.JUnit4

class StateSpecTest extends JUnit4(StateSpec)

object StateSpec extends Specification {
  "state" should {
    "have a reasonable string representation" in {
      new iokeState().toString must be_==("iokeState")
    }

    "have a debug representation" in {
      new iokeState().debugString must be_==("#<iokeState>")
    }

    "Object proto should be based on iokeObject"
    "Symbol proto should be based on SymbolData"
    "Array proto should be based on ArrayData"
    "Message proto should be based on MessageData"

    "activate symbol should represent the string 'activate'"
    "forward symbol should represent the string 'forward'"
    "self symbol should represent the string 'self'"
    "set-slot symbol should represent the string 'set-slot'"
    "internal:set-slot symbol should represent the string 'internal:set-slot'"
    "call symbol should represent the string 'call'"
    "type symbol should represent the string 'type'"
    "semicolon symbol should represent the string ';'"

    "string proto should have the correct meta name"
    "string proto should have a type slot"

    "symbol proto should be prototyped from string proto"
    "array proto should be prototyped from object proto"
    
    "top level should have a top level slot pointing to itself"
    "top level should have a slot to the protos"
    "protos should have a slot to core"

    "protos should be prototyped from object"
    "core should be prototyped from object"
    "toplevel should be prototyped from object"

    "object should be prototyped from the top level"
    "top level should be prototyped from protos"
    "protos should be prototyped from core"
    
    "core should have a slot for Object"
    "core should have a slot for Array"
    "core should have a slot for Symbol"
    "core should have a slot for Message"
  }
}
