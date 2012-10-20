-----------------------------------------------
-- genericWeapon.lua
-- Represents a generic weapon a player can wield or pick up
-- I think there should be only 3 types of weapons:
---- throwable (like throwing knives, bombs, torch?): 
---- wieldable (like the mace,sword,hammer,torch?):
---- wield w/ throw (bow, gun)
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

local Weapon = {}
Weapon.__index = Weapon
Weapon.weapon = true
Weapon.singleton = nil

local WeaponImage = love.graphics.newImage('images/mace.png')

--unique fields:
---item
---weaponName
---position
---itemImage
---wieldingImage
---weaponHandOffsetLocation optional
---collider
---isWeapon
---damage
---bb (the bounding box)
---wieldRate optional
---handPositions locations in the wieldingImage for a hand
---action (the attack sequence for the player)

--unique methods:
--use()
---update()
---wield()  (activating a weapon that is out) optional

--common methods:
---draw()
---collide()
---collide_end()
---unuse()
---animation()

---
-- Draws the weapon to the screen
-- @return nil
function Weapon:draw()
    if self.dead then return end
    
    if not self.plyr then
        love.graphics.drawq(self.sheet, love.graphics.newQuad(0,0, self.width,self.height,self.width,self.height), self.position.x, self.position.y)
        return
    end

    
    
    local scalex = 1
    if self.player.direction=='left' then
        scalex = -1
    end
    local animation = self:myAnimation()
    animation:draw(self.sheet, math.floor(self.position.x), self.position.y, 0, scalex, 1)

    Weapon.drawBox(self.bb)
end

---
-- Called when the weapon begins colliding with another node
-- @return nil
function Weapon:collide(node, dt, mtv_x, mtv_y)
    if node.character then return end
    if not node then return end
    if node.die then
        node:die(self.damage)
    end
    
    --if self.hitAudioClip and node.die then
    --    sound.playSfx(self.hitAudioClip)
    --end

    --handles code for burning an object
    if self.torch and node.burn then
        node:burn(self.position.x,self.position.y)
    end
end

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
end

---
-- Called when the weapon is returned to the inventory
function Weapon:unuse()
    self.dead = true
    self.collider:setGhost(self.bb)
    self.player.inventory:addItem(self.item)
    self.player.wielding = false
    self.player.currently_held = nil
    self.player:setSpriteStates('default')
    self.item.quantity = self.item.quantity + 1
    if self.unuseAudioClip then
        sound.playSfx(self.unuseAudioClip)
    else
        --this is a reasonable default noise
        sound.playSfx('sword_sheathed')
    end
        
end

--default update method
--overload this in the specific weapon if this isn't well-suited for your weapon
function Weapon:update(dt)
    if not self.player then return end

    if self.dead then return end

    local playerDirection = 1
    if self.player.direction == "left" then playerDirection = -1 end

    local animation = self:myAnimation()
    animation:update(dt)

    local player = self.player
    local plyrOffset = player.width/2
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
        if self.defaultAnimation then
            self:defaultAnimation()
        end
    end

end

function Weapon:myAnimation()
    return self.animation
end


return Weapon