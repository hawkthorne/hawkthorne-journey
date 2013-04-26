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
        black_potion =  {0,0,0,0,0,0,0,0},
        blue_potion =   {1,1,1,1,1,1,1,1},
        green_potion =  {2,2,2,2,2,2,2,2},
        orange_potion = {3,3,3,3,3,3,3,3},
        purple_potion = {4,4,4,4,4,4,4,4},
        red_potion =    {0,4,0,4,0,4,0,4},
        white_potion =  {1,4,1,4,1,4,1,4},
        yellow_potion = {2,4,2,4,2,4,2,4}
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
    --sound
    sound.playSfx('potion_brew')

    --give potion
    local ItemClass = require('items/item')
    local NodeClass = require('nodes/consumable')
    local node = {type = 'consumable', name = potion}
    local item = ItemClass.new(node)
    self.player.inventory:addItem(item)

    --prompt
    -- self.player.freeze = true
    -- self.player.invulnerable = true
    -- self.player.character.state = "acquire"
    -- node.delay = 0
    -- node.life = math.huge
    -- local message = {'You brewed a '..potion}
    -- local callback = function(result)
    --     self.prompt = nil
    --     self.player.freeze = false
    --     self.player.invulnerable = false
    -- end
    -- local options = {'Exit'}
    -- node.position = { x = self.player.position.x +14  ,y = self.player.position.y - 10}

    -- self.prompt = Prompt.new(message, callback, options, node)
end

function state:check()
    for potion,combo in pairs(self.potions) do
        if table.concat(combo) == table.concat(self.ingredients) then
            self:brew(potion)
            break  
        end
    end
    Gamestate.switch(self.previous)

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
    if self.screenshot then
        love.graphics.draw( self.screenshot, camera.x, camera.y, 0, window.width / love.graphics:getWidth(), window.height / love.graphics:getHeight() )
    else
        love.graphics.setColor( 0, 0, 0, 255 )
        love.graphics.rectangle( 'fill', 0, 0, love.graphics:getWidth(), love.graphics:getHeight() )
        love.graphics.setColor( 255, 255, 255, 255 )
    end

    local width = window.width
    local height = window.height
    local menu_right = width/2 - self.background:getWidth()/2
    local menu_top = height/2 - self.background:getHeight()/2
    love.graphics.draw( self.background, menu_right,menu_top, 0 )

    local firstcell_right = menu_right + 30
    local firstcell_top = menu_top + 9
    local fifthcell_right = menu_right + 145
    local fifthcell_top = menu_top + 9

    love.graphics.printf(self.brewText, 0, 200, width, 'center')
    love.graphics.printf(self.backText, 0, 213, width, 'center')

    --draw selected
    if self.selected <= 4 then
        love.graphics.drawq(selectionSprite, 
            love.graphics.newQuad(0,0,selectionSprite:getWidth(),selectionSprite:getHeight(),selectionSprite:getWidth(),selectionSprite:getHeight()),
            firstcell_right, firstcell_top + ((self.selected-1) * 22))
    else
        love.graphics.drawq(selectionSprite, 
            love.graphics.newQuad(0,0,selectionSprite:getWidth(),selectionSprite:getHeight(),selectionSprite:getWidth(),selectionSprite:getHeight()),
            fifthcell_right, fifthcell_top + ((self.selected-5) * 22))
    end

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