local Gamestate = require 'vendor/gamestate'
local camera = require 'camera'
local state = Gamestate.new()

function state:init()
    self.background = love.graphics.newImage("images/pause.png")
    self.arrow = love.graphics.newImage("images/medium_arrow.png")
    self.checkbox_checked = love.graphics.newImage("images/checkbox_checked.png")
    self.checkbox_unchecked = love.graphics.newImage("images/checkbox_unchecked.png")
    self.fullscreen = false
end

function state:enter(previous)
    self.music = love.audio.play("audio/daybreak.ogg", "stream", true)

    camera:setPosition(0, 0)
    self.previous = previous
end

function state:leave()
    love.audio.stop(self.music)
end

function state:keypressed(key)
    if key == 'escape' then
        Gamestate.switch(self.previous)
        return
    elseif key == 'return' then
		-- Note: if/when we have multiple options, change behavior here based on selected option
		self.fullscreen = not self.fullscreen
		if self.fullscreen then
			love.graphics.setMode(0, 0, true)
			local width = love.graphics:getWidth()
			local height = love.graphics:getHeight()
			camera:setScale(456 / width , 264 / height)
			love.graphics.setMode(width, height, true)
		else
			local scale = 2
			camera:setScale(1 / scale , 1 / scale)
			love.graphics.setMode(456 * scale, 264 * scale, false)
		end
    end
end

function state:draw()
    love.graphics.draw(self.background)
    love.graphics.setColor(0, 0, 0)

	love.graphics.print('FULLSCREEN', 120, 60)
	-- Note: if/when we have multiple options, move the arrow dynamically
	love.graphics.draw(self.arrow, 110, 62)
	if self.fullscreen then
		love.graphics.draw(self.checkbox_checked, 250, 60)
	else
		love.graphics.draw(self.checkbox_unchecked, 250, 60)
	end

    love.graphics.setColor(255, 255, 255)
end

return state
