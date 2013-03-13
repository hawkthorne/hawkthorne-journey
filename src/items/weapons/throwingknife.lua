-----------------------------------------------
-- throwingKnifeItem.lua
-- The code for the throwing knife, when it in the players inventory.
-- Created by HazardousPeach
-----------------------------------------------
local Projectile = require 'nodes/projectile'
local GS = require 'vendor/gamestate'
return{
    name = "throwingknife",
    type = "weapon",
    MAX_ITEMS = 8,
    quantity = 4,
    use = function(player,item)
        local node = require('nodes/projectiles/'..item.name)
        node.x = player.position.x
        node.y = player.position.y + player.height/2
        node.directory = item.type.."s/"
        local level = GS.currentState()
        local knife = Projectile.new(node, level.collider)
        knife:throw(player)
        level:addNode(knife)
    end
}
