local Board = require "board"
local window = require "window"
local fonts = require "fonts"
local Prompt = {}

--TODO:  THIS CAN PROBABLY BE WRAPPED INTO SOMETHING A BIT MORE GENERIC

Prompt.__index = Prompt
---
-- Create a new Prompt
-- @param message to display
-- @param callback when user answer's prompt
-- @return Prompt
function Prompt.new(callback)
    local prompt = {}
	prompt.callback = callback
    setmetatable(prompt, Prompt)
    prompt.board = Board.new(200, 55)
    prompt.board:open()
    prompt.message = 'Choose a game to play!'
	prompt.options = {'Poker', 'Blackjack', 'Close'}
    prompt.result = 1

    return prompt
end

function Prompt:update(dt)
    self.board:update(dt)
    if self.board.state == 'closed' and self.callback and not self.called then
        self.called = true
        self.callback(self.result)
    end
end

function Prompt:draw(x, y)
    if self.board.state == 'closed' then
        return
    end

    fonts.set( 'default' )

    self.board:draw(x, y)

    if self.board.state == 'opened' then
        local ox = math.floor(x - self.board.width / 2+ 5)
		local x2 = math.floor(ox + self.board.width / 3)
		local x3 = math.floor(x2 + self.board.width / 3 + 15)
        local oy = math.floor(y - self.board.height / 2 + 5)
        love.graphics.printf(self.message, ox, oy, self.board.width - 10)

        if self.result == 1 then
            love.graphics.setColor(254, 204, 2)
        else
            love.graphics.setColor(255, 255, 255)
        end
        love.graphics.print(self.options[1], ox, math.floor(y + self.board.height / 2 - 17))

        if self.result == 2 then
            love.graphics.setColor(254, 204, 2)
        else
            love.graphics.setColor(255, 255, 255)
        end
        love.graphics.print(self.options[2], x2, math.floor(y + self.board.height / 2 - 17))

		if self.result == 3 then
            love.graphics.setColor(254, 204, 2)
        else
            love.graphics.setColor(255, 255, 255)
        end
        love.graphics.print(self.options[3], x3, math.floor(y + self.board.height / 2 - 17))
    end

    love.graphics.setColor(255, 255, 255)

    fonts.revert()
end

function Prompt:keypressed(key)
    if self.board.state == 'closed' then
        return
    end

    if key == 'return' then
        self.board:close()
        return
    end

    if key == 'left' or key == 'a' then
    	self.result = (self.result - 2) % 3 + 1
	elseif key == 'right' or key == 'd' then 
		self.result  = (self.result) % 3 + 1
    end
end

return Prompt





