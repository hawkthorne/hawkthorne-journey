-----------------------------------------------------------------------
-- inventory.lua
-- Manages the players currently held objects
-- Created by HazardousPeach
-----------------------------------------------------------------------

local controls = require 'controls'
local anim8 = require 'vendor/anim8'
local sound = require 'vendor/TEsound'
local camera = require 'camera'
local debugger = require 'debugger'

--The crafting recipes (for example stick+rock=knife)
local recipes = require 'items/recipes'
local Item = require 'items/item'

local Inventory = {}
Inventory.__index = Inventory

--Load in all the sprites we're going to be using.
local sprite = love.graphics.newImage('images/inventory/inventory.png')
local scrollSprite = love.graphics.newImage('images/inventory/scrollbar.png')
local selectionSprite = love.graphics.newImage('images/inventory/selection.png')
local curWeaponSelect = love.graphics.newImage('images/inventory/selectedweapon.png')
local craftingAnnexSprite = love.graphics.newImage('images/inventory/craftingannex.png')
craftingAnnexSprite:setFilter('nearest', 'nearest')
sprite:setFilter('nearest', 'nearest')
scrollSprite:setFilter('nearest','nearest')

--The animation grids for different animations.
local g = anim8.newGrid(100, 105, sprite:getWidth(), sprite:getHeight())
local scrollG = anim8.newGrid(5,40, scrollSprite:getWidth(), scrollSprite:getHeight())
local craftingG = anim8.newGrid(75, 29, craftingAnnexSprite:getWidth(), craftingAnnexSprite:getHeight())

---
-- Creates a new inventory
-- @return inventory
function Inventory.new( player )
    local inventory = {}
    setmetatable(inventory, Inventory)
    
    inventory.player = player

    --These variables keep track of whether the inventory is open, and whether the crafting annex is open.
    inventory.visible = false
    inventory.craftingVisible = false

    --These variables keep track of whether certain keys were down the last time we checked. This is neccessary to only do actions once when the player presses something.
    inventory.openKeyWasDown = false
    inventory.rightKeyWasDown = false
    inventory.leftKeyWasDown = false
    inventory.upKeyWasDown = false
    inventory.downKeyWasDown = false
    inventory.selectKeyWasDown = false

    inventory.pages = {} --These are the pages in the inventory that hold items
    for i=0, 3 do
        inventory.pages[i] = {}
    end
    inventory.pageNames = {'Weapons', 'Keys', 'Materials', 'Potions'}
    inventory.pageIndexes = {weapons = 0, keys = 1, materials = 2, potions = 3}
    inventory.cursorPos = {x=0,y=0} --The position of the cursor.
    inventory.selectedWeaponIndex = 0 --The index of the item on the weapons page that is selected as the current weapon.

    inventory.state = 'closed' --The current state of the crafting box.

    --These are all the different states of the crafting box and their respective animations.
    inventory.animations = {
        opening = anim8.newAnimation('once', g('1-5,1'),0.05), --The box is currently opening
        openWeapons = anim8.newAnimation('once', g('6,1'), 1), --The box is open, and on the weapons page.
        openKeys = anim8.newAnimation('once', g('7,1'), 1), --The box is open, and on the keys page.
        openMaterials = anim8.newAnimation('once', g('8,1'), 1), --The box is open, and on the materials page.
        openPotions = anim8.newAnimation('once', g('9,1'), 1), --The box is open, and on the potions page.
        closing = anim8.newAnimation('once', g('1-5,1'),0.02), --The box is currently closing.
        closed = anim8.newAnimation('once', g('1,1'),1) --The box is fully closed. Strictly speaking, this animation is not necessary as the box is invisible when in this state.
    }
    inventory.animations['closing'].direction = -1 --Sort of a hack, these two lines allow the closing animation to be the same as the opening animation, but reversed.
    inventory.animations['closing'].position = 5

    inventory.scrollAnimations = {
        anim8.newAnimation('once', scrollG('1,1'),1),
        anim8.newAnimation('once', scrollG('2,1'),1),
        anim8.newAnimation('once', scrollG('3,1'),1),
        anim8.newAnimation('once', scrollG('4,1'),1)
    } --The animations for the scroll bar.

    inventory.scrollbar = 1
    inventory.pageLength = 13

    --This is all pretty much identical to the cooresponding lines for the main inventory, but applies to the crafting annex.
    inventory.craftingState = 'closing'
    inventory.craftingAnimations = {
        opening = anim8.newAnimation('once', craftingG('1-6,1'),0.04),
        open = anim8.newAnimation('once', craftingG('6,1'), 1),
        closing = anim8.newAnimation('once', craftingG('1-6,1'),0.01)
    }
    inventory.craftingAnimations['closing'].direction = -1
    inventory.craftingAnimations['closing'].position = 6
    inventory.currentIngredients = {a = -1, b = -1} --The indices of the current ingredients. -1 indicates no ingredient

    return inventory
