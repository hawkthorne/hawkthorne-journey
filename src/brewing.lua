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
    self.potions = {
        blue_potion =   {2,1,2,3,3,4,1,1},
        green_potion =  {3,2,3,3,3,2,4,2},
        orange_potion = {1,3,4,0,2,4,3,1},
        purple_potion = {2,4,2,1,0,1,3,2},
        red_potion =    {2,1,2,4,0,0,0,0},
        white_potion =  {4,3,3,0,4,2,1,0},
        yellow_potion = {1,3,0,1,1,4,4,3}
    }
    self.ingredients = {0,0,0,0,0,0,0,0}

    self.selected = 1
    self.brewText = "PRESS " .. controls.getKey('JUMP') .. " TO BREW"
    self.backText = "PRESS " .. controls.getKey('START') .. " TO EXIT"
end

--called when this gamestate receives a keypress event
--@param button the button that was pressed
function state:keypressed( button )
    --exit when you press START
    if button == "START" then
        Gamestate.switch(self.previous)
    elseif button == "UP" then
        if (self.selected - 1) <= 1 then
            self.selected = 1
        else
            self.selected  = self.selected - 1
        end
        sound.playSfx('click')
    elseif button == "DOWN" then
        if (self.selected + 1) >= 8 then
            self.selected = 8
        else
            self.selected = self.selected + 1
        end
        sound.playSfx('click')
    elseif button == "LEFT" then
        if (self.ingredients[self.selected] - 1) <= 0 then
            self.ingredients[self.selected] = 0
        else
            self.ingredients[self.selected]  = self.ingredients[self.selected] - 1
        end
        sound.playSfx('click')
    elseif button == "RIGHT" then
        if (self.ingredients[self.selected] + 1) >= 4 then
            self.ingredients[self.selected] = 4
        else
            self.ingredients[self.selected]  = self.ingredients[self.selected] + 1
        end
        sound.playSfx('click')
    elseif button == "JUMP" then
        self:check()
    end
end

function state:brew( potion )
    --classes
    local SpriteClass = require('nodes/sprite')
    local ItemClass = require('items/item')

    --sound
    sound.playSfx('potion_brew')

    --give potion 
    local itemItem = require('items/consumables/'..potion)
    local item = ItemClass.new(itemItem)
    self.player.inventory:addItem(item)

    --prompt
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
    local brewed = false
    Gamestate.switch(self.previous)
    for potion,combo in pairs(self.potions) do
        if table.concat(combo) == table.concat(self.ingredients) then
            brewed = true
            self:brew(potion)
            break
        end
    end 
    if not brewed then
        brewed = true
        self:brew("black_potion")
    end
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
    --draw background
    if self.screenshot then
        love.graphics.draw( self.screenshot, camera.x, camera.y, 0, window.width / love.graphics:getWidth(), window.height / love.graphics:getHeight() )
    else
        love.graphics.setColor( 0, 0, 0, 255 )
        love.graphics.rectangle( 'fill', 0, 0, love.graphics:getWidth(), love.graphics:getHeight() )
        love.graphics.setColor( 255, 255, 255, 255 )
    end

    --draw gui
    local width = window.width
    local height = window.height
    local menu_right = width/2 - self.background:getWidth()/2
    local menu_top = height/2 - self.background:getHeight()/2
    love.graphics.draw( self.background, menu_right,menu_top, 0 )

    --draw selected
    local firstcell_right = menu_right + 30
    local firstcell_top = menu_top + 9
    local fifthcell_right = menu_right + 145
    local fifthcell_top = menu_top + 9
    if self.selected <= 4 then
        love.graphics.drawq(selectionSprite, 
            love.graphics.newQuad(0,0,selectionSprite:getWidth(),selectionSprite:getHeight(),selectionSprite:getWidth(),selectionSprite:getHeight()),
            firstcell_right, firstcell_top + ((self.selected-1) * 22))
    else
        love.graphics.drawq(selectionSprite, 
            love.graphics.newQuad(0,0,selectionSprite:getWidth(),selectionSprite:getHeight(),selectionSprite:getWidth(),selectionSprite:getHeight()),
            fifthcell_right, fifthcell_top + ((self.selected-5) * 22))
    end

    --print info
    love.graphics.printf(self.brewText, 0, 200, width, 'center')
    love.graphics.printf(self.backText, 0, 213, width, 'center')

    --draw numbers
    for i = 1,4 do
        love.graphics.printf(self.ingredients[i], firstcell_right + 6, firstcell_top + 3.5 + ((i-1) * 22), width, 'left')
    end
    for i = 5,8 do
        love.graphics.printf(self.ingredients[i], fifthcell_right + 6, fifthcell_top + 3.5 + ((i-5) * 22), width, 'left')
    end

end

--called every update cycle
-- dt the amount of seconds since this was last called
function state:update(dt)
    assert(type(dt)=="number", "update time (dt) must be a number")
end

return state