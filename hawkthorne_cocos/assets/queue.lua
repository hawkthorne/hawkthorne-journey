local Queue = {}
Queue.__index = Queue

function Queue.new()
    local queue = {}
    queue.items = {}
    setmetatable(queue, Queue)
    return queue
end


function Queue:flush()
    -- returns true if the queue had items in it
    local item = table.remove(self.items)
    local filled = false

    while item do 
        filled = true
        item = table.remove(self.items)
    end

    return filled
end

function Queue:push(item)
    return table.insert(self.items, item)
end

return Queue
