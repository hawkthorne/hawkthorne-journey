-----------------------------------------------
-- genericWeapon.lua
-- Represents a generic weapon a player can wield or pick up
-- I think there should be only 3 types of weapons:
---- throwable (like throwing knives, bombs, torch?): 
---- wieldable (like the mace,sword,hammer,torch?):
---- wield w/ throw (bow, gun)
-- Created by HazardousPeach
-----------------------------------------------
local anim8 = require 'vendor/anim8'

local Weapon = {}
Weapon.__index = Weapon
Weapon.mace = true 

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
---wield()  optional

--common methods:
---draw()
---collide()
---collide_end()
---unuse()
---animation()

--
-- Creates a new battle mace object
-- @return the battle mace object created
function Weapon.addWeaponMethods(myWeapon)
    for k,v in pairs(Weapon) do
        if not myWeapon[k] then
            myWeapon[k] = v
        end
    end
    return myWeapon
end
---
-- Draws the weapon to the screen
-- @return nil
function Weapon:draw()
    if self.dead then return end
    local scalex = 1
    if ((self.velocity.x + 0)< 0) then
        scalex = -1
    end
    local animation = self:animation()
    animation:draw(self.sheet, math.floor(self.position.x), self.position.y)

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
end

function Weapon.drawBox(bb)
    if bb._type == 'circle' then
        --love.graphics.circle("line", bb._center.x, bb._center.y, bb._radius)
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
end

--default update method
--overload this in the specific weapon if this isn't well-suited for your weapon
function Weapon:update(dt)
    if self.dead then return end

    local playerDirection = 1
    if self.player.direction == "left" then playerDirection = -1 end

    local animation = self:animation()
    animation:update(dt)

    local player = self.player
    
    if self.player.direction == "right" then
        self.position.x = math.floor(player.position.x) + (24-self.handX) +player.offset_hand_left[1]
        self.position.y = math.floor(player.position.y) + (-self.handY) + player.offset_hand_left[2] 
    else
        self.position.x = math.floor(player.position.x) + (24-self.handX) +player.offset_hand_right[1]
        self.position.y = math.floor(player.position.y) + (-self.handY) + player.offset_hand_right[2] 
    end
    if player.offset_hand_right[1] == 0 or player.offset_hand_left[1] == 0 then
        print(string.format("Need hand offset for %dx%d", player.frame[1], player.frame[2]))
    end

    if animation.position == 1 then
        if playerDirection == 1 then
            self.bb:moveTo(self.position.x + 22, self.position.y+11)
        else
            self.bb:moveTo(self.position.x + (48-22), self.position.y+11)
        end
    elseif animation.position == 2 then
        if playerDirection == 1 then
            self.bb:moveTo(self.position.x + 37, self.position.y+23)
        else
            self.bb:moveTo(self.position.x + (48-37), self.position.y+23)
        end
    elseif animation.position == 3 then
        if playerDirection == 1 then
            self.bb:moveTo(self.position.x + 35, self.position.y+37)
        else
            self.bb:moveTo(self.position.x + (48-35), self.position.y+37)
        end
    elseif animation.position == 4 then
        if playerDirection == 1 then
            self.bb:moveTo(self.position.x + 23, self.position.y+9)
        else
            self.bb:moveTo(self.position.x + (48-23), self.position.y+9)
        end
    end

    if animation.status == "finished" then
        self.collider:setPassive(self.bb)
        self.wielding = false
        self.player.wielding = false
    end

end



---
-- Called when the weapon begins colliding with another node
-- @return nil
function Weapon:collide(node, dt, mtv_x, mtv_y)
    if node.character then return end
    if not node then return end
    if node.die then
        node:die(self.damage)
        self.collider:setPassive(self.bb)
        self.wielding = false
    end
end


function Weapon:animation()
    return self.animations[self.player.direction]
end


return Weapon