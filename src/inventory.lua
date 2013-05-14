-----------------------------------------------------------------------
-- inventory.lua
-- Manages the player's currently held objects
-----------------------------------------------------------------------

local controls = require('controls')
local anim8 = require('vendor/anim8')
local sound = require('vendor/TEsound')
local camera = require('camera')
local debugger = require('debugger')
local recipes = require('items/recipes')
local Item = require('items/item')

local Inventory = {}
Inventory.__index = Inventory

--Load in the inventory sprites
local animSprite = love.graphics.newImage('images/inventory/inventory.png')
local scrollSprite = love.graphics.newImage('images/inventory/scrollbar.png')
local selectionSprite = love.graphics.newImage('images/inventory/selection.png')
local selectedweaponSprite = love.graphics.newImage('images/inventory/selectedweapon.png')
local craftingannexSprite = love.graphics.newImage('images/inventory/craftingannex.png')
craftingannexSprite:setFilter('nearest', 'nearest')
animSprite:setFilter('nearest', 'nearest')
scrollSprite:setFilter('nearest', 'nearest')

--The animation grids for different animations
local animGrid = anim8.newGrid(100,105, animSprite:getWidth(), animSprite:getHeight())
local scrollGrid = anim8.newGrid(5,40, scrollSprite:getWidth(), scrollSprite:getHeight())
local craftingGrid = anim8.newGrid(75, 29, craftingannexSprite:getWidth(), craftingannexSprite:getHeight())

---
-- Creates a new inventory
-- @return new inventory table
function Inventory.new( player )
    local inventory = {}
    setmetatable(inventory, Inventory)

    inventory.player = player

    inventory.animations = {
        opening = anim8.newAnimation('once', animGrid('1-6,1'), 0.05),
        closing = anim8.newAnimation('once', animGrid('1-6,1'), 0.02),
        open = anim8.newAnimation('once', animGrid('6,1'), 1),
        closed = anim8.newAnimation('once', animGrid('1,1'),1)
    }
    inventory.animations['closing'].direction = -1
    inventory.animations['closing'].position = 5

    inventory.scrollAnimations = {
        anim8.newAnimation('once', scrollGrid('1,1'),1),
        anim8.newAnimation('once', scrollGrid('2,1'),1),
        anim8.newAnimation('once', scrollGrid('3,1'),1),
        anim8.newAnimation('once', scrollGrid('4,1'),1),
    }
    inventory.scrollbar = 1

    inventory.craftingAnimations = {
        opening = anim8.newAnimation('once', craftingGrid('1-6,1'),0.04),
        open = anim8.newAnimation('once', craftingGrid('6,1'), 1),
        closing = anim8.newAnimation('once', craftingGrid('1-6,1'),0.01)
    }
    inventory.craftingAnimations['closing'].direction = -1
    inventory.craftingAnimations['closing'].position = 6

    inventory.pageList = {
        weapons = {'keys', 'consumables'},
        keys = {'materials', 'weapons'},
        materials = {'consumables', 'keys'},
        consumables = {'weapons', 'materials'}
    } --Each key's value is a table with this format: {nextpage, previouspage}
    inventory.currentPageName = 'consumables' --Initial inventory page
    inventory.pageLength = 13 --With 0 index, pages have a capacity of 14
    inventory.pages = {}
    for i in pairs(inventory.pageList) do --Creates a new blank table for each key in pageList
        inventory.pages[i] = {}
    end

    inventory.currentIngredients = {a = nil, b = nil} --Set crafting box to empty. Note {} is equivalent.

    inventory.animState = 'closed'
    inventory.craftingState = 'closing'
    inventory.visible = false
    inventory.craftingVisible = false

    return inventory
end

---
-- Updates the inventory animations
-- @param dt delta time
-- @return nil
function Inventory:update( dt )
    if not self.visible then return end

    self:animation():update(dt)
    self:craftingAnimation():update(dt)

    self:animUpdate()
end

