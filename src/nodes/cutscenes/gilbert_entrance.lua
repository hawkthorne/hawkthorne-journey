local anim8 = require 'vendor/anim8'
local gamestate = require 'vendor/gamestate'
local tween = require 'vendor/tween'
local sound = require 'vendor/TEsound'
local Timer = require 'vendor/timer'
local Manualcontrols = require 'manualcontrols'
local Projectile = require 'nodes/projectile'

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
  player = player or Player.factory()
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

  self.dialog = dialog.new("Oh crap. It's Buddy!", function ()
    player.character.direction = 'left'
    self.nodes.pierce.desireDirection = 'left'
    self:moveCharacter(900,y,self.nodes.abed)
    --self:moveCharacter(850,y,self.nodes.britta)
    self:moveCharacter(850,y,self.nodes.pierce)
    self:moveCharacter(920,y,self.nodes.shirley)
    self:moveCharacter(860,y,self.nodes.troy)
    self:moveCharacter(800,y,self.nodes.annie)
    self:moveCharacter(620,y,self.nodes.jeff)
    self:moveCharacter(600,y,self.nodes.buddy)
    self.dialog = dialog.new("Well, well, well. Looks like someone is behind", function ()
      self:moveCharacter(840,y,self.nodes.pierce)
      self.nodes.pierce.desireDirection = 'left'
      self.dialog = dialog.new("While you were shopping I gained enough levels to do this... ", function ()
        --self:moveCharacter(840,y,self.nodes.pierce)
        self:jumpCharacter(self.nodes.buddy)
        self:actionCharacter("attack",self.nodes.buddy)

        local node = require('nodes/projectiles/lightning')
        node.x = self.nodes.buddy.position.x
        node.y = self.nodes.buddy.position.y + self.nodes.buddy.height/2
        local knife = Projectile.new(node, gamestate.currentState().collider)
        knife:throw(self.nodes.buddy)
        table.insert(gamestate.currentState().nodes, knife)

        self.dialog = dialog.new("he's throwing lightning", function ()
          self:actionCharacter("die",self.nodes.shirley)
          
          self.dialog = dialog.new("...and I lost my pants to a pair of 9s ", function ()
            --end level
            --sound.playMusic("level")
            self.finished = true
            tween(2, current.darken, {0, 0, 0, 0}, 'outQuad')
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
    char[action](char)
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
    --oignore the y for now
    if char.position.x < x then
        self:keypressedCharacter('RIGHT',char)
    else
        self:keypressedCharacter('LEFT',char)
    end
    char.desiredX = x
end

function Scene:moveCamera(x,y)
end

function Scene:tweenCamera(x,y)
end

--probably won't be implemented
function Scene:zoomCamera(factor)
end

return Scene
