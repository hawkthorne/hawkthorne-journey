local Board = require "board"
local window = require "window"
local Dialog = {}

Dialog.__index = Dialog
---
-- Create a new Dialog
-- @param message to display
-- @param callback when user answer's say
-- @return Dialog
function Dialog.new(width, height, message, callback)
    local say = {}
    setmetatable(say, Dialog)
    say.board = Board.new(width, height)
    say.board:open()
    say.message = 1

    if type(message) == 'string' then
        say.messages = {message}
    else
        say.messages = message
    end

    say.callback = callback
    say.state = 'opened'
    say.result = false
    return say
end

function Dialog:update(dt)
    self.board:update(dt)
    if self.board.state == 'closed' and self.state ~= 'closed' then
        self.state = 'closed'
        if self.callback then self.callback(self.result) end
    end
end

function Dialog:draw(x, y)
    if self.board.state == 'closed' then
        return
    end
    
    self.board:draw(x, y)

    if self.board.state == 'opened' then
        local ox = math.floor(x - self.board.width / 2 + 5)
        local oy = math.floor(y - self.board.height / 2 + 5)
        love.graphics.printf(self.messages[self.message],
                             ox, oy, self.board.width - 10)
    end

    love.graphics.setColor( 255, 255, 255, 255 )
end

function Dialog:keypressed( button )
    if self.board.state == 'closed' then
        return
    end

    if button == 'ACTION' then
        if self.message ~= #self.messages then
            self.message = self.message + 1
        else
            self.board:close()
            self.state = 'closing'
        end
    end
end


return Dialog






