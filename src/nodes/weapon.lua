-----------------------------------------------
-- weapon.lua
-- Represents a generic weapon a player can wield or pick up
-- I think there should be only 2 types of weapons:
---- the only action that should play once is the animation for ing your weapon
-- Created by NimbusBP1729
-----------------------------------------------
local sound = require 'vendor/TEsound'
local anim8 = require 'vendor/anim8'
local game = require 'game'
local utils = require 'utils'

local Weapon = {}
Weapon.__index = Weapon
Weapon.isWeapon = true

function Weapon.new(node, collider, plyr, weaponItem)
    local weapon = {}
    setmetatable(weapon, Weapon)
    
    weapon.name = node.name

    local props = utils.require( 'nodes/weapons/' .. weapon.name )

    weapon.item = weaponItem

    -- Checks if for plyr and if plyr is a player
    weapon.player = (plyr and plyr.isPlayer) and plyr or nil
    
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
    weapon.dropWidth = props.dropWidth
    weapon.dropHeight = props.dropHeight
    weapon.bbox_width = props.bbox_width
    weapon.bbox_height = props.bbox_height
    weapon.bbox_offset_x = props.bbox_offset_x
    weapon.bbox_offset_y = props.bbox_offset_y

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
    -- Damage that does not affect all enemies ie. stab, fire
    weapon.special_damage = props.special_damage or {}
    weapon.knockback = node.properties.knockback or props.knockback or 10
    weapon.dead = false

    --create the bounding box
    weapon:initializeBoundingBox(collider)
    
    -- Represents direction of the weapon when no longer in the players inventory
    weapon.direction = node.properties.direction or 'right'
    
    -- Flipping an image moves it, this adjust for that image flip offset
    if weapon.direction == 'left' then
        weapon.position.x = weapon.position.x + weapon.boxWidth
    end

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
    
    weapon.action = props.action or 'wieldaction'
    weapon.dropping = false
    weapon.dropped = false
    
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
    elseif self.direction == 'left' then
        scalex = -1
    end
    
    local animation = self.animation
    if not animation then return end
    animation:draw(self.sheet, math.floor(self.position.x), self.position.y, 0, scalex, 1)
end

---
-- Called when the weapon begins colliding with another node
-- @return nil
function Weapon:collide(node, dt, mtv_x, mtv_y)
    if not node or self.dead or (self.player and not self.player.wielding) or self.dropped then return end
    if node.isPlayer then return end

    if self.dropping and (node.isFloor or node.floorspace or node.isPlatform) then
        self.dropping = false
    end

    if node.hurt and self.player then
        local knockback = self.player.character.direction == 'right' and self.knockback or -self.knockback
        node:hurt(self.damage, self.special_damage, knockback)
        self.collider:setGhost(self.bb)
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
    self.boxTopLeft = {x = self.position.x + self.bbox_offset_x[1],
                        y = self.position.y + self.bbox_offset_y[1]}
    self.boxWidth = self.bbox_width
    self.boxHeight = self.bbox_height

    --update the collider using the bounding box
    self.bb = collider:addRectangle(self.boxTopLeft.x,self.boxTopLeft.y,self.boxWidth,self.boxHeight)
    self.bb.node = self
    self.collider = collider
    
    if self.player then
        self.collider:setGhost(self.bb)
    else
        self.collider:setSolid(self.bb)
    end
end

