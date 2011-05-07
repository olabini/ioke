; Based on V8 JavaScript richards

ID_IDLE       = 0
ID_WORKER     = 1
ID_HANDLER_A  = 2
ID_HANDLER_B  = 3
ID_DEVICE_A   = 4
ID_DEVICE_B   = 5
NUMBER_OF_IDS = 6

COUNT         = 10000

EXPECTED_QUEUE_COUNT = 23246
EXPECTED_HOLD_COUNT = 9297

STATE_RUNNING = 0
STATE_RUNNABLE = 1
STATE_SUSPENDED = 2
STATE_HELD = 4
STATE_SUSPENDED_RUNNABLE = STATE_SUSPENDED | STATE_RUNNABLE
STATE_NOT_HELD = -5

DATA_SIZE = 4

; The Richards benchmark simulates the task dispatcher of an
; operating system.
runRichards = method(
  scheduler = Scheduler create
  scheduler addIdleTask(ID_IDLE, 0, nil, COUNT)
  queue = Packet create(link: nil, id: ID_WORKER, kind: :work)
  queue = Packet create(link: queue, id: ID_WORKER, kind: :work)
  
  scheduler addWorkerTask(ID_WORKER, 1000, queue)

  queue = Packet create(link: nil,   id: ID_DEVICE_A, kind: :device)
  queue = Packet create(link: queue, id: ID_DEVICE_A, kind: :device)
  queue = Packet create(link: queue, id: ID_DEVICE_A, kind: :device)

  scheduler addHandlerTask(ID_HANDLER_A, 2000, queue)
  
  queue = Packet create(link: nil,   id: ID_DEVICE_B, kind: :device)
  queue = Packet create(link: queue, id: ID_DEVICE_B, kind: :device)
  queue = Packet create(link: queue, id: ID_DEVICE_B, kind: :device)
  
  scheduler addHandlerTask(ID_HANDLER_B, 3000, queue)

  scheduler addDeviceTask(ID_DEVICE_A, 4000, nil)
  scheduler addDeviceTask(ID_DEVICE_B, 5000, nil)
  
  scheduler schedule!

  if(scheduler queueCount != EXPECTED_QUEUE_COUNT || scheduler holdCount != EXPECTED_HOLD_COUNT,
    error!("Error during execution: queueCount = #{scheduler queueCount}, holdCount = #{scheduler holdCount}."))
)

Scheduler = Origin mimic do(
  create = method(
    with(
      queueCount: 0,
      holdCount: 0,
      blocks: [nil] * NUMBER_OF_IDS,
      workList: nil,
      currentTcb: nil,
      currentId: nil
    )
  )

  addIdleTask = method(id, priority, queue, count,
    addRunningTask(id, priority, queue, IdleTask with(scheduler: self, v1: 1, count: count))
  )

  addWorkerTask = method(id, priority, queue,
    addTask(id, priority, queue, WorkerTask with(scheduler: self, v1: ID_HANDLER_A, v2: 0))
  )

  addHandlerTask = method(id, priority, queue,
    addTask(id, priority, queue, HandlerTask with(scheduler: self))
  )

  addDeviceTask = method(id, priority, queue,
    addTask(id, priority, queue, DeviceTask with(scheduler: self))
  )

  addRunningTask = method(id, priority, queue, task,
    addTask(id, priority, queue, task)
    currentTcb running!
  )

  addTask = method(id, priority, queue, task,
    @currentTcb = TaskControlBlock create(link: workList, id: id, priority: priority, queue: queue, task: task)
    @workList = currentTcb
    blocks[id] = currentTcb
  )

  schedule! = method(
    @currentTcb = workList
    while(currentTcb,
      if(currentTcb heldOrSuspended?,
        @currentTcb = currentTcb link,
        @currentId = currentTcb id
        @currentTcb = currentTcb run!
      )
    )
  )

  release = method(id,
    tcb = blocks[id]
    unless(tcb, return tcb)
    tcb markAsNotHeld!
    if(tcb priority > currentTcb priority,
      tcb,
      currentTcb)
  )

  holdCurrent = method(
    @holdCount ++
    currentTcb markAsHeld!
    currentTcb link
  )

  suspendCurrent = method(
    currentTcb markAsSuspended!
    currentTcb
  )

  queue = method(packet,
    t = blocks[packet id]
    unless(t, return t)
    @queueCount ++
    packet link = nil
    packet id = currentId
    t checkPriorityAdd(currentTcb, packet)
  )
)

