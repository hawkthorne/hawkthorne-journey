local store = require 'hawk/store'

local anim8 = require 'vendor/anim8'
local gamestate = require 'vendor/gamestate'
local timer = require 'vendor/timer'
local tween = require 'vendor/tween'
local machine = require 'datastructures/lsm/statemachine'

local game = require 'game'
local camera = require 'camera'

local KEY = 'gamesaves.1.cuttriggers.'

local head = love.graphics.newImage('images/cornelius_head.png')
local g = anim8.newGrid(144, 192, head:getWidth(), head:getHeight())
local talking = anim8.newAnimation('loop', g('2,1', '3,1', '1,1'), 0.2)

local timeline = {
  opacity=0
}

local db = store.load('gamesave1-1')

local SceneTrigger = {}

SceneTrigger.__index = SceneTrigger
SceneTrigger.isTrigger = true

function SceneTrigger.new(node, collider, layer, level)
  local trigger = {}
  setmetatable(trigger, SceneTrigger)
  trigger.x = node.x
  trigger.y = node.y
  trigger.width = node.width
  trigger.height = node.height

  if db:get(KEY .. node.properties.cutscene, false) then --already seen
    return trigger
  end

  local scene = require('nodes/cutscenes/'..node.properties.cutscene)
  if scene.isScript then
    scene = require('nodes/scene')
  end
  trigger.scene = scene.new(node, collider, layer, level)

  -- Figure out how to "mix this in"
  trigger.state = machine.create({
    initial = db:get(KEY, 'ready'),
    events = {
      {name = 'start', from = 'ready', to = 'playing'},
      {name = 'stop', from = 'playing', to = 'finished'},
  }})

  -- so much work
  trigger.collider = collider
  trigger.bb = collider:addRectangle(node.x, node.y, node.width, node.height)
  trigger.bb.node = trigger
  collider:setPassive(trigger.bb)

  return trigger
end


function SceneTrigger:update(dt, player)
  if not self.state:is('playing') then
    return
  end
  self.scene:update(dt, player)
end


function SceneTrigger:keypressed(button)
  if not self.state:is('playing') then
    return false
  end
  return self.scene:keypressed(button)
end


function SceneTrigger:collide(node, dt, mtv_x, mtv_y)
  if node and node.character and self.state:can('start') then
    local current = gamestate.currentState()

    current.scene = self

    self.state:start()
    current.trackPlayer = false
    node.controlState:inventory()
    node.velocity.x = math.min(node.velocity.x,game.max_x)
    self.scene:start()
  end
end

function SceneTrigger:draw(player)
  if not self.state:is('playing') then
    return
  end

  self.scene:draw(player)

  if self.scene.finished then
    local current = gamestate.currentState()

    self.state:stop()
    current.player.controlState:standard()
    current.trackPlayer = true
    current.scene = nil
  end
end

return SceneTrigger

