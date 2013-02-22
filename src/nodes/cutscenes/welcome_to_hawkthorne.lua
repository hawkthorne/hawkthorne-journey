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
local g = anim8.newGrid(148, 195, image:getWidth(), image:getHeight())
local talking = anim8.newAnimation('loop', g('2,1', '3,1', '1,1'), 0.2)

Scene.__index = Scene

function Scene.new(node, collider)
  local scene = {}
  setmetatable(scene, Scene)
  scene.x = node.x
  scene.y = node.y

  state.state = machine.create({
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

  camera:panTo(0, 0, 5)

  timer.add(3, function() 
    player.controlState:standard()
    current.trackPlayer = true
    self.state:stop()
  end)

end


function Scene:update(dt, player)
end

function Scene:collide(node, dt, mtv_x, mtv_y)
  if node and node.character and self.state:can('start') then
    self:start(node)
  end
end

function Scene:draw()
end

return Scene