---
-- Finishes updating animations for opening and closing
-- @return nil
function Inventory:animUpdate()
    if self:animation().status == 'finished' then
        if self.animState == 'closing' then
            self:animation():gotoFrame(5)
            self:animation():pause()
            self.visible = false
            self.animState = 'closed'
            self.cursorPos = {x = 0, y = 0}
            self.scrollbar = 1
            self.player.freeze = false
        elseif self.animState == 'opening' then
            self:animation():gotoFrame(1)
            self:animation():pause()
            self.animState = 'open'
        end
    end
    if self:craftingAnimation().status == 'finished' then
        if self.craftingState == 'closing' then
            self:craftingAnimation():gotoFrame(5)
            self:craftingAnimation():pause()
            self.craftingVisible = false
        elseif self.craftingState == 'opening' then
            self:craftingAnimation():gotoFrame(1)
            self:craftingAnimation():pause()
            self.CraftingState = 'open'
        end
    end
end

---
-- Draws the inventory to the screen
-- @param playerPosition the coordinates to draw offset from
-- @return nil
function Inventory:draw( playerPosition )
    if not self.visible then return end

    --The default position of the inventory
    local pos = {
        x = playerPosition.x - (animGrid.frameWidth + 6),
        y = playerPosition.y - (animGrid.frameHeight - 22)
    }

    --Adjust the default position to keep inventory within bounds, and under the HUD
    local hud_right = camera.x + 130
    local hud_top = camera.y + 60
    if pos.x < 0 then
        pos.x = playerPosition.x + 54
    end
    if pos.x < hud_right and pos.y < hud_top then
        pos.y = hud_top
    end
    if pos.y < 0 then pos.y = 0 end

    --Draw the main inventory sprite
    self:animation():draw(animSprite, pos.x, pos.y)
    
    --Only draw inventory elements if it is fully open
    if (self:isOpen()) then

        --TODO: Draw the text
        love.graphics.setColor(255, 255, 255)
        love.graphics.print(string.upper(string.sub(self.currentPageName,1,1)) .. string.sub(self.currentPageName, 2), pos.x, pos.y)
        --Draw the scroll bar
        self.scrollAnimations[self.scrollbar]:draw(scrollSprite, pos.x + 8, pos.y + 43)

        local firstSlotPos = {x = pos.x + 29, y = pos.y + 30}
        
        --Draw all the items in their respective slots
        for i=0,7 do
            local scrollIndex = i + ((self.scrollbar - 1) * 2)
            local indexDisplay = debugger.on and scrollIndex
            if self:currentPage()[scrollIndex] then
                local slotPos = self:slotPosition(i)
                local item = self:currentPage()[scrollIndex]
                if self.currentIngredients.a ~= scrollIndex and self.currentIngredients.b ~= scrollIndex then
                    item:draw({x = slotPos.x + firstSlotPos.x, y = slotPos.y + firstSlotPos.y}, indexDisplay)
                end
            end
        end

        --Draw a border around the currently selected slot
        if self.curserPos.x < 2 then --If the cursor is in the main inventory section..
            local width, height = selectionSprite:getWidth(), selectionSprite:getHeight()
            love.graphics.drawq(selectionSprite,
                love.graphics.newQuad(0, 0, width, height, width, height),
                firstSlotPos.x + self.cursorPos.x * 38, firstSlotPos.y + self.cursorPos.y * 18)
        else --Otherwise, we're in the crafting annex, so...
            local width, height = selectionSprite:getWidth(), selectionSprite:getHeight()
            love.graphics.drawq(selectionSprite,
                love.graphics.newQuad(0, 0, width, height, width, height),
                firstSlotPos.x + (self.cursorPos.x - 3) * 19 + 101, firstSlotPos.y + 18)
        end

        --On the weapons screen, draw a green border around the currently selected index if it is in view
        if self.state == 'openWeapons' then --TODO: WRONG! SO SO WRONG! Fix it
            local lowestVisibleIndex = (self.scrollbar - 1) * 2
            if self.selectedWeaponIndex >= lowestVisibleIndex and self.selectedWeaponIndex < lowestVisibleIndex + 8 then
                local weaponPosition = self.selectedWeaponIndex - lowestVisibleIndex
                local width, height = curWeaponSelect:getWidth(), curWeaponSelect:getHeight()
                love.graphics.drawq(curWeaponSelect,
                    love.graphics.newQuad(0, 0, width, height, width, height),
                    self:slotPosition(weaponPosition).x + firstSlotPos.x - 2,
                    self:slotPosition(weaponPosition).y + firstSlotPos.y - 2)
            end
        end

        --Draw the crafting window, if it's open
        if self.craftingVisible then
            self:craftingAnimation():draw(craftingannexSprite, os.x +97, pos.y + 42)
            if self.currentIngredients.a then
                local indexDisplay = debugger.on and self.currentIngredients.a
                local item = self:currentPage()[self.currentIngredients.a]
                item:draw({x = 102 + firstSlotPos.x, y = 19 + firstSlotPos.y}, indexDisplay)
            end
            if self.currentIngredients.b then
                local indexDisplay = debugger.on and self.currentIngredients.b
                local item = self:currentPage()[self.currentIngredients.b]
                item:draw({x = 121 + firstSlotPos.x, y = 19 + firstSlotPos.y}, indexDisplay)
            end
            --Draw the result of a valid recipe
            if self.currentIngredients.a and self.currentIngredients.b then 
                local result = self:findResult(self:currentPage()[self.currentIngredients.a], self:currentPage()[self.currentIngredients.b])
                if result then
                    local resultFolder = string.lower(result.type)..'s'
                    local itemNode = require ('items/' .. resultFolder .. '/' .. result.name)
                    local item = Item.new(itemNode)
                    item:draw({x = 83 + firstSlotPos.x, y = 19 + firstSlotPos.y})
                end
            end
        end

    end
