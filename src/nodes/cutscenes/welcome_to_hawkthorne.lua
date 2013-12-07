local anim8 = require 'vendor/anim8'
local gamestate = require 'vendor/gamestate'
local tween = require 'vendor/tween'
local sound = require 'vendor/TEsound'
local middle = require 'hawk/middleclass'

local camera = require 'camera'
local dialog = require 'dialog'

local Scene = {}
Scene.__index = Scene

local function nametable(layer)
  local names = {}
  for i,v in pairs(layer.objects) do
    names[v.name] = v
  end
  return names
end

local function center(node)
  return node.x + node.width / 2, node.y + node.height / 2
end

local Lightning = middle.class('Lightning')

function Lightning:initialize(x, y)
  self.image = love.graphics.newImage('images/cutscenes/lightning.png')
  local h = anim8.newGrid(48, 336, self.image:getWidth(), self.image:getHeight())
  self.animation = anim8.newAnimation('loop', h('1-6,1'), 0.025)
  self.position = {x=x, y=y}
  self.opacity = 0
end

function Lightning:draw()
  love.graphics.setColor(255, 255, 255, self.opacity)
  self.animation:draw(self.image, self.position.x, self.position.y)
end

function Lightning:update(dt)
  self.animation:update(dt)
end


function Scene.new(node, collider, layer)
  local scene = {}
  setmetatable(scene, Scene)
  scene.x = node.x
  scene.y = node.y
  scene.finised = false

  scene.head = love.graphics.newImage('images/cutscenes/cornelius_head.png')
  scene.ovalImg = love.graphics.newImage('images/cutscenes/corn_circles.png')
  scene.sparkle = love.graphics.newImage('images/cutscenes/cornelius_sparkles.png')

  scene.nodes = nametable(layer)
  scene.nodes.head.opacity = 0
  scene.nodes.oval.opacity = 0
  scene.sparkle_opacity = 0
  
  scene.sparkles = {}
  scene.sparkle_animations = {}

  scene.lightning = Lightning(scene.nodes.lightning.x, scene.nodes.lightning.y)
  
  for n in pairs(scene.nodes) do
    if n:match("sparkle") == "sparkle" then
        table.insert(scene.sparkles, n)
    end
  end 

  -- dummy camera to prevent tearing
  scene.camera = {
    tx = 0,
    ty = 0,
    sx = 1,
    sy = 1,
  }

  local g = anim8.newGrid(144, 192, scene.head:getWidth(), scene.head:getHeight())
  scene.talking = anim8.newAnimation('loop', g('1,1', '2,1', '3,1', '2,1', '1,1'), 0.15)
  local j = anim8.newGrid(192, 264, scene.ovalImg:getWidth(), scene.ovalImg:getHeight())
  scene.circle = anim8.newAnimation('once', j('1-6,1'), 0.15)
  scene.pulse = anim8.newAnimation('loop', j('5-6,1'), 0.7)
  local s = anim8.newGrid(24, 24, scene.sparkle:getWidth(), scene.sparkle:getHeight())
  
  for spark in pairs(scene.sparkles) do
    local anim = anim8.newAnimation('loop', s('1-4,1'), 0.22 + math.random() / 10)
    table.insert(scene.sparkle_animations, anim)
  end
  
  scene.oval = scene.circle
  
  return scene
end

function Scene:start(player)
  sound.playMusic("cornelius-appears")
  --local cx, cy = 

  local x, y = camera:target(center(self.nodes.head))
  local current = gamestate.currentState()
  self.camera.tx = camera.x
  self.camera.ty = camera.y
  self.camera.sx = camera.scaleX
  self.camera.sy = camera.scaleY

  self.fade = {0, 0, 0, 0}


  script = {
    "Piercinald, in 1980, you said that video games, not moist towelettes, were the business of the future.",
    "Today, moist towelettes are stocked in every supermarket, while arcade after arcade closes.",
    "Nevertheless, I designed this game to be played upon my death by you and whatever cabal of fruits, junkies, and sluts you call your friends.",
    "Only one player can win... the first to reach my throne inside Castle Hawkthorne. Their reward, Pierce, will be your inheritance.",
  "So you see, Pierce, turns out you were right. Video games are important. Ha Ha Ha ! WORST SON EVER!",
  }

  self.dialog = dialog.new("Welcome to Hawkthorne.", function()

  tween(3, self.camera, {tx=x, ty=y + 48}, 'outQuad', function()
  tween(0.1, self.lightning, {opacity=255}, 'outQuad', function()
  self.shake = true
  self.enter = true
  tween(1, self.lightning, {opacity=0}, 'outQuad')
  tween(1, self.fade, {0, 0, 200, 130}, 'outQuad')
  tween(1, self.nodes.oval, {opacity=255}, 'outQuad', function()
  tween(3, self.nodes.head, {opacity=255}, 'outQuad')
  tween(3, self, {sparkle_opacity=255}, 'outQuad')
  
  self.shake = false
  self.oval = self.pulse

  self.dialog = dialog.create(script)
  self.dialog:open(function()
  self.shake = true

  tween(3, self.nodes.head, {opacity=0}, 'outQuad')
  tween(3, self, {sparkle_opacity=0}, 'outQuad')
  tween(3, self.nodes.oval, {opacity=0}, 'outQuad', function()

  self.shake = false
  local px, py = current:cameraPosition()

  tween(2, self.fade, {0, 0, 0, 0}, 'outQuad')

  tween(3, self.camera, {tx=px, ty=py}, 'outQuad', function()
    sound.playMusic("forest-2")
    self.finished = true
  end)
  end)
  end)
  end)
  end)
  end)
  end)

end


function Scene:update(dt, player)
  --call setPosition manually to prevent tearing
  local shake = 0

  if self.shake then
    shake = (math.random() * 4) - 2
  end

  camera:setPosition(self.camera.tx + shake, self.camera.ty + shake)
  camera:setScale(self.camera.sx, self.camera.sy)

  self.talking:update(dt)
  for _, s in pairs(self.sparkle_animations) do
    s:update(dt)
  end
  if self.enter then
    self.lightning:update(dt)
    self.oval:update(dt)
  end

end

function Scene:draw(player)
  love.graphics.setColor(unpack(self.fade))
  love.graphics.rectangle('fill', camera.x, camera.y,
    love.graphics.getWidth(), love.graphics.getHeight())
  love.graphics.setColor(255, 255, 255, 255)
    

  -- Lightning
  self.lightning:draw()
 
  love.graphics.setColor(255, 255, 255, self.nodes.oval.opacity)
  self.oval:draw(self.ovalImg, self.nodes.oval.x, self.nodes.oval.y)
    
  love.graphics.setColor(255, 255, 255, self.nodes.head.opacity)
  self.talking:draw(self.head, self.nodes.head.x, self.nodes.head.y)
  love.graphics.setColor(255, 255, 255, 255)
  
  for i, s in pairs(self.sparkle_animations) do
    local spark = self.sparkles[i]
    love.graphics.setColor(255, 255, 255, self.sparkle_opacity)
    s:draw(self.sparkle, self.nodes[spark].x, self.nodes[spark].y)
    love.graphics.setColor(255, 255, 255, 255)
  end
  

  player:draw()

  local x, y = center(self.nodes.head)
end

function Scene:keypressed(button)
  if self.dialog then
    self.dialog:keypressed(button)
  end
  return true
end

return Scene
