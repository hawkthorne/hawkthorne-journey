-- made by Nicko21
local Gamestate = require 'vendor/gamestate'
local fonts = require 'fonts'
local controls = require 'controls'
local window = require 'window'
local sound = require 'vendor/TEsound'
local Item = require 'items/item'
local camera = require 'camera'
local Prompt = require 'prompt'
local Timer = require 'vendor/timer'
local potion_recipes = require 'items/potion_recipes'
--instantiate this gamestate
local state = Gamestate.new()

local selectionSprite = love.graphics.newImage('images/inventory/selection.png')

local ITEMS_ROW_AMT = 4
bundle = {}

--called once when the gamestate is initialized
function state:init()
    self.background = love.graphics.newImage( 'images/potion_menu.png' )
end

--called when the player enters this gamestate
--enter may take additional arguments from previous as necessary
--@param previous the actual gamestate that the player came from (not just its name)
function state:enter(previous, player, screenshot, supplierName)
    fonts.set( 'arial' )
    sound.playMusic( "potionlab" )
    self.previous = previous
    self.screenshot = screenshot
    self.player = player
    self.offset = 0

    -- This checks if the player has items to brew with
    local playerMaterials = self.player.inventory.pages.materials
    if (#playerMaterials == 0) then
        -- TODO: MESSAGE FOR PLAYER SAYING BRING INGREDINETS
        Gamestate.switch(self.previous)
    end

    -- This block creates a table of the players inventory with limits on items and also holds how many ingredients are added
    self.values = {}
    self.referanceValues = {} -- Due to the nature of editing the item data once it is in a table, a second table is made :)
    self.ingredients = {}
    local temp = {}     -- Temp stores the index of an item in the values list
    local count = 0
    for key,orgiMat in pairs(playerMaterials) do
        mat = {name = orgiMat.name, quantity = orgiMat.quantity}
        if temp[mat.name] == nil then
            count = count + 1
            temp[mat.name] = count
            table.insert(self.values, mat)
            table.insert(self.referanceValues, orgiMat)
            self.ingredients[mat.name] = 0
        else
            self.values[temp[mat.name]].quantity = self.values[temp[mat.name]].quantity + mat.quantity
        end
    end

    -- This initializes the menu and selects the first ingredient
    self.selected = 1
    self.overall = self.selected + self.offset
    self.current = self.ingredients[self.values[self.overall].name] or nil
end

