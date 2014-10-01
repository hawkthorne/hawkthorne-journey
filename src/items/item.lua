-----------------------------------------------
-- item.lua
-- The code for an object, when it in the players inventory.
-- Created by HazardousPeach and NimbusBP1729
-----------------------------------------------
local GS = require 'vendor/gamestate'
local Weapon = require 'nodes/weapon'
local rangedWeapon = require 'nodes/rangedWeapon'
local playerEffects = require 'playerEffects'

local Item = {}
Item.__index = Item
Item.isItem = true
Item.types = {
    ITEM_WEAPON     = "weapon",
    ITEM_KEY        = "key",
    ITEM_CONSUMABLE = "consumable",
    ITEM_MATERIAL   = "material"
}

Item.MaxItems = 10000
-- Item constructor
-- Description: Will construct a new Item.
-- Items are the representation of in-game items when in the player's inventory, not in the world.
-- @param node the base object for this Item. (located in /items/
-- @param count (optional) if provided, this parameter determines how many Items will be placed into inventory.
--    It will override the base node quantity.
function Item.new(node, count)
    local item = {}
    setmetatable(item, Item)
    item.name = node.name
    item.type = node.type
    item.props = node

    local imagePath = 'images/' .. item.type .. 's/' .. item.name .. '.png'

    if not love.filesystem.exists(imagePath) then
      return nil
    end

    item.image = love.graphics.newImage(imagePath)
    local itemImageY = item.image:getHeight() - 15
    item.image_q = love.graphics.newQuad( 0,itemImageY, 15, 15, item.image:getWidth(),item.image:getHeight() )
    item.MaxItems = node.MAX_ITEMS or 10000
    item.quantity = count or node.quantity or 1
    item.isHolding = node.isHolding
    item.description = node.description or "item"
    item.subtype = node.subtype or "item"
    item.info = node.info or "unknown info"
    item.damage = node.damage or "nil"
    item.special_damage = node.special_damage or "nil"    

    return item
end

---
-- Draws the item in the inventory
-- @param position the location in the inventory
-- @return nil
function Item:draw(position, scrollIndex, hideAmount)
    love.graphics.draw(self.image, self.image_q, position.x, position.y)
    if not hideAmount and self.quantity > 1 then
       love.graphics.print("x" .. self.quantity, position.x + 4, position.y + 10,0, 0.5, 0.5)
    end
    if scrollIndex ~= nil then
        love.graphics.print("#" .. scrollIndex, position.x, position.y, 0, 0.5, 0.5) --Adds index #
    end
end

--this is the action the item takes when it is selected in the inventory
function Item:select(player)
    
    --can be used primarily for potions
    if self.props.select then
        self.props.select(player,self)
    elseif self.props.subtype == "melee" then
        -- Only add the node to the level if the player isn't already holding something
        if not player.currently_held then
            local node = { 
                            name = self.name,
                            x = player.position.x,
                            y = player.position.y,
                            width = 50,
                            height = 50,
                            type = self.type,
                            properties = {
                                ["foreground"] = "false",
                            },
                           }
            local level = GS.currentState()
            local weapon = Weapon.new(node, level.collider,player,self)
            level:addNode(weapon)
            player.currently_held = weapon
            if player.isClimbing then
                player:setSpriteStates('climbing')
            else
                player:setSpriteStates(weapon.spriteStates or 'wielding')
            end
        end
    elseif self.props.subtype == "ranged" then 
        local node = { 
                        name = self.name,
                        x = player.position.x,
                        y = player.position.y,
                        width = 50,
                        height = 50,
                        type = self.type,
                        properties = {
                            ["foreground"] = "false",
                        },
                       }
        local level = GS.currentState()
        local ranged = rangedWeapon.new(node, level.collider,player,self)
        level:addNode(ranged)
        if not player.currently_held then
            player.currently_held = ranged
            if player.isClimbing then
                player:setSpriteStates('climbing')
            else
                player:setSpriteStates(ranged.spriteStates or 'wielding')
            end
        end
    elseif self.props.subtype == "projectile" then
        --do nothing, the projectile is activated by attacking
    end
    if self.quantity <= 0 then
        player.inventory:removeItem(player.inventory.selectedWeaponIndex, player.inventory.currentPageName)
    end

end

function Item:use(player, thrower)
    if self.props.subtype == "ammo" and not thrower then
        player:switchWeapon()
        if player.inventory:currentWeapon() == self then
            player.doBasicAttack = true
        end
        return
    end
    if self.type == "weapon" or self.type == "scroll" then
        assert(self.props.subtype,"A subtype is required for weapon ("..self.name..")")

        if self.props.subtype == "melee" or self.props.subtype == 'ranged' then
            --if wieldable do nothing
        elseif self.props.subtype == "projectile" or self.props.subtype == "ammo" then
            self.quantity = self.quantity - 1
            
            local direction = player.character.direction
            local hand_y = player.height/2
            if direction == "right" and thrower then
                hand_y = player.offset_hand_right[2]
            elseif thrower then
                hand_y = player.offset_hand_left[2]
            end
            
            
            local node = require('nodes/projectiles/'..self.props.name)
            node.x = player.position.x + player.character.bbox.width/2
            node.y = player.position.y + hand_y - node.height/2 - player.character.bbox.y
            node.directory = self.props.type.."s/"
            local level = GS.currentState()
            local proj = require('nodes/projectile').new(node, level.collider)
            
            if thrower then proj:throw(thrower)
            else proj:throw(player) end
            level:addNode(proj)
        end
        if self.quantity <= 0 then
            if self.type == 'weapon' then
                player.inventory:removeItem(player.inventory.selectedWeaponIndex, 'weapons')
            else
                player.inventory:removeItem(player.inventory.selectedWeaponIndex - player.inventory.pageLength, 'scrolls')
                -- If the weapons page is full, nextAvailableSlot('weapons') will return nil, just select the first item.
                player.inventory.selectedWeaponIndex = player.inventory:nextAvailableSlot('weapons') or 1
            end
        end
    elseif self.type == "consumable" then
        if self.props.consumable then
            playerEffects:doEffect(self.props.consumable, player)
        else
            playerEffects.dudEffect(self.props.description, player)
        end
        self.quantity = self.quantity - 1
        if self.quantity <= 0 then
            player.inventory:removeItem(player.inventory.selectedConsumableIndex, 'consumables')
        end
    end

end

---
-- Returns whether or not the given item can be merged or partially merged with this one.
-- @param otherItem the item that the client wants to merge with this one.
-- @returns whether otherItem can merge with self
function Item:mergible(otherItem)
    if self.name ~= otherItem.name or 
       self.type ~= otherItem.type then
        return false 
    end
    if self.quantity >= self.MaxItems then return false end
    return true
end

---
-- Merges the two knives
-- @param otherItem the knife to merge with.
-- @returns true if the item could be completely merged, false if it could not be merged or could only be partially merged.
function Item:merge(otherItem)
    if self.quantity + otherItem.quantity <= self.MaxItems then 
        self.quantity = self.quantity + otherItem.quantity
        return true
    else
        otherItem.quantity = (otherItem.quantity + self.quantity) - self.MaxItems
        self.quantity = self.MaxItems
        return false
    end
end

return Item