TaskControlBlock = Origin mimic do(
  create = method(link:, id:, priority:, queue:, task:,
    with(link: link, id: id, priority: priority, queue: queue, task: task) tap(x,
      x state = if(x queue, STATE_SUSPENDED_RUNNABLE, STATE_SUSPENDED)
    )
  )

  running!         = method(@state = STATE_RUNNING)
  markAsNotHeld!   = method(@state = state & STATE_NOT_HELD) 
  markAsHeld!      = method(@state = state | STATE_HELD)
  heldOrSuspended? = method(((state & STATE_HELD) != 0) || (state == STATE_SUSPENDED))
  markAsSuspended! = method(@state = state | STATE_SUSPENDED)
  markAsRunnable!  = method(@state = state | STATE_RUNNABLE)

  run!             = method(
    task run(
      if(state == STATE_SUSPENDED_RUNNABLE,
        packet = queue
        @queue = packet link
        @state = if(queue, STATE_RUNNABLE, STATE_RUNNING)
        packet,
        nil)
    )
  )

  checkPriorityAdd = method(task, packet,
    if(queue,
      @queue = packet addTo(queue),
      @queue = packet
      markAsRunnable!
      if(priority > task priority, return self))
    task)

  asText = method(
    "tcb { #{task}@#{state} }"
  )
)

IdleTask = Origin mimic do(
  run = method(packet,
    @count --
    if(count == 0, return(scheduler holdCurrent))
    if((v1 & 1) == 0,
      @v1 = v1 >> 1
      scheduler release(ID_DEVICE_A),
      @v1 = (v1 >> 1) ^ 53256
      scheduler release(ID_DEVICE_B)))

  asText = "IdleTask"
)

DeviceTask = Origin mimic do(
  v1 = nil
  run = method(packet,
    if(packet,
      @v1 = packet
      scheduler holdCurrent,
      unless(v1, return(scheduler suspendCurrent))
      v = v1
      @v1 = nil
      scheduler queue(v)))

  asText = "DeviceTask"
)

WorkerTask = Origin mimic do(
  run = method(packet,
    if(packet,
      @v1 = if(v1 == ID_HANDLER_A, ID_HANDLER_B, ID_HANDLER_A)
      packet id = v1
      packet a1 = 0
      (0...DATA_SIZE) each(i,
        @v2 ++
        if(v2 > 26, @v2 = 1)
        packet a2[i] = v2)
      scheduler queue(packet),
      scheduler suspendCurrent))

  asText = "WorkerTask"
)

HandlerTask = Origin mimic do(
  v1 = nil
  v2 = nil
  run = method(packet,
    if(packet,
      if(packet kind == :work,
        @v1 = packet addTo(v1),
        @v2 = packet addTo(v2)))
    if(v1,
      count = v1 a1
      if(count < DATA_SIZE,
        if(v2,
          v = v2
          @v2 = v2 link
          v a1 = v1 a2[count]
          v1 a1 = count + 1
          return(scheduler queue(v))),
        v = v1
        @v1 = v1 link
        return(scheduler queue(v))))
    scheduler suspendCurrent
  )

  asText = "HandlerTask"
)


Packet = Origin mimic do(
  create = method(link:, id:, kind:,
    with(link: link, id: id, kind: kind) tap(x,
      x a1 = 0
      x a2 = [nil] * DATA_SIZE
    )
  )
  
  addTo = method(queue,
    @link = nil
    unless(queue, return self)
    next = queue
    while(peek = next link,
      next = peek)
    next link = self
    queue
  )

  asText = method("Packet<link=#{link}, id=#{id}, kind=#{@kind}, a1=#{a1}, a2=#{a2 map(x, if(x nil?, "", x asText)) join(",")}>")
)


System ifMain(
  use("benchmark")
  Benchmark report(runRichards)
)
