local anim8 = require 'vendor/anim8'
local Gamestate = require 'vendor/gamestate'
local Item = require 'items/item'
local sound = require 'vendor/TEsound'
local Timer = require 'vendor/timer'

local AnimatedDoorTrigger = {}
AnimatedDoorTrigger.__index = AnimatedDoorTrigger
-- Nodes with 'isInteractive' are nodes which the player can interact with, but not pick up in any way
AnimatedDoorTrigger.isInteractive = true

function AnimatedDoorTrigger.new(node, collider)
  local art = {}
  setmetatable(art, AnimatedDoorTrigger)
  art.x = node.x
  art.y = node.y
  art.bb = collider:addRectangle(node.x, node.y, node.width, node.height)
  art.bb.node = art
  art.player_touched = false
  art.shown = false
    
  assert( node.properties.sprite, 'You must provide a sprite property for the animateddoortrigger node' )
  assert( node.properties.width, 'You must provide a width property for the animateddoortrigger node' )
  assert( node.properties.height, 'You must provide a height property for the animateddoortrigger node' )
  assert( node.properties.target, 'You must provide a target property for the animateddoortrigger node' )
    
  art.sprite = node.properties.sprite
  art.width = tonumber(node.properties.width)
  art.height = tonumber(node.properties.height)
  art.target = node.properties.target
    
  art.image = love.graphics.newImage('images/hiddendoor/' .. art.sprite .. '.png')
  art.g = anim8.newGrid(art.width,art.height, art.image:getWidth(), art.image:getHeight())
  
  art.closed = anim8.newAnimation('once',art.g('1,1'), 1)
  art.open = anim8.newAnimation('once', art.g('2,1'), 1)
    
  collider:setPassive(art.bb)
  return art
end

function AnimatedDoorTrigger:update(dt)
end

function AnimatedDoorTrigger:enter(previous)
  --Gamestate.currentState().doors[self.target].node:hide(previous)
end

function AnimatedDoorTrigger:draw()
  if self.shown then
    self.closed:draw(self.image, self.x, self.y)
  else
    self.open:draw(self.image, self.x, self.y)
  end
end

function AnimatedDoorTrigger:keypressed( button, player )
  if button == 'INTERACT' then
    local itemNode = {type = 'key',name = 'white_crystal'}
    local itemNodeMaster = {type = 'key', name = 'master'}
    local item = Item.new(itemNode)
    local itemMaster = Item.new(itemNodeMaster)
    local playerItem, pageIndex, slotIndex = player.inventory:search(item)
    local playerItemMaster, pageIndexMaster, slotIndexMaster = player.inventory:search(itemMaster)
    if not (playerItem or playerItemMaster) then
      sound.playSfx('unlocked')
    else
      --Gamestate.currentState().doors[self.target].node:show()
      self.shown = true
    end
  end
end

return AnimatedDoorTrigger
