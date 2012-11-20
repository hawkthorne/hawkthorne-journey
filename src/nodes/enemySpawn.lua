local Enemy = require 'nodes/enemy'
local gamestate = require 'vendor/gamestate'

local Spawn = {}
Spawn.__index = Spawn

function Spawn.new(node, collider, enemytype)
    local spawn = {}
    setmetatable(spawn, Spawn)
    
    local type = node.properties.enemytype or enemytype
    
    spawn.spawned = 0
    spawn.spawnMax = 2
    spawn.lastspawn = 6
    spawn.node = node
    spawn.collider = collider
    spawn.type = type
    return spawn
end
    
function Spawn:update( dt, player )
    if math.abs(player.position.x - self.node.x) > 100 then
        return
    end
    self.lastspawn = self.lastspawn + dt
    if self.lastspawn > 5 then
        if self.spawned >= self.spawnMax then
            return
        end
        local level = gamestate.currentState()
        table.insert( level.nodes, Enemy.new(self.node, self.collider, self.type) )
        self.spawned = self.spawned + 1
    end
end

return Spawn