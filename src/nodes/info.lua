local Dialog = require 'dialog'

local Info = {}
Info.__index = Info
 
function Info.new(node, collider)
    local info = {}
    setmetatable(info, Info)
    info.bb = collider:addRectangle(node.x, node.y, node.width, node.height)
    info.bb.node = info
    info.info = split( node.properties.info, '|' )

    info.x = node.x
    info.y = node.y
    info.height = node.height
    info.width = node.width
    info.foreground = 'true'

    collider:setPassive(info.bb)
    
    info.dialog = nil
    info.current = nil

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

function Info:collide(node, dt, mtv_x, mtv_y)
    if node.isPlayer then
        node.interactive_collide = true
    end
end

function Info:collide_end(node, dt)
    if node.isPlayer then
        node.interactive_collide = false
    end
end

function Info:keypressed( button, player )
    if self.dialog then
        return self.dialog:keypressed(button)
    end
    
    if button == 'INTERACT' and self.dialog == nil and not player.freeze then
        player.freeze = true
        self.dialog = Dialog.new(self.info, function()
            player.freeze = false
            self.dialog = nil
        end)
        return true
    end
end

return Info