end

---
-- Returns the inventorys animation
-- @return animation
function Inventory:animation()
    assert(self.animations[self.state] ~= nil, "State " .. self.state .. " does not have a coorisponding animation!")
    return self.animations[self.state]
end

---
-- Returns the crafting annex's animation
-- @return the crafting annex's animation
function Inventory:craftingAnimation()
    return self.craftingAnimations[self.craftingState]
end

---
-- Draws the inventory to the screen
-- @param playerPosition the coordinates to draw offset from
-- @return nil
function Inventory:draw(playerPosition)
    if not self.visible then return end

    --The default position of the inventory
    local pos = {x=playerPosition.x - (g.frameWidth + 6),y=playerPosition.y - (g.frameHeight - 22)}

    --If the default position would result in our left side being off the map, move to the right side of the player
    if pos.x < 0 then
        pos.x = playerPosition.x + --[[width of player--]] 48 + 6
    end

    --If the inventory would be drawn underneath the HUD then lower the vertical position.
    local hud_right = camera.x + 130
    local hud_top = camera.y + 60
    if pos.x < hud_right and pos.y < hud_top then
        pos.y = hud_top
    end
    
    --If the default y position would result in our top being above the map, move us down until we are on the map
    if pos.y < 0 then pos.y = 0 end
    
    --Now, draw the main body of the inventory screen
    self:animation():draw(sprite, pos.x, pos.y)
    
    --Only draw the rest of this if the inventory is fully open, and not currently opening.
    if (self:isOpen()) then

       --Draw the crafting annex, if it's open
       if self.craftingVisible then
           self:craftingAnimation():draw(craftingAnnexSprite, pos.x + 97, pos.y + 42)
       end
        
        --Draw the scroll bar
        self.scrollAnimations[self.scrollbar]:draw(scrollSprite, pos.x + 8, pos.y + 43)

        --Stands for first frame position, indicates the position of the first item slot (top left) on screen
        local ffPos = {x=pos.x + 29,y=pos.y + 30} 

        --Draw the white border around the currently selected slot
        if self.cursorPos.x < 2 then --If the cursor is in the main inventory section, draw this way
            love.graphics.drawq(selectionSprite, 
                love.graphics.newQuad(0,0,selectionSprite:getWidth(),selectionSprite:getHeight(),selectionSprite:getWidth(),selectionSprite:getHeight()),
                ffPos.x + self.cursorPos.x * 38, ffPos.y + self.cursorPos.y * 18)
        else --Otherwise, we're in the crafting annex, so draw this way.
            love.graphics.drawq(selectionSprite,
                love.graphics.newQuad(0,0,selectionSprite:getWidth(), selectionSprite:getHeight(), selectionSprite:getWidth(), selectionSprite:getHeight()),
                ffPos.x + (self.cursorPos.x - 3) * 19 + 101, ffPos.y + 18)
        end

        --Draw all the items in their respective slots
        for i=0,7 do
            local scrollIndex = i + ((self.scrollbar - 1) * 2)
            local indexDisplay = scrollIndex
            if self:currentPage()[scrollIndex] ~= nil then
                local slotPos = self:slotPosition(i)
                local item = self:currentPage()[scrollIndex]
                if not debugger.on then indexDisplay = nil end
                if self.currentIngredients.a ~= scrollIndex and self.currentIngredients.b ~= scrollIndex then
                    if not debugger.on then indexDisplay = nil end
                    item:draw({x=slotPos.x+ffPos.x,y=slotPos.y + ffPos.y}, indexDisplay)
                end
            end
        end

        --Draw the crafting window
        if self.craftingVisible then
            if self.currentIngredients.a ~= -1 then
                local indexDisplay = self.currentIngredients.a
                if not debugger.on then indexDisplay = nil end
                local item = self:currentPage()[self.currentIngredients.a]
                item:draw({x=ffPos.x + 102,y= ffPos.y + 19}, indexDisplay)
            end
            if self.currentIngredients.b ~= -1 then
                local indexDisplay = self.currentIngredients.b
                if not debugger.on then indexDisplay = nil end
                local item = self:currentPage()[self.currentIngredients.b]
                item:draw({x=ffPos.x + 121,y= ffPos.y + 19}, indexDisplay)
            end
            --Draw the result of a valid recipe
            if self.currentIngredients.a ~= -1 and self.currentIngredients.b ~= -1 then
                local result = self:findResult(self:currentPage()[self.currentIngredients.a], self:currentPage()[self.currentIngredients.b])
                if result ~= nil then
                    local resultFolder = string.lower(result.type)..'s'
                    local itemNode = require ('items/' .. resultFolder .. '/' .. result.name)
                    local item = Item.new(itemNode)
                    item:draw({x=ffPos.x + 83, y=ffPos.y + 19}, nil)
                end
            end
        end


        --If we're on the weapons screen, then draw a green border around the currently selected index, unless it's out of view.
        if self.state == 'openWeapons' then
            local lowestVisibleIndex = (self.scrollbar - 1 )* 2
            local weaponPosition = self.selectedWeaponIndex - lowestVisibleIndex
            if self.selectedWeaponIndex >= lowestVisibleIndex and self.selectedWeaponIndex < lowestVisibleIndex + 8 then
                love.graphics.drawq(curWeaponSelect,
                    love.graphics.newQuad(0,0, curWeaponSelect:getWidth(), curWeaponSelect:getHeight(), curWeaponSelect:getWidth(), curWeaponSelect:getHeight()),
                    self:slotPosition(weaponPosition).x + ffPos.x - 2, self:slotPosition(weaponPosition).y + ffPos.y - 2)
            end
        end


    end
