local Gamestate = require 'vendor/gamestate'
local fonts = require 'fonts'
local controls = require 'controls'
local window = require 'window'
local sound = require 'vendor/TEsound'
local Item = require 'items/item'
--instantiate this gamestate
local state = Gamestate.new()

local healthQuad = love.graphics.newQuad( 0, 0, 13, 12, 26, 12)
local healthImage = love.graphics.newImage( "images/tokens/health.png" )

local ITEMS_ROW_AMT = 4
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
    self.categories = {}
    table.insert(self.categories,"weapons")
    table.insert(self.categories,"materials")
    table.insert(self.categories,"potions")
    table.insert(self.categories,"keys")
    table.insert(self.categories,"armor")
    table.insert(self.categories,"misc")
    self.categorySelection = table.indexof(self.categories,"weapons")
    self.categoryHighlight = table.indexof(self.categories,"weapons")
    self.window = "categoriesWindow"
    self.itemsWindowSelection = 1
    self.itemsWindowTop = 1
    self.purchaseWindowSelection = 1
    self.items = {}
    self.purchaseOptions = {"BUY","EXIT"}
    
end

--called when the player enters this gamestate
--enter may take additional arguments from previous as necessary
--@param previous the actual gamestate that the player came from (not just its name)
function state:enter(previous, player, screenshot, supplierName)
    fonts.set( 'arial' )
    sound.playMusic( "blacksmith" )
    self.previous = previous
    self.categorySelection = table.indexof(self.categories,"weapons")
    self.categoryHighlight = table.indexof(self.categories,"weapons")
    self.window = "categoriesWindow"
    --not necessarily the most elegant way to select one
    self.player = player
    self.supplierName = supplierName or "blacksmith"
    self.supplier = require ("suppliers/"..self.supplierName)
    assert(self.supplier,"supplier by the name of "..self.supplierName.." has no content")
    assert(table.propcount(self.supplier)>0, "supplier must have at least one category")
    self.itemsWindowSelection = 1
    self.purchaseWindowSelection = 1
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
            elseif category=="misc" then
                --item = self:loadMisc(name)
            else
                error("Unsupported category: "..category)
            end
            info["item"] = item
        end
    end
    
    while(not self.supplier[self.categories[self.categoryHighlight]]) do
        self.categoryHighlight = nonzeroMod(self.categoryHighlight+1,#self.categories)
    end
    self.categorySelection = self.categoryHighlight
end

--called when this gamestate receives a keypress event
--@param button the button that was pressed
function state:keypressed( button )
    --exit when you press START
    if button == "START" then
        Gamestate.switch(self.previous)
    end
    
    if self.window=="categoriesWindow" then
        self:categoriesWindowKeypressed(button)
    elseif self.window=="itemsWindow" then
        self:itemsWindowKeypressed(button)
    elseif self.window=="purchaseWindow" then
        self:purchaseWindowKeypressed(button)
    end
    
end

function state:categoriesWindowKeypressed( button )
    if button == "DOWN" then
        self.categoryHighlight = nonzeroMod(self.categoryHighlight+1,#self.categories)
        local t = 1
        while(not self.supplier[self.categories[self.categoryHighlight]]) do
            self.categoryHighlight = nonzeroMod(self.categoryHighlight+1,#self.categories)
            t = t + 1
        end
        if t == #self.categories then
            sound.playSfx('unlocked')
        else
            sound.playSfx('click')
        end
    elseif button == "UP" then
        self.categoryHighlight = nonzeroMod(self.categoryHighlight-1, #self.categories)
        local t = 1
        while(not self.supplier[self.categories[self.categoryHighlight]]) do
            self.categoryHighlight = nonzeroMod(self.categoryHighlight-1,#self.categories)
            t = t + 1
        end
        if t == #self.categories then
            sound.playSfx('unlocked')
        else
            sound.playSfx('click')
        end
    elseif button == "JUMP" and not self.supplier[self.categories[self.categoryHighlight]] then
        self.statusMessage = "There are no "..self.categories[self.categoryHighlight].." available"
        sound.playSfx('click')
    elseif button == "JUMP" then
        self.statusMessage = nil
        self.categorySelection = self.categoryHighlight
        self.window = "itemsWindow"
        self.items = self.supplier[self.categories[self.categorySelection]]
        self.itemsWindowSelection = 1
        self.itemsWindowTop = 1
        self.purchaseWindowSelection = 1
        sound.playSfx('confirm')
    elseif button == "ATTACK" then
        Gamestate.switch(self.previous)
    end
end

function state:itemsWindowKeypressed( button )
    if button == "DOWN" and self.itemsWindowSelection < #self.items then
        self.itemsWindowSelection = nonzeroMod(self.itemsWindowSelection+1, #self.items)
        if self.itemsWindowTop + ITEMS_ROW_AMT < self.itemsWindowSelection then
            self.itemsWindowTop = self.itemsWindowSelection - ITEMS_ROW_AMT
        end
        sound.playSfx('click')
    elseif button == "DOWN" then
        sound.playSfx('unlocked')
    elseif button == "UP" and self.itemsWindowSelection >1 then            
        self.itemsWindowSelection = nonzeroMod(self.itemsWindowSelection-1, #self.items)
        if self.itemsWindowTop > self.itemsWindowSelection then
            self.itemsWindowTop = self.itemsWindowSelection
        end
        sound.playSfx('click')
    elseif button == "UP" then
        sound.playSfx('unlocked')
    elseif button == "JUMP" and #self.items > 0 then
        self.purchaseWindowSelection = 1
        self.window = "purchaseWindow"
        sound.playSfx('confirm')
    elseif button == "ATTACK" then
        self.window = "categoriesWindow"
        sound.playSfx('confirm')
    end
end

function state:purchaseWindowKeypressed( button )
    if button == "DOWN" then
        self.purchaseWindowSelection = nonzeroMod(self.purchaseWindowSelection+1, #self.purchaseOptions)
        sound.playSfx('click')
    elseif button == "UP" then
        self.purchaseWindowSelection = nonzeroMod(self.purchaseWindowSelection-1, #self.purchaseOptions)
        sound.playSfx('click')
    elseif button == "JUMP" then
        if self.purchaseOptions[self.purchaseWindowSelection] == "BUY" then
            self:buySelectedItem()
            sound.playSfx('confirm')
        elseif self.purchaseOptions[self.purchaseWindowSelection] == "SELL" then
            self:sellSelectedItem()
            sound.playSfx('confirm')
        elseif self.purchaseOptions[self.purchaseWindowSelection] == "EXIT" then
            self.statusMessage = nil
            self.window = "itemsWindow"
            sound.playSfx('confirm')
        else
            error("invalid selection:"..self.purchaseOptions[self.purchaseWindowSelection])
        end
    elseif button == "ATTACK" then
        self.window = "itemsWindow"
        sound.playSfx('confirm')
    end
end

function state:buySelectedItem()
    local itemInfo = self.items[self.itemsWindowSelection]
    local name = itemInfo[1]
    local amount = itemInfo[2]
    local cost = itemInfo[3]
    local item = itemInfo.item
    self.statusMessage = nil

    if self.player.money < cost then
        self.statusMessage = "You can't afford it, honey!!"
        return
    end
    if amount <= 0 then
        self.statusMessage = "We are out of stock!!"
        return
    end
    
    if itemInfo.action then
        itemInfo.action(self.player)
    else
        local itemCopy = deepcopy(item)
        itemCopy.quantity = 1
        if not self.player.inventory:addItem(itemCopy) then
            self.statusMessage = "You have too many"
            return
        end
    end
    
    itemInfo[2] = itemInfo[2] - 1
    self.statusMessage = "success!!!"
    self.player.money = self.player.money - cost
    
end

--called when this gamestate receives a keyrelease event
--@param button the button that was released
function state:keyreleased( button )
end

--called when the player leaves this gamestate
function state:leave()
end

--called when love draws this gamestate
function state:draw()
    --background colour
    love.graphics.setColor( 0, 0, 0, 255 )
    love.graphics.rectangle( 'fill', 0, 0, love.graphics:getWidth(), love.graphics:getHeight() )
    love.graphics.setColor( 255, 255, 255, 255 )

    --table
    local width = window.width
    local height = window.height
    love.graphics.draw( self.background, width/2 - self.background:getWidth()/2,height/2 - self.background:getHeight()/2, 0 )

    --print title
    love.graphics.printf(string.upper(self.supplierName.."'s shop"), 0, 40, width, 'center')
    love.graphics.printf(string.upper(self.categories[self.categorySelection]), 0, 70, width, 'center')    
    
    --print categories
    local x = 116
    local y = 77
    for i,category in pairs(self.categories) do
        if i == self.categorySelection and self.window=="categoriesWindow" then
            love.graphics.setColor( 0, 255, 0, 255 )
            love.graphics.line( x-3, y+16*i-3, x+102, y+16*i-3, x+102, y+16*i+11, x-3, y+16*i+11,
                                x-3, y+16*i-3)
            love.graphics.line( x+101, y+16*i-2, x+101, y+16*i+10)
  
            love.graphics.setColor( 255, 255, 255, 255 )
        end
        if i == self.categoryHighlight then
            love.graphics.setColor( 255, 255, 255, 255 )
            love.graphics.line( x-2, y+16*i-2, x+101, y+16*i-2, x+101, y+16*i+10, x-2, y+16*i+10,
                                x-2, y+16*i-2)
            love.graphics.line( x+101, y+16*i-2, x+101, y+16*i+10)
        elseif self.supplier[category] then
            love.graphics.setColor( 210, 210, 210, 255 )
        else
            love.graphics.setColor( 70, 70, 70, 255 )
        end

        love.graphics.print(string.upper(category), x, y + 16*i)
    end
    love.graphics.setColor( 255, 255, 255, 255 )
    
    --print items
    x = 274
    y = 73
    for i, itemInfo in pairs(self.items) do
        local name = itemInfo[1]
        local amount = itemInfo[2]
        local cost = itemInfo[3]

        if (i >= self.itemsWindowTop and i <= self.itemsWindowTop + ITEMS_ROW_AMT) then
            local visI = i - self.itemsWindowTop + 1
            if itemInfo.draw then
                itemInfo.draw(x-28, y + 22*visI -2, self.player)
            elseif itemInfo.item.draw then
                itemInfo.item:draw({x=x-28, y=y + 22*visI - 5}, nil, true)
            end

            if i == self.itemsWindowSelection and self.window=="itemsWindow" then
                love.graphics.setColor( 0  , 255, 0  , 255 )

                love.graphics.line( x-7, y+22*visI-5, x+90, y+22*visI-5, x+90, y+22*visI+11, x-7, y+22*visI+11,
                                    x-7, y+22*visI-5)
            elseif i == self.itemsWindowSelection then
                love.graphics.setColor( 255 , 255, 255 , 255 )
            else
                love.graphics.setColor( 190, 190, 190, 255 )
            end
            love.graphics.print(name, x, y + 22*visI)

            love.graphics.setColor( 255, 255, 255, 255 )

            love.graphics.print("x"..amount, x+95, y + 22*visI)
            love.graphics.print("$"..cost, x+120, y + 22*visI)
        end
    end

    --print buy/sell window
    x = 265
    y = 185
    if self.window=="purchaseWindow" then
        for i,v in pairs(self.purchaseOptions) do
            if i == self.purchaseWindowSelection then
                love.graphics.setColor( 0  , 255, 0  , 255 )
                love.graphics.rectangle("fill", x-20, y+22*i, 8, 8 )
            else
                love.graphics.setColor( 190, 190, 190, 255 )
            end

            love.graphics.print(v, x, y + 22*i)
        end
    end

    
    love.graphics.setColor( 255, 255, 255, 255 )
    --print info box
    local itemInfo = self.items[self.itemsWindowSelection]
    local boxWidth = 100    
    love.graphics.printf(self.statusMessage or (itemInfo and itemInfo.msg) or "", 116, 205, boxWidth, 'left')
    
    --print player's info
    x = 370
    y = 205
    love.graphics.print(self.player.lives, x, y )
    love.graphics.print(self.player.money, x, y +13)

    love.graphics.setColor(255, 255, 255, 255)
    local rowMax = 9
    local horizPad = 10
    local vertPad = 10
    for i = 0,self.player.max_health-1 do
        if self.player.health < i then
            love.graphics.setColor(255, 255, 255, 80)
        end
        love.graphics.drawq(healthImage,healthQuad,x+(i%rowMax)*horizPad-28,y+math.floor(i/rowMax)*vertPad+27)
    end

    --print controls
    love.graphics.printf(self.selectText, 0, 288, width, 'center')
    love.graphics.printf(self.backText, 0, 318, width, 'center')
end

--called every update cycle
-- dt the amount of seconds since this was last called
function state:update(dt)
    assert(type(dt)=="number", "update time (dt) must be a number")
end

return state