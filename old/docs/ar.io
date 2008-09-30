IoRecord := Object clone do(
  init := method(
    self belongings := list
    self hasOnes := list
    self hasManies := list
    self hasFews := list
  )

  appender := method(msg,
    blk := block(
      call sender doMessage(msg) append(call message next name)
      call message setNext(call message next next)
    )
    blk setIsActivatable(true)
  )

  collector := method(
    meths := call argCount / 2
    waiter := Object clone
    for(index, 0, meths-1,
      waiter setSlot(call argAt(index*2) name, 
        appender(call argAt(index*2+1)))
    )
    waiter
  )

  belongs := collector(
    to, belongings
  )

  has := collector(
    many, hasManies,
    one, hasOnes
  )

  asString := method(
    indent := (x:=""; ((self type size) + 2) repeat(x = x .. " "); x)   
    self type .. "[ belongs to(" .. (belongings join(", ")) .. ")," .. "\n" .. 
      indent .. "has many(" .. (hasManies join(", ")) .. "),\n" .. 
      indent .. "has one(" .. (hasOnes join(", ")) .. "),\n" ..
      indent .. "]")

  curlyBrackets := method(
    current := self clone
    call message setName("do")
    current doMessage(call message)
  )
)

Post := IoRecord {
  has many authors
  belongs to blog
  belongs to isp
}

Author := IoRecord {
  has many blogs
  has many posts
  has one name
}

Post println
Author println

