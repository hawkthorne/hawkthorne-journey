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
    spawn.initialState = node.properties.initialState or 'default'
    assert(spawn.spawnType == 'proximity' or
           spawn.spawnType == 'keypress' or
           spawn.spawnType == 'drop', "type must be proximity, keypress or drop")
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

function Spawn:enter()
    if (self.spawnType == 'drop') then
        self.floor = self:determineFloorY( self.node.x, self.node.y )
    end
end

-- Determine where the closest floor is from this spawn
-- TODO: Put in a more centralized location
-- This is a dirty way to determine where the closest floor is, if someone has a better way
-- then by all means, do it!
function Spawn:determineFloorY( targetX, targetY )
    -- Set the closestFloor location to be sufficiently large
    local closestFloor = 1000000
    local found = false

    -- Iterate over the platforms and blocks to determine the best candidate
    -- If the platform/block's x + width falls in range of the target x AND
    -- the platform/block's y is below the target y AND
    -- the platform/block's y is closer to the target y
    -- v.x <= x weeds out all platforms/blocks that are way to the right
    if gamestate.currentState().map.objectgroups.platform then
        for k,v in pairs(gamestate.currentState().map.objectgroups.platform.objects) do
            if (v.x <= targetX and v.x + v.width >= targetX and v.y > targetY and v.y < closestFloor) then
                found = true
                closestFloor = v.y
            end
        end
    end
    -- Iterate over the blocks to determine the best candidate
    if gamestate.currentState().map.objectgroups.block then
        for k,v in pairs(gamestate.currentState().map.objectgroups.block.objects) do
            if (v.x <= targetX and v.x + v.width >= targetX and v.y > targetY and v.y < closestFloor) then
                found = true
                closestFloor = v.y
            end
        end
    end
    if not found then
        print ( "Warning: no floor found for Spawn at (" .. self.node.x .. "," .. self.node.y .. ")" )
    end
    return closestFloor
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
    elseif self.spawnType == 'drop' then
        -- TODO: Need to add smart drop, based on floor distance and SPEED
         if math.abs(player.position.x - self.node.x) <= 100 then
            self.lastspawn = self.lastspawn + dt
            if self.lastspawn > 5 then
                self.lastspawn = 0
                if self.spawned >= self.spawnMax then
                    return
                end
                local node = self:createNode()
                node.node.floor = self.floor
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
    spawnedNode.state = self.initialState
    level:addNode(spawnedNode)
    self.spawned = self.spawned + 1
    if spawnedNode.props.enter then
        spawnedNode.props.enter( spawnedNode )
    end
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
