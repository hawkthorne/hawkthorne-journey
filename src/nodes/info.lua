local Dialog = require 'dialog'

local Info = {}
Info.__index = Info
 
function Info.new(node, collider)
    local info = {}
    setmetatable(info, Info)
    info.bb = collider:addRectangle(node.x, node.y, node.width, node.height)
    info.bb.node = info
    info.info = node.properties.info

    info.x = node.x
    info.y = node.y
    info.foreground = 'true'

    collider:setPassive(info.bb)
    
    info.dialog = nil

    return info
end

function Info:update(dt, player)
    if self.dialog then self.dialog:update(dt) end
end

function Info:draw()
    if self.dialog then
        self.dialog:draw( self.x, self.y - 30 )
    end
end

function Info:keypressed(key, player)
    if self.dialog then
        self.dialog:keypressed('return')
    end
    
    if (key == 'rshift' or key == 'lshift') and self.dialog == nil then
        player.freeze = true
        self.dialog = Dialog.new(115, 50, self.info, function()
            player.freeze = false
            self.dialog = nil
        end)
    end
end

return Info