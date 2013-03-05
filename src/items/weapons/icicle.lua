-----------------------------------------------
-- throwingKnifeItem.lua
-- The code for the icicle, when it is in the players inventory.
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
        local level = GS.currentState()
        local icicle = Projectile.new(node, level.collider)
        icicle:throw(player)
        level:addNode(icicle)
    end
}