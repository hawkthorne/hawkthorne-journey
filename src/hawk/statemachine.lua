local machine = {}
machine.__index = machine


local function create_transition(name, to, initial)
  return function(self, ...)
    if self:can(name) then

      local from = self._current or initial

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
      end

      self._current = to

      if self["on" .. to] then 
        self["on" .. to](self, name, from, to, ...)
      end

      if self["on" .. name] then 
        self["on" .. name](self, name, from, to, ...)
      end

      if self.onstatechange then 
        self.onstatechange(self, name, from, to, ...)
      end

      return true
    end
    return false
  end
end


function machine.create(options)
  assert(options.events)

  local fsm = {}
  setmetatable(fsm, machine)

  fsm._current = options.initial or 'none'
  fsm.events = options.events

  for _, event in ipairs(options.events) do
    fsm[event.name] = create_transition(event.name, event.to, options.initial or 'none')
  end

  return fsm
end

function machine:is(state)
  return self._current == state
end

function machine:can(e)
  for _, event in ipairs(self.events) do
    if event.name == e and self._current == event.from then
      return true
    end
  end
  return false
end

function machine:cannot(e)
  return not self:can(e)
end

function machine.mixin(options)
  assert(options.events)

  local events = options.events
  local initial = options.initial or 'none'

  local mixin = {
    is = function (self, state)
      return (self._current or initial) == state
    end,
    can = function(self, e)
      for _, event in ipairs(events) do
        if event.name == e and (self._current or initial) == event.from then
          return true
        end
      end
      return false
    end,
    cannot = function(self, e)
      return not self:can(e)
    end,
  }

  for _, event in ipairs(events) do
    mixin[event.name] = create_transition(event.name, event.to, initial)
  end

  return mixin
end

return machine
