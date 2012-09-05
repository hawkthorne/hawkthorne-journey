-----------------------------------------------------------------------
-- inventory.lua
-- Manages the players currently held objects
-- Created by HazardousPeach
-----------------------------------------------------------------------

local anim8 = require 'vendor/anim8'
local knife = require 'items/throwingKnifeItem'

local Inventory = {}
Inventory.__index = Inventory

local sprite = love.graphics.newImage('images/inventory.png')
sprite:setFilter('nearest', 'nearest')

local scrollSprite = love.graphics.newImage('images/inventoryScrollBar.png')
scrollSprite:setFilter('nearest','nearest')

local selectionSprite = love.graphics.newImage('images/inventory_selection.png')
local curWeaponSelect = love.graphics.newImage('images/selectedWeapon.png')

local g = anim8.newGrid(100, 105, sprite:getWidth(), sprite:getHeight())
local scrollG = anim8.newGrid(5,40, scrollSprite:getWidth(), scrollSprite:getHeight())

---
-- Creates a new inventory
-- @return inventory
function Inventory.new()
    local inventory = {}

    setmetatable(inventory, Inventory)
    inventory.visible = false
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
    inventory.pageNames = {'Weapons', 'Blocks', 'Materials', 'Potions'}
    inventory.pageIndexes = {Weapons = 0, Blocks = 1, Materials = 2, Potions = 3}
    inventory.cursorPos = {x=0,y=0}
    inventory.selectedWeaponIndex = 0

    inventory.state = 'closed'
    inventory.animations = {
        opening = anim8.newAnimation('once', g('1-5,1'),0.05),
        openWeapons = anim8.newAnimation('once', g('6,1'), 1),
        openBlocks = anim8.newAnimation('once', g('7,1'), 1),
        openMaterials = anim8.newAnimation('once', g('8,1'), 1),
        openPotions = anim8.newAnimation('once', g('9,1'), 1),
        closing = anim8.newAnimation('once', g('1-5,1'),0.02),
        closed = anim8.newAnimation('once', g('1,1'),1)
    }
    inventory.animations['closing'].direction = -1
    inventory.animations['closing'].position = 5

    inventory.scrollAnimations = {
        anim8.newAnimation('once', scrollG('1,1'),1),
        anim8.newAnimation('once', scrollG('2,1'),1),
        anim8.newAnimation('once', scrollG('3,1'),1),
        anim8.newAnimation('once', scrollG('4,1'),1)
    }

    --For testing purposes
    inventory.pages[inventory.pageIndexes['Weapons']][0] = knife.new()

    return inventory
end

---
-- Returns the inventorys animation
-- @return animation
function Inventory:animation()
    assert(self.animations[self.state] ~= null, "State " .. self.state .. " does not have a coorisponding animation!")
    return self.animations[self.state]
end

---
-- Draws the inventory to the screen
-- @param playerPosition the coordinates to draw offset from
-- @return nil
function Inventory:draw(playerPosition)
    if not self.visible then --If the inventory is closed, don't draw it
        return
    end

    --The default position of the inventory
    local pos = {x=playerPosition.x - (g.frameWidth + 6),y=playerPosition.y - (g.frameHeight - 22)}

    --If the default position would result in our left side being off the map, move to the right side of the player
    if pos.x < 0 then
        pos.x = playerPosition.x + --[[width of player--]] 48 + 6
    end
    
    --If the default y position would result in our top being above the map, move us down until we are on the map
    if pos.y < 0 then pos.y = 0 end
    
    --Now, draw the main body of the inventory screen
    self:animation():draw(sprite, pos.x, pos.y)
    
    --Only draw the rest of this if the inventory is fully open, and not currently opening.
    if (self:isOpen()) then
        
        --Draw the scroll bar
        self.scrollAnimations[1]:draw(scrollSprite, pos.x + 8, pos.y + 43)

        --Stands for first frame position, indicates the position of the first item slot (top left) on screen
        local ffPos = {x=pos.x + 29,y=pos.y + 30} 

        --Draw the white border around the currently selected slot
        love.graphics.drawq(selectionSprite, 
            love.graphics.newQuad(0,0,selectionSprite:getWidth(),selectionSprite:getHeight(),selectionSprite:getWidth(),selectionSprite:getHeight()),
            ffPos.x + self.cursorPos.x * 38, ffPos.y + self.cursorPos.y * 18)

        --Draw all the items in their respective slots
        for i=0,7 do
            if self:currentPage()[i] ~= nil then
                local slotPos = self:slotPosition(i)
                self:currentPage()[i]:draw({x=slotPos.x+ffPos.x,y=slotPos.y + ffPos.y})
            end
        end

        --If we're on the weapons screen, then draw a green border around the currently selected index.
        if self.state == 'openWeapons' then
            love.graphics.drawq(curWeaponSelect,
                love.graphics.newQuad(0,0, curWeaponSelect:getWidth(), curWeaponSelect:getHeight(), curWeaponSelect:getWidth(), curWeaponSelect:getHeight()),
                self:slotPosition(self.selectedWeaponIndex).x + ffPos.x - 2, self:slotPosition(self.selectedWeaponIndex).y + ffPos.y - 2)
        end
    end
end

