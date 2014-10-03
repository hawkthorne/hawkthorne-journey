local Gamestate = require 'vendor/gamestate'
local sound = require 'vendor/TEsound'
local Item = require 'items/item'
local window = require 'window'
local camera = require 'camera'
local fonts = require 'fonts'
local HUD = require 'hud'
local utils = require 'utils'
local anim8 = require 'vendor/anim8'
local Item = require 'items/item'


--instantiate this gamestate
local state = Gamestate.new()

local ROW = 2 
bundle = {}

local function nonzeroMod(a,b)
    local m = a%b
    if m==0 then
        return b
    else
        return m
    end
end

local function __NULL__() end


--called once when the gamestate is initialized
function state:init()


    self.background = love.graphics.newImage( 'images/shopping/background.png' )
    self.backgroundc = love.graphics.newImage( 'images/shopping/backgroundcategories.png' )
    self.backgroundp = love.graphics.newImage( 'images/shopping/backgroundpurchase.png' )
    self.backgroundt = love.graphics.newImage( 'images/shopping/backgroundtooltip.png' )

    self.selectionbox = love.graphics.newImage ('images/shopping/selection.png' )
    self.noselection = love.graphics.newImage ('images/shopping/noselection.png' )

    self.arrow = love.graphics.newImage("images/menu/small_arrow.png")

    local backgroundtGrid = anim8.newGrid(87, 130, self.backgroundt:getWidth(), self.backgroundt:getHeight())

    self.categories = {}
    self.categories[1] = "weapons"
    self.categories[2] = "materials"
    self.categories[3] = "consumables"
    self.categories[4] = "keys"
    self.categories[5] = "armor"
    self.categories[6] = "misc"

    -- used for centering text below boxes
    self.shift = {}
    self.shift["weapons"] = 2
    self.shift["materials"] = 0
    self.shift["consumables"] = 0
    self.shift["keys"] = 8
    self.shift["armor"] = 6
    self.shift["misc"] = 9

    self.categoriespic = {}
    for i = 1, #self.categories do
        self.categoriespic[i] = love.graphics.newImage('images/shopping/' .. self.categories[i] .. '.png')
    end

    self.items = {}
    self.purchaseOptions = {"BUY", "SELL"} 

    self.categorySelection = utils.indexof(self.categories,"weapons")

    self.itemsSelection = 1
    self.purchaseSelection = 1
    
    self.categoriesWindowLeft = 1
    self.itemsWindowLeft = 1

    self.buyAmount = 1
    self.sellAmount = 1

    self.window = "categoriesWindow"
    self.player = nil
    self.tooltipVisible = false

        --This is all pretty much identical to the corresponding lines for the main inventory, but applies to the tooltip annex.
    self.tooltipState = 'closing'
    self.tooltipAnimations = {
        opening = anim8.newAnimation('once', backgroundtGrid('1-8,1'),0.04),
        open = anim8.newAnimation('once', backgroundtGrid('8,1'), 1),
        closing = anim8.newAnimation('once', backgroundtGrid('1-8,1'),0.06)
    }
    self.tooltipAnimations['closing'].direction = -1
    self.tooltipAnimations['closing'].position = 8

end


--called when the player enters this gamestate
function state:enter(previous, player, screenshot, supplierName)

    fonts.set( 'small' )

    self.previous = previous
    self.player = player
    self.screenshot = screenshot
    self.hud = HUD.new(previous)
    
    self.message = nil

    self.categorySelection = utils.indexof(self.categories,"weapons")
    self.itemsSelection = 1
    self.purchaseSelection = 1

    self.categoriesWindowLeft = 1
    self.itemsWindowLeft = 1

    self.buyAmount = 1
    self.sellAmount = 1

    self.window = "categoriesWindow"

    self.supplierName = supplierName or "blacksmith"
    self.supplier = require ("suppliers/"..self.supplierName)
    assert(self.supplier,"supplier by the name of "..self.supplierName.." has no content")
    assert(utils.propcount(self.supplier)>0, "supplier must have at least one category")

    self.selectText = "PRESS " .. player.controls:getKey('JUMP') .. " TO SELECT"
    self.backText = "PRESS " .. player.controls:getKey('ATTACK') .. " TO GO BACK"
    self.tooltipText = "PRESS " .. player.controls:getKey('INTERACT') .. " TO OPEN THE TOOLTIP"

    for category,stock in pairs(self.supplier) do
        for _,info in pairs(stock) do
            local name = info[1]
            local amount = info[2]
            local item
            if love.filesystem.exists('items/'..category) then
                local itemNode = require ('items/' .. category .. '/' .. name)
                item = Item.new(itemNode)
            elseif category=="keys" then
                local itemNode = {type = 'key',name = name}
                item = Item.new(itemNode)
            else
                error("Unsupported category: "..category)
            end
            info["item"] = item
        end
    end
