local anim8 = require 'vendor/anim8'
local gamestate = require 'vendor/gamestate'
local timer = require 'vendor/timer'
local tween = require 'vendor/tween'
local machine = require 'datastructures/lsm/statemachine'

local camera = require 'camera'
local datastore = require 'datastore'

local Scene = {}

local KEY = 'gamesaves.1.cutscenes.welcome_to_hawkthorne'

local head = love.graphics.newImage('images/cornelius_head.png')
local g = anim8.newGrid(148, 195, head:getWidth(), head:getHeight())
local talking = anim8.newAnimation('loop', g('2,1', '3,1', '1,1'), 0.2)

local timeline = {
  opacity=0
}

Scene.__index = Scene

function Scene.new(node, collider)
  local scene = {}
  setmetatable(scene, Scene)
  scene.x = node.x
  scene.y = node.y

  -- Figure out how to "mix this in"
  scene.state = machine.create({
    initial = datastore.get(KEY, 'ready'),
    events = {
      {name = 'start', from = 'ready', to = 'playing'},
      {name = 'stop', from = 'playing', to = 'finished'},
  }})

  -- so much work
  scene.collider = collider
  scene.bb = collider:addRectangle(node.x, node.y, node.width, node.height)
  scene.bb.node = scene
  collider:setPassive(scene.bb)

  return scene
end

function Scene:start(player)
  self.state:start()

  local current = gamestate.currentState()
  current.trackPlayer = false

  player.controlState:inventory()

  local x, y = camera:bound(self.x - 40, self.y + 80)

  tween(3, camera, {x=math.floor(x), y=math.floor(y)}, 'outQuad', function()
  tween(3, timeline, {opacity=255}, 'outQuad', function()
  tween(3, timeline, {opacity=0}, 'outQuad', function()
  local px, py = current:cameraPosition()
  tween(3, camera, {x=px, y=py}, 'outQuad', function()
    player.controlState:standard()
    current.trackPlayer = true
    self.state:stop()
  end)
  end)
  end)
  end)

end


function Scene:update(dt, player)
  if not self.state:is('playing') then
    return
  end

  talking:update(dt)
end

function Scene:collide(node, dt, mtv_x, mtv_y)
  if node and node.character and self.state:can('start') then
    self:start(node)
  end
end

function Scene:draw()
  if not self.state:is('playing') then
    return
  end

  love.graphics.setColor(255, 255, 255, timeline.opacity)
  talking:draw(head, self.x + 24 + 148 / 2, self.y + 90)
  love.graphics.setColor(255, 255, 255, 255)
end

return Scene
