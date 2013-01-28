local Gamestate = require 'vendor/gamestate'
local anim8 = require 'vendor/anim8'

local Trigger = {}

Trigger.__index = Trigger

function Trigger.new(node, collider)
  local trigger = {}
  setmetatable(trigger, Trigger)

  trigger.event = node.properties.event
  trigger.player_touched = false
  trigger.bb = collider:addRectangle(node.x, node.y, node.width, node.height)
  trigger.bb.node = trigger
  trigger.collider = collider
  collider:setPassive(trigger.bb)

  return trigger
end

function Trigger:collide(node)
  if not node.isPlayer then return end
  local state = Gamestate.currentState()

  if state.events then
    state.events:push('trigger', self.event)
  end

  if self.collider then
    self.collider:remove(self.bb)
    self.collider = nil
  end
end

return Trigger
