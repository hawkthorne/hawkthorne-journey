-----------------------------------------------
-- weapon.lua
-- Represents a generic weapon a player can wield or pick up
-- I think there should be only 2 types of weapons:
---- the only action that should play once is the animation for wielding your weapon
-- Created by NimbusBP1729
-----------------------------------------------
local sound = require 'vendor/TEsound'
local anim8 = require 'vendor/anim8'
local controls = require 'controls'
local utils = require 'utils'
local game = require 'game'

local Weapon = {}
Weapon.__index = Weapon
Weapon.isWeapon = true

function Weapon.new(node, collider, plyr, weaponItem)
    local weapon = {}
    setmetatable(weapon, Weapon)
    
    weapon.type = node.properties.nodeType

    local props = require( 'nodes/weapons/' .. weapon.type )

    weapon.item = weaponItem

    weapon:setPlayer(plyr)
    
    weapon.foreground = node.properties.foreground
    weapon.position = {x = node.x, y = node.y}
    weapon.velocity = {x = node.properties.velocityX, y = node.properties.velocityY}

    --position that the hand should be placed with respect to any frame
    weapon.hand_x = props.hand_x
    weapon.hand_y = props.hand_y

    --setting up the sheet
    local rowAmt = props.rowAmt
    local colAmt = props.colAmt
    weapon.frameWidth = props.frameWidth
    weapon.frameHeight = props.frameHeight
    weapon.sheetWidth = weapon.frameWidth*colAmt
    weapon.sheetHeight = weapon.frameHeight*rowAmt
    weapon.width = props.width or 10
    weapon.height = props.height or 10
    weapon.sheet = props.sheet

    weapon.wield_rate = props.animations.wield[3]

    local g = anim8.newGrid(weapon.frameWidth, weapon.frameHeight,
            weapon.sheetWidth, weapon.sheetHeight)
    weapon.defaultAnimation = anim8.newAnimation(
                props.animations.default[1],
                g(unpack(props.animations.default[2])),
                props.animations.default[3])
    weapon.wieldAnimation = anim8.newAnimation(
                props.animations.wield[1],
                g(unpack(props.animations.wield[2])),
                props.animations.wield[3])

    weapon.animation = weapon.defaultAnimation
    
    weapon.damage = node.properties.damage or props.damage or 1
    weapon.dead = false

    --create the bounding box
    weapon:initializeBoundingBox(collider)

    --audio clip when weapon is put away
    weapon.unuseAudioClip = node.properties.unuseAudioClip or 
                            props.unuseAudioClip or 
                            'sword_sheathed'
    
    --audio clip when weapon hits something
    weapon.hitAudioClip = node.properties.hitAudioClip or 
                            props.hitAudioClip or 
                            'weapon_hit'

    --audio clip when weapon swing through air
    weapon.swingAudioClip = node.properties.swingAudioClip or 
                            props.swingAudioClip or 
                            nil
    
    weapon.wielding = false
    weapon.action = 'wieldaction'
    weapon.dropping = false
    return weapon
end

---
-- Draws the weapon to the screen
-- @return nil
function Weapon:draw()
    if self.dead then return end
    
    local scalex = 1
    if self.player then
        if self.player.direction=='left' then
            scalex = -1
        end
    end

    local animation = self.animation
    self.animation:draw(self.sheet, math.floor(self.position.x), self.position.y, 0, scalex, 1)
end

---
-- Called when the weapon begins colliding with another node
-- @return nil
function Weapon:collide(node, dt, mtv_x, mtv_y)
    if not node then return end    
    if self.dead then return end
    if node.isPlayer then return end

    if self.dropping and (node.isFloor or node.floorspace or node.isPlatform) then
        self.dropping = false
    end
    
    
    if node.die then
        node:die(self.damage)
    end
    
    if self.hitAudioClip and node.die then
        sound.playSfx(self.hitAudioClip)
    end

    --handles code for burning an object
    if self.isTorch and node.burn then
        node:burn(self.position.x,self.position.y)
    end
end

function Weapon:setPlayer(plyr)
    if plyr.isPlayer then
        self.player = plyr
    else
        self.player = nil
    end
end

function Weapon:initializeBoundingBox(collider)
    local boxTopLeft = {x = self.position.x,
                        y = self.position.y}
    local boxWidth = self.width
    local boxHeight = self.height

    --update the collider using the bounding box
    self.bb = collider:addRectangle(boxTopLeft.x,boxTopLeft.y,boxWidth,boxHeight)
    self.bb.node = self
    self.collider = collider
    
    if self.player then
        self.collider:setPassive(self.bb)
    else
        self.collider:setActive(self.bb)
    end
