-----------------------------------------------
-- Represents a singleBomb that a player has thrown
-- Created by HazardousPeach
-----------------------------------------------
local anim8 = require 'vendor/anim8'
local Weapon = require 'nodes/weapon'
local RangeWeapon = require 'nodes/rangeWeapon'
local sound = require 'vendor/TEsound'
local Global = require 'global'
local Baseball = require 'nodes/baseball'
local GS = require 'vendor/gamestate'
local game = require 'game'
local window = require 'window'
local Projectile = require 'nodes/projectile'
-----------------------------------------------
-- bombs.lua
-- Represents a set of bombs that a player can throw
-- Created by HazardousPeach
-----------------------------------------------
local SingleBomb = {}
--set behavior of a single bomb on collision


local Bombs = {}
Bombs.__index = Bombs
Bombs.bomb = true

--
-- Creates a new battle bombs object
-- @return the battle bombs object created
function Bombs.new(node, collider, plyr, bombsItem)
    local bombs = {}
    setmetatable(bombs, Bombs)
    --subclass RangeWeapon methods and set defaults if not populated
    bombs = Global.inherits(bombs,RangeWeapon)

    --subclass Weapon methods and set defaults if not populated
    bombs = Global.inherits(bombs,Weapon)


    --populate data from the bombsItem
    bombs.item = bombsItem

    bombs.foreground = node.properties.foreground
    bombs.position = {x = node.x, y = node.y}
    bombs.velocity = {x = node.properties.velocityX, y = node.properties.velocityY}

    --position that the hand should be placed with respect to any frame

    bombs.hand_x = 20
    bombs.hand_y = 26

    --setting up the sheet
    local rowAmt = 1
    local colAmt = 5
    bombs.frameWidth = 40
    bombs.frameHeight = 40
    bombs.sheetWidth = bombs.frameWidth*colAmt
    bombs.sheetHeight = bombs.frameHeight*rowAmt
    bombs.width = bombs.frameWidth
    bombs.height = bombs.frameHeight
    bombs.sheet = love.graphics.newImage('images/bomb_action.png')
    bombs.h = anim8.newGrid( bombs.frameWidth, bombs.frameHeight, bombs.sheetWidth, bombs.sheetHeight)

    bombs.wield_rate = 0.09

    --play the sheet
    bombs.animation = bombs:defaultAnimation()
    bombs.wielding = false
    bombs.action = 'wieldaction'

    --create the bounding box
    local boxTopLeft = {x = bombs.position.x,
                        y = bombs.position.y}
    local boxWidth = bombs.width
    local boxHeight = bombs.height

    --update the collider using the bounding box
    bombs.bb = collider:addRectangle(boxTopLeft.x,boxTopLeft.y,boxWidth,boxHeight)
    bombs.bb.node = bombs
    bombs.collider = collider
    bombs.collider:setPassive(bombs.bb)

    bombs.damage = 4
    bombs.dead = false
    bombs.player = plyr

    --set audioclips played by Weapon
    --audio clip when weapon is put away
    --bombs.unuseAudioClip = 'sword_sheathed'

    --audio clip when weapon hits something
    bombs.hitAudioClip = 'bombs_hit'

    --audio clip when weapon swing through air
    --bombs.swingAudioClip = 'fire_thrown'    

    --temporary until persistence. limits bombs creation
    bombs.singleton = bombs

    return bombs
end

--creates and launches a new individual range weapon 
-- e.g an arrow if this class represents bows and arrows
function Bombs:createNewProjectile()
--node requires:
-- an x and y coordinate,
-- a width and height, 
-- a velocityX and velocityY,
-- properties.sheet
-- properties.animationGrid
-- properties.defaultAnimation

    local h = self.h
    local sheet = self.sheet
    --return SingleBomb.new(self,self.collider)

    local bombNode = {x=self.player.position.x, y=self.player.position.y,
                    width = 40, height = 30}
    bombNode.properties = {animationGrid = h,
                       defaultAnimation = anim8.newAnimation('loop', h('1,1','2,1','3,1'), 0.09),
                       endAnimation = anim8.newAnimation('once', h('4,1','5,1'), 0.09),
                       sheet = sheet,
                       bounceFactor = 0.5,
                       objectFriction = 0.8, --effect of floor on velocity.x
                       velocityX = 500, velocityY=-50}
    local bomb = Projectile.new(bombNode,self.collider,GS.currentState().map)
    bomb:throw(self.player)

    return bomb
end

--plays when a ranged weapon is held
--e.g. if this class is bow and arrows this draws the bow
function Bombs:defaultAnimation()
    if not self.defaultAnim then
        local h =self.h
        self.defaultAnim = anim8.newAnimation('loop', h('1,1','2,1','3,1'), 0.09)
    end
    return self.defaultAnim
end

--plays when a ranged weapon is thrown
--e.g. if this class is bow and arrows this draws the bow when being pulled back
function Bombs:wieldAnimation()
     local h = self.h
     self.animation = anim8.newAnimation('once', h('1,1','2,1'),0.09)
end

return Bombs