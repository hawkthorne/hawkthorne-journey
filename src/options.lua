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

    self.option_map = {}
    self.options = datastore.get('options', {
    --           display name          type    value
        { name = 'FULLSCREEN',         bool  = false         },
        { name = 'MUSIC VOLUME',       range = { 0, 10, 10 } },
        { name = 'SFX VOLUME',         range = { 0, 10, 10 } },
        { name = 'SHOW FPS',           bool  = false         }
    } )

    for i,o in pairs( self.options ) do
        self.option_map[o.name] = o
    end

    self.selection = 0

    self:updateFullscreen()
    self:updateSettings()
    self:updateFpsSetting()
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
    if self.option_map['FULLSCREEN'].bool then
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

function state:updateFpsSetting()
    window.showfps = self.option_map['SHOW FPS'].bool
end

function state:updateSettings()
    sound.volume('music', self.option_map['MUSIC VOLUME'].range[3] / 10)
    sound.volume('sfx', self.option_map['SFX VOLUME'].range[3] / 10)
end

function state:keypressed( button )
    local option = self.options[self.selection + 1]

    if button == 'START' or button == 'B' then
        Gamestate.switch(self.previous)
        return
    elseif  button == 'SELECT' or button == 'A' then
        if option.bool ~= nil then
            option.bool = not option.bool
            if option.name == 'FULLSCREEN' then
                sound.playSfx( 'click' )
                self:updateFullscreen()
            elseif option.name == 'SHOW FPS' then
                sound.playSfx( 'click' )
                self:updateFpsSetting()
            end
        end
    elseif button == 'LEFT' then
        if option.range ~= nil then
            if option.range[3] > option.range[1] then
                sound.playSfx( 'click' )
                option.range[3] = option.range[3] - 1
            end
        end
    elseif button == 'RIGHT' then
        if option.range ~= nil then
            if option.range[3] < option.range[2] then
                sound.playSfx( 'click' )
                option.range[3] = option.range[3] + 1
            end
        end
    elseif button == 'UP' then
        self.selection = (self.selection - 1) % #self.options
    elseif button == 'DOWN' then
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
        if tonumber( n ) ~= nil then
            love.graphics.print( opt.name, 156, y)

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
            y = y + 30
        end
    end

    love.graphics.draw( self.arrow, 141, 128 + ( 30 * ( self.selection - 1 ) ) )
    love.graphics.setColor(255, 255, 255)
end

return state
