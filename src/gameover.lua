local Gamestate = require 'vendor/gamestate'
local window = require 'window'
local camera = require 'camera'
local sound = require 'vendor/TEsound'
local fonts = require 'fonts'
local state = Gamestate.new()
local part = require 'verticalparticles'
local character = require 'character'

function state:init()
    self.text="G A M E   O V E R !"
    self.text2="-Press any key to continue-"
    part.init()
    -- The X coordinates of the columns
    self.left = 180
    -- The Y coordinate of the top key
    self.top = 93
    -- Vertical spacing between keys
    self.spacing = 20
end

function state:enter(previous)
    fonts.set( 'big' )
    sound.playMusic( "you-just-lost" )

    character.state = 'dead'
    character.direction = 'right'
    
    self.blink=0
    
    camera:setPosition(0, 0)
    self.previous = previous
end

function state:leave()
    fonts.reset()
end

function state:keypressed( button )
    Gamestate.switch("splash")
end

function state:update(dt)
    character:animation():update(dt)
    part.update(dt)
    self.blink = self.blink + dt
    if self.blink > 1 then
        self.blink = 0
    end
end

function state:draw()
    love.graphics.setColor( 0, 0, 0, 255 )
    love.graphics.rectangle( "fill", 0, 0, 528, 336 )
    part.draw()
    fonts.set('big')
    love.graphics.print( self.text, self.left - 20, self.top )
    character:animation():draw( character:sheet(), self.left + 60, self.top + 20 )
    fonts.set('ariel')
    if self.blink < 0.5 then
        love.graphics.print( self.text2, self.left + 5, self.top + 80 )
    end
    love.graphics.setColor( 255, 255, 255, 255 )
end

return state