end


--called when this gamestate receives a keypress event
function state:keypressed( button )

    if button == "START" then
        Gamestate.switch(self.previous)
        self.buyAmount = 1
        self.sellAmount = 1
    end
    
    if self.window=="categoriesWindow" then
        self:categoriesWindowKeypressed(button)
    elseif self.window=="itemsWindow" then
        self:itemsWindowKeypressed(button)
    elseif self.window=="purchaseWindow" then
        self:purchaseWindowKeypressed(button)
    elseif self.window=="messageWindow" then
        self:messageWindowKeypressed(button)
    --[[elseif self.window=="tooltip" then
        self:tooltipWindowKeypressed(button)]]
    end

end


--called when this gamestate receives a keypress event when categoriesWindow is selected
function state:categoriesWindowKeypressed( button )

    local c = #self.categories

    if button == "RIGHT" and self.categorySelection < c then
        self.categorySelection = nonzeroMod(self.categorySelection + 1, c )
        if self.categoriesWindowLeft + ROW < self.categorySelection then
            self.categoriesWindowLeft = self.categorySelection - ROW
        end
        sound.playSfx('click')
    elseif button == "RIGHT" then
        sound.playSfx('unlocked')

    elseif button == "LEFT" and self.categorySelection > 1 then
        self.categorySelection = nonzeroMod(self.categorySelection - 1, c )
        if self.categoriesWindowLeft > self.categorySelection then
            self.categoriesWindowLeft = self.categorySelection      
        end
        sound.playSfx('click')
    elseif button == "LEFT" then
        sound.playSfx('unlocked')

    elseif button == "JUMP" and not self.supplier[self.categories[self.categorySelection]] then
        sound.playSfx('unlocked')
    elseif button == "JUMP" then
        self.window = "itemsWindow"
        self.items = self.supplier[self.categories[self.categorySelection]]
        self.itemSelection = 1
        self.itemsWindowLeft = 1
        sound.playSfx('confirm')
    end

end


--called when this gamestate receives a keypress event when itemsWindow is selected
function state:itemsWindowKeypressed( button )

    local it = #self.items
        
    if button == "RIGHT" and self.itemSelection < it then
        self.itemSelection = nonzeroMod(self.itemSelection + 1, it )
        if self.itemsWindowLeft + ROW < self.itemSelection then
            self.itemsWindowLeft = self.itemSelection - ROW
        end
        sound.playSfx('click')
    elseif button == "RIGHT" then
        sound.playSfx('unlocked')

    elseif button == "LEFT" and self.itemSelection > 1 then            
        self.itemSelection = nonzeroMod(self.itemSelection - 1, it)
        if self.itemsWindowLeft > self.itemSelection then
            self.itemsWindowLeft = self.itemSelection
        end
        sound.playSfx('click')
    elseif button == "LEFT" then
        sound.playSfx('unlocked')

    elseif button == "JUMP" and it > 0 then
        self.purchasSelection = 1
        self.window = "purchaseWindow"
        sound.playSfx('confirm')

    elseif button == "ATTACK" then
        self.window = "categoriesWindow"
        sound.playSfx('confirm')
        self.tooltipVisible = false

    elseif button == "INTERACT" then
    	if self.tooltipVisible then self:tooltipClose() else self:tooltipOpen() end
    end

end


--called when this gamestate receives a keypress event when purchaseWindowKeypressed is selected