---
-- Called when the weapon is returned to the inventory
function Weapon:deselect()
    self.dead = true
    self.collider:remove(self.bb)
    self.containerLevel:removeNode(self)
    self.player.wielding = false
    self.player.currently_held = nil
    local state = self.player.isClimbing and 'climbing' or 'default'
    self.player:setSpriteStates(state)

    sound.playSfx(self.unuseAudioClip)
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
            self.velocity = {x = self.velocity.x,
                            y = self.velocity.y + game.gravity*dt}
                            
            local offset_x = 0
            
            if self.bbox_offset_x then
                offset_x = self.bbox_offset_x[1]
            end
            if self.bb then
                self.bb:moveTo(self.position.x + offset_x + self.dropWidth / 2,
                               self.position.y + self.dropHeight / 2)
            end
        end

    else
        --the weapon is being used by a player
        local player = self.player
        local plyrOffset = player.width/2
    
        if not self.position or not self.position.x or not player.position or not player.position.x then return end
    
        local framePos = (player.wielding) and self.animation.position or 1
        if player.character.direction == "right" then
            self.position.x = math.floor(player.position.x) + (plyrOffset-self.hand_x) +player.offset_hand_left[1]
            self.position.y = math.floor(player.position.y) + (-self.hand_y) + player.offset_hand_left[2]
            if self.bb then
                self.bb:moveTo(self.position.x + (self.bbox_offset_x[framePos] or 0) + self.bbox_width/2,
                               self.position.y + (self.bbox_offset_y[framePos] or 0) + self.bbox_height/2)
            end
        else
            self.position.x = math.floor(player.position.x) + (plyrOffset+self.hand_x) +player.offset_hand_right[1]
            self.position.y = math.floor(player.position.y) + (-self.hand_y) + player.offset_hand_right[2]

            if self.bb then
                self.bb:moveTo(self.position.x - (self.bbox_offset_x[framePos] or 0) - self.bbox_width/2,
                               self.position.y + (self.bbox_offset_y[framePos] or 0) + self.bbox_height/2)
            end
        end

        if player.offset_hand_right[1] == 0 or player.offset_hand_left[1] == 0 then
            --print(string.format("Need hand offset for %dx%d", player.frame[1], player.frame[2]))
        end

        if player.wielding and self.animation and self.animation.status == "finished" then
            if self.bb then
                self.collider:setGhost(self.bb)
            end
            player.wielding = false
            self.animation = self.defaultAnimation
        end
    end
    if self.animation then
        self.animation:update(dt)
    end
end

function Weapon:keypressed( button, player)
    if self.player then return end

    if button == 'INTERACT' then
        --the following invokes the constructor of the specific item's class
        local Item = require 'items/item'
        local itemNode = utils.require ('items/weapons/'..self.name)
        local item = Item.new(itemNode, self.quantity)
        if player.inventory:addItem(item) then
            if self.bb then
                self.collider:remove(self.bb)
            end
            self.containerLevel:removeNode(self)
            self.dead = true
            if not player.currently_held then
                item:select(player)
            end
            -- Key has been handled, halt further processing
            return true
        end
    end
end

--handles a weapon being activated
function Weapon:wield()
    self.collider:setSolid(self.bb)

    self.player.wielding = true
    
    if self.animation then
        self.animation = self.wieldAnimation
        self.animation:gotoFrame(1)
        self.animation:resume()
    end

    self.player.character.state = self.action
    self.player.character:animation():gotoFrame(1)
    self.player.character:animation():resume()

    if self.swingAudioClip then
        sound.playSfx( self.swingAudioClip )
    end

end

-- handles weapon being dropped in the real world
function Weapon:drop(player)

    self.collider:remove(self.bb)
    self.bb = self.collider:addRectangle(self.position.x,self.position.y,self.dropWidth,self.dropHeight)
    self.bb.node = self
    self.collider:setSolid(self.bb)
    if player.footprint then
        self:floorspace_drop(player)
        return
    end
    self.dropping = true
    self.dropped = true
end

-- handle weapon being dropped in a floorspace
function Weapon:floorspace_drop(player)
    self.position.y = player.footprint.y - self.dropHeight
    
    if self.bbox_offset_x then
        offset_x = self.bbox_offset_x[1]
    end
    
    self.bb:moveTo(self.position.x + offset_x + self.dropWidth / 2, self.position.y + self.dropHeight / 2)
end

function Weapon:floor_pushback(node, new_y)
    if not self.dropping then return end
    
    local offset_x = 0
    
    self.dropping = false
    self.position.y = new_y + self.height - self.dropHeight --adding height cancels the height this is here until it is figured out what height is used for
    if self.bbox_offset_x then
        offset_x = self.bbox_offset_x[1]
    end
    if self.bb then
        self.bb:moveTo(self.position.x + offset_x + self.dropWidth / 2,
                       self.position.y + self.dropHeight / 2)
    end
    self.velocity.y = 0
end

return Weapon
