local machine = {}
machine.__index = machine
machine.ASYNC = 1 -- Lua constants?

local function state_transition(self, from, to, name, ...)
  self.current = to

  if self["on" .. to] then 
    self["on" .. to](self, name, from, to, ...)
  end

  if self["on" .. name] then 
    self["on" .. name](self, name, from, to, ...)
  end

  if self.onstatechange then 
    self.onstatechange(self, name, from, to, ...)
  end
end


local function create_transition(name, to)
  return function(self, ...)
    if self._async ~= nil then
      return false
    end

    if self:can(name) then

      local from = self.current

      if self["onbefore" .. name] then 
        local cancel = self["onbefore" .. name](self, name, from, to, ...)
        if cancel == false then
          return false
        end
      end

      if self["onleave" .. from] then 
        local cancel = self["onleave" .. from](self, name, from, to, ...)
        if cancel == false then
          return false
        end
        if cancel == machine.ASYNC then -- A little gross
          self._async = (function(self, from, to, name, args) 
            return function()
              state_transition(self, from, to, name, unpack(args))
            end
          end)(self, from, to, name, {...})
          return true
        end
      end

      state_transition(self, from, to, name, ...)
      return true
    end
    return false
  end
end


function machine.create(options)
  assert(options.events)

  local fsm = {}
  setmetatable(fsm, machine)

  fsm.current = options.initial or 'none'
  fsm.events = options.events
  fsm._async = nil

  for _, event in ipairs(options.events) do
    fsm[event.name] = create_transition(event.name, event.to)
  end

  return fsm
end

function machine:is(state)
  return self.current == state
end

function machine:transition()
  if self._async == nil then
    return false
  end
  self._async()
  self._async = nil
  return true
end


function machine:can(e)
  for _, event in ipairs(self.events) do
    if event.name == e and self.current == event.from then
      return true
    end
  end
  return false
end

function machine:cannot(e)
  return not self:can(e)
end

return machine
