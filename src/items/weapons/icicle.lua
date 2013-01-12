-----------------------------------------------
-- throwingKnifeItem.lua
-- The code for the throwing knife, when it in the players inventory.
-- Created by HazardousPeach
-----------------------------------------------
local Projectile = require 'nodes/projectile'
local GS = require 'vendor/gamestate'
return{
    name = "icicle",
    type = "weapon",
    MAX_ITEMS = 10,
    quantity = 5,
    use = function(player,item)
        local node = require('nodes/projectiles/'..item.name)
        node.x = player.position.x
        node.y = player.position.y + player.height/2
        node.directory = item.type.."s/"
        local knife = Projectile.new(node, GS.currentState().collider)
        knife:throw(player)
        table.insert(GS.currentState().nodes, knife)
    end
}