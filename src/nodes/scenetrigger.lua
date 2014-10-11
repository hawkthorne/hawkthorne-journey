local middle = require 'hawk/middleclass'
local machine = require 'hawk/statemachine'

local app = require 'app'

local anim8 = require 'vendor/anim8'
local gamestate = require 'vendor/gamestate'
local timer = require 'vendor/timer'
local tween = require 'vendor/tween'

local game = require 'game'
local camera = require 'camera'

local NAMESPACE = 'cuttriggers.'

local timeline = {
  opacity=0
}


local SceneTrigger = middle.class('SceneTrigger')

SceneTrigger:include(machine.mixin({
  initial = 'ready',
  events = {
    {name = 'start', from = 'ready', to = 'playing'},
    {name = 'stop', from = 'playing', to = 'finished'},
  }
}))

function SceneTrigger:initialize(node, collider, layer)
  assert(node.properties.cutscene, "A cutscene to trigger is required")
  self.isTrigger = true --eventually replace me
  self.x = node.x
  self.y = node.y
  self.db = app.gamesaves:active()
  self.key = NAMESPACE .. node.properties.cutscene

  if self.db:get(self.key, false) then --already seen
    return
  end

  local scene = require('nodes/cutscenes/' .. node.properties.cutscene)
  self.scene = scene.new(node, collider, layer)

  -- Figure out how to "mix this in"
  -- so much work
  self.collider = collider
  self.bb = collider:addRectangle(node.x, node.y, node.width, node.height)
  self.bb.node = self
  collider:setPassive(self.bb)
end

function SceneTrigger:update(dt, player)
  if not self:is('playing') then
    return
  end
  self.scene:update(dt, player)
end

function SceneTrigger:keypressed(button)
  if not self:is('playing') then
    return false
  end
  return self.scene:keypressed(button)
end

function SceneTrigger:collide(node, dt, mtv_x, mtv_y)
  if node and node.character and self:can('start') then
    local current = gamestate.currentState()

    current.scene = self

    self:start()
    current.trackPlayer = false
    node.controlState:inventory()
    node.velocity.x = math.min(node.velocity.x,game.max_x)
    self.scene:start()
  end
end

function SceneTrigger:draw(player)
  if not self:is('playing') then
    return
  end

  self.scene:draw(player)

  if self.scene.finished then
    local current = gamestate.currentState()

    self:stop()
    current.player.controlState:standard()
    current.trackPlayer = true
    current.scene = nil
    self.db:set(self.key, true)
  end
end

return SceneTrigger
