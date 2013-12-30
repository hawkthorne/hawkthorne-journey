-----------------------------------------------
-- rangedWeapon.lua
-- Represents a generic ranged weapon a player can wield or pick up
-- adapted from code originally written by NimbusBP1729
-----------------------------------------------
local sound = require 'vendor/TEsound'
local anim8 = require 'vendor/anim8'
local Timer = require 'vendor/timer'
local game = require 'game'
local GS = require 'vendor/gamestate'
local weaponClass = require 'nodes/weapon'

local Weapon = {}
setmetatable(Weapon, weaponClass)
Weapon.__index = Weapon
Weapon.isWeapon = true

function Weapon.new(node, collider, plyr, weaponItem)
    local weapon = {}
    setmetatable(weapon, Weapon)
    
    weapon.name = node.name

    local props = require( 'nodes/weapons/' .. weapon.name )
    weapon.projectile = props.projectile
    weapon.isRangedWeapon = true

    weapon.item = weaponItem

    weapon.player = plyr
    
    weapon.quantity = node.properties.quantity or props.quantity or 1

    weapon.foreground = node.properties.foreground
    weapon.position = {x = node.x, y = node.y}
    weapon.velocity={}
    weapon.velocity.x = node.properties.velocityX or 0
    weapon.velocity.y = node.properties.velocityY or 0
    weapon:initializeBoundingBox(collider)
    weapon.direction = "right"

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
    weapon.throwDelay = props.throwDelay

    
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
    
    weapon.dead = false

    --audio clip when weapon is put away
    weapon.unuseAudioClip = node.properties.unuseAudioClip or 
                            props.unuseAudioClip or 
                            'sword_sheathed'

    --audio clip when weapon swing through air
    weapon.attackAudioClip = node.properties.attackAudioClip or 
                            props.attackAudioClip or 
                            nil
    
    weapon.action = props.action or 'shootarrow'
    weapon.actionwalk = props.actionwalk or 'shootarrowwalk'
    weapon.actionjump = props.actionjump or 'shootarrowjump'
    weapon.dropping = false
    
    return weapon
end

function Weapon:initializeBoundingBox(collider)
    self.collider = collider
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
        end

    else
        --the weapon is being used by a player
        local player = self.player
        local plyrOffset = player.width/2
        self.direction = self.player.character.direction
        self.velocity = player.velocity
    
        if not self.position or not self.position.x or not player.position or not player.position.x then return end

        local framePos = (player.wielding) and self.animation.position or 1
        if player.character.direction == "right" then
            self.position.x = math.floor(player.position.x) + (plyrOffset-self.hand_x) +player.offset_hand_left[1]
            self.position.y = math.floor(player.position.y) + (-self.hand_y) + player.offset_hand_left[2] 
        else
            self.position.x = math.floor(player.position.x) + (plyrOffset+self.hand_x) +player.offset_hand_right[1]
            self.position.y = math.floor(player.position.y) + (-self.hand_y) + player.offset_hand_right[2] 
        end

        if player.offset_hand_right[1] == 0 or player.offset_hand_left[1] == 0 then
            --print(string.format("Need hand offset for %dx%d", player.frame[1], player.frame[2]))
        end

        if player.wielding and self.animation and self.animation.status == "finished" then
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
        local itemNode = require ('items/weapons/'..self.name)
        local item = Item.new(itemNode, self.quantity)
        if player.inventory:addItem(item) then
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

    self.player.wielding = true

    if self.animation then
        self.animation = self.wieldAnimation
        self.animation:gotoFrame(1)
        self.animation:resume()
    end
    if self.player:isWalkState(self.player.character.state) then
        self.player.character.state = self.actionwalk
    elseif self.player:isJumpState(self.player.character.state) then
        self.player.character.state = self.actionjump
    else
        self.player.character.state = self.action
    end
    self.player.character:animation():gotoFrame(1)
    self.player.character:animation():resume()
    self:throwProjectile()

    if self.attackAudioClip then
        sound.playSfx( self.attackAudioClip )
    end

end

-- handles weapon being dropped in the real world
function Weapon:drop(player)
    self.dropping = true

    self.player:setSpriteStates('default')
    self.player.currently_held = nil
    self.player = nil
end

function Weapon:throwProjectile()
    if not self.player then return end
    local ammo = require('items/weapons/'..self.projectile)
    local currentWeapon = nil
    local page = nil
    local index = nil
    if not currentWeapon then
        currentWeapon, page, index = self.player.inventory:search(ammo)
    end
    if not currentWeapon then
        self.player.holdingAmmo = false
        self:deselect()
        self.player.doBasicAttack = true
        return
    end
    self.player.inventory.selectedWeaponIndex = index
    self.player.holdingAmmo = true
    
    Timer.add(self.throwDelay, function()
        currentWeapon:use(self.player, self)
        end)
end

function Weapon:floor_pushback(node, new_y)
    if not self.dropping then return end

    self.dropping = false
    self.position.y = new_y
    self.velocity.y = 0
end

return Weapon