function state:purchaseWindowKeypressed( button )

    local itemInfo = self.items[self.itemSelection]
    local amount = itemInfo[2]
    local cost = itemInfo[3]
    local item = itemInfo.item
    local iamount = self.player.inventory:count(item)

    local p = #self.purchaseOptions
    

    if button == "JUMP" then 
        if self.purchaseOptions[self.purchaseSelection] == "BUY" then
            self:buySelectedItem()
            sound.playSfx('confirm')
        elseif self.purchaseOptions[self.purchaseSelection] == "SELL" then
            self:sellSelectedItem()
            sound.playSfx('confirm')
        else
            error("invalid selection:"..self.purchaseOptions[self.purchaseSelection])
        end    
    
    elseif button == "DOWN" then
        self.purchaseSelection = nonzeroMod(self.purchaseSelection + 1, p )
        sound.playSfx('click')

    elseif button == "UP" then
        self.purchaseSelection = nonzeroMod(self.purchaseSelection - 1, p)
        sound.playSfx('click')

    elseif button == "ATTACK" then
        self.window = "itemsWindow"
        self.buyAmount = 1
        self.sellAmount = 1
        sound.playSfx('confirm')

	elseif button == "INTERACT" then
        if self.tooltipVisible then self:tooltipClose() else self:tooltipOpen() end

    elseif button == "LEFT" then
        if (self.purchaseSelection == 1 and self.buyAmount > 1 )then
            self.buyAmount = self.buyAmount - 1
            sound.playSfx('click')
        elseif (self.purchaseSelection == 2 and self.sellAmount > 1) then
            self.sellAmount = self.sellAmount - 1
            sound.playSfx('click')
        else
            sound.playSfx('unlocked')
        end

    elseif button == "RIGHT" then
        if (self.purchaseSelection == 1 and (self.buyAmount + 1)*cost <=self.player.money) and self.buyAmount + 1 <= amount then
            self.buyAmount = self.buyAmount + 1
            sound.playSfx('click')
        elseif (self.purchaseSelection == 2 and self.sellAmount + 1 <= iamount) then
            self.sellAmount = self.sellAmount + 1
            sound.playSfx('click')
        else
            sound.playSfx('unlocked')
        end

    end

end

function state:messageWindowKeypressed( button )
    self.window = "itemsWindow"
    self.message = nil
    self.buyAmount = 1
    self.sellAmount = 1
end


--called when this gamestate receives a keyrelease event
function state:keyreleased( button )
end


function state:buySelectedItem()

    local itemInfo = self.items[self.itemSelection]
    local amount = itemInfo[2]
    local cost = itemInfo[3]
    local item = itemInfo.item

    self:tooltipClose()

    if self.player.money < cost*self.buyAmount then
        self.message = "You don't have enough money to make this purchase."
        self.window = "messageWindow"

    elseif amount <= 0 then
        self.message = "This item is out of stock."
        self.window = "messageWindow"

    else

        for i = 1,self.buyAmount do

            if itemInfo.action then
                itemInfo.action(self.player)
            else
                local itemCopy = utils.deepcopy(item)
                itemCopy.quantity = 1
                if not self.player.inventory:addItem(itemCopy) then
                    if i == 1 then
                        self.message = "Purchase unsuccessful. Your inventory is full."
                    else
                        itemInfo[2] = itemInfo[2] - (i-1)
                        self.player.money = self.player.money - cost*(i-1)
                        self.message = "You only bought " .. i-1 .. " of these items because your inventory is full."
                    end
                    self.window = "messageWindow"
                    return
                end
            end
        end

        itemInfo[2] = itemInfo[2] - self.buyAmount
        self.player.money = self.player.money - cost*self.buyAmount
        self.message = "Purchase successful."
        self.window = "messageWindow"
    end

end


function state:sellSelectedItem()

    local itemInfo = self.items[self.itemSelection]
    local name = itemInfo[1]
    local cost = itemInfo[3]
    local item = itemInfo.item
    local iamount = self.player.inventory:count(item)

    local playerItem, pageIndex, slotIndex = self.player.inventory:search(item)

    self:tooltipClose()

    if iamount <= 0 or not playerItem then
        self.message = "You don't have any of these to sell."
        self.window = "messageWindow"

    elseif playerItem.name == name then
        for i = 1, self.sellAmount do
            if (playerItem.quantity > 1 and self.catergoriesSelection ~= 2) then
                playerItem.quantity = playerItem.quantity - 1
            else
                playerItem, pageIndex, slotIndex = self.player.inventory:search(item)
                self.player.inventory:removeItem(slotIndex, pageIndex)
            end
        end
  
        local money = ((cost / 2) - (cost / 2) % 1)
        self.player.money = self.player.money + money*self.sellAmount
        itemInfo[2] = itemInfo[2] + self.sellAmount --Increases vendor stock
        self.message = "You have successfully sold this item."
        self.window = "messageWindow"
    end

end


--called when the player leaves this gamestate
function state:leave()
    if self.tooltipVisible then self.tooltipVisible = false end
end


