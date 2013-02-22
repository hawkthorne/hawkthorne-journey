local timer = require 'vendor/timer'
local tween = require 'vendor/tween'
local gamestate = require 'vendor/gamestate'

local camera = require 'camera'
local datastore = require 'datastore'

local Scene = {}

local KEY = 'gamesaves.1.cutscenes.welcome_to_hawkthorne'

Scene.__index = Scene

function Scene.new(node, collider)
  local scene = {}
  setmetatable(scene, Scene)
  scene.seen = datastore.get(KEY, false)

  -- so much work
  scene.collider = collider
  scene.bb = collider:addRectangle(node.x, node.y, node.width, node.height)
  scene.bb.node = scene
  collider:setPassive(scene.bb)

  return scene
end

function Scene:start(player)
  self.seen = true

  local current = gamestate.currentState()
  current.trackPlayer = false

  player.controlState:inventory()

  camera:panTo(0, 0, 5)

  timer.add(3, function() 
    player.controlState:standard()
    current.trackPlayer = true
  end)

end


function Scene:update(dt, player)
end

function Scene:collide(node, dt, mtv_x, mtv_y)
  if self.seen then
    return
  end

  if node and node.character then
    self:start(node)
  end
end

function Scene:draw()
end

return Scene
