local app       = require 'app'
local Gamestate = require 'vendor/gamestate'
local camera    = require 'camera'
local sound     = require 'vendor/TEsound'
local fonts     = require 'fonts'
local state     = Gamestate.new()
local window    = require 'window'
local controls  = require 'controls'
local VerticalParticles = require "verticalparticles"

function state:init()
    VerticalParticles.init()

    self.background = love.graphics.newImage("images/menu/pause.png")
    self.arrow = love.graphics.newImage("images/menu/medium_arrow.png")
    self.option_map = {}
    self.options = {
        --           display name                   action
        { name = 'SLOT ALPHA',             action   = 'load_alpha' },
        { name = 'SLOT BRAVO',             action   = 'load_bravo'  },
        { name = 'SLOT CHARLIE',           action   = 'load_charlie'  },
        {},
        { name = 'RESET SAVES AND EXIT',   action   = 'reset_saves' }
    }
    for i,o in pairs( self.options ) do
        if o.name then
            self.option_map[o.name] = self.options[i]
        end
    end

    self.selection = 0
end

function state:update(dt)
    VerticalParticles.update(dt)
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

-- Loads the first slot
function state:load_alpha()
    app.gamesaves:activate(1)
    Gamestate.switch('select')
end

-- Loads the second slot
function state:load_bravo()
    app.gamesaves:activate(2)
    Gamestate.switch('select')
end

-- Loads the third slot
function state:load_charlie()
    app.gamesaves:activate(3)
    Gamestate.switch('select')
end

-- Removes save data and exits
-- TODO this shouldn't be necessary
function state:reset_saves()
    --set the quit callback function to wipe out all save data
    function love.quit()
        for i,file in pairs(love.filesystem.enumerate('')) do
            if file:find('gamesaves.*%.json$') then
                love.filesystem.remove(file)
            end
        end
    end
    love.event.push("quit")
end

function state:keypressed( button )
    -- Flag to track if the options need to be updated
    -- Used to minimize the number of db:flush() calls to reduce UI stuttering
    local updateOptions = false
    local option = self.options[self.selection + 1]

    if button == 'START' then
        Gamestate.switch(self.previous)
        return
    elseif  button == 'ATTACK' or button == 'JUMP' then
        sound.playSfx('click')
        if option.action then
            state[option.action]()
        end
    elseif button == 'UP' then
        sound.playSfx('click')
        self.selection = (self.selection - 1) % #self.options
        while self.options[self.selection + 1].name == nil do
            self.selection = (self.selection - 1) % #self.options
        end
    elseif button == 'DOWN' then
        sound.playSfx('click')
        self.selection = (self.selection + 1) % #self.options
        while self.options[self.selection + 1].name == nil do
            self.selection = (self.selection + 1) % #self.options
        end
    end
end

function state:draw()
    VerticalParticles.draw()

    love.graphics.setColor(255, 255, 255)
    local back = controls.getKey("START") .. ": BACK TO MENU"
    love.graphics.print(back, 25, 25)
    local y = 96

    love.graphics.draw(self.background,
      camera:getWidth() / 2 - self.background:getWidth() / 2,
      camera:getHeight() / 2 - self.background:getHeight() / 2)

    love.graphics.setColor( 0, 0, 0, 255 )

    for n, opt in pairs(self.options) do
        if tonumber( n ) ~= nil  then
            if opt.name then love.graphics.print( app.i18n(opt.name), 150, y) end

            if opt.bool ~= nil then
                if opt.bool then
                    love.graphics.draw( self.checkbox_checked, 366, y )
                else
                    love.graphics.draw( self.checkbox_unchecked, 366, y )
                end
            elseif opt.range ~= nil then
                love.graphics.draw( self.range, 336, y + 2 )
                love.graphics.draw( self.range_arrow, 338 + ( ( ( self.range:getWidth() - 1 ) / ( opt.range[2] - opt.range[1] ) ) * ( opt.range[3] - 1 ) ), y + 9 )
            end
            y = y + 26
        end
    end

    love.graphics.draw( self.arrow, 138, 124 + ( 26 * ( self.selection - 1 ) ) )
    love.graphics.setColor( 255, 255, 255, 255 )
end

return state