--called when love draws this gamestate
function state:draw()

    --background
    if self.screenshot then
        love.graphics.draw( self.screenshot, camera.x, camera.y, 0, window.width / love.graphics:getWidth(), window.height / love.graphics:getHeight() )
    else
        love.graphics.setColor( 0, 0, 0, 255 )
        love.graphics.rectangle( 'fill', 0, 0, love.graphics:getWidth(), love.graphics:getHeight() )
        love.graphics.setColor( 255, 255, 255, 255 )
    end

   -- HUD
    self.hud:draw( self.player )

    local width = window.width
    local height = window.height

    local xcorner = camera.x + width/2 - self.background:getWidth()/2
    local ycorner = camera.y + height*2/5 - self.background:getHeight()/2

    love.graphics.draw( self.background, xcorner, ycorner , 0 )

	--Draw the tooltip annex, if it's open
	if self.tooltipVisible then
		self:tooltipAnimation():draw( self.backgroundt, xcorner + 116, (ycorner - 32) )
	end

	--draws the tooltiop information
 	if self.tooltipState == 'open' and (self.window == "itemsWindow" or self.window == "purchaseWindow") and self.tooltipVisible then
		local tooltipText = {
                x = xcorner + 130,
                y = ycorner -24
            }

		local itemInfo = self.items[self.itemSelection]
        local name = itemInfo.name
		local item = itemInfo.item
		local lineHeight = love.graphics.getFont():getHeight("line height")

		--love.graphics.draw( self.backgroundt, xcorner + 116, (ycorner - 32), 0 )
        local _, descriptionWrap = love.graphics.getFont():getWrap(item.description, 64)
        love.graphics.printf(item.description, tooltipText.x, tooltipText.y, 64, "left", 0, 0.9, 0.9)

		drawSeparator(tooltipText.x, tooltipText.y + (descriptionWrap * lineHeight), 64)
        local statWrap = 0

		-- Get additional item stats if they exist
		itemStats = self:getItemStats(item)
		if itemStats ~= "" then
        	tastytext = fonts.tasty.new(itemStats, tooltipText.x, tooltipText.y + (descriptionWrap * lineHeight), 64, love.graphics.getFont(), fonts.colors, lineHeight)
        	statWrap = tastytext.lines
        	tastytext:draw()
        		drawSeparator(tooltipText.x, tooltipText.y + ((descriptionWrap + statWrap) * lineHeight), 64)
        end
		
		-- Lastly, insert our item information after everything else
		love.graphics.printf("\n" .. item.info, tooltipText.x, tooltipText.y + ((descriptionWrap + statWrap) * lineHeight), 64, "left", 0, 0.9, 0.9)
    	--set color back to white
		love.graphics.setColor(255, 255, 255)
	end

    if self.window == "categoriesWindow" then

        love.graphics.draw( self.backgroundc, xcorner, ycorner , 0 )

        love.graphics.printf(string.upper(self.supplierName), xcorner + 8 , ycorner + 8 , 103 , "center" )

        for i,category in pairs(self.categories) do
            if ( i >= self.categoriesWindowLeft and i <= self.categoriesWindowLeft + ROW) then

                local visI = i - self.categoriesWindowLeft

                love.graphics.draw( self.categoriespic[i], xcorner + 19 + 32*visI, ycorner + 22, 0 )

                if not self.supplier[self.categories[i]] then
                    love.graphics.draw( self.noselection, xcorner + 19 + 32*visI, ycorner + 22, 0 )
                    love.graphics.setColor( 101, 101, 101, 213 )
                    love.graphics.print(string.upper(category), xcorner + 13 + 32*visI + self.shift[category], ycorner + 45, 0, 0.5, 0.5 )
                    love.graphics.setColor( 255, 255, 255, 255 )
                else
                    love.graphics.print(string.upper(category), xcorner + 13 + 32*visI + self.shift[category], ycorner + 45, 0, 0.5, 0.5 )
                end               

                if i == self.categorySelection then
                    love.graphics.draw( self.selectionbox, xcorner + 19 + 32*visI, ycorner + 22, 0 )
                end
            end
        end


    elseif self.window == "itemsWindow" then

        love.graphics.draw( self.backgroundc, xcorner, ycorner , 0 )
        love.graphics.printf(string.upper(self.categories[self.categorySelection]), xcorner + 8 , ycorner + 8 , 103, "center" )

        for i, itemInfo in pairs(self.items) do
            local name = itemInfo[1]
            local amount = itemInfo[2]
            local cost = itemInfo[3]

            if ( i >= self.itemsWindowLeft and i <= self.itemsWindowLeft + ROW) then

                local visI = i - self.itemsWindowLeft

                love.graphics.print(cost .. " coins", xcorner + 15 + 32*visI, ycorner + 45, 0, 0.5, 0.5 )

                if itemInfo.draw then
                    itemInfo.draw(xcorner + 20 + 32*visI, ycorner + 23, self.player)
                elseif itemInfo.item.draw then
                    itemInfo.item:draw({x=xcorner + 20 + 32*visI, y =  ycorner + 23 }, nil, true)
                end

                if i == self.itemSelection then
                    love.graphics.draw( self.selectionbox, xcorner + 19 + 32*visI, ycorner + 22, 0 )
                end
            end
        end

    elseif self.window == "purchaseWindow" then

        local itemInfo = self.items[self.itemSelection]
        local name = itemInfo[1]
        local amount = itemInfo[2]
        local cost = itemInfo[3]
        local item = itemInfo.item
        local iamount = self.player.inventory:count(item)

        love.graphics.draw( self.backgroundp, xcorner, ycorner , 0 )
        love.graphics.printf(item.description, xcorner + 8 , ycorner + 8 , 103, "center")


        if itemInfo.draw then
             itemInfo.draw(xcorner + 20, ycorner + 23, self.player)
        elseif itemInfo.item.draw then
             itemInfo.item:draw({x=xcorner + 20, y =  ycorner + 23 }, nil, true)
        end

        if self.purchaseOptions[self.purchaseSelection] == "BUY" then
        love.graphics.print(amount .. " in stock", xcorner + 13, ycorner + 44, 0, 0.5, 0.5 )
        elseif self.purchaseOptions[self.purchaseSelection] == "SELL" then
        love.graphics.print( iamount .. " in inventory", xcorner + 8, ycorner + 44, 0, 0.5, 0.5 )
        end

        love.graphics.draw( self.arrow, xcorner + 58, ycorner + 17 + 15*self.purchaseSelection, 3.14159)
        love.graphics.draw( self.arrow, xcorner + 104, ycorner + 10 + 15*self.purchaseSelection)

        love.graphics.print("Buy  " .. self.buyAmount, xcorner + 63, ycorner + 25)
        love.graphics.print("Sell " .. self.sellAmount, xcorner + 63, ycorner + 40)

    elseif self.window == "messageWindow" then

        love.graphics.printf(self.message, xcorner + 10, ycorner + 15, 99, "left" )

    end

