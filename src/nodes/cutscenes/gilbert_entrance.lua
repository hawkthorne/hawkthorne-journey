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
  return node.position.x + node.width / 2, node.position.y + node.height / 2
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

function Scene:runScriptAndActions(script,actions,depth)
    local current = gamestate.currentState()
    depth = depth or 1
    assert(#script==#actions)
    local size = #actions
    if(depth==size) then
      self.dialog = dialog.new(script[depth],function ()
        actions[depth]()
        self.finished = true
        tween(2, current.darken, {0, 0, 0, 0}, 'outQuad')
      end)
      return self.dialog
    else
      self.dialog = dialog.new(script[depth],function()
        actions[depth]()
        self:runScriptAndActions(script,actions,depth+1)
      end)
      return self.dialog
    end
end

function Scene:start(player)
  --local cx, cy = 
  player = player or Player.factory()
  player.health = player.max_health
  local current = gamestate.currentState()
  self.camera.tx = camera.x
  self.camera.ty = camera.y
  self.camera.sx = camera.scaleX
  self.camera.sy = camera.scaleY

  current.darken = {0, 0, 0, 0}

  tween(2, current.darken, {0, 0, 0, 130}, 'outQuad')

  self.nodes.britta.opacity = 0

  script = {
    {"Oh crap. It's Buddy!"},
    {"Well, well, well. Looks like someone's one step behind"},
    {"While you were shopping I gained enough levels to do this... "},
    {"he's throwing lightning"},
    {"...and I'm naked."},
    {"...Quick Britta, drink your strength potion."},
  }

  actions = {
    function()
        player.character.direction = 'left'
        self.nodes.pierce.desireDirection = 'left'
        self:moveCharacter(900,y,self.nodes.abed)
        --self:moveCharacter(850,y,self.nodes.britta)
        self:moveCharacter(850,y,self.nodes.pierce)
        self:moveCharacter(920,y,self.nodes.shirley)
        self:moveCharacter(self.nodes.troy.position.x-5,y,self.nodes.troy)
        self:moveCharacter(800,y,self.nodes.annie)
        self:moveCharacter(620,y,self.nodes.jeff)
        self:moveCharacter(600,y,self.nodes.buddy)
    end,
    function ()
            self:moveCharacter(840,y,self.nodes.pierce)
            self:moveCharacter(900,y,self.nodes.shirley)
            self.nodes.pierce.desireDirection = 'left'
    end,
    function ()
            --self:moveCharacter(840,y,self.nodes.pierce)
            self:jumpCharacter(self.nodes.buddy)
            self:moveCharacter(1000,y,self.nodes.pierce)
            self:actionCharacter("attack",self.nodes.buddy)
            local node = require('nodes/projectiles/lightning')
            node.x = self.nodes.buddy.position.x
            node.y = self.nodes.buddy.position.y
            local lightning = Projectile.new(node, gamestate.currentState().collider)
            lightning:throw(self.nodes.buddy)
            table.insert(current.nodes, lightning)
    end,
    function ()
            self:keypressedCharacter('DOWN',self.nodes.pierce)
            self:actionCharacter("die",self.nodes.shirley)
            tween(2, self.nodes.britta, {opacity=255}, 'outQuad')
            self.nodes.britta.doTracking = true
    end,
    function ()
            self:moveCharacter(400,y,self.nodes.britta)
            self:jumpCharacter(self.nodes.buddy)
            self:moveCharacter(1000,y,self.nodes.pierce)
            --TODO: add potion sprite
    end,
    function()
    end,
}
  
  self:runScriptAndActions(script,actions)

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
    if not v.isInvisible then
        v:draw()
    end
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
    --ignore the y for now
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