end

---
-- Returns the current inventory animation
-- @return animation
function Inventory:animation()
    assert(self.animations[self.animState] ~= nil, 'State ' .. self.animState .. ' does not have a corrisponding animation!')
    return self.animations[self.animState]
end

---
-- Returns the crafting annex animation
-- @return animation
function Inventory:craftingAnimation()
    return self.craftingAnimations[self.craftingState]
end

---
-- Gets the current page
-- @return the current inventory page table
function Inventory:currentPage()
    assert(self:isOpen(), 'You cannot get the current page when inventory is closed!')
    local page = self.pages[self.currentPageName]
    assert(page, 'Could not find page "' .. self.currentPageName .. '"')
    return page
end

---
-- Determines whether the inventory is fully opened
-- @return boolean
function Inventory:isOpen()
    return self.animState == 'open'
end

---
-- Handles player input while in the inventory
-- @return nil
function Inventory:keypressed( button )
    local keys = {
        UP = self.up,
        DOWN = self.down,
        RIGHT = self.right,
        LEFT = self.left,
        SELECT = self.close,
        ATTACK = self.select
    }
    if self:isOpen() and keys[button] then keys[button]() end
end

---
-- Moves the cursor up
-- @return nil
function Inventory:up()
    if self.cursorPos.y == 0 then
        if self.scrollbar > 1 then
            self.scrollbar = self.scrollbar - 1
        end
        return
    end
    self.cursorPos.y = self.cursorPos.y - 1
end

---
-- Moves the cursor down
-- @return nil
function Inventory:down()
    if self.cursorPos.y == 3 then
        if self.scrollbar < 4 then
            self.scrollbar = self.scrollbar + 1
        end
        return
    end
    self.cursorPos.y = self.cursorPos.y + 1
end

---
-- Moves the cursor right
-- @return nil
function Inventory:right()
    if self.cursorPos.x > 1 then self.cursorPos.y = 1 end
    local maxX = self.craftingVisible and 4 or 1
    if self.cursorPos.x < maxX then
        self.cursorPos.x = self.cursorPos.x + 1
    else
        self:switchScreen(1)
    end
end

---
-- Moves the cursor left
-- @return nil
function Inventory:left()
    if self.cursorPos.x > 1 then self.cursorPos.y = 1 end
    if self.cursorPos.x > 0 then
        self.cursorPos.x = self.cursorPos.x - 1
    else
        self:switchScreen(2)
    end
end

---
-- Switches to the next or previous inventory screen
-- @param direction 1 for next or 2 for previous determines direction of page switch
-- @return nil
function Inventory:switchScreen( direction )
    self:craftingClose()
    self.cursorPos.x = 0
    self.scrollbar = 1
    self.currentPageName = self.pageList[self.currentPage][direction]
end

