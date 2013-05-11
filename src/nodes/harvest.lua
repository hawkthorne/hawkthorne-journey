local Harvest = {}
Harvest.__index = Harvest

function Harvest.new(node, collider)
    local harvest = {}
    setmetatable(harvest, Harvest)
    harvest.bb = collider:addRectangle(node.x, node.y, node.width, node.height)
    harvest.bb.node = harvest
    harvest.player_touched = false
    harvest.level = node.properties.level
    harvest.reenter = node.properties.reenter
    harvest.to = node.properties.to
    harvest.height = node.height
    harvest.width = node.width
    harvest.item = node.properties.item or "eye"
    harvest.left = node.properties.amount or 3
    collider:setPassive(harvest.bb)
    return harvest
end

function Harvest:keypressed( button, player )
    if button == 'INTERACT' then
        if self.left > 0 then
            local ItemClass = require('items/item')
            local itemNode = {type = 'material', name = self.item, quanity = 1, MAX_ITEMS=10}
            local item = ItemClass.new(itemNode)
            player.inventory:addItem(item)
            self.left = self.left - 1
        end
        return true
    end
end

return Harvest
