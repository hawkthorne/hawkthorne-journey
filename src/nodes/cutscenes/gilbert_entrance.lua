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

function Scene:runScript(script,depth)
    local current = gamestate.currentState()
    depth = depth or 1
    local line = script[depth][1]
    local action = script[depth][2]
    print(line,action)
    local size = #script
    if(depth==size) then
      self.dialog = dialog.new(line,function ()
        action()
        self.finished = true
        tween(2, current.darken, {0, 0, 0, 0}, 'outQuad')
      end)
      return self.dialog
    else
      self.dialog = dialog.new(line,function()
        action()
        self:runScript(script,depth+1)
      end)
      return self.dialog
    end
end

function Scene:start(player)
  --local cx, cy = 
  player = player or Player.factory()

  local origControls = player.controls
  local tempControls = Manualcontrols.new()
  
  player.controls = tempControls

  self.nodes.britta.opacity = 0
  self.nodes.buddy.invulnerable = true
  self.nodes.shirley.health = 2
  self.nodes.britta.health = 3
  self.nodes[player.character.name] = player
  
  player.health = player.max_health
  local current = gamestate.currentState()
  self.camera.tx = camera.x
  self.camera.ty = camera.y
  self.camera.sx = camera.scaleX
  self.camera.sy = camera.scaleY

  current.darken = {0, 0, 0, 0}

  tween(2, current.darken, {0, 0, 0, 130}, 'outQuad')

  script = {
    {"Oh crap. It's Buddy!",
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
    end},
    {"Well, well, well. Looks like someone's one step behind",
    function ()
            self:moveCharacter(840,y,self.nodes.pierce)
            self:moveCharacter(900,y,self.nodes.shirley)
            self.nodes.pierce.desireDirection = 'left'
    end},
    {"While you were shopping I gained enough levels to do this... ",
    function ()
            --self:moveCharacter(840,y,self.nodes.pierce)
            self:jumpCharacter(self.nodes.buddy)
            self:moveCharacter(1000,y,self.nodes.pierce)
            self:actionCharacter("attack",self.nodes.buddy)
            local node = require('nodes/projectiles/lightning')
            node.x = self.nodes.buddy.position.x
            node.y = self.nodes.buddy.position.y
            local lightning = Projectile.new(node, current.collider)
            lightning:throw(self.nodes.buddy)
            table.insert(current.nodes, lightning)
    end},
    {"he's throwing lightning",
    function ()
            self:keypressedCharacter('DOWN',self.nodes.pierce)
            tween(2, self.nodes.britta, {opacity=255}, 'outQuad')
            self.nodes.britta.doTracking = true
    end},
    {"...and I'm naked.",
    function ()
            self:moveCharacter(self.nodes.buddy.position.x+40,y,self.nodes.buddy)
            self.nodes.shirley.opacity = 255
            tween(2, self.nodes.shirley, {opacity=0}, 'outQuad')
            self:moveCharacter(1000,y,self.nodes.pierce)
            --TODO: add potion sprite
    end},
    {"Britta, drink that super strength potion you made.",
    function()
            self:moveCharacter(self.nodes.buddy.position.x-10,y,self.nodes.buddy)
            self:moveCharacter(400,y,self.nodes.britta)
    end},
    {"Right, right, right",
    function()
        local node = { x = self.nodes.britta.position.x, y = self.nodes.britta.position.y,
                        properties = {
                            sheet = 'images/potion.png',
                            height = 24, width = 24,
                          }
                        }
        local sprite = Sprite.new(node, collider)
        table.insert(current.nodes, sprite)

        local lightNode = require('nodes/projectiles/rainbowbeam')
        lightNode.x = self.nodes.buddy.position.x
        lightNode.y = self.nodes.buddy.position.y
        local lightning = Projectile.new(lightNode, current.collider)
        lightning:throw(self.nodes.buddy)
        table.insert(current.nodes, lightning)
    end},
    {"I thought I could count on Britta to not screw up drinking",
    function()
        self.nodes.britta.opacity = 255
        tween(2, self.nodes.britta, {opacity=0}, 'outQuad')
        self:moveCharacter(400,y,self.nodes.buddy)
    end},
    {"This'll be fun.",
    function()
        self.nodes.britta.doTracking = false
        self.nodes.jeff.doTracking = true
        table.remove(current.nodes,#current.nodes-1)
        self.nodes.buddy.character.state = 'holdjump'
    end},
    {"What the hell?",
    function()
        self.nodes.buddy.invulnerable = false
        self:actionCharacter("die",self.nodes.buddy)
    end},
    {"Here's hoping we can count on her to screw up making potions",
    function()
        self:jumpCharacter(self.nodes.troy)
    end},
    {"END",
    function()
        player.desiredX = nil
        player.controls = origControls
    end}
    
}
  
  self:runScript(script)

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
    Timer.add(0.4,function()
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

--teleport character to x,y
function Scene:teleportCharacter(x,y,char)
    char.position.x = x
    char.position.y = y
end

function Scene:moveCamera(x,y)
end

function Scene:tweenCamera(x,y)
end

--probably won't be implemented
function Scene:zoomCamera(factor)
end

return Scene
