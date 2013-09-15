local core  = require 'hawk/core'
local middle = require 'hawk/middleclass'

local store = require 'hawk/store'
local utils = require 'utils'

local camera = require 'camera'
local sound = require 'vendor/TEsound'
local fonts = require 'fonts'
local window = require 'window'
local controls = require 'controls'
local VerticalParticles = require "verticalparticles"

local db = store('options-2')

local Options = middle.class("Options", core.Scene)

function Options:initialize(app)
    self.app = app
    VerticalParticles.init()

    self.background = love.graphics.newImage("images/menu/pause.png")
    self.arrow = love.graphics.newImage("images/menu/medium_arrow.png")
    self.checkbox_checked = love.graphics.newImage("images/menu/checkbox_checked.png")
    self.checkbox_unchecked = love.graphics.newImage("images/menu/checkbox_unchecked.png")
    self.range = love.graphics.newImage("images/menu/range.png")
    self.range_arrow = love.graphics.newImage("images/menu/small_arrow_up.png")

    self.option_map = {}
    self.options = db:get('options', {
    --           display name                   type    value
        { name = 'FULLSCREEN',             bool   = false          },
        { name = 'MUSIC VOLUME',           range  = { 0, 10, 10 }  },
        { name = 'SFX VOLUME',             range  = { 0, 10, 10 }  },
        { name = 'SHOW FPS',               bool   = false          },
        {},
        { name = 'RESET SETTINGS AND EXIT',   action = 'reset_settings' }
    } )

    for i,o in pairs( self.options ) do
        if o.name then
            self.option_map[o.name] = self.options[i]
        end
    end

    self.selection = 0

    self:updateFullscreen()
    self:updateSettings()
    self:updateFpsSetting()
end

function Options:update(dt)
    VerticalParticles.update(dt)
end

function Options:show()
    fonts.set( 'big' )
    sound.playMusic("daybreak" )

    camera:setPosition(0, 0)
end

function Options:hide()
    fonts.reset()
end

function Options:updateFullscreen()
    if self.option_map['FULLSCREEN'].bool then
        utils.setMode(0, 0, true)
        local width = love.graphics:getWidth()
        local height = love.graphics:getHeight()
        camera:setScale( window.width / width , window.height / height )
    else
        camera:setScale(window.scale,window.scale)
        utils.setMode(window.screen_width, window.screen_height, false)
    end
end

function Options:updateFpsSetting()
    window.showfps = self.option_map['SHOW FPS'].bool
end

function Options:updateSettings()
    sound.volume('music', self.option_map['MUSIC VOLUME'].range[3] / 10)
    sound.volume('sfx', self.option_map['SFX VOLUME'].range[3] / 10)
end

local function reset_settings()
    --set the quit callback function to wipe out all save data
    function love.quit()
        for i,file in pairs(love.filesystem.enumerate('')) do
            if file:find('%.json$') then
                love.filesystem.remove(file)
            end
        end
    end
    love.event.push("quit")
end

function Options:buttonpressed(button)
    -- Flag to track if the options need to be updated
    -- Used to minimize the number of db:flush() calls to reduce UI stuttering
    local updateOptions = false
    local option = self.options[self.selection + 1]

    if button == 'START' then
        self.app:redirect('/title')
        return
    elseif  button == 'ATTACK' or button == 'JUMP' then
        if option.bool ~= nil then
            option.bool = not option.bool
            if option.name == 'FULLSCREEN' then
                sound.playSfx( 'confirm' )
                self:updateFullscreen()
                updateOptions = true
            elseif option.name == 'SHOW FPS' then
                sound.playSfx( 'confirm' )
                self:updateFpsSetting()
                updateOptions = true
            end
        elseif option.action then
            _G[option.action]()
        end
    elseif button == 'LEFT' then
        if option.range ~= nil then
            if option.range[3] > option.range[1] then
                sound.playSfx( 'confirm' )
                option.range[3] = option.range[3] - 1
                updateOptions = true
            end
        end
    elseif button == 'RIGHT' then
        if option.range ~= nil then
            if option.range[3] < option.range[2] then
                sound.playSfx( 'confirm' )
                option.range[3] = option.range[3] + 1
                updateOptions = true
            end
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

    -- Only flush the options db when necessary
    if updateOptions == true then
        self:updateSettings()
        db:set('options', self.options)
        db:flush()
    end
end

function Options:draw()
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
            if opt.name then love.graphics.print( self.app.i18n(opt.name), 150, y) end

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

return Options
