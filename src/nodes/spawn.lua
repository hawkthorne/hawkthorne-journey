local Enemy = require 'nodes/enemy'
local Gamestate = require 'vendor/gamestate'
local Level = require 'level'

local Spawn = {}
Spawn.__index = Spawn

Spawn.turkeyCount = 0
Spawn.turkeyMax = 7

--a class for dynamically spawning a node
function Spawn.new(node, collider, enemytype)
    --enemytype is useless, fail loudly
    assert(not enemytype)

    local spawn = {}
    setmetatable(spawn, Spawn)
    
    spawn.spawnCount = 0
    spawn.spawnMax = 5
    spawn.lastSpawnTime = 5
    spawn.collider = collider
    spawn.node = node
    return spawn
end
    
function Spawn:update( dt, player )
    if math.abs(player.position.x - self.node.x) > 100 then
        return
    end
    self.lastSpawnTime = self.lastSpawnTime + dt
    if self.lastSpawnTime > 5 then
        self.lastSpawnTime = 0
        if self.spawnCount >= self.spawnMax then
            return
        end
        local NodeClass = Level.load_node(self.node.properties.type)
        local level = Gamestate.currentState()
        local spawnedNode = NodeClass.new( self.node, level.collider )
        if spawnedNode.velocity then
            if self.node.properties.velocityX then
                spawnedNode.velocity.x = tonumber(self.node.properties.velocityX)
            end
            if self.node.properties.velocityY then
                spawnedNode.velocity.y = tonumber(self.node.properties.velocityY)
            end
        end
        table.insert( level.nodes, spawnedNode )
        self.spawnCount = self.spawnCount + 1
        Spawn.turkeyCount = Spawn.turkeyCount + 1
    end
end

return Spawn