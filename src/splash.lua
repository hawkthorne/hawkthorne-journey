local Gamestate = require 'vendor/gamestate'
local window = require 'window'
local fonts = require 'fonts'
local splash = Gamestate.new()
local camera = require 'camera'
local tween = require 'vendor/tween'
local sound = require 'vendor/TEsound'
local controls = require 'controls'
local timer = require 'vendor/timer'
local flash = true

function splash:init()
    self.cityscape = love.graphics.newImage("images/menu/cityscape.png")
    self.logo = love.graphics.newImage("images/menu/logo.png")
    self.logo_position = {y=-self.logo:getHeight()}
    self.logo_position_final = self.logo:getHeight() / 2 + 40
    self.text = ""
    tween(4, self.logo_position, { y=self.logo_position_final})

    -- 'time_scale' is used to speed up the animation of the logo + splash
    self.time_scale = 1
end

function splash:enter(a)
    fonts.set( 'big' )

    self.text = controls.getKey('A') .. " OR " .. controls.getKey('B') .. " TO START"
    
    camera:setPosition(0, 0)
    self.bg = sound.playMusic( "opening" )

    self.handle = timer.addPeriodic(.5, function() 
      flash = not flash
    end)
end

function splash:update(dt)
    timer.update(dt)
    tween.update(dt * self.time_scale)
end

function splash:leave()
    fonts.reset()

    if self.handle then 
      timer.cancel(self.handle)
    end
end

function splash:keypressed( button )
    if self.logo_position.y < self.logo_position_final then
        self.time_scale = 40
    else
        if button == 'A' or button == 'B' then
          Gamestate.switch('select')
        end
    end
end

function splash:draw()
    love.graphics.draw(self.cityscape)
    love.graphics.draw(self.logo, window.width / 2 - self.logo:getWidth()/2,
    window.height / 2 - self.logo_position.y)

    if self.logo_position.y >= self.logo_position_final and flash then
      love.graphics.setColor(0, 0, 0)
      love.graphics.printf(self.text, 0, window.height * 3 / 4, window.width, 'center')
      love.graphics.setColor(255, 255, 255)
    end
end

return splash
