-----------------------------------------------
-- weapon.lua
-- Represents a generic weapon a player can wield or pick up
-- I think there should be only 2 types of weapons:
---- throwable (like throwing knives, bombs): 
---- wieldable (like the mace,sword,hammer,torch?):
---- throwable weapons subclass both weapon.lua and rangeWeapon.lua
---- wieldable weapons only subclass weapon.lua
--- Methodology:
----Let x be the name of the weapon:
----xItem.lua represents the item in the inventory
----x.lua represents the item as a node,
---- this subclasses Weapon.lua in order to draw it
----x_action.png is the image sheet that houses all frames of weapon x
----Note:
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
Weapon.position = {x=0,y=0}

local WeaponImage = love.graphics.newImage('images/mace.png')

--unique fields: these must be set in the subclass
---item
---weaponName
---position
---wieldingImage
---hand_x,hand_y: location of the hand in every frame
---collider
---damage: amount of damage the weapon inflicts
---bb (the bounding box)
---wieldRate: how fast the wield motion is
---action (the attack sequence for the player)
---player: the player who owns this object

--unique methods: these must be set in the subclass
--new()
---defaultAnimation()
---wieldAnimation()  (activating a weapon that is out)

--common methods:these are all managed by weapon.lua
---draw()
---collide()
---collide_end()
---unuse()         --item returned to inventory
---animation()

--set defaults:
--Weapon.damage = 4
--Weapon.wield_rate = 0.09
Weapon.unuseAudioClip = 'sword_sheathed'
Weapon.action = 'wieldaction'  --the motion sequence the player uses
Weapon.dead = false
Weapon.dropping = false

function retrieveItemClass(itemName)
    Item = require ('items/'..itemName..'Item')
    return Item
end

---
-- Draws the weapon to the screen
-- @return nil
function Weapon:draw()
    if self.dead then return end
    
    if not self.player then
        local animation = self.animation
        animation:draw(self.sheet, math.floor(self.position.x), self.position.y, 0, 1, 1)
        return
    end

    local scalex = 1
    if self.player.direction=='left' then
        scalex = -1
    end
    local animation = self.animation
    animation:draw(self.sheet, math.floor(self.position.x), self.position.y, 0, scalex, 1)
end

---
-- Called when the weapon begins colliding with another node
-- @return nil
function Weapon:collide(node, dt, mtv_x, mtv_y)
    if not node then return end
    
    if self.dropping and (node.isFloor or node.floorspace or node.isPlatform) then
        self.dropping = false
    end
    
    if node.character then
        self.touchedPlayer = node
        return
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

function Weapon:initializeSheet()

    self.animation = self:defaultAnimation()
    self.wielding = false
    self.action = 'wieldaction'

end

function Weapon:setPlayer(plyr)

    if plyr.character then
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

--draws the bounding box
function Weapon.drawBox(bb)
    if bb._type == 'circle' then
        love.graphics.circle("line", bb._center.x, bb._center.y, bb._radius)
    end

    if bb._type == 'polygon' then
        local v = bb._polygon.vertices
        for i = 2,#v do
            love.graphics.line(v[i-1].x,v[i-1].y,v[i].x,v[i].y)
        end
        love.graphics.line(v[#v].x,v[#v].y,v[1].x,v[1].y)
    end
	
end
---
-- Called when the weapon finishes colliding with another node
-- @return nil
function Weapon:collide_end(node, dt)
    if node and node.character then
        self.touchedPlayer = nil
    end
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

    
    --self.item.quantity = self.quantity
    
    if mode=="sound_off" then 
        return
    elseif self.unuseAudioClip then
        local x=47
        sound.playSfx(self.unuseAudioClip)
    else
        local x =47
        sound.playSfx('sword_sheathed')
    end
end

--default update method
--overload this in the specific weapon if this isn't well-suited for your weapon
function Weapon:update(dt)
    sound.cleanup()
    
    local animation = self.animation
    animation:update(dt)

    if self.dead then return end
    if not self.player then
        if controls.isDown( 'UP' ) and self.touchedPlayer then
            --the following invokes the constructor of the specific item's class
            local Item = retrieveItemClass(self.name)
            local item = Item.new()
            if self.touchedPlayer.inventory:addItem(item) then
                self.collider:setGhost(self.bb)
                self.dead = true
                if not self.touchedPlayer.currently_held then
                    item:use(self.touchedPlayer)
                end
            end
        end
        
        if self.dropping then
            self.position = {x = self.position.x + self.velocity.x*dt,
                            y = self.position.y + self.velocity.y*dt}
            self.velocity = {x = self.velocity.x*0.1*dt,
                            y = self.velocity.y + game.gravity*dt}
            self.bb:moveTo(self.position.x,self.position.y)
        end
        return
    end

    local playerDirection = 1
    if self.player.direction == "left" then playerDirection = -1 end

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

--    local offset = self.width   
    if playerDirection == 1 then
        self.bb:moveTo(player.position.x+player.width/2+self.width/2,
        self.position.y+self.height/2)
    else
        self.bb:moveTo(player.position.x+player.width/2-self.width/2,
        self.position.y+self.height/2)
    end

    if animation.status == "finished" then
        self.collider:setPassive(self.bb)
        self.wielding = false
        self.player.wielding = false
        self.animation = self:defaultAnimation()
    end

end

function Weapon:wield()
    self.dead = false
    self.collider:setActive(self.bb)

    if not self.wielding then
        local h = anim8.newGrid(self.frameWidth,self.frameHeight,self.sheetWidth,self.sheetHeight)
        local g = anim8.newGrid(48, 48, self.player.sheet:getWidth(), 
        self.player.sheet:getHeight())

        --test directions
        self:wieldAnimation()
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

function Weapon:myAnimation()
    return self.animation
end

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