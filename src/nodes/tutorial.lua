local anim8 = require 'vendor/anim8'
local app = require 'app'
local controls = require('inputcontroller').get()
local Dialog = require 'dialog'
local utils = require 'utils'

local Tutorial = {}
Tutorial.__index = Tutorial
-- Nodes with 'isInteractive' are nodes which the player can interact with, but not pick up in any way
Tutorial.isInteractive = true

function Tutorial.new(node, collider)
  local tutorial = {}
  setmetatable(tutorial, Tutorial)

  tutorial.instructions = require ("tutcontrols")

  tutorial.bb = collider:addRectangle(node.x, node.y, node.width, node.height)
  tutorial.bb.node = tutorial
  tutorial.info = tutorial.instructions[node.properties.type] or "No instructions available." 
  tutorial.dt = math.random()

  tutorial.x = node.x
  tutorial.y = node.y
  tutorial.height = 24
  tutorial.width = 24
  tutorial.position = { x = node.x, y = node.y }

  tutorial.sprite = love.graphics.newImage('images/info/qmark.png')
  tutorial.speed = node.properties.speed and tonumber(node.properties.speed) or 0.20

  local g = anim8.newGrid(tonumber(node.width), tonumber(node.height),
                                    tutorial.sprite:getWidth(), tutorial.sprite:getHeight())

  tutorial.animation = anim8.newAnimation( 'loop', g('1-8,1'), tutorial.speed )


  collider:setPassive(tutorial.bb)

  tutorial.current = nil

  return tutorial
end

function Tutorial:update(dt, player)
  self.dt = self.dt + dt

  if self.animation then
    self.animation:update(dt)
  end
end

function Tutorial:draw()
   self.animation:draw(self.sprite, self.x, self.y)
end

function Tutorial:keypressed( button, player )

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

if app.config.tutorial then
  return Tutorial
else
  return nil
end
