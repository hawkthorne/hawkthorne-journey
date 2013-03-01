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
      end)
    else
      self.dialog = dialog.new(line,function()
        precondition()
        action()
        self:runScript(script,depth+1)
      end)
    end
    postcondition()
    return self.dialog
end

function Scene:start(player)
  --local cx, cy = 
  player = player or Player.factory()

  local origControls = player.controls
  local tempControls = Manualcontrols.new()
  
  player.controls = tempControls

  self.nodes.britta.opacity = 0
  self.nodes.britta.invulnerable= true
  self.nodes.buddy.invulnerable = true
  self.nodes.shirley.health = 2
  self.nodes.britta.health = 1
  self.nodes[player.character.name] = player
  
  player.health = player.max_health
  local current = gamestate.currentState()
  self.camera.tx = camera.x
  self.camera.ty = camera.y
  self.camera.sx = camera.scaleX
  self.camera.sy = camera.scaleY

  current.darken = {0, 0, 0, 0}

  tween(2, current.darken, {0, 0, 0, 0}, 'outQuad')

  script = {
    {line = "Oh crap. It's Buddy!",
    action = function()
        player.character.direction = 'left'
        self.nodes.pierce.desireDirection = 'left'
        self:moveCharacter(900,nil,self.nodes.abed)
        --self:moveCharacter(850,nil,self.nodes.britta)
        self:moveCharacter(850,nil,self.nodes.pierce)
        self:moveCharacter(920,nil,self.nodes.shirley)
        self:moveCharacter(900,nil,self.nodes.troy)
        self:moveCharacter(800,nil,self.nodes.annie)
        self:moveCharacter(620,nil,self.nodes.jeff)
        self:moveCharacter(600,nil,self.nodes.buddy)
    end},

    {line = "Well, well, well. Looks like someone's one step behind",
    precondition = function()
        self:teleportCharacter(900,nil,self.nodes.abed)
        self:teleportCharacter(850,nil,self.nodes.pierce)
        self:teleportCharacter(920,nil,self.nodes.shirley)
        self:teleportCharacter(900,nil,self.nodes.troy)
        self:teleportCharacter(800,nil,self.nodes.annie)
        self:teleportCharacter(620,nil,self.nodes.jeff)
        self:teleportCharacter(600,nil,self.nodes.buddy)
    end,
    action = function ()
        self:moveCharacter(840,nil,self.nodes.pierce)
        self:moveCharacter(900,nil,self.nodes.shirley)
        self.nodes.pierce.desireDirection = 'left'
    end},

    {line = "While you were shopping I gained enough levels to do this... ",
    precondition = function()
        self:teleportCharacter(840,nil,self.nodes.pierce)
        self:teleportCharacter(900,nil,self.nodes.shirley)
    end,
    action = function ()
        --self:moveCharacter(840,nil,self.nodes.pierce)
        self:jumpCharacter(self.nodes.buddy)
        self:moveCharacter(1000,nil,self.nodes.pierce)
        self:actionCharacter("attack",self.nodes.buddy)
        local node = require('nodes/projectiles/lightning')
        node.x = self.nodes.buddy.position.x
        node.y = self.nodes.buddy.position.y
        local lightning = Projectile.new(node, current.collider)
        lightning:throw(self.nodes.buddy)
        table.insert(current.nodes, lightning)
    end},

    {line = "he's throwing lightning",
    precondition = function()
        self:teleportCharacter(1000,nil,self.nodes.pierce)
        self.nodes.britta.invulnerable = false
    end,
    action = function ()
        --self:trackCharacter("troy")
        self:keypressedCharacter('DOWN',self.nodes.pierce)
        tween(2, self.nodes.britta, {opacity=255}, 'outQuad')
    end},

    {line = "...and I'm naked.",
   action = function ()
        self:moveCharacter(670,nil,self.nodes.buddy)
        self.nodes.shirley.opacity = 255
        tween(2, self.nodes.shirley, {opacity=0}, 'outQuad')
        --TODO: add potion sprite
    end},

    {line = "Britta, drink that super strength potion you made.",
    precondition = function()
        self:teleportCharacter(670,nil,self.nodes.buddy)
    end,
    action = function()
        self:trackCharacter("britta")
        --self:trackCharacter("jeff9)
        self:moveCharacter(660,nil,self.nodes.buddy)
        self:moveCharacter(400,nil,self.nodes.britta)
    end},

    {line = "Right, right, right",
    precondition = function()
        self:teleportCharacter(660,nil,self.nodes.buddy)
        self:teleportCharacter(400,nil,self.nodes.britta)
        self.nodes.buddy.character.direction = 'left'
    end,
    action = function()
        --self:trackCharacter("britta")
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

    {line = "I thought I could count on Britta to not screw up drinking",
    action = function()
        --self:trackCharacter("jeff")
        self.nodes.britta.opacity = 255
        tween(2, self.nodes.britta, {opacity=0}, 'outQuad')
        self:moveCharacter(400,nil,self.nodes.buddy)
        self:moveCharacter(550,nil,self.nodes.troy)
    end},

    {line = "This'll be fun.",
    precondition = function()
        if(math.abs(400-self.nodes.buddy.position.x)>40) then
            self:teleportCharacter(400,nil,self.nodes.buddy)
        end
    end,
    action = function()
        --self:trackCharacter("buddy")
        --local x, y = camera:target(center(self.nodes.jeff))
        --self:tweenCamera(x,y)
        table.remove(current.nodes,#current.nodes-1)
        self.nodes.buddy.character.state = 'holdjump'
    end},

    {line = "What the hell?",
    action = function()
        self:trackCharacter("jeff")
        self.nodes.buddy.invulnerable = false
        self:actionCharacter("die",self.nodes.buddy)
    end},

    {line = "Here's hoping we can count on her to screw up making potions",
    action = function()
        --self:trackCharacter("jeff")
        self:jumpCharacter(self.nodes.troy)
    end},

    {line = "END",
    action = function()
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

function Scene:jumpCharacter(char)
    self:keypressedCharacter('JUMP',char)
    Timer.add(0.4,function()
        self:keyreleasedCharacter('JUMP',char)
    end)
end

--calls char's function "action" with the optional arguments
function Scene:actionCharacter(action,char,...)
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

--probably won't be implemented
function Scene:zoomCamera(factor)
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

return Scene
