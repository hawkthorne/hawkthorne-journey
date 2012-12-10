local Stack = {}
Stack.__index = Stack

function Stack.new()
    local stack = {}
    stack.items = {}
    setmetatable(stack, Stack)
    return stack
end


function Stack:flush()
    -- returns true if the stack had items in it
    local item = table.remove(self.items)
    local filled = false

    while item do 
        filled = true
        item = table.remove(self.items)
    end

    return filled
end

function Stack:push(item)
    return table.insert(self.items, item)
end

-- @param item an optional parameter that is 'assert'ed against the top
-- @return top item on the stack, if possible
function Stack:pop(item)
    topItem = table.remove(self.items)
    if item then assert(item == topItem,"Incorrect top object expected:  "..item.."found: "..topItem) end
    return topItem
end

function Stack:isEmpty()
    return #self.items == 0
end
return Stack
