local GS = require 'vendor/gamestate'

local KeyboardContext = {}
KeyboardContext.__index = KeyboardContext

---
-- Create a new keyboard context handler.
-- @param state: string, the name of the state
-- @param force: Set gamestate's keyboard context immediately
-- @return KeyboardContext
function KeyboardContext.new(state, force)
    local kc = {}
    setmetatable(kc, KeyboardContext)

    kc.state = state
    if force then
        kc:set()
    end

    return kc
end

---
-- Set the global keyboard context
-- @param state
-- @return nil
function KeyboardContext:setTo(state)
    local currentstate = GS.currentState()
    currentstate.keyboard_context = state
end

-- Set the global keyboard context to this handler's state
-- @return nil
function KeyboardContext:set()
    self:setTo(self.state)
end

---
-- Get the global keyboard context
-- @return state
function KeyboardContext:get()
    local currentstate = GS.currentState()
    if currentstate.keyboard_context then
        return currentstate.keyboard_context
    else
        return ""
    end
end

---
-- Get whether current context is active
-- @return state
function KeyboardContext:active()
    if self:get() == self.state then
        return true
    else
        return false
    end
end

return KeyboardContext