end

---
-- Updates the inventory with player input
-- @param dt the delta time for updating the animation.
-- @return nil
function Inventory:update( dt )
    if not self.visible then return end

    --Update the animations
    self:animation():update(dt)
    self:craftingAnimation():update(dt)

    --If we're finished with an animation, then in some cases that means we should move to the next one.
    if self:animation().status == "finished" then
        if self.state == "closing" then
            self:closed()
        elseif self.state == "opening" then
            self:opened()
        end
    end
    if self:craftingAnimation().status == "finished" then
        if self.craftingState == "closing" then
            self:craftingClosed()
        elseif self.craftingState == "opening" then
            self:craftingOpened()
        end
    end
end

function Inventory:keypressed( button )
    if self:isOpen() then
        if button == 'SELECT' then
            self:close()
        end
        if button == 'RIGHT' then
            self:right()
        end
        if button == 'LEFT' then
            self:left()
        end
        if button == 'UP' then
            self:up()
        end
        if button == 'DOWN' then
            self:down()
        end
        if button == 'ATTACK' then
            self:select()
        end
    end
end

---
-- Begins opening the players inventory.
-- @return nil
function Inventory:open( )
    self.player.controlState:inventory()
    self.visible = true
    self.state = 'opening'
    self:animation():resume()
end

