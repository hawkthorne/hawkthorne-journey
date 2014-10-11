local Dialog = require 'dialog'
local anim8 = require 'vendor/anim8'
local utils = require 'utils'

local Info = {}
Info.__index = Info
-- Nodes with 'isInteractive' are nodes which the player can interact with, but not pick up in any way
Info.isInteractive = true

function Info.new(node, collider)
  local info = {}
  setmetatable(info, Info)

  info.bb = collider:addRectangle(node.x, node.y, node.width, node.height)
  info.bb.node = info
  info.info = utils.split(node.properties.info, '|')
  info.dt = math.random()

  info.x = node.x
  info.y = node.y
  info.height = node.height
  info.width = node.width
  info.position = { x = node.x, y = node.y }
  info.animation = node.properties.animation or false

  if node.properties.sprite ~= nil then
    info.sprite = love.graphics.newImage('images/info/'.. node.properties.sprite ..'.png')
  end
  if info.animation then
    info.flip = node.properties.flip == 'true'
    info.speed = node.properties.speed and tonumber(node.properties.speed) or 0.20

    local g = anim8.newGrid(tonumber(node.width), tonumber(node.height), 
                    info.sprite:getWidth(), info.sprite:getHeight())

    info.animation = anim8.newAnimation( 'loop', g( unpack( utils.split( node.properties.animation, '|' ) ) ), info.speed )
  end

  collider:setPassive(info.bb)

  info.current = nil

  return info
end

function Info:update(dt, player)
  self.dt = self.dt + dt

  if self.animation then
    self.animation:update(dt)
  end
end

function Info:draw()
  if self.sprite ~= nil and self.animation then
    self.animation:draw(self.sprite, self.x, self.y, 0, self.flip and -1 or 1, 1, self.flip and self.width or 0)
  elseif self.sprite ~= nil and not self.animation then
    love.graphics.draw(self.sprite, self.position.x, self.position.y)
  end
end

function Info:keypressed( button, player )
  if button == 'INTERACT' and self.dialog == nil and not player.freeze then
    player.freeze = true
    Dialog.new(self.info, function()
      player.freeze = false
      Dialog.currentDialog = nil
    end)
    -- Key has been handled, halt further processing
    return true
  end
end

return Info
