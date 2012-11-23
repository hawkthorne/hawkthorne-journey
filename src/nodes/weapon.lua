-----------------------------------------------
-- weapon.lua
-- Represents a generic weapon a player can wield or pick up
-- I think there should be only 2 types of weapons:
---- the only action that should play once is the animation for     ing your weapon
-- Created by NimbusBP1729
-----------------------------------------------
local sound = require 'vendor/TEsound'
local anim8 = require 'vendor/anim8'
local controls = require 'controls'
local game = require 'game'

local Weapon = {}
Weapon.__index = Weapon
Weapon.isWeapon = true

function Weapon.new(node, collider, plyr, weaponItem)
    local weapon = {}
    setmetatable(weapon, Weapon)
    
    weapon.name = node.name

    local props = require( 'nodes/weapons/' .. weapon.name )
    weapon.isRangeWeapon = props.isRangeWeapon
    --temporary to ensure throwing knives remain unchanged
    if weapon.isRangeWeapon then 
        return node
    end

    weapon.item = weaponItem

    weapon.player = plyr
    
    weapon.quantity = node.properties.quantity or props.quantity or 1

    weapon.foreground = node.properties.foreground
    weapon.position = {x = node.x, y = node.y}
    weapon.velocity={}
    weapon.velocity.x = node.properties.velocityX or 0
    weapon.velocity.y = node.properties.velocityY or 0

    --position that the hand should be placed with respect to any frame
    weapon.hand_x = props.hand_x
    weapon.hand_y = props.hand_y

    --setting up the sheet
    local colAmt = props.frameAmt
    weapon.sheet = love.graphics.newImage('images/weapons/'..weapon.name..'.png')
    weapon.sheetWidth = weapon.sheet:getWidth()
    weapon.sheetHeight = weapon.sheet:getHeight()
    weapon.frameWidth = weapon.sheetWidth/colAmt
    weapon.frameHeight = weapon.sheetHeight-15
    weapon.width = props.width or 10
    weapon.height = props.height or 10

    weapon.isFlammable = node.properties.isFlammable or props.isFlammable or false
    
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
                            nil

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
        if self.player.character.direction=='left' then
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
    if not node or self.dead or not self.wielding then return end
    if node.isPlayer then return end

    if self.dropping and (node.isFloor or node.floorspace or node.isPlatform) then
        self.dropping = false
    end
    
    
    if node.hurt then
        node:hurt(self.damage)
    end
    
    if self.hitAudioClip and node.hurt then
        sound.playSfx(self.hitAudioClip)
    end

    --handles code for burning an object
    if self.isFlammable and node.burn then
        node:burn(self.position.x,self.position.y)
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
-- Called when the weapon is returned to the inventory
function Weapon:unuse(mode)
    self.dead = true
    self.collider:remove(self.bb)
    self.item.quantity = 1
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

    else
        --the weapon is being used by a player
        local player = self.player
        local plyrOffset = player.width/2
    
        if not self.position or not self.position.x or not player.position or not player.position.x then return end
    
        if self.player.character.direction == "right" then
            self.position.x = math.floor(player.position.x) + (plyrOffset-self.hand_x) +player.offset_hand_left[1]
            self.position.y = math.floor(player.position.y) + (-self.hand_y) + player.offset_hand_left[2] 

            self.bb:moveTo(player.position.x+player.width/2+self.width/2,
                        self.position.y+self.height/2)
        else
            self.position.x = math.floor(player.position.x) + (plyrOffset+self.hand_x) +player.offset_hand_right[1]
            self.position.y = math.floor(player.position.y) + (-self.hand_y) + player.offset_hand_right[2] 

            self.bb:moveTo(player.position.x+player.width/2-self.width/2,
                        self.position.y+self.height/2)
        end

        if player.offset_hand_right[1] == 0 or player.offset_hand_left[1] == 0 then
            --print(string.format("Need hand offset for %dx%d", player.frame[1], player.frame[2]))
        end

        if self.wielding and self.animation.status == "finished" then
            self.collider:setPassive(self.bb)
            self.wielding = false
            self.player.wielding = false
            self.animation = self.defaultAnimation
        end
    end
    
    self.animation:update(dt)
end

function Weapon:keypressed( button, player)
    if self.player then return end

    if button == 'UP' then
        --the following invokes the constructor of the specific item's class
        local Item = require 'items/item'
        local itemNode = require ('items/weapons/'..self.name)
        local item = Item.new(itemNode)
        if player.inventory:addItem(item) then
            self.collider:remove(self.bb)
            self.dead = true
            if not player.currently_held then
                item:use(player)
            end
        end
    end
end

--handles a weapon being activated
function Weapon:wield()
    if self.wielding then return end
    self.collider:setActive(self.bb)

    self.player.wielding = true
    self.wielding = true

    self.animation = self.wieldAnimation
    self.animation:gotoFrame(1)
    self.animation:resume()

    self.player.character.state = self.action
    self.player.character:animation():gotoFrame(1)
    self.player.character:animation():resume()

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
    self.player.currently_held = nil
    self.player = nil
end

function Weapon:floor_pushback(node, new_y)
    if not self.dropping then return end

    self.dropping = false
    self.position.y = new_y
    self.velocity.y = 0
end

return Weapon
