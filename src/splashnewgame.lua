local app = require 'app'
local anim8 = require 'vendor/anim8'
local Gamestate = require 'vendor/gamestate'
local window    = require 'window'
local fonts     = require 'fonts'
local splashnewgame    = Gamestate.new()
local camera    = require 'camera'
local tween     = require 'vendor/tween'
local sound     = require 'vendor/TEsound'
local controls  = require 'controls'
local timer     = require 'vendor/timer'
local VerticalParticles = require "verticalparticles"


function splashnewgame:init()

    VerticalParticles.init()
	
    self.cityscape = love.graphics.newImage("images/menu/cityscapefly.png")
    self.logo = love.graphics.newImage("images/menu/logo.png")
    self.logo_position = {y=-self.logo:getHeight()}
    self.logo_position_final = self.logo:getHeight() / 2 + 40
	
	camera.x = 528
	self.camera_x = {y = camera.x}
	self.camera_y = {y = camera.y}
	-- pans down
	tween(2, self.camera_y, {y = window.height*2})
	-- pans across & then logo pans up
    timer.add(2, function() 
	    tween(2, self.camera_x, {y = 0}) 
		timer.add(2, function() tween(4, self.logo_position, { y=self.logo_position_final}) end)
    end)

    -- sparkles
    self.sparklesprite = love.graphics.newImage('images/cornelius_sparkles.png')
    self.bling = anim8.newGrid(24, 24, self.sparklesprite:getWidth(), self.sparklesprite:getHeight())
    self.sparkles = {{55,34},{42,112},{132,139},{271,115},{274,50}}
    for _,_sp in pairs(self.sparkles) do
        _sp[3] = anim8.newAnimation('loop', self.bling('1-4,1'), 0.22 + math.random() / 10) 
        _sp[3]:gotoFrame( math.random( 4 ) ) 
    end

    -- 'double_speed' is used to speed up the animation of the logo + splash
    self.double_speed = false
end

function splashnewgame:enter(a)
    fonts.set( 'big' )
    
    camera:setPosition(0, 0)
    self.bg = sound.playMusic( "opening" )
end

function splashnewgame:update(dt)

    VerticalParticles.update( dt )

    if self.double_speed then
        tween.update(dt * 20)
    end

    for _,_sp in pairs(self.sparkles) do
        _sp[3]:update(dt)
    end
	
	camera.x = self.camera_x.y
	camera.y = self.camera_y.y

end

function splashnewgame:leave()
    fonts.reset()

    if self.handle then 
      timer.cancel(self.handle)
    end
end

function splashnewgame:keypressed( button )
    if self.logo_position.y < self.logo_position_final then
        self.double_speed = true
    elseif button == 'START' then
		Gamestate.switch('start')
	else
		Gamestate.switch('studyroom', 'main') 
    end
end

function splashnewgame:draw()

    VerticalParticles.draw()

    local xlogo = window.width / 2 - self.logo:getWidth()/2
    local ylogo = window.height / 2 - self.logo_position.y
   
    love.graphics.draw(self.cityscape)
    love.graphics.draw(self.logo, xlogo, ylogo + camera.y )

	if camera.x == 0 then
        for _,_sp in pairs(self.sparkles) do
            _sp[3]:draw( self.sparklesprite, _sp[1] - 12 + xlogo, _sp[2] - 12 + ylogo + camera.y)
        end
    end

    if self.logo_position.y >= self.logo_position_final then
      love.graphics.printf("PRESS START", 0, window.height - 45 + camera.y, window.width, 'center', 0.5, 0.5)
    end

end

return splashnewgame
