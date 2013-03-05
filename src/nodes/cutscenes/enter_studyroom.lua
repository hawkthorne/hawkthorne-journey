local anim8 = require 'vendor/anim8'
local gamestate = require 'vendor/gamestate'
local tween = require 'vendor/tween'
local sound = require 'vendor/TEsound'

local camera = require 'camera'
local dialog = require 'dialog'
local Player = require 'player'

local Scene = {}

Scene.__index = Scene

local function nametable(layer, collider)
  local names = {}
  for i,v in pairs(layer.objects) do
    if v.type == "character" then
        local plyr = Player.factory(collider, v.name)
        plyr.position = {x = v.x, y = v.y}
        names[v.name] = plyr
    else
        names[v.name] = v
    end
  end
  return names
end

local function center(node)
  return node.x + node.width / 2, node.y + node.height / 2
end


function Scene.new(node, collider, layer)
  local scene = {}
  setmetatable(scene, Scene)
  scene.x = node.x
  scene.y = node.y
  scene.finised = false
  
  scene.nodes = nametable(layer, collider)
  inspect(scene.nodes,2)
  scene.opacity = node.properties.opacity or 255

  -- dummy camera to prevent tearing
  scene.camera = {
    tx = 0,
    ty = 0,
    sx = 1,
    sy = 1,
  }

  return scene
end

function Scene:start(player)
  --local cx, cy = 

  local current = gamestate.currentState()
  self.camera.tx = camera.x
  self.camera.ty = camera.y
  self.camera.sx = camera.scaleX
  self.camera.sy = camera.scaleY

  current.darken = {0, 0, 0, 0}

  tween(2, current.darken, {0, 0, 200, 130}, 'outQuad')

  script = {
    "Piercinald, in 1980, you said that video games, not moist towelettes, were the business of the future.",
    "Today, moist towelettes are stocked in every supermarket, while arcade after arcade closes.",
    "Nevertheless, I designed this game to be played upon my death by you and whatever cabal of fruits, junkies, and sluts you call your friends.",
    "Only one player can win... the first to reach my throne inside Castle Hawkthorne. Their reward, Pierce, will be your inheritance.",
  "So you see, Pierce, turns out you were right. Video games are important. Ha Ha Ha ! WORST SON EVER!",
  }

  self.dialog = dialog.new("Welcome to Hawkthorne.", function()

      tween(3, self.nodes.jeff, {opacity=255}, 'outQuad', function()

        self.dialog = dialog.create(script)
        self.dialog:open(function()

          tween(3, self.nodes.jeff, {opacity=0}, 'outQuad', function()
            local px, py = current:cameraPosition()

            tween(2, current.darken, {0, 0, 0, 0}, 'outQuad')

            tween(3, self.camera, {tx=px, ty=py}, 'outQuad', function()
              --sound.playMusic("level")
              self.finished = true
            end)
          end)
        end)
      end)
  end)

end


function Scene:update(dt, player)
  --call setPosition manually to prevent tearing
  camera:setPosition(self.camera.tx, self.camera.ty)
  camera:setScale(self.camera.sx, self.camera.sy)
  for k,v in pairs(self.nodes) do
    if v.isPlayer then
      v.boundary = player.boundary
    end
    v:update(dt)
  end

  if self.dialog then
    self.dialog:update(dt)
  end
end

function Scene:draw()
  love.graphics.setColor(255, 255, 255, self.opacity)
  for k,v in pairs(self.nodes) do
    v:draw()
  end
  --self.nodes.jeff:draw()
  love.graphics.setColor(255, 255, 255, 255)

  if self.dialog then
    self.dialog:draw()
  end

end

function Scene:keypressed(button)
  if self.dialog then
    self.dialog:keypressed(button)
  end
  return true
end

function Scene:talkCharacter(char,message)
end

function Scene:jumpCharacter(char)
    self:keypressedCharacter('JUMP',char)
    Timer.add(0.2,function()
        self:keyreleasedCharacter('JUMP',char)
    end)
end

function Scene:actionCharacter(action,char)
    self.nodes[char][action]()
end

function Scene:keypressedCharacter(button,char)
    self.nodes[char]:keypressed(button)
end

function Scene:keyreleasedCharacter(button,char)
    self.nodes[char]:keyreleased(button)
end

function Scene:moveCamera(x,y)
end

function Scene:tweenCamera(x,y)
end

--probably won't be implemented
function Scene:zoomCamera(factor)
end

return Scene
