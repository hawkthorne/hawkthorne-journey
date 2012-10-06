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

function Dialog.textToSpeech(message)
    SYSTEM_NAME = "windows"
    ESPEAK_LOCATION = "src\\audio\\espeak.exe"
    if SYSTEM_NAME == "windows" and file_exists(ESPEAK_LOCATION) then
        t = os.execute("echo "..message.." | "..ESPEAK_LOCATION.."&")
    else
        --your system does not support tts or you don't have espeak in ESPEAK_LOCATION
    end
end

function file_exists(name)
   local f=io.open(name,"r")
   if f~=nil then io.close(f) return true else return false end
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

    love.graphics.setColor(255, 255, 255)
end

function Dialog:keypressed(key)
    if self.board.state == 'closed' then
        return
    end

    if key == 'return' or key == 'kpenter' then
        if self.state ~= 'closing' then
            Dialog.textToSpeech(self.messages[self.message])
        end
        if self.message ~= #self.messages then
            self.message = self.message + 1
        else
            self.board:close()
            self.state = 'closing'
        end
    end
end

return Dialog






