-----------------------------------------------
-- throwingKnifeItem.lua
-- The code for the throwing knife, when it in the players inventory.
-- Created by HazardousPeach
-----------------------------------------------
local ThrowingKnife = require 'nodes/weapons/throwingknife'
local GS = require 'vendor/gamestate'
return{
    name = "throwingknife",
    type = "weapon",
    MAX_ITEMS = 8,
    quantity = 4,
    use = function(player,item)
        if item.quantity < 2 then
            player.inventory:removeItem(player.inventory.selectedWeaponIndex, 0)
        end
        item.quantity = item.quantity - 1
        local playerDirection = player.character.direction == "left" and -1 or 1
        local knifeX = player.position.x + (player.width / 2) + (15 * playerDirection)
        local knifeNode = { 
                        name = "throwingknife",
                        x = knifeX, 
                        y = player.position.y + (player.height / 1.5),
                        width = 20,
                        height = 7,
                        type = "weapon",
                        properties = {
                          ["velocityX"] = (7 * playerDirection) .. "",
                          ["velocityY"] = "0",
                        },
                       }
        local knife = ThrowingKnife.new(knifeNode, GS.currentState().collider)
        table.insert(GS.currentState().nodes, knife)
    end

}