local Gamestate = require 'vendor/gamestate'
local app = require 'app'
local sound = require 'vendor/TEsound'

local Switch = {}
Switch.__index = Switch
-- Nodes with 'isInteractive' are nodes which the player can interact with, but not pick up in any way
Switch.isInteractive = true

function Switch.new(node, collider)
  local switch = {}
  setmetatable(switch, Switch)
  switch.bb = collider:addRectangle(node.x, node.y, node.width, node.height)
  switch.bb.node = switch
  switch.player_touched = false
  switch.height = node.height
  switch.width = node.width
  switch.trigger = node.properties.trigger or nil
  switch.db = app.gamesaves:active()
  switch.sound = node.properties.sound or false
  collider:setPassive(switch.bb)
  return switch
end

function Switch:setDB(trigger)
  if self.db:get( trigger ) == true then
    self.db:set( trigger, false)
  else
    self.db:set( trigger, true)
  end
end

function Switch:keypressed( button, player )
  if button == 'INTERACT' then
    if self.sound ~= false then
      sound.playSfx( self.sound )
    end
    if self.trigger ~= nil then
      self:setDB(self.trigger)
      return true
    end
  end
end

return Switch
