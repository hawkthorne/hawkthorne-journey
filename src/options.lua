local Gamestate = require 'vendor/gamestate'
local camera = require 'camera'
local sound = require 'vendor/TEsound'
local fonts = require 'fonts'
local state = Gamestate.new()
local window = require 'window'
local Pers = require 'gamePers'

function state:init()
    self.background = love.graphics.newImage("images/pause.png")
    self.arrow = love.graphics.newImage("images/medium_arrow.png")
    self.checkbox_checked = love.graphics.newImage("images/checkbox_checked.png")
    self.checkbox_unchecked = love.graphics.newImage("images/checkbox_unchecked.png")
    self.range = love.graphics.newImage("images/range.png")
    self.range_arrow = love.graphics.newImage("images/small_arrow_up.png")

    self.selection = 0

    self.pData = Pers.Load()
    if self.pData ~= nil then 
        sound.volume('music', self.pData.settings.musicVol)
        sound.volume('sfx', self.pData.settings.sfxVol)
    end
    self:setVolume()
end

---
-- Sets the volume dials to the actual volume
-- @return nil
function state:setVolume()
    self.options = {
    --    display name          value
        { 'FULLSCREEN',         false         },
        { 'MUSIC VOLUME',       { 0, 10, sound.findVolume('music') * 10.0 } },
        { 'SFX VOLUME',         { 0, 10, sound.findVolume('sfx') * 10.0 } }
    }
    --assert(false, "music volume is loaded as " .. sound.findVolume('music') .. " and is multiplied by ten to be " .. sound.findVolume('music') * 10.0)
    -- value can either be true or false, and will render as a checkbox
    --     or it can be a range { low, high, default } and will render as a slider
end

function state:enter(previous)
    fonts.set( 'big' )
    sound.playMusic( "daybreak" )

    camera:setPosition(0, 0)
    self.previous = previous

end

function state:leave()
    if self.pData == nil then
        self.pData = {}
        self.pData.settings = {}
    end
    self.pData.settings.musicVol = sound.findVolume('music')
    self.pData.settings.sfxVol = sound.findVolume('sfx')
    Pers.Save(self.pData)
    fonts.reset()
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
                if option[2] then
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
    
    if option[1] == 'MUSIC VOLUME' then
        sound.volume( 'music', option[2][3] / ( option[2][2] - option[2][1] ) )
    elseif option[1] == 'SFX VOLUME' then
        sound.volume( 'sfx', option[2][3] / ( option[2][2] - option[2][1] ) )
    end
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
