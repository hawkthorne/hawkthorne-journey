local Gamestate = require 'vendor/gamestate'
local window = require 'window'
local camera = require 'camera'
local sound = require 'vendor/TEsound'
local fonts = require 'fonts'
local state = Gamestate.new()


function state:init()
    self.background = love.graphics.newImage("images/pause.png")
    self.instructions = {
        { 'UP',          'W / UP ARROW'},
        { 'DOWN',        'S / DOWN ARROW'},
        { 'LEFT',        'A / LEFT ARROW'},
        { 'RIGHT',       'D / RIGHT ARROW'},
        { 'A (ATTACK)',    'L / Z / SHIFT'},
        { 'B (JUMP)',      'K / X / SPACEBAR'},
        { 'START',       'ESC'},
        { 'SELECT',      'RETURN / ENTER'}
    }

    -- The X coordinates of the columns
    self.left_column = 136
    self.right_column = 245
    -- The Y coordinate of the top key
    self.top = 93
    -- Vertical spacing between keys
    self.spacing = 20
end

function state:enter(previous)
    fonts.set( 'big' )
    sound.playMusic( "daybreak" )

    camera:setPosition(0, 0)
    self.previous = previous
end

function state:leave()
    fonts.reset()
end

function state:keypressed( button )
    Gamestate.switch(self.previous)
end

function state:draw()
    love.graphics.draw(self.background)
    love.graphics.setColor(0, 0, 0)

    for n,instruction in ipairs(self.instructions) do
        local y = self.top + self.spacing * (n - 1)
        -- Draw action
        love.graphics.print(instruction[1], self.left_column, y, 0, 0.8)
        -- And draw associated key
        love.graphics.print(instruction[2], self.right_column, y, 0, 0.8)
    end

    love.graphics.setColor(255, 255, 255)
end

return state