---
-- Begins opening the crafting annex
-- @return nil
function Inventory:craftingOpen()
    self.craftingVisible = true
    self.craftingState = 'opening'
    self:craftingAnimation():resume()
end

---
-- Finishes opening the players inventory
-- @return nil
function Inventory:opened()
    self:animation():gotoFrame(1)
    self:animation():pause()
    self.state = "openMaterials"
end

---
-- Finishes opening the crafting annex
-- @return nil
function Inventory:craftingOpened()
    self:craftingAnimation():gotoFrame(1)
    self:craftingAnimation():pause()
    self.craftingState = "open"
end

---
-- Determines whether the inventory is currently open
-- @return whether the inventory is currently open
function Inventory:isOpen()
    return self.state == 'openKeys' or self.state == 'openMaterials' or self.state == 'openPotions' or self.state == 'openWeapons'
end

---
-- Begins closing the players inventory
-- @return nil
function Inventory:close()
    self.player.controlState:standard()
    self:craftingClose()
    self.state = 'closing'
    self:animation():resume()
end

---
-- Begins closing the crafting annex
-- @return nil
function Inventory:craftingClose()
    self.craftingState = 'closing'
    self:craftingAnimation():resume()
    self.currentIngredients = {a=-1,b=-1}
end

---
-- Finishes closing the players inventory
-- @return nil
function Inventory:closed()
    self:animation():gotoFrame(5)
    self:animation():pause()
    self.visible = false
    self.state = 'closed'
    self.cursorPos = {x=0,y=0}
    self.scrollbar = 1
    self.player.freeze = false
end

---
-- Finishes closing the players inventory
-- @return nil
function Inventory:craftingClosed()
    self:craftingAnimation():gotoFrame(5)
    self:craftingAnimation():pause()
    self.craftingVisible = false
end

---
-- Moves to the next inventory screen
-- @return nil
function Inventory:nextScreen()
    local nextState = ""
    self:craftingClose()
    self.scrollbar = 1
    if self.state == "openWeapons" then
        nextState = "openKeys"
    end
    if self.state == "openKeys" then
        nextState = "openMaterials"
    end
    if self.state == "openMaterials" then
        nextState = "openPotions"
    end
    if self.state == "openPotions" then
        nextState = "openWeapons"
    end
    if nextState ~= "" then
        self.state = nextState
    end
end

---
-- Moves to the previous inventory screen
-- @return nil
function Inventory:prevScreen()
    local nextState = ""
    self:craftingClose()
    self.scrollbar = 1
    if self.state == "openKeys" then
        nextState = "openWeapons"
    end
    if self.state == "openMaterials" then
        nextState = "openKeys"
    end
    if self.state == "openPotions" then
        nextState = "openMaterials"
    end
    if self.state == "openWeapons" then
        nextState = "openPotions"
    end
    if nextState ~= "" then
        self.state = nextState
    end
end

---
-- Moves the cursor right
-- @return nil
function Inventory:right()
    if self.cursorPos.x > 1 then self.cursorPos.y = 1 end
    local maxX = 1
    if self.craftingVisible then 
        maxX = 4 
    end
    if self.cursorPos.x < maxX then
        self.cursorPos.x = self.cursorPos.x + 1
    else
        self:nextScreen()
        self.cursorPos.x = 0
    end
end

