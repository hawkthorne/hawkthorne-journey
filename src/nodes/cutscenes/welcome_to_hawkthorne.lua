local anim8 = require 'vendor/anim8'
local gamestate = require 'vendor/gamestate'
local tween = require 'vendor/tween'

local camera = require 'camera'

local head = love.graphics.newImage('images/cornelius_head.png')
local Scene = {}

Scene.__index = Scene

function Scene.new(node, collider, layer)
  local scene = {}
  setmetatable(scene, Scene)
  scene.x = node.x
  scene.y = node.y
  scene.finised = false

  -- dummy camera to prevent tearing
  scene.camera = {
    x = 0,
    y = 0,
  }

  local g = anim8.newGrid(144, 192, head:getWidth(), head:getHeight())
  scene.talking = anim8.newAnimation('loop', g('2,1', '3,1', '1,1'), 0.2)

  scene.timeline = {
    opacity=0
  }

  return scene
end

function Scene:start(player)

  self.camera.x = camera.x
  self.camera.y = camera.y
  local x, y = camera:bound(self.x - 40, self.y + 80)
  local current = gamestate.currentState()

  tween(3, self.camera, {x=math.floor(x), y=math.floor(y)}, 'outQuad', function()
  tween(3, self.timeline, {opacity=255}, 'outQuad', function()
  tween(3, self.timeline, {opacity=0}, 'outQuad', function()
  local px, py = current:cameraPosition()
  tween(3, self.camera, {x=px, y=py}, 'outQuad', function()
    self.finished = true
  end)
  end)
  end)
  end)

end


function Scene:update(dt, player)
  --call setPosition manually to prevent tearing
  camera:setPosition(self.camera.x, self.camera.y)
  self.talking:update(dt)
end

function Scene:draw()
  love.graphics.setColor(255, 255, 255, self.timeline.opacity)
  self.talking:draw(head, self.x + 24 + 148 / 2, self.y + 90)
  love.graphics.setColor(255, 255, 255, 255)
end

return Scene
