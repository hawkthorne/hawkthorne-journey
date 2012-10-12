-----------------------------------------------
-- battle_mace.lua
-- Represents a mace that a player can wield or pick up
-- Created by HazardousPeach
-----------------------------------------------
local anim8 = require 'vendor/anim8'

local Mace = {}
Mace.__index = Mace
Mace.mace = true

local MaceImage = love.graphics.newImage('images/mace.png')

--
-- Creates a new battle mace object
-- @return the battle mace object created
function Mace.new(node, collider, plyr, maceItem)
    local mace = {}
    setmetatable(mace, Mace)
    if plyr then
        --mace.image = MaceWieldingImage
    else
        --mace.image = MaceImage
    end
    mace.maceItem = maceItem
    mace.foreground = node.properties.foreground
    mace.position = {x = node.x - 12, y = node.y}
    mace.velocity = {x = node.properties.velocityX, y = node.properties.velocityY}
    mace.width = node.width
    mace.height = node.height

    local bb_radius = 14;
    local bb_cx_initial = 22;
    local bb_cy_initial = 11;

    mace.bb = collider:addCircle(mace.position.x + bb_cx_initial, mace.position.y + bb_cy_initial, bb_radius)
    mace.bb.node = mace
    mace.collider = collider
    mace.collider:setPassive(mace.bb)

    mace.damage = 4
    mace.dead = false
    mace.player = plyr

    mace.wield_rate = 0.09

    local h = anim8.newGrid(48, 48, 192, 96)
    mace.animations = {
            right = anim8.newAnimation('once', h('1,1'), 1),
            left = anim8.newAnimation('once', h('1,2'), 1)
        }
    mace.sheet = love.graphics.newImage('images/mace_action3.png')
    mace.wielding = false
    mace.offsetX = 10
    mace.offsetY = -10
    mace.isWeapon = true

    return mace
end

---
-- Draws the mace to the screen
-- @return nil
function Mace:draw()
    if self.dead then return end
    local scalex = 1
    if ((self.velocity.x + 0)< 0) then
        scalex = -1
    end
    local animation = self:animation()
    animation:draw(self.sheet, math.floor(self.position.x), self.position.y)
end

---
-- Called when the mace begins colliding with another node
-- @return nil
function Mace:collide(node, dt, mtv_x, mtv_y)
    if node.character then return end
    if not node then return end
    if node.die then
        node:die(self.damage)
    end
end

---
-- Called when the mace finishes colliding with another node
-- @return nil
function Mace:collide_end(node, dt)
end

---
-- Updates the mace and moves it around.
function Mace:update(dt)
    if self.dead then return end

    local playerDirection = 1
    if self.player.direction == "left" then playerDirection = -1 end

    local animation = self:animation()
    animation:update(dt)
    
    self.position = {x=self.player.position.x + playerDirection*12,
                     y=self.player.position.y}

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
        --print("animation complete"..self.player.direction)
        self.collider:setPassive(self.bb)
        self.wielding = false
        self.player.wielding = false
    end

end

function Mace:unwield()
    self.dead = true
    self.collider:setGhost(self.bb)
    self.player.inventory:addItem(self.maceItem)
    self.player.wielding = false
    self.player.currently_held = nil
    self.player.walk_state = 'walk'
    self.player.state = 'idle'
end

function Mace:wield()
    print("wielding")
    self.dead = false
    self.collider:setActive(self.bb)

    self.player.state = 'wieldaction'

    if not self.wielding then
        local h = anim8.newGrid(48, 48, 192, 96)
        local g = anim8.newGrid(48, 48, self.player.sheet:getWidth(), 
        self.player.sheet:getHeight())

        --test directions
        if self.player.direction == 'right' then
            self.animations['right'] = anim8.newAnimation('once', h('1-4,1'), self.wield_rate)
            self.player.animations['wieldaction']['right'] = anim8.newAnimation('once', g('6,7','9,7','3,7','6,7'), self.wield_rate)
        else 
            self.animations['left'] = anim8.newAnimation('once', h('1-4,2'), self.wield_rate)
            self.player.animations['wieldaction']['left'] = anim8.newAnimation('once', g('6,8','9,8','3,8','6,8'), self.wield_rate)
        end
    end
    self.player.wielding = true
    self.wielding = true
end

---
-- Called when the knife begins colliding with another node
-- @return nil
function Mace:collide(node, dt, mtv_x, mtv_y)
    if node.character then return end
    if not node then return end
    if node.die then
        node:die(self.damage)

        self.collider:setPassive(self.bb)
        self.wielding = false
    end
end


function Mace:animation()
    return self.animations[self.player.direction]
end


return Mace