local gamestate = require 'vendor/gamestate'
local Level = require 'level'
local anim8 = require 'vendor/anim8'
local sound = require 'vendor/TEsound'
local Prompt = require 'prompt'

local Spawn = {}
Spawn.__index = Spawn

function Spawn.new(node, collider, enemytype)
    --temporary to make sure it's not being used
    local spawn = {}
    setmetatable(spawn, Spawn)
    
    spawn.spawned = 0
    spawn.spawnMax = tonumber(node.properties.spawnMax) or 1
    spawn.lastspawn = 6
    spawn.collider = collider
    spawn.bb = collider:addRectangle( node.x, node.y, node.width, node.height )
    spawn.bb.node = spawn
    spawn.position = {x = node.x,y = node.y}

    spawn.node = node
    spawn.state = "closed"
    spawn.type = node.properties.type
    spawn.spawnType = node.properties.spawnType or 'proximity'
    spawn.nodeType = node.properties.nodeType
    spawn.offset_x = node.properties.offset_x or 0
    spawn.offset_y = node.properties.offset_y or 0
    spawn.key = node.properties.key
    assert(spawn.spawnType == 'proximity' or
           spawn.spawnType == 'keypress', "type must be proximity or keypress")
    assert(spawn.nodeType,"spawn node must have a nodeType")
    
    
    local g = anim8.newGrid( 24, 24, 24, 48)
    spawn.animations = {
        closed = anim8.newAnimation( 'once', g(1,1), 1),
        open = anim8.newAnimation( 'once', g(1,2), 1),
    }
    spawn.sprite = love.graphics.newImage( 'images/chest.png' )
    spawn.sprite:setFilter('nearest', 'nearest')
    return spawn
end
    
function Spawn:update( dt, player )

    if self.spawnType == 'proximity' then
        if math.abs(player.position.x - self.node.x) <= 100 and math.abs(player.position.y - self.node.y) <= 125 then
            self.lastspawn = self.lastspawn + dt
            if self.lastspawn > 5 then
                self.lastspawn = 0
                if self.spawned >= self.spawnMax then
                    return
                end
                self:createNode()
            end
        end
    end
    --note: keypress is accessed by level.lua
end

function Spawn:draw()
    if self.spawnType=='keypress' then
        self:animation():draw( self.sprite, math.floor( self.position.x ), math.floor( self.position.y ) )
    end
end

function Spawn:animation()
    return self.animations[self.state]
end

function Spawn:createNode()
    local NodeClass = require('nodes/' .. self.nodeType)
    local spawnedNode = NodeClass.new(self.node, self.collider)
    spawnedNode.velocity = {
        x = tonumber(self.node.properties.velocityX) or 0,
        y = tonumber(self.node.properties.velocityY) or 0,
    }
    spawnedNode.node = self.node
    spawnedNode.position.x = spawnedNode.position.x + self.offset_x
    spawnedNode.position.y = spawnedNode.position.y + self.offset_y
    local level = gamestate.currentState()
    level:addNode(spawnedNode)
    self.spawned = self.spawned + 1
    return spawnedNode
end

function Spawn:keypressed( button, player )
    if button == 'INTERACT' and self.spawnType == 'keypress' and 
              self.spawned < self.spawnMax then
        if not self.key or player.inventory:hasKey(self.key) then
            sound.playSfx('unlocked')
            self.state = "open"
            player.freeze = true
            player.invulnerable = true
            player.character.state = "acquire"
            local node = self:createNode()
            node.delay = 0
            node.life = math.huge
            local message = {'You found a "'..self.node.name..'" '..self.nodeType}
            local callback = function(result)
                self.prompt = nil
                player.freeze = false
                player.invulnerable = false
                if node.keypressed then
                    node:keypressed( button, player )
                end
            end
            local options = {'Exit'}
            node.position = { x = player.position.x +14  ,y = player.position.y - 10}

            self.prompt = Prompt.new(message, callback, options, node)
            self.collider:remove(self.bb)
            return true
        else
            sound.playSfx('locked')
            player.freeze = true
            player.invulnerable = true
            local message = {'You need the "'..self.key..'" key to open this.'}
            local callback = function(result)
                self.prompt = nil
                player.freeze = false
                player.invulnerable = false
            end
            local options = {'Exit'}
            self.prompt = Prompt.new(message, callback, options)
            return true
        end
    end
end

return Spawn
