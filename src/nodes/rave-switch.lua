local Gamestate = require 'vendor/gamestate'

local RaveSwitch = {}
RaveSwitch.__index = RaveSwitch
-- Nodes with 'isInteractive' are nodes which the player can interact with, but not pick up in any way
RaveSwitch.isInteractive = true

function RaveSwitch.new(node, collider)
  local raveswitch = {}
  setmetatable(raveswitch, RaveSwitch)
  raveswitch.bb = collider:addRectangle(node.x, node.y, node.width, node.height)
  raveswitch.bb.node = raveswitch
  raveswitch.player_touched = false
  raveswitch.level = node.properties.level
  raveswitch.reenter = node.properties.reenter
  raveswitch.to = node.properties.to
  raveswitch.height = node.height
  raveswitch.width = node.width
  collider:setPassive(raveswitch.bb)
  return raveswitch
end

function RaveSwitch:switch(player)
  local level = Gamestate.get(self.level)
  local current = Gamestate.currentState()

  current.collider:setPassive(player.bb)
  Gamestate.switch(self.level)
  if self.to ~= nil then
    local level = Gamestate.get(self.level)
    local coordinates = {x=level.doors[self.to].x,
               y=level.doors[self.to].y,
               }
    level.player.position = {x=coordinates.x+self.width/2-24, 
    y=coordinates.y+self.height-48} -- Copy, or player position corrupts entrance data
    
    if level.doors[self.to].warpin then
      level.player:respawn()
    end
  end
end

function RaveSwitch:keypressed( button, player )
  if button == 'INTERACT' then
    self:switch(player)
    -- Key has been handled, halt further processing
    return true
  end
end

return RaveSwitch
