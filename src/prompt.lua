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
function Prompt.new(width, height, message, callback, options)
    local prompt = {}
    setmetatable(prompt, Prompt)
    prompt.message = message
    prompt.callback = callback
    -- options is a list of strings, with the last being the default
    -- if the last is a duplicate, then it is removed and the first instance is set to the default.
        -- ex: {'red','blue','green','blue'} would only show red, blue and green, but blue is set to the default
    prompt.options = options or {'Yes','No'}
    prompt.selected = #prompt.options
    for i,o in pairs( prompt.options ) do
        if o == prompt.options[#prompt.options] and i < #prompt.options then
            prompt.selected = i
            prompt.options[#prompt.options] = nil
            break
        end
    end
    prompt.board = Board.new(width, height)
    prompt.board:open()
    
    return prompt
end

function Prompt:update(dt)
    self.board:update(dt)
    if self.board.state == 'closed' and self.callback and not self.called then
        self.called = true
        self.callback(self.selected)
    end
end

function Prompt:draw(x, y)
    if self.board.state == 'closed' then
        return
    end

    fonts.set( 'default' )

    self.board:draw(x, y)

    if self.board.state == 'opened' then
        -- origin / offset ( x,y is centered )
        local ox = math.floor(x - self.board.width / 2 + 5)
        local oy = math.floor(y - self.board.height / 2 + 5)
        love.graphics.printf(self.message, ox, oy, self.board.width - 10)

        local _x = ox + self.board.width * 0.30
        local _y = oy + self.board.height - ( 20 * math.floor( ( #self.options / 2 ) + 0.5) )

        local Font = love.graphics.getFont()

        for i,o in pairs( self.options ) do
            love.graphics.setColor(255, 255, 255)
            if i == self.selected then
                love.graphics.setColor(254, 204, 2)
            end

            love.graphics.print(o, _x - Font:getWidth(o) / 2, _y)

            if i % 2 == 1 then --right option next
                _x = ox + self.board.width * 0.7
            else --left option / new line next
                _y = _y + 20
                _x = ox + self.board.width * 0.3
            end
        end
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

    if key == 'left' or key == 'a' then
        if self.selected % 2 == 0 then
            self.selected = self.selected - 1
        end
    elseif key == 'right' or key == 'd' then
        if self.selected % 2 == 1 and self.selected < #self.options then
            self.selected = self.selected + 1
        end
    elseif key == 'up' or key == 'w' then
        if self.selected > 2 then
            self.selected = self.selected - 2
        end
    elseif key == 'down' or key == 's' then
        if self.selected + 2 <= #self.options then
            self.selected = self.selected + 2
        end
    end
end

return Prompt





