local Gamestate = require 'vendor/gamestate'
local window = require 'window'
local camera = require 'camera'
local sound = require 'vendor/TEsound'
local fonts = require 'fonts'
local state = Gamestate.new()
local part = require 'particlesystem'
local playSpr; local playDead
gO=false



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
	
	self.playSpr = love.graphics.newImage('images/characters/' .. playName .. '/base.png')
	self.playDead = love.graphics.newQuad(8*48, 1*48, 48, 48, self.playSpr:getWidth(), self.playSpr:getHeight())
	
	self.blink=0
end

function state:enter(previous)
    fonts.set( 'big' )
    sound.playMusic( "village-forest" )
	
	self.playSpr = love.graphics.newImage('images/characters/' .. playName .. '/base.png')
	self.playDead = love.graphics.newQuad(0*48, 0*48, 48, 48, self.playSpr:getWidth(), self.playSpr:getHeight())
	gO=true
	
    camera:setPosition(0, 0)
    self.previous = previous
end

function state:leave()
    fonts.reset()
end

function state:keypressed( button )
    Gamestate.switch("home")
	gO=false
	lives=3
end

function state:update(dt)
	part.update(dt)
	self.blink=self.blink+1
	if self.blink>75 then
		self.blink=0
	end
end

function state:draw()

	
    love.graphics.setColor(0, 0, 0)
	love.graphics.rectangle("fill", 0, 0, 528, 336)
	part.draw()
	fonts.set('big')
	love.graphics.print(self.text,self.left-20, self.top)
	love.graphics.drawq(self.playSpr, self.playDead, self.left+60, self.top+20)
	fonts.set('ariel')
	if self.blink<60 then
		love.graphics.print(self.text2,self.left+5, self.top+80)
	end
    love.graphics.setColor(255, 255, 255)
end

return state
