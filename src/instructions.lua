local Gamestate = require 'vendor/gamestate'
local window = require 'window'
local camera = require 'camera'
local sound = require 'vendor/TEsound'
local fonts = require 'fonts'
local controls = require 'controls'
local VerticalParticles = require "verticalparticles"
local Menu = require 'menu'
local state = Gamestate.new()
local menu = Menu.new({
    'UP',
    'DOWN',
    'LEFT',
    'RIGHT',
    'SELECT',
    'START',
    'JUMP',
    'ACTION'})

menu:onSelect(function()
    controls.enableRemap = true
    state.statusText = "PRESS NEW KEY" end)

function state:init()
    VerticalParticles.init()

    self.arrow = love.graphics.newImage("images/menu/arrow.png")
    self.background = love.graphics.newImage("images/menu/pause.png")
    self.instructions = {}

    -- The X coordinates of the columns
    self.left_column = 160
    self.right_column = 300
    -- The Y coordinate of the top key
    self.top = 93
    -- Vertical spacing between keys
    self.spacing = 20

end

function state:enter(previous)
    fonts.set( 'big' )
    sound.playMusic( "daybreak" )

    camera:setPosition(0, 0)
    self.instructions = controls.getButtonmap()
    self.previous = previous
    self.option = 0
    self.statusText = ''
end

function state:leave()
    fonts.reset()
end

function state:keypressed( button )
    if controls.enableRemap then self:remapKey(button) end
    if controls.getButton then menu:keypressed(button) end
    if button == 'START' then Gamestate.switch(self.previous) end
end

function state:update(dt)
    VerticalParticles.update(dt)
end

function state:draw()
    VerticalParticles.draw()

    love.graphics.draw(self.background, 
      camera:getWidth() / 2 - self.background:getWidth() / 2,
      camera:getHeight() / 2 - self.background:getHeight() / 2)

    local n = 1

    love.graphics.setColor(255, 255, 255)
    local back = controls.getKey("START") .. ": BACK TO MENU"
    local howto = controls.getKey("ACTION") .. " OR " .. controls.getKey("JUMP") .. ": REASSIGN CONTROL"
    love.graphics.print(back, 25, 25)
    love.graphics.print(howto, 25, 55)
    love.graphics.print(self.statusText, self.left_column, 280)
    love.graphics.setColor( 0, 0, 0, 255 )

    for i, button in ipairs(menu.options) do
        local y = self.top + self.spacing * (i - 1)
        local key = controls.getKey(button)
        love.graphics.print(button, self.left_column, y, 0, 0.8)
        love.graphics.print(key, self.right_column, y, 0, 0.8)
    end
    
    love.graphics.setColor( 255, 255, 255, 255 )
    love.graphics.draw(self.arrow, 135, 87 + self.spacing * menu:selected())
end

function state:remapKey(key)
    local button = menu.options[menu:selected() + 1]
    if not controls.newButton(key, button) then
        self.statusText = "KEY IS ALREADY IN USE"
    else
        if key == ' ' then key = 'space' end
        assert(controls.getKey(button) == key)
        self.statusText = button .. ": " .. key
    end
    controls.enableRemap = false
end

return state
