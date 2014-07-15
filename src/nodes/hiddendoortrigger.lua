local anim8 = require 'vendor/anim8'
local app = require 'app'
local Gamestate = require 'vendor/gamestate'
local Prompt = require 'prompt'
local sound = require 'vendor/TEsound'
local Timer = require 'vendor/timer'

local HiddenDoorTrigger = {}
HiddenDoorTrigger.__index = HiddenDoorTrigger
-- Nodes with 'isInteractive' are nodes which the player can interact with, but not pick up in any way
HiddenDoorTrigger.isInteractive = true

function HiddenDoorTrigger.new(node, collider)
  local art = {}
  setmetatable(art, HiddenDoorTrigger)
  art.x = node.x
  art.y = node.y
  art.bb = collider:addRectangle(node.x, node.y, node.width, node.height)
  art.bb.node = art
  art.player_touched = false
  art.fixed = false
  art.prompt = nil
  art.needKey = node.properties.needKey --used only if key is needed for trigger to work
    
  assert( node.properties.sprite, 'You must provide a sprite property for the hiddendoortrigger node' )
  assert( node.properties.width, 'You must provide a width property for the hiddendoortrigger node' )
  assert( node.properties.height, 'You must provide a height property for the hiddendoortrigger node' )
  assert( node.properties.target, 'You must provide a target property for the hiddendoortrigger node' )
  if not art.needKey then
    assert( node.properties.message, 'You must provide a message property for the hiddendoortrigger node' )
  end

  art.sprite = node.properties.sprite
  art.width = tonumber(node.properties.width)
  art.height = tonumber(node.properties.height)
  art.message = node.properties.message
  art.target = node.properties.target

  art.key = "doortriggers." .. art.sprite
  if app.gamesaves:active():get(art.key, false) then
    art.fixed = true
    art.open = true
  end
    
  art.image = love.graphics.newImage('images/hiddendoor/' .. art.sprite .. '.png')
  art.g = anim8.newGrid(art.width,art.height, art.image:getWidth(), art.image:getHeight())
  art.closed = anim8.newAnimation('once',art.g('2,1'), 1)
  art.opened = anim8.newAnimation('once', art.g('1,1'), 1)
  
  collider:setPassive(art.bb)
  return art
end

function HiddenDoorTrigger:update(dt)
end

function HiddenDoorTrigger:enter(previous)
  Gamestate.currentState().doors[self.target].node:hide(previous)
end

function HiddenDoorTrigger:draw()
  if self.fixed or self.open then
    self.opened:draw(self.image, self.x, self.y)
  else
    self.closed:draw(self.image, self.x, self.y)
  end
end

function HiddenDoorTrigger:keypressed( button, player )
  if button == 'INTERACT' then
    if self.needKey then
      if player.inventory:hasKey(self.needKey) then
        self.fixed = true
        Gamestate.currentState().doors[self.target].node:show()
        app.gamesaves:active():set(self.key, true)
      else
        sound.playSfx('unlocked')
      end
    elseif self.prompt == nil and not self.fixed then
      player.freeze = true
      self.prompt = Prompt.new(self.message, function(result)
        if result == 'Yes' then
          Gamestate.currentState().doors[self.target].node:show()
          app.gamesaves:active():set(self.key, true)
        end
        player.freeze = false
        self.fixed = result == 'Yes'
        Timer.add(2, function() self.fixed = false end)
        self.prompt = nil
      end)
    end
  end

  if self.prompt then
    return self.prompt:keypressed( button )
  end
end

return HiddenDoorTrigger
