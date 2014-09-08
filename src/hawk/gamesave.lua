local middle = require 'hawk/middleclass'
local store = require 'hawk/store'

local SCHEMA = 1
local Gamesave = middle.class('Gamesave')

function Gamesave:initialize(slots)
  self.slots = {
    store('gamesaves-alpha-' .. SCHEMA),
    store('gamesaves-beta-' .. SCHEMA),
    store('gamesaves-gamma-' .. SCHEMA),
  }
  self._active = 1 
end

function Gamesave:all()
  return self.slots
end

function Gamesave:active()
  return self.slots[self._active]
end

function Gamesave:activate(slot)
  self._active = slot
  return true
end

function Gamesave:delete(slot)
  return self.slots[slot]:delete()
end

function Gamesave:save()
  return self.slots[self._active]:flush()
end

return Gamesave
