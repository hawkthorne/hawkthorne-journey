local Board = require "board"
local camera = require "camera"
local Dialog = {}

Dialog.__index = Dialog
---
-- Create a new Dialog
-- @param message to display
-- @param callback when user answer's say
-- @return Dialog
function Dialog.new(message, callback)
    local say = {}
    setmetatable(say, Dialog)
    say.board = Board.new(312, 60)
    say.board:open()
    say.line = 1
    say.cursor = 0

    if type(message) == 'string' then
        say.messages = {message}
    else
        say.messages = message
    end

    say.callback = callback
    say.blink = 0
    say.state = 'opened'
    say.result = false
    return say
end

function Dialog:update(dt)
    local rate = 15
    self.blink = self.blink + dt < .50 and self.blink + dt or 0
    self.board:update(dt)
    self.cursor = math.min(self.cursor + (dt * rate), string.len(self.messages[self.line]))
    
    if self.board.state == 'closed' and self.state ~= 'closed' then
        self.state = 'closed'
        if self.callback then self.callback(self.result) end
    end
end

function Dialog:message()
  local long = self.messages[self.line]
  if math.floor(self.cursor) >= long:len() then
    return long .. (self.blink > .25 and "^" or "")
  else
    return string.sub(long, 1, math.floor(self.cursor))
  end
end

function Dialog:draw()
    local font = love.graphics.getFont()
    font:setLineHeight(1.3)

    if self.board.state == 'closed' then
        return
    end
    
    x, y = self.board:draw(camera.x + camera:getWidth() / 2,
                           camera.y + camera:getHeight() - 36)

    if self.board.state == 'opened' then
        local message = self:message()
        local _, lines = font:getWrap(message, self.board.width - 20)
        local ox = math.floor(x - self.board.width / 2 + 10)
        local oy = math.floor(y - (14 * lines / 2))

        love.graphics.printf(message, ox, oy, self.board.width - 20)
    end

    love.graphics.setColor( 255, 255, 255, 255 )
    font:setLineHeight(1.0)
end

function Dialog:keypressed( button )
    if self.board.state == 'closed' then
        return false
    end

    if button == 'JUMP' then
        if self.cursor < string.len(self.messages[self.line]) then
            self.cursor = string.len(self.messages[self.line])
        elseif self.line ~= #self.messages then
            self.cursor = 0
            self.line = self.line + 1
        else
            self.board:close()
            self.state = 'closing'
        end
    end

    return true
end


return Dialog






