local Queue = {}
Queue.__index = Queue

function Queue.new()
  local queue = {}
  queue.items = {}
  setmetatable(queue, Queue)
  return queue
end

function Queue:poll(key)
  -- returns true if the queue had items in it
  local args = self.items[key]
  self.items[key] = nil

  if args == nil then
    return false
  end

  if #args > 0 then
    return true, unpack(args)
  end

  return true
end

function Queue:push(key, ...)
  self.items[key] = {...}
end

return Queue
