local Gamestate = require 'vendor/gamestate'
local window = require 'window'
local camera = require 'camera'
local sound = require 'vendor/TEsound'
local fonts = require 'fonts'
local state = Gamestate.new()
local controls = require 'controls'
local VerticalParticles = require "verticalparticles"


function state:init()
    VerticalParticles.init()

    self.background = love.graphics.newImage("images/menu/pause.png")
    self.instructions = {}

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
    self.instructions = controls.getButtonmap()
    self.previous = previous
end

function state:leave()
    fonts.reset()
end

function state:keypressed( button )
    if button == 'ACTION' then
        local key = controls.getKey(button)
        controls.newButton('z', button)
        return
    end
    Gamestate.switch(self.previous)
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
    local back = controls.getKey("JUMP") .. ": BACK TO MENU"
    love.graphics.print(back, 25, 25)

    love.graphics.setColor( 0, 0, 0, 255 )

    for key, action in pairs(self.instructions) do
        local y = self.top + self.spacing * (n - 1)
        -- Draw action
        love.graphics.print(key, self.left_column, y, 0, 0.8)
        -- And draw associated key
        love.graphics.print(action, self.right_column, y, 0, 0.8)

        n = n + 1
    end

    love.graphics.setColor( 255, 255, 255, 255 )
end

return state