---
-- Moves the cursor left
-- @return nil
function Inventory:left()
    if self.cursorPos.x > 1 then
        self.cursorPos.y = 1 
    end
    local maxX = 1
    if self.craftingVisible then 
        maxX = 4 
    end
    if self.cursorPos.x > 0 then
        self.cursorPos.x = self.cursorPos.x - 1
    else
        self:prevScreen()
        self.cursorPos.x = 1
    end
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
-- Adds an item to the players inventory
-- @return a bool representing whether the player could add the item
function Inventory:addItem(item)
    local pageIndex = self.pageIndexes[item.type .. "s"]
    assert(pageIndex ~= null, "Bad Item type! " .. item.type .. " is not a valid item type.")
    if self:tryMerge(item) then return true end --If we had a complete successful merge with no remainders, there is no reason to add the item.
    local slot = self:nextAvailableSlot(pageIndex)
    if slot == -1 then
        return false
    end
    self.pages[pageIndex][slot] = item
    sound.playSfx('pickup')
    return true
end

---
-- Removes the item in the given slot
-- @parameter slotIndex the index of the slot to remove from
-- @parameter pageIndex the index of the page on which the item resides
-- @return nil
function Inventory:removeItem(slotIndex, pageIndex)
    self.pages[pageIndex][slotIndex] = nil
    if pageIndex == 0 and slotIndex == self.selectedWeaponIndex then 
        self:tryNextWeapon()
    end
end

---
-- Finds the first available slot on the page. Returns -1 if no slots are available
-- @param pageIndex the index of the page to check
-- @returns nil
function Inventory:nextAvailableSlot(pageIndex)
    local currentPage = self.pages[pageIndex]
    for i=0, self.pageLength do
        if currentPage[i] == nil then
            return i
        end
    end
    return -1
end

---
-- Gets the position of a slot relative to the top left of the first slot
-- @param slotIndex the index of the slot to find the position of
-- @returns the slot position
function Inventory:slotPosition(slotIndex)
    yPos = math.floor(slotIndex / 2) * 18 + 1
    xPos = slotIndex % 2 * 38 + 1
    return {x = xPos, y = yPos}
end

---
-- Gets the current page
-- @returns the current page
function Inventory:currentPage()
    assert(self:isOpen(), "Inventory is closed, you cannot get the current page when inventory is closed.")
    local pageName = string.lower(self.state:sub(5,self.state:len()))
    local pageIndex = self.pageIndexes[pageName]
    local page = self.pages[pageIndex]
    assert(page ~= nil, "Could not find page ".. pageName .. " at index " .. pageIndex)
    return page
end

-- returns true if the player has the key or a 'master' key
function Inventory:hasKey(keyName)
    local pageIndex = self.pageIndexes['keys']
    for slot,key in pairs(self.pages[pageIndex]) do
        if key.name == keyName or key.name == "master" then
            return true
        end
    end
    return
end

---
-- Gets the currently selected weapon
-- @returns the currently selected weapon
function Inventory:currentWeapon()
    local selectedWeapon = self.pages[self.pageIndexes['weapons']][self.selectedWeaponIndex]
    if selectedWeapon then
        return selectedWeapon
    end
    return nil
end

---
-- Gets the index of a given cursor position
-- @return the slot index coorisponding to the position
function Inventory:slotIndex(slotPosition)
    return slotPosition.x + ((slotPosition.y + self.scrollbar - 1) * 2)
end

---
-- Selects the current slot as the selected weapon
-- @return nil
function Inventory:selectCurrentSlot()
    self.selectedWeaponIndex = self:slotIndex(self.cursorPos)
    local weapon = self.pages[self.pageIndexes['weapons']][self.selectedWeaponIndex]
    self.player:useWeapon(weapon)
end

