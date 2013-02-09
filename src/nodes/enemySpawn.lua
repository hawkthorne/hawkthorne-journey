local Enemy = require 'nodes/enemy'
local gamestate = require 'vendor/gamestate'

local Spawn = {}
Spawn.__index = Spawn

function Spawn.new(node, collider, enemytype)
    local spawn = {}
    setmetatable(spawn, Spawn)
    
    local type = node.properties.enemytype or enemytype
    
    spawn.spawned = 0
    spawn.spawnMax = 1
    spawn.lastspawn = 6
    spawn.collider = collider
    spawn.node = node
    spawn.type = type
    return spawn
end
    
function Spawn:update( dt, player )
    if math.abs(player.position.x - self.node.x) > 100 then
        return
    end
    self.lastspawn = self.lastspawn + dt
    if self.lastspawn > 5 then
        self.lastspawn = 0
        if self.spawned >= self.spawnMax then
            return
        end
        local node = require ('nodes/enemies/'..self.type)
        node.properties = self.node.properties
        node.x = self.node.x
        node.y = self.node.y
        local collider = {}
        for k,v in pairs(self.collider) do
            collider[k] = v
        end
        local spawnedTurkey = Enemy.new(node, self.collider, self.type)
        local level = gamestate.currentState()
        table.insert( level.nodes, spawnedTurkey )
        self.spawned = self.spawned + 1
    end
end

return Spawn