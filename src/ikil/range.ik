
IKIL {
  ;; will create fields and constructor automatically
  ;; will create an init method that makes sure it inits the correct things
  ;; will add accessors for all the fields
  ;; will add native method stuff for all methods defined
  ;; will add standardized getInspect and getNotice

  Range = IokeObjectData([Origin, Mixins Sequenced],
    from      = IokeObject
    to        = IokeObject
    inclusive = boolean
    inverted  = boolean

    methods {
      exclusive?: method("returns true if the receiver is an exclusive range, false otherwise",
        return(boolean(not(data inclusive)))),

      inclusive?: method("returns true if the receiver is an inclusive range, false otherwise",
        return(boolean(data inclusive))),

      from: method("returns the 'from' part of the range",
        return(data from)),

      to: method("returns the 'to' part of the range",
        return(data to)),

      inspect: method("Returns a text inspection of the object",
        return(text(inspect(self)))),

      notice: method("Returns a brief text inspection of the object",
        return(text(notice(self)))),
      }

    inspect {
      append(globalInspect(from))

      if(inclusive,
        append(".."),
        append("..."))

      append(globalInspect(to))
      }

    notice {
      append(globalNotice(from))

      if(inclusive,
        append(".."),
        append("..."))

      append(globalNotice(to))
      }
  )
}