end

---
-- Compiles item stats as string
-- @return item stats as string
function state:getItemStats( item )
    local itemStats = ""
    if item.subtype ~= nil and item.subtype ~= "item" then
        itemStats = itemStats .. "{{white}}\ntype: {{teal}}" .. item.subtype
    end
    if item.damage ~= nil and item.damage ~= "nil" then
        itemStats = itemStats .. "{{white}}\ndamage: {{red}}" .. tostring(item.damage)
    end
    if item.special_damage ~= nil and item.special_damage ~= "nil" then
        itemStats = itemStats .. "{{white}}\nspecial: {{red}}" .. item.special_damage
    end
    return itemStats
end


function drawSeparator(x, y, width)
    y = y + 3 -- for padding around the text

    --draw dividing line
    love.graphics.setColor(112, 28, 114)
    love.graphics.line(x, y, x + width, y)
    
    --draw yellow squares on the ends of the dividing line
    love.graphics.setColor(219, 206, 98)
    love.graphics.rectangle("fill", x, y - 1, 2, 2)
    love.graphics.rectangle("fill", x + width, y - 1, 2, 2)

    -- set color back to white
    love.graphics.setColor(255, 255, 255)
end

--called every update cycle
-- dt the amount of seconds since this was last called
function state:update(dt)
    assert(type(dt)=="number", "update time (dt) must be a number")

    --update the animations
    self:tooltipAnimation():update(dt)

    self:animUpdate()
end

function state:animUpdate()
	if self:tooltipAnimation().status == "finished" then
        if self.tooltipState == "closing" then
            self:tooltipAnimation():gotoFrame(8)
            self:tooltipAnimation():pause()
            self.tooltipVisible = false
        elseif self.tooltipState == "opening" then
            self:tooltipAnimation():gotoFrame(1)
            self:tooltipAnimation():pause()
            self.tooltipState = "open"
        end
    end
    
end

-- Gets the tooltip annex's animation
-- @return the tooltip annex's animation
function state:tooltipAnimation()
    return self.tooltipAnimations[self.tooltipState]
end

---
-- Opens the tooltip annex
-- @return nil
function state:tooltipOpen()
    self.tooltipVisible = true
    self.tooltipState = 'opening'
    self:tooltipAnimation():resume()
end

---
-- Begins closing the tooltip annex
-- @return nil
function state:tooltipClose()
    --self.tooltipVisible = false
    self.tooltipState = 'closing'
    self:tooltipAnimation():resume()
end

return state
