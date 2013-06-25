local Gamestate = require 'vendor/gamestate'
local sound = require 'vendor/TEsound'
local controls = require 'controls'
local Item = require 'items/item'
local window = require 'window'
local camera = require 'camera'
local fonts = require 'fonts'
local HUD = require 'hud'


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

    self.selectionbox = love.graphics.newImage ('images/shopping/selection.png' )
    self.noselection = love.graphics.newImage ('images/shopping/noselection.png' )

    self.arrow = love.graphics.newImage("images/menu/small_arrow.png")

    self.categories = {}
    self.categories[1] = "weapons"
    self.categories[2] = "materials"
    self.categories[3] = "consumables"
    self.categories[4] = "keys"
    self.categories[5] = "armor"
    self.categories[6] = "misc"

    self.categoriespic = {}
    for i = 1, #self.categories do
        self.categoriespic[i] = love.graphics.newImage('images/shopping/' .. self.categories[i] .. '.png')
    end

    self.items = {}
    self.purchaseOptions = {"BUY", "SELL", "EXIT"} 

    self.categorySelection = table.indexof(self.categories,"weapons")

    self.itemsSelection = 1
    self.purchaseSelection = 1
    
    self.categoriesWindowLeft = 1
    self.itemsWindowLeft = 1

    self.window = "categoriesWindow"

    self.player = player

end


--called when the player enters this gamestate
function state:enter(previous, player, screenshot, supplierName)

    fonts.set( 'small' )
    sound.playMusic( "blacksmith" )

    self.previous = previous
    self.player = player
    self.screenshot = screenshot
    self.hud = HUD.new(previous)
    
    self.message = nil

    self.categorySelection = table.indexof(self.categories,"weapons")
    self.itemsSelection = 1
    self.purchaseSelection = 1

    self.window = "categoriesWindow"

    self.supplierName = supplierName or "blacksmith"
    self.supplier = require ("suppliers/"..self.supplierName)
    assert(self.supplier,"supplier by the name of "..self.supplierName.." has no content")
    assert(table.propcount(self.supplier)>0, "supplier must have at least one category")

    self.selectText = "PRESS " .. controls.getKey('JUMP') .. " TO SELECT"
    self.backText = "PRESS " .. controls.getKey('ATTACK') .. " TO GO BACK"

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
            --elseif category=="misc" then
-- is there a reason this is commented out?
                --item = self:loadMisc(name)
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
    end
    
    if self.window=="categoriesWindow" then
        self:categoriesWindowKeypressed(button)
    elseif self.window=="itemsWindow" then
        self:itemsWindowKeypressed(button)
    elseif self.window=="purchaseWindow" then
        self:purchaseWindowKeypressed(button)
    elseif self.window=="messageWindow" then
        self:messageWindowKeypressed(button)
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
    end

end


--called when this gamestate receives a keypress event when purchaseWindowKeypressed is selected

function state:purchaseWindowKeypressed( button )

    local p = #self.purchaseOptions
    

    if button == "JUMP" then 
        if self.purchaseOptions[self.purchaseSelection] == "BUY" then
            self:buySelectedItem()
            sound.playSfx('confirm')
        elseif self.purchaseOptions[self.purchaseSelection] == "SELL" then
            self:sellSelectedItem()
            sound.playSfx('confirm')
        elseif self.purchaseOptions[self.purchaseSelection] == "EXIT" then
            Gamestate.switch(self.previous)
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
        sound.playSfx('confirm')
    end

end

function state:messageWindowKeypressed( button )

    if button == "ATTACK" then
        self.window = "purchaseWindow"
        self.messgae = nil
    end

end


--called when this gamestate receives a keyrelease event
function state:keyreleased( button )
end


function state:buySelectedItem()

    local itemInfo = self.items[self.itemSelection]
    local name = itemInfo[1]
    local amount = itemInfo[2]
    local cost = itemInfo[3]
    local item = itemInfo.item

    if self.player.money < cost then
        self.message = "You don't have enough money to purchase this item."
        self.window = "messageWindow"

    elseif amount <= 0 then
        self.message = "You can't afford this item."
        self.window = "messageWindow"
    else
        if itemInfo.action then
            itemInfo.action(self.player)
        else
            local itemCopy = deepcopy(item)
            itemCopy.quantity = 1
            if not self.player.inventory:addItem(itemCopy) then
                self.message = "You have enough of this item already."
        self.window = "messageWindow"
            end
        end
    
        itemInfo[2] = itemInfo[2] - 1
        self.player.money = self.player.money - cost
        self.message = "Purchase successful."
        self.window = "messageWindow"
    end

end


function state:sellSelectedItem()

    local itemInfo = self.items[self.itemSelection]
    local name = itemInfo[1]
    local cost = itemInfo[3]
    local item = itemInfo.item
    local amount = self.player.inventory:count(item)

    local playerItem, pageIndex, slotIndex = self.player.inventory:search(item)


    if amount <= 0 or not playerItem then
        self.message = "You don't have any of these to sell."
        self.window = "messageWindow"
    elseif playerItem.name == name then
        if playerItem.quantity > 1 then
            playerItem.quantity = playerItem.quantity - 1
        else
            self.player.inventory:removeItem(slotIndex, pageIndex)
        end
  
        local money = ((cost / 2) - (cost / 2) % 1)
        self.player.money = self.player.money + money
        itemInfo[2] = itemInfo[2] + 1 --Increases vendor stock
        self.message = "You have successfully sold this item."
        self.window = "messageWindow"
    end

end


--called when the player leaves this gamestate
function state:leave()
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

    local xcorner = width/2 - self.background:getWidth()/2
    local ycorner = height*2/5 - self.background:getHeight()/2

    love.graphics.draw( self.background, xcorner, ycorner , 0 )

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
                    love.graphics.print(string.upper(category), xcorner + 13 + 32*visI, ycorner + 45, 0, 0.5, 0.5 )
                    love.graphics.setColor( 255, 255, 255, 255 )
                else
                    love.graphics.print(string.upper(category), xcorner + 13 + 32*visI, ycorner + 45, 0, 0.5, 0.5 )
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
                    itemInfo.draw(xcorner + 20 + 32*visI, y + 23, self.player)
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

        love.graphics.draw( self.backgroundp, xcorner, ycorner , 0 )
        love.graphics.printf(name, xcorner + 8 , ycorner + 8 , 103, "center")


        if itemInfo.draw then
             itemInfo.draw(xcorner + 20, y + 23, self.player)
        elseif itemInfo.item.draw then
             itemInfo.item:draw({x=xcorner + 20, y =  ycorner + 23 }, nil, true)
        end

        love.graphics.print(amount .. " in stock", xcorner + 13, ycorner + 44, 0, 0.5, 0.5 )

        love.graphics.draw( self.arrow, xcorner + 55, ycorner + 11 + 11*self.purchaseSelection )

        love.graphics.print("Buy", xcorner + 65, ycorner + 22)
        love.graphics.print("Sell", xcorner + 65, ycorner + 33)
        love.graphics.print("Exit", xcorner + 65, ycorner + 44)


    elseif self.window == "messageWindow" then

        love.graphics.printf(self.message, xcorner + 10, ycorner + 15, 99, "left" )

    end

end


--called every update cycle
-- dt the amount of seconds since this was last called
function state:update(dt)
    assert(type(dt)=="number", "update time (dt) must be a number")
end

return state