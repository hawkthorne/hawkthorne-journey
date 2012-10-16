-----------------------------------------------
-- battle_mace.lua
-- Represents a mace that a player can wield or pick up
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
    --if bb._type == 'circle' then
    --    love.graphics.circle("line", bb._center.x, bb._center.y, bb._radius)
    --end
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