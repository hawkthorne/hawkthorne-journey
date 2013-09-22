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
	
	camera.x = 528
	self.camera_x = {y = camera.x}
	self.camera_y = {y = camera.y}
	
    self.cityscape = love.graphics.newImage("images/menu/cityscape.png")
	self.beams_1 = love.graphics.newImage("images/menu/beams_1.png")
	self.beams_2 = love.graphics.newImage("images/menu/beams_2.png")
	self.beams_3 = love.graphics.newImage("images/menu/beams_3.png")
	self.beams_4 = love.graphics.newImage("images/menu/beams_4.png")
	self.beams_5 = love.graphics.newImage("images/menu/beams_5.png")
    self.logo = love.graphics.newImage("images/menu/logo.png")
	
    self.logo_position = {y=-self.logo:getHeight()}
    self.logo_position_final = self.logo:getHeight() / 2 + 40
	
	-- panning of camera & logo appears
	tween(2, self.camera_y, {y = window.height*2})
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

	-- press START flashing
	self.blink = 0
	
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
	
	self.blink = self.blink + dt < 1 and self.blink + dt or 0
	
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
	
	if self.camera_y.y < 616 then
	    love.graphics.draw(self.beams_1, window.width*0.55 + camera.x, camera.y)
	elseif self.camera_y.y <628 or self.camera_x.y > 516 then
	    love.graphics.draw(self.beams_2, window.width*0.51 + camera.x, window.height*0.116 + camera.y )
	elseif self.camera_x.y > 20 then
	    love.graphics.draw(self.beams_3, window.width*0.36 + camera.x, window.height*0.2 + camera.y )
	elseif self.camera_x.y > 8 then
	    love.graphics.draw(self.beams_4, window.width*0.29 + camera.x, window.height*0.24 + camera.y )
	elseif self.camera_x.y > 0 then
	    love.graphics.draw(self.beams_5, window.width*0.29 + camera.x, window.height*0.27 + camera.y )
	end

	if camera.x == 0 then
        for _,_sp in pairs(self.sparkles) do
            _sp[3]:draw( self.sparklesprite, _sp[1] - 12 + xlogo, _sp[2] - 12 + ylogo + camera.y)
        end
    end

    if self.logo_position.y >= self.logo_position_final and self.blink <= 0.5 then
      love.graphics.printf("PRESS START", 0, window.height - 45 + camera.y, window.width, 'center', 0.5, 0.5)
    end

end

return splashnewgame
