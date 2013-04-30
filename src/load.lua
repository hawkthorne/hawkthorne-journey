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
        --           display name       slot number
        { name = 'SLOT 1',        slot = 1 },
        { name = 'SLOT 2',        slot = 2 },
        { name = 'SLOT 3',        slot = 3 },
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

function state:update( dt )
    VerticalParticles.update( dt )
end

function state:enter( previous )
    fonts.set( 'big' )
    sound.playMusic( "daybreak" )
    camera:setPosition( 0, 0 )
    self.previous = previous
end

function state:leave()
    fonts.reset()
end

-- Loads the given slot number
-- @param slotNumber the slot number to load
function state:load_slot( slotNumber )
    app.gamesaves:activate( slotNumber )
    Gamestate.switch( 'select' )
end

-- Gets the saved slot's level name, or the empty string
-- @param slotNumber the slot number to get the level name for
function state.get_slot_level(slotNumber)
    local gamesave = app.gamesaves:all()[ slotNumber ]
    if gamesave ~= nil then
        local savepoint = gamesave:get( 'savepoint' )
        if savepoint ~= nil and savepoint.level ~= nil then
            return savepoint.level
        end
    else
        print( "Warning: no gamesave information for slot: " .. slotNumber )
    end
    return "<empty>"
end

-- Removes save data and exits
-- TODO this shouldn't be necessary
-- If we're going to do this, we really should prompt the user
function state:reset_saves()
    --set the quit callback function to wipe out all save data
    function love.quit()
        for i,file in pairs(love.filesystem.enumerate('')) do
            if file:find('gamesaves.*%.json$') then
                love.filesystem.remove(file)
            end
        end
    end
    love.event.push( "quit" )
end

function state:keypressed( button )

    local option = self.options[ self.selection + 1 ]

    if button == 'START' then
        if self.previous.name then
            Gamestate.switch( self.previous )
        else
            Gamestate.switch( Gamestate.home )
        end
        return
    elseif  button == 'ATTACK' or button == 'JUMP' then
        sound.playSfx('click')
        if option.slot then
            -- Load the selected slot
            self:load_slot( option.slot )
        elseif option.action then
            self[option.action]()
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
    local y = 91

    love.graphics.draw(self.background,
      camera:getWidth() / 2 - self.background:getWidth() / 2,
      camera:getHeight() / 2 - self.background:getHeight() / 2)

    love.graphics.setColor( 0, 0, 0, 255 )

    for n, opt in pairs(self.options) do
        if tonumber( n ) ~= nil  then
            if opt.name and opt.slot then
                love.graphics.print( opt.name .. "......" .. self.get_slot_level( opt.slot ), 150, y, 0, 0.75 )
            elseif opt.name then
                love.graphics.print( opt.name, 150, y, 0, 0.75 )
            end
            y = y + 18
        end
    end
    love.graphics.draw( self.arrow, 138, 108 + ( 18 * ( self.selection - 1 ) ) )
    love.graphics.setColor( 255, 255, 255, 255 )
end

return state
