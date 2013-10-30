local Dialog = require 'dialog'
local utils = require 'utils'

local Info = {}
Info.__index = Info
-- Nodes with 'isInteractive' are nodes which the player can interact with, but not pick up in any way
Info.isInteractive = true

function Info.new(node, collider)
    local info = {}
    setmetatable(info, Info)
    
    info.bb = collider:addRectangle(node.x, node.y, node.width, node.height)
    info.bb.node = info
    info.info = utils.split(node.properties.info, '|')

    info.x = node.x
    info.y = node.y
    info.height = node.height
    info.width = node.width
    info.position = { x = node.x, y = node.y }

    if node.properties.sprite ~= nil then
        info.sprite = love.graphics.newImage('images/info/'.. node.properties.sprite ..'.png')
    end

    collider:setPassive(info.bb)
    
    info.current = nil

    return info
end

function Info:update(dt, player)
end

function Info:draw()
    if self.sprite ~= nil then
        love.graphics.draw(self.sprite, self.position.x, self.position.y)
    end
end

function Info:keypressed( button, player )
    
    if button == 'INTERACT' and self.dialog == nil and not player.freeze then
        player.freeze = true
        Dialog.new(self.info, function()
            player.freeze = false
            Dialog.currentDialog = nil
        end)
        -- Key has been handled, halt further processing
        return true
    end
end

return Info
