local Board = require "board"
local window = require "window"
local fonts = require "fonts"
local Prompt = {}

Prompt.__index = Prompt
---
-- Create a new Prompt
-- @param message to display
-- @param callback when user answer's prompt
-- @return Prompt
function Prompt.new(width, height, message, callback)
    local prompt = {}
    setmetatable(prompt, Prompt)
    prompt.board = Board.new(width, height)
    prompt.board:open()
    prompt.message = message
    prompt.callback = callback
    prompt.result = false
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
        local ox = math.floor(x - self.board.width / 2 + 5)
        local oy = math.floor(y - self.board.height / 2 + 5)
        love.graphics.printf(self.message, ox, oy, self.board.width - 10)

        if self.result then
            love.graphics.setColor(254, 204, 2)
        else
            love.graphics.setColor(255, 255, 255)
        end
        love.graphics.print('Yes', ox, math.floor(y + self.board.height / 2 - 17))

        if not self.result then
            love.graphics.setColor(254, 204, 2)
        else
            love.graphics.setColor(255, 255, 255)
        end
        love.graphics.print('No', x, math.floor(y + self.board.height / 2 - 17))
    end

    love.graphics.setColor(255, 255, 255)

    fonts.revert()
end

function Prompt:keypressed(key)
    if self.board.state == 'closed' then
        return
    end

    if key == 'return' or key == 'kpenter' then
        self.board:close()
        return
    end

    if key == 'left' or key == 'a' or key == 'right' or key == 'd' then
        self.result = not self.result
    end
end

return Prompt





