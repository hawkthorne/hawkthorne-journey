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
    
    info.current = nil

    return info
end

function Info:update(dt, player)
end

function Info:draw()
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
    if button == 'INTERACT' and self.dialog == nil and not player.freeze then
        player.freeze = true
        self.dialog = Dialog.new(self.info, function()
            player.freeze = false
            Dialog.currentDialog = nil
        end)
        return true
    end
end

return Info