---
-- Updates the inventory with player input
-- @param dt the delta time for updating the animation.
-- @return nil
function Inventory:update(dt)
    self:animation():update(dt)

    if self:animation().status == "finished" then
        if self.state == "closing" then
            self:closed()
        elseif self.state == "opening" then
            self:opened()
        end
    end

    if love.keyboard.isDown('e') then
        if not self.openKeyWasDown then
            if self:isOpen() then
                self:close()
            elseif self.state == 'closed' then
                self:open()
            end
        end
            self.openKeyWasDown = true
    else
        self.openKeyWasDown = false;
    end
    
    if not self:isOpen() then
        return
    end
    
    if love.keyboard.isDown('right') or love.keyboard.isDown('d') then
        if not self.rightKeyWasDown then
            self:right()
            self.rightKeyWasDown = true
        end
    else
        self.rightKeyWasDown = false
    end
    if love.keyboard.isDown('left') or love.keyboard.isDown('a') then
        if not self.leftKeyWasDown then
            self:left()
            self.leftKeyWasDown = true
        end
    else
        self.leftKeyWasDown = false
    end
    if love.keyboard.isDown('up') or love.keyboard.isDown('w') then
        if not self.upKeyWasDown then
            self:up()
            self.upKeyWasDown = true
        end
    else
        self.upKeyWasDown = false
    end
    if love.keyboard.isDown('down') or love.keyboard.isDown('s') then
        if not self.downKeyWasDown then
            self:down()
            self.downKeyWasDown = true
        end
    else
        self.downKeyWasDown = false
    end
    if self.state == 'openWeapons' then 
        if love.keyboard.isDown('lshift') or love.keyboard.isDown('rshift') then
            if not self.selectKeyWasDown then
                self:selectCurrentSlot()
                self.selectKeyWasDown = true
            end
        else
            self.selectKeyWasDown = false
        end
    end
end

---
-- Begins opening the players inventory.
-- @return nil
function Inventory:open()
    self.visible = true
    self.state = 'opening'
    self:animation():resume()
end

---
-- Finishes opening the players inventory
-- @return nil
function Inventory:opened()
    self:animation():gotoFrame(1)
    self:animation():pause()
    self.state = "openWeapons"
end

---
-- Determines whether the inventory is currently open
-- @return whether the inventory is currently open
function Inventory:isOpen()
    return self.state == 'openBlocks' or self.state == 'openMaterials' or self.state == 'openPotions' or self.state == 'openWeapons'
end

---
-- Begins closing the players inventory
-- @return nil
function Inventory:close()
    self.state = 'closing'
    self:animation():resume()
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
end
---
-- Moves to the next inventory screen
-- @return nil
function Inventory:nextScreen()
    local nextState = ""
    if self.state == "openWeapons" then
        nextState = "openBlocks"
    end
    if self.state == "openBlocks" then
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
    if self.state == "openBlocks" then
        nextState = "openWeapons"
    end
    if self.state == "openMaterials" then
        nextState = "openBlocks"
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
    if self.cursorPos.x == 1 then
        self:nextScreen()
        self.cursorPos.x = 0
        return
    end
    self.cursorPos.x = 1
end

---
-- Moves the cursor left
-- @return nil
function Inventory:left()
    if self.cursorPos.x == 0 then
        self:prevScreen()
        self.cursorPos.x = 1
        return
    end
    self.cursorPos.x = 0
end

---
-- Moves the cursor up
-- @return nil
function Inventory:up()
    if self.cursorPos.y == 0 then
        return
    end
    self.cursorPos.y = self.cursorPos.y - 1
end

---
-- Moves the cursor down
-- @return nil
function Inventory:down()
    if self.cursorPos.y == 3 then
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
    local slot = self:nextAvailableSlot(pageIndex)
    if slot == -1 then
        return false
    end
    self.pages[pageIndex][slot] = item
    return true
end

---
-- Finds the first available slot on the page. Returns -1 if no slots are available
-- @param pageIndex the index of the page to check
-- @returns nil
function Inventory:nextAvailableSlot(pageIndex)
    local currentPage = self.pages[pageIndex]
    for i=0, 8 do
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
    yPos = slotIndex % 4 * 18 + 1
    xPos = math.floor(slotIndex / 4) * 38 + 1
    return {x = xPos, y = yPos}
end

---
-- Gets the current page
-- @returns the current page
function Inventory:currentPage()
    assert(self:isOpen(), "Inventory is closed, you cannot get the current page when inventory is closed.")
    local pageName = self.state:sub(5,self.state:len())
    local pageIndex = self.pageIndexes[pageName]
    local page = self.pages[pageIndex]
    assert(page ~= nil, "Could not find page ".. pageName .. " at index " .. pageIndex)
    return page
end

---
-- Gets the currently selected weapon
-- @returns the currently selected weapon
function Inventory:currentWeapon()
    local selectedWeapon = self.pages[self.pageIndexes['Weapons']][self.selectedWeaponIndex]
    if selectedWeapon then
        return selectedWeapon
    end
    return nil
end

---
-- Gets the index of a given cursor position
-- @return the slot index coorisponding to the position
function Inventory:slotIndex(slotPosition)
    return slotPosition.x * 4 + slotPosition.y
end

---
-- Selects the current slot as the selected weapon
-- @return nil
function Inventory:selectCurrentSlot()
    self.selectedWeaponIndex = self:slotIndex(self.cursorPos)
end

return Inventory