---
-- Closes the inventory
-- @return nil
function Inventory:close()
    self.player.controlState:standard()
    self:craftingClose()
    self.animState = 'closing'
    self:animation():resume()
end

---
-- Closes the crafting annex
-- @return nil
function Inventory:craftingClose()
    self.craftingState = 'closing'
    self:craftingAnimation():resume()
    self.currentIngredients = {}
end

---
-- Opens the inventory
-- @return nil
function Inventory:open()
    self.player.controlState:inventory()
    self.visible = true
    self.state = 'opening'
    self:animation():resume()
end

---
-- Opens the crafting annex
-- @return nil
function Inventory:craftingOpen()
    self.craftingVisible = true
    self.craftingState = 'opening'
    self:craftingAnimation():resume()
end

---
-- Handles the player selecting a slot in the inventory
-- @return nil
function Inventory:select()
    local functions = {
        weapons = self.wieldCurrentSlot,
        consumables = self.consumeCurrentSlot,
        materials = self.craftCurrentSlot
    }
    if functions[self.currentPageName] then functions[self.currentPageName]() end
end

---
-- Selects the current slot as the equipped weapon
-- @return nil
function Inventory:wieldCurrentSlot()
    self.selectedWeaponIndex = self:slotIndex(self.cursorPos)
    local weapon = self.pages.weapons[self.selectedWeaponIndex]
    self.player:selectWeapon(weapon)
    self.player.doBasicAttack = false
end

---
-- Consumes the currently selected consumable
-- @return nil
function Inventory:consumeCurrentSlot()
    self.selectedConsumableIndex = self:slotIndex(self.cursorPos)
    local consumable = self.pages.consumables[self.selectedConsumableIndex]
    if consumable then
        consumable:use(self.player)
        sound.playSfx('confirm')
    end
end

---
-- Handles the crafting window selection functionality
-- @return nil
function Inventory:craftCurrentSlot()
    if not self.craftingVisible then
        self:craftingOpen()
    end
    if self.cursorPos.x > 1 then --While in the crafting annex, use this selection behavior for items
        if self.cursorPos.x == 3 and self.currentIngredients.a then
            self.currrentIngredients.a = nil
            if self.currentIngredients.b then
                self.currentIngredients.a = self.currentIngredients.b
                self.currentIngredients.b = nil
            end
        end
        if self.cursorPos.x == 4 and self.currentIngredients.b then
            self.currentIngredients.b = nil
        end
        if self.cursorPos.x == 2 and self.currentIngredients.a and self.currentIngredients.b then
            self:craft()
        end
        return
    end
    if self.currentIngredients.b then return end --If the crafting annex is already full then return
    if self:currentPage()[self:slotIndex(self.cursorPos)] == nil then return end -- Ignore empty slots
    if self.currentIngredients.a == self:sllotIndex(self.cursorPos) or self.currentIngredients.b == self:slotIndex(self.cursorPos) then return end -- Ignore already selected items
    if not self.currentIngredients.a then
        self.currentIngredients.a = self:slotIndex(self.cursorPos)
    else
        self.currentIngredients.b = self:slotIndex(self.cursorPos)
    end
end

---
-- Crafts items when the player selects the craft item slot with a full crafting window
-- @return nil
function Inventory:craft()
    local result = self:findResult(self:currentPage()[self.currentIngredients.a], self:currentPage()[self.currentIngredients.b]) --Look up the crafting recipe
    if not result then return end --If there is no recipe for these items, do nothing.
    local resultFolder = string.lower(result.type)..'s'
    local itemNode = require('items/' .. resultFolder .. '/' .. result.name)
    local item = Item.new(itemNode)
    self:addItem(item)
    
    self:removeItem(self.currentIngredients.a, self.currentPageName)
    self:removeItem(self.currentIngredients.b, self.currentPageName)
    self.currentIngredients = {}
end

---
-- Finds the recipe, if one exists, for the given pair of items.
-- @param a the first item's name
-- @param b the second item's name
-- @return the resulting item's filename, if one exists, or nil.
function Inventory:findResult( a, b )
    for i = 1, #recipes do
        local currentRecipe = recipes[i]
        if currentRecipe[1].type == a.type and currentRecipe[2].type == b.type and
            currentRecipe[1].name == a.name and currentRecipe[2].name == b.name then
            return currentRecipe[3]
        end
        if currentRecipe[1].type == b.type and currentRecipe[2].type == a.type and
            currentRecipe[1].name == b.name and currentRecipe[2].name == a.name then
            return currentRecipe[3]
        end
    end
    
end

---
-- Adds an item to the players inventory
-- @return a bool representing whether the player added the item
function Inventory:addItem( item )
    local pageName = item.type .. 's'
    local page = self.pages[pageName]
    assert(page ~= nil, 'Bad item type! ' .. item.type .. ' is not a valid item type.')
    if self:tryMerge(item) then return true end --If merge was complete, no need to add the item.
    local slot = self:nextAvailableSlot(pageName)
    if not slot then return false end --If inventory is full (no available slot), return false.
    self.pages[pageName][slot] = item
    sound.playSfx('pickup')
    return true
end

---
-- Removes the item in the given slot
-- @param slotIndex the index of the slot to remove from
-- @param pageName the name of the page on which the item resides
-- @return nil
function Inventory:removeItem( slotIndex, pageName)
    self.pages[pageName][slotIndex] = nil
end

---
-- Finds the first available slot on the page. Returns a -1 if no slots are available.
-- @return number of first available slot, or nil if none available.
function Inventory:nextAvailableSlot()
    local page = self:currentPage()
    for i = 0, self.pageLength do
        if not currentPage[i] then return i end
    end
end

---
-- Gets the position of a slot relative to the top left of the first slot
-- @param slotIndex the index of the slot to the find the position of
-- @returns the slot position
function Inventory:slotPosition( slotIndex )
    return {
        x = math.floor(slotIndex / 2) * 18 + 1,
        y = slotIndex % 2 * 38 + 1
    }
end

---
-- Gets the index of a given cursor position
-- @return the slot index corrusponding to the position
function Inventory:slotIndex( slotPosition)
    return slotPosition.x + ((slotPosition.y + self.scrollbar -1) * 2)
end

---
-- Gets the current weapon
-- @return the currently selected weapon
function Inventory:currentWeapon()
    local selectedWeapon = self.pages.weapons[self.selectedWeaponIndex]
    if selectedWeapon then return selectedWeapon end
end

--TODO: The following functions contain similar search functionality that should ideally be separated out for reusability.

---
-- Searches inventory for the first instance of 'item'
-- @param item the item being searched for
-- @return the first item found, its page index value, and its slot index value. else, returns nil
function Inventory:search( item )
    local page = item.type .. 's'
    for i = 0, self.pageLength do
        local itemInSlot = self.pages[page][i]
        if itemInSlot and itemInSlot.name == item.name then
            return itemInSlot, page, i
        end
    end
end

---
-- Searches inventory and counts the total number of 'item' present
-- @param item the item being counted
-- @return number of 'item' in inventory
function Inventory:count( item )
    local page = item.type .. 's'
    local count = 0
    for i = 0, selfpageLength do
        local itemInSlot = self.pages[page][i]
        if itemInSlot and itemInSlot.name == item.name then
            count = count + itemInSlot.quantity
        end
    end
    return count
end

---
-- Tries to merge stackable 'item' with any existing stacks in the inventory.
-- @return true if completely merged, false if an item still remains after trying to merge.
function Inventory:tryMerge( item )
    local page = item.type .. 's'
    for i = 0, self.pageLength do
        local itemInSlot = self.pages[page][i]
        if itemInSlot and itemInSlot. name == item.name and itemInSlot. mergible and itemInSlot:mergible(item) then
            if itemInSlot:merge(item) then
                return true
            end
        end
    end
    return false
end

---
-- Searches inventory for keyName
-- @return true if player has key or a 'master' key in the inventory
function Inventory:hasKey( keyName )
    for slot, key in pairs(self.pages.keys) do
        if key.name == keyName or key.name == 'master' then
            return true
        end
    end
end

---
-- Tries to select the next available weapon
-- @return nil
function Inventory:tryNextWeapon()
    local i = self.selectedWeaponIndex + 1
    while i ~= self.selectedWeaponIndex do
        if self.pages.weapons[i] then
            self.selectedWeaponIndex = i
            break
        end
        i = i < self.pageLength and i + 1 or 0
    end
end

return Inventory