---
-- Handles the player selecting a slot in thier inventory
-- @return nil
function Inventory:select()
    if self.state == "openWeapons" then self:selectCurrentSlot() end

    ---------This is all crafting stuff.
    if self.state == "openMaterials" then --We can only craft in the materials section.
        if not self.craftingVisible then --If we're in the materials section, we try to craft something, and the annex isn't open, open it.
            self:craftingOpen() 
        end
        if self.cursorPos.x > 1 then --If we're already in the crafting annex, then we have some special behavior
            if self.cursorPos.x == 3 and self.currentIngredients.a ~= -1 then --If we're selecting the first ingredient, and it's not empty, then we remove it
                self.currentIngredients.a = -1
                if self.currentIngredients.b ~= nil then --If we're removing the first ingredient, and there is a second ingredient, put remove it from the b slot and add it to the a slot
                    self.currentIngredients.a = self.currentIngredients.b
                    self.currentIngredients.b = -1
                end
            end
            if self.cursorPos.x == 4 and self.currentIngredients.b ~= -1 then --If we're selecting the second ingredient, and it's not empty, then we remove it
                self.currentIngredients.b = -1
            end
            if self.cursorPos.x == 2 and self.currentIngredients.a ~= -1 and self.currentIngredients.b ~= -1 then --If we're pressing the craft button and there are two incredients selected, then we can craft
                self:craft()
            end
            return 
        end
        if self.currentIngredients.b ~= -1 then return end --If we're already full, don't do anything
        if self:currentPage()[self:slotIndex(self.cursorPos)] == nil then return end --If we are selecting an empty slot, don't do anything
        if self.currentIngredients.a == self:slotIndex(self.cursorPos) or self.currentIngredients.b == self:slotIndex(self.cursorPos) then return end --If we already have the current item selected, don't do anything
        if self.currentIngredients.a == -1 then
            self.currentIngredients.a = self:slotIndex(self.cursorPos)
        else
            self.currentIngredients.b = self:slotIndex(self.cursorPos)
        end
    end
end

---
-- Crafts items when the player selects the craft item button
-- @return nil
function Inventory:craft()
    local result = self:findResult(self:currentPage()[self.currentIngredients.a], self:currentPage()[self.currentIngredients.b]) --We get the item that should result from the craft.
    if result == nil then return end --If there is no recipe for these items, do nothing.
    local resultFolder = string.lower(result.type)..'s'
    itemNode = require ('items/' .. resultFolder..'/'..result.name)
    local item = Item.new(itemNode)
    self:addItem(item) --Add this item to it's appropriate place.

    --Get our current page. Technically not very useful, as it will always be Materials since that is the only place you can craft.
    local pageName = string.lower(self.state:sub(5,self.state:len()))
    local pageIndex = self.pageIndexes[pageName]

    --Remove the "used up" ingredients.
    self:removeItem(self.currentIngredients.a, pageIndex)
    self:removeItem(self.currentIngredients.b, pageIndex)
    self.currentIngredients.a = -1
    self.currentIngredients.b = -1
end

---
-- Finds the recipe, if one exists, for the given pair of items. If none exists return nil.
-- @param a the first item's name
-- @param b the second item's name
-- @return the resulting item's filename, if one exists, or nil.
function Inventory:findResult(a, b)
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
-- Tries to select the next available weapon
-- @return nil
function Inventory:tryNextWeapon()
    local i = self.selectedWeaponIndex + 1
    while i ~= self.selectedWeaponIndex do
        if self.pages[0][i] ~= nil then
            self.selectedWeaponIndex = i
            break
        end
        if i < self.pageLength then 
            i = i + 1
        else 
            i = 0 
        end
    end
end

--- 
-- Tries to merge the item with one that is already in the inventory. Returns false if there is still something left.
function Inventory:tryMerge(item)
    for i = 0, self.pageLength, 1 do
        local itemInSlot = self.pages[self.pageIndexes[item.type .. "s"]][i]
        if itemInSlot ~= nil and itemInSlot.name == item.name and itemInSlot.mergible and itemInSlot:mergible(item) then
        --This statement does a lot more than it seems. First of all, regardless of whether itemInSlot:merge(item) returns true or false, some merging is happening. If it returned false
        --then the item was partially merged, so we are getting the remainder of the item back to continue to try to merge it with other items. If it returned true, then we got a
        --complete merge, and we can stop looking right now.
            if itemInSlot:merge(item) then 
                return true
            end
        end
    end
    return false
end

return Inventory
