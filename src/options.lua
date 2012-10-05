local Gamestate = require 'vendor/gamestate'
local camera = require 'camera'
local sound = require 'vendor/TEsound'
local fonts = require 'fonts'
local datastore = require 'datastore'
local state = Gamestate.new()
local window = require 'window'

function state:init()
    self.background = love.graphics.newImage("images/pause.png")
    self.arrow = love.graphics.newImage("images/medium_arrow.png")
    self.checkbox_checked = love.graphics.newImage("images/checkbox_checked.png")
    self.checkbox_unchecked = love.graphics.newImage("images/checkbox_unchecked.png")
    self.range = love.graphics.newImage("images/range.png")
    self.range_arrow = love.graphics.newImage("images/small_arrow_up.png")

    self.options = datastore.get('options', {
    --    display name          value
        { 'FULLSCREEN',         false         },
        { 'MUSIC VOLUME',       { 0, 10, 10 } },
        { 'SFX VOLUME',         { 0, 10, 10 } }
    })
    -- value can either be true or false, and will render as a checkbox
    --     or it can be a range { low, high, default } and will render as a slider

    self.selection = 0

    self:updateFullscreen()
    self:updateSettings()
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

function state:updateFullscreen()
    if self.options[1][2] then
        love.graphics.setMode(0, 0, true)
        local width = love.graphics:getWidth()
        local height = love.graphics:getHeight()
        camera:setScale( window.width / width , window.height / height )
        love.graphics.setMode(width, height, true)
    else
        camera:setScale(window.scale,window.scale)
        love.graphics.setMode(window.screen_width, window.screen_height, false)
    end
end

function state:updateSettings()
    sound.volume('music', self.options[2][2][3] / 10)
    sound.volume('sfx', self.options[3][2][3] / 10)
end

function state:keypressed(key)
    local option = self.options[self.selection + 1]

    if key == 'escape' then
        Gamestate.switch(self.previous)
        return
    elseif key == 'return' or key == 'kpenter' or key == " " then
        if type( option[2] ) == 'boolean' then
            option[2] = not option[2]
            if option[1] == 'FULLSCREEN' then
                sound.playSfx( 'click' )
                self:updateFullscreen()
            end
        end
    elseif key == 'left' or key == 'a' then
        if type( option[2] ) == 'table' then
            if option[2][3] > option[2][1] then
                sound.playSfx( 'click' )
                option[2][3] = option[2][3] - 1
            end
        end
    elseif key == 'right' or key == 'd' then
        if type( option[2] ) == 'table' then
            if option[2][3] < option[2][2] then
                sound.playSfx( 'click' )
                option[2][3] = option[2][3] + 1
            end
        end
    elseif key == 'up' or key == 'w' then
        self.selection = (self.selection - 1) % #self.options
    elseif key == 'down' or key == 's' then
        self.selection = (self.selection + 1) % #self.options
    end
    
    self:updateSettings()
    datastore.set('options', self.options)
end

function state:draw()
    love.graphics.draw(self.background)
    love.graphics.setColor(0, 0, 0)

    local y = 96
    
    for n, opt in pairs(self.options) do
        love.graphics.print( opt[1], 156, y)

        if type(opt[2]) == 'boolean' then
            if opt[2] then
                love.graphics.draw( self.checkbox_checked, 366, y )
            else
                love.graphics.draw( self.checkbox_unchecked, 366, y )
            end
        elseif type(opt[2]) == 'table' then
            love.graphics.draw( self.range, 336, y + 2 )
            love.graphics.draw( self.range_arrow, 338 + ( ( ( self.range:getWidth() - 1 ) / ( opt[2][2] - opt[2][1] ) ) * ( opt[2][3] - 1 ) ), y + 9 )
        end
        y = y + 30
    end

    love.graphics.draw( self.arrow, 141, 128 + ( 30 * ( self.selection - 1 ) ) )
    love.graphics.setColor(255, 255, 255)
end

return state