end

---
-- Called when the weapon finishes colliding with another node
-- @return nil
function Weapon:collide_end(node, dt)
end

---
-- Called when the weapon is returned to the inventory
function Weapon:unuse(mode)
    self.dead = true
    self.collider:setGhost(self.bb)
    if not self.isRangeWeapon then
        self.item.quantity = 1
    end
    self.player.inventory:addItem(self.item)
    self.player.wielding = false
    self.player.currently_held = nil
    self.player:setSpriteStates('default')
    
    if mode=="sound_off" then 
        return
    else
        sound.playSfx(self.unuseAudioClip)
    end
end

--default update method
--overload this in the specific weapon if this isn't well-suited for your weapon
function Weapon:update(dt)
    if self.dead then return end
    
    --the weapon is in the level unclaimed
    if not self.player then
        
        if self.dropping then
            self.position = {x = self.position.x + self.velocity.x*dt,
                            y = self.position.y + self.velocity.y*dt}
            self.velocity = {x = self.velocity.x*0.1*dt,
                            y = self.velocity.y + game.gravity*dt}
            self.bb:moveTo(self.position.x,self.position.y)
        end
        return
    end

    --the weapon is being used by a plater
    local player = self.player
    local plyrOffset = player.width/2
    
    if not self.position or not self.position.x or not player.position or not player.position.x then return end
    
    if self.player.direction == "right" then
        self.position.x = math.floor(player.position.x) + (plyrOffset-self.hand_x) +player.offset_hand_left[1]
        self.position.y = math.floor(player.position.y) + (-self.hand_y) + player.offset_hand_left[2] 
    else
        self.position.x = math.floor(player.position.x) + (plyrOffset+self.hand_x) +player.offset_hand_right[1]
        self.position.y = math.floor(player.position.y) + (-self.hand_y) + player.offset_hand_right[2] 
    end
    if player.offset_hand_right[1] == 0 or player.offset_hand_left[1] == 0 then
        print(string.format("Need hand offset for %dx%d", player.frame[1], player.frame[2]))
    end

    if self.player.direction == "right" then
        self.bb:moveTo(player.position.x+player.width/2+self.width/2,
                        self.position.y+self.height/2)
    else
        self.bb:moveTo(player.position.x+player.width/2-self.width/2,
                        self.position.y+self.height/2)
    end

    if self.wielding and self.animation.status == "finished" then
        self.collider:setPassive(self.bb)
        self.wielding = false
        self.player.wielding = false
        self.animation = self.defaultAnimation
    end

    self.animation:update(dt)
end

function Weapon:keypressed( button, player)
    if self.player then return end

    if button == 'UP' then
        --the following invokes the constructor of the specific item's class
        local Item = require ('items/'..self.type..'Item')
        local item = Item.new(itemNode)
        if player.inventory:addItem(item) then
            self.collider:setGhost(self.bb)
            self.dead = true
            if not player.currently_held then
                item:use(player)
            end
        end
    end
end

--handles a weapon being activated
function Weapon:wield()
    self.collider:setActive(self.bb)

    if not self.wielding then
        local h = anim8.newGrid(self.frameWidth,self.frameHeight,self.sheetWidth,self.sheetHeight)
        local g = anim8.newGrid(48, 48, self.player.sheet:getWidth(), 
        self.player.sheet:getHeight())

        self.animation = self.wieldAnimation
        self.animation:gotoFrame(1)
        self.animation:resume()
        if self.player.direction == 'right' then
            self.player.animations[self.action]['right'] = anim8.newAnimation('loop', g('6,7','9,7','3,7','6,7'), self.wield_rate)
        else
            self.player.animations[self.action]['left'] = anim8.newAnimation('loop', g('6,8','9,8','3,8','6,8'), self.wield_rate)
        end

    end
    self.player.wielding = true
    self.wielding = true
    if self.swingAudioClip then
        sound.playSfx( self.swingAudioClip )
    end
end

-- handles weapon being dropped in the real world
function Weapon:drop()
    self.dropping = true
    self.collider:setActive(self.bb)
    self.velocity = {x=self.player.velocity.x,
                     y=self.player.velocity.y,
    }
    self.player:setSpriteStates('default')
    self.player = nil
end

return Weapon