local anim8 = require 'vendor/anim8'
local gamestate = require 'vendor/gamestate'
local tween = require 'vendor/tween'
local sound = require 'vendor/TEsound'
local Timer = require 'vendor/timer'
local Manualcontrols = require 'manualcontrols'
local Projectile = require 'nodes/projectile'
local Sprite = require 'nodes/sprite'

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
        plyr.controls = Manualcontrols.new()
        plyr.position = {x = v.x, y = v.y}
        names[v.name] = plyr
     else
        names[v.name] = v
    end
  end
  return names
end

local function center(node)
  return node.position.x + node.width / 2, node.position.y + node.height / 2
end


function Scene.new(node, collider, layer, level)
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

  inspect(level,2)
  scene.script = require("nodes/cutscenes/"..node.properties.cutscene).new(scene,Player.factory(),level)

  return scene
end

function Scene:runScript(script,depth,origControls)
    local current = gamestate.currentState()
    depth = depth or 1
    local line = script[depth]["line"]
    local action = script[depth]["action"]
    
    local function __NULL__() end
    local precondition = script[depth]["precondition"] or __NULL__
    local postcondition = script[depth]["postcondition"] or __NULL__

    print(line,action)
    local size = #script
    --precondition()
    if(depth==size) then
      self.dialog = dialog.new(line,function ()
        precondition()
        action()
        self.finished = true
        tween(2, current.darken, {0, 0, 0, 0}, 'outQuad')
        player = player or Player.factory()
        player.opacity=255
        player.desiredX = nil
        self.camera.sx = 1
        self.camera.sy = 1

      end)
    else
      self.dialog = dialog.new(line,function()
        precondition()
        action()
        self:runScript(script,depth+1,origControls)
      end)
    end
    postcondition()
    return self.dialog
end

function Scene:start(player)
  --local cx, cy = 
  player = player or Player.factory()
  player.opacity = 255

  tween(2, player,{opacity=0}, 'outQuad')
  self.nodes.britta.opacity = 0
  self.nodes.britta.invulnerable= true
  self.nodes.buddy.invulnerable = true
  self.nodes.shirley.health = 2
  self.nodes.britta.health = 1
  self.nodes[player.character.name].character.costume = player.character.costume
  
  player.health = player.max_health
  local current = gamestate.currentState()
  self.camera.tx = camera.x
  self.camera.ty = camera.y
  self.camera.sx = camera.scaleX
  self.camera.sy = camera.scaleY

  current.darken = {0, 0, 0, 0}

  tween(2, current.darken, {0, 0, 0, 0}, 'outQuad')

  self:runScript(self.script,nil,origControls)

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

--makes a manually-controlled character jump
function Scene:jumpCharacter(char)
    self:keypressedCharacter('JUMP',char)
    Timer.add(0.4,function()
        self:keyreleasedCharacter('JUMP',char)
    end)
end

--calls char's function "action" with the optional arguments
function Scene:actionCharacter(action,char,...)
    char[action](char,...)
end

function Scene:keypressedCharacter(button,char)
    char.controls:press(button)
    char:keypressed(button)
end
function Scene:keyreleasedCharacter(button,char)
    char.controls:release(button)
    char:keyreleased(button)
end

--walk character as close as possible to x,y
function Scene:moveCharacter(x,y,char)
    --ignore the y for now
    if char.position.x < x then
        self:keypressedCharacter('RIGHT',char)
    else
        self:keypressedCharacter('LEFT',char)
    end
    char.desiredX = x
end

--teleport character to x,y
function Scene:teleportCharacter(x,y,char)
    x = x or char.position.x
    y = y or char.position.y
    char.position.x = math.abs(x-char.position.x) < 40 and char.position.x  or x
    char.position.y = math.abs(y-char.position.y) < 40 and char.position.y  or y
    char.position.x = x
    char.position.y = y
end

function Scene:moveCamera(x,y)
  self:trackCharacter(nil)
  self.camera.tx = x
  self.camera.ty = y
end


function Scene:tweenCamera(x,y)
  self:trackCharacter(nil)
  tween(2, self.camera, {tx = x or self.camera.tx, ty = y or self.camera.ty}, 'outQuad')
end

--FIXME: modify zoom at the end of script has poor behaviour
function Scene:zoomCamera(factor)
    self.camera.sx = self.camera.sx * factor
    self.camera.sy = self.camera.sy * factor
end

local last_tracked = nil
function Scene:trackCharacter(char)
    if last_tracked then
        self.nodes[last_tracked].doTracking = false
    end
    if char then
        self.nodes[char].doTracking = true
    end
    last_tracked = char
end

--TODO: call with postconditions rather than within the subclass
function Scene:endScene()
end

return Scene