--called when this gamestate receives a keypress event
--@param button the button that was pressed
function state:keypressed( button )
    self.overall = self.selected + self.offset
    self.current = self.ingredients[self.values[self.overall].name] or nil
    -- exit when you press START
    if button == "START" then
        Gamestate.switch(self.previous)

    -- This code checks if the player is at the top of the list and scrolls if is, else just moves cursor
    elseif button == "UP" then
        if (self.selected - 1) <= 0 then
            if (self.offset > 0) then
                self.offset = self.offset - 1
            end
        else
            self.selected  = self.selected - 1
        end
        sound.playSfx('click')

    -- This code checks if the player is at the bottom of the list and scrolls if is, else just moves cursor
    elseif button == "DOWN" then
        
        if (self.overall < #self.values) then
            if (self.selected + 1) >= 5 then
                self.offset = self.offset + 1
            else
                self.selected = self.selected + 1
            end
        end
        sound.playSfx('click')

    -- This code removes an ingredient, down to zero
    elseif button == "LEFT" then
        if self.current and not (self.current <= 0) then
            self.current  = self.current - 1
        end
        sound.playSfx('click')

    -- This code adds an ingredient, up to the amount the player has in thier inventory
    elseif button == "RIGHT" then
        if self.current and (not (self.current >= 4) and not (self.current >= self.values[self.overall].quantity)) then
            self.current  = self.current + 1
        end
        sound.playSfx('click')

    -- This starts the potion checking/brewing
    elseif button == "JUMP" then
        self:check()
    end

    -- This updates the cursor
    self.ingredients[self.values[self.overall].name] = self.current
end

function state:brew( potion )
    -- classes
    local SpriteClass = require('nodes/sprite')
    local ItemClass = require('items/item')

    -- sound
    sound.playSfx('potion_brew')

    -- remove items
    for mat,amount in pairs(self.ingredients) do
        self.player.inventory:removeManyItemsOverStacks(amount, {name=mat, type="material"})
    end

    -- give potion 
    local potionItem = require('items/consumables/'..potion)
    local item = ItemClass.new(potionItem)
    self.player.inventory:addItem(item)

    -- prompt/Shows the player holding the potion saying, you brewed a potion!
    self.player.freeze = true
    self.player.invulnerable = true
    self.player.character.state = "acquire"
    local message = {'You brewed a '..item.name..'!'}
    local callback = function(result)
         self.prompt = nil
         self.player.freeze = false
         self.player.invulnerable = false
    end
    local options = {'Exit'}
    local node = SpriteClass.new(
        {x = self.player.position.x +14, 
        y = self.player.position.y - 10, 
        properties = {
            animation = "1,1", 
            sheet = 'images/consumables/'..potion..'.png', 
            width = 24, 
            height = 24, 
            mode='once'
            }
        })
    self.prompt = Prompt.new(message, callback, options, node)
end

function state:check()
    -- This code checks wheather the player has accually put an item in before trying to brew
    local notBlankBrew = false
    for mat,amount in pairs(self.ingredients) do
        if amount >= 1 then
            notBlankBrew = true
        end
    end
    -- This is the main checking code
    if notBlankBrew then
        local brewed = false
        -- We are going back!
        Gamestate.switch(self.previous)
        -- This goes though all the possible recipes
        for _,currentRecipe in pairs(potion_recipes) do                             -- The logic behind my checking is to count the amount correct ingredients the player has         
            local correctAmount = 0                                                 -- and compare that to the amount of ingredients in the recipe. If they are the same the
            local recipeLenth = 0                                                   -- player has added in all the correct ingerdients and a potion can be brewed.
            local recipe = currentRecipe.recipe
            for mat,amount in pairs(currentRecipe.recipe) do
                recipeLenth = recipeLenth + 1
                if self.ingredients[mat] == amount then
                    correctAmount = correctAmount + 1
                end
            end
            -- Check if the same
            if  correctAmount == recipeLenth then
                -- Brew and exit loop
                brewed = true
                self:brew(currentRecipe.name)
                break
            end
        end
        if not brewed then
            -- Brew the consilation potion
            brewed = true
            self:brew("black_potion")
        end
    else
        -- TODO: PLAY A "NO" SOUND
    end
end

--called when this gamestate receives a keyrelease event
--@param button the button that was released
function state:keyreleased( button )
end

--called when the player leaves this gamestate
function state:leave()
end

-- Called when love draws this gamestate
function state:draw()

    -- Draw background
    if self.screenshot then
        love.graphics.draw( self.screenshot, camera.x, camera.y, 0, window.width / love.graphics:getWidth(), window.height / love.graphics:getHeight() )
    else
        love.graphics.setColor( 0, 0, 0, 255 )
        love.graphics.rectangle( 'fill', 0, 0, love.graphics:getWidth(), love.graphics:getHeight() )
        love.graphics.setColor( 255, 255, 255, 255 )
    end

    -- Draw gui
    local width = window.width
    local height = window.height
    local menu_right = width/2 - self.background:getWidth()/2
    local menu_top = height/2 - self.background:getHeight()/2
    love.graphics.draw( self.background, menu_right,menu_top, 0 )

    -- For referance
    local firstcell_right = menu_right + 30
    local firstcell_top = menu_top + 9

    -- Draw selected
        love.graphics.drawq(selectionSprite, 
            love.graphics.newQuad(0,0,selectionSprite:getWidth(),selectionSprite:getHeight(),selectionSprite:getWidth(),selectionSprite:getHeight()),
            firstcell_right, firstcell_top + ((self.selected-1) * 22))

    -- Print info
    love.graphics.setColor( 0, 255, 0, 255 )
    love.graphics.printf(controls.getKey('JUMP') .. " BREW", 0, 200, width, 'center')
    love.graphics.setColor( 255, 0, 0, 255 )
    love.graphics.printf(controls.getKey('START') .. " CANCEL", 0, 213, width, 'center')
    love.graphics.setColor( 255, 255, 255, 255 )

    
    for i = 1,4 do
        if self.values[i+self.offset] ~= nil then
            -- Draw images
            self.referanceValues[i+self.offset]:draw({x=firstcell_right-21,y=firstcell_top + 1 + ((i-1) * 22)} , nil, true)
            -- Draw numbers
            love.graphics.printf(self.ingredients[self.values[i+self.offset].name], firstcell_right + 6, firstcell_top + 3.5 + ((i-1) * 22), width, 'left')
            -- Draw names
            love.graphics.printf(self.values[i+self.offset].name, firstcell_right + 25, firstcell_top + 3.5 + ((i-1) * 22), width, 'left')
        end
    end
end

--called every update cycle
-- dt the amount of seconds since this was last called
function state:update(dt)
    assert(type(dt)=="number", "update time (dt) must be a number")
end

return state
