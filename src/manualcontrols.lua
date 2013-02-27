local Manualcontrols = {}
Manualcontrols.__index = Manualcontrols

function Manualcontrols.new()
    local manualcontrols = {}
    setmetatable(manualcontrols, Manualcontrols)
    
    manualcontrols.buttons = {}

    return manualcontrols
end

function Manualcontrols:isDown(button)
    return self.buttons[button]
end

function Manualcontrols:press(button)
    self.buttons[button] = true
end

function Manualcontrols:release(button)
    self.buttons[button] = false
end

return Manualcontrols