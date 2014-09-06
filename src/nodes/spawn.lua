local gamestate = require 'vendor/gamestate'
local Level = require 'level'
local anim8 = require 'vendor/anim8'
local sound = require 'vendor/TEsound'
local Prompt = require 'prompt'
local utils = require 'utils'
require 'utils'

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
    spawn.message = node.properties.message or 'You found a '..node.name..'!'
    spawn.spawnType = node.properties.spawnType or 'proximity'
    -- If the spawn is a chest, or another interactive-type spawn, be sure to
    -- set the isInteractive flag for interaction
    if spawn.spawnType == 'keypress' then
        spawn.isInteractive = true
    end
    spawn.x_Proximity = node.properties.x_Proximity or 100
    spawn.y_Proximity = node.properties.y_Proximity or 125
    spawn.nodeType = node.properties.nodeType
    spawn.offset_x = node.properties.offset_x or 0
    spawn.offset_y = node.properties.offset_y or 0
    spawn.key = node.properties.key
    spawn.initialState = node.properties.initialState or 'default'
    assert(spawn.spawnType == 'proximity' or
           spawn.spawnType == 'keypress' or
           spawn.spawnType == 'smart', "type must be proximity, keypress or smart")
    assert(spawn.nodeType,"spawn node must have a nodeType")
    
    
    local g = anim8.newGrid( 24, 24, 24, 48)
    spawn.animations = {
        closed = anim8.newAnimation( 'once', g(1,1), 1),
        open = anim8.newAnimation( 'once', g(1,2), 1),
    }
    spawn.spritename = node.properties.sprite or 'chest'
    spawn.sprite = love.graphics.newImage( 'images/spawn/'..spawn.spritename..'.png' )
    spawn.sprite:setFilter('nearest', 'nearest')
    return spawn
end

function Spawn:enter()
    if (self.spawnType == 'smart') then
        self.floor = utils.determineFloorY( gamestate, self.node.x, self.node.y )
        if self.floor == nil then
            print ( "Warning: no floor found for Spawn at (" .. self.node.x .. "," .. self.node.y .. ")" )
            self.fallFrames = 1
            self.floor = self.node.y
        else
            -- Determine (roughly) how many frames it will take to fall to the floor that we found
            -- divided by four seems to give a good value
            self.fallFrames = (self.floor - self.position.y) / 4
        end
    end
end

function Spawn:update( dt, player )

    if self.spawned >= self.spawnMax then
        return
    end
    if self.spawnType == 'proximity' then
        if math.abs(player.position.x - self.node.x) <= self.x_Proximity + 0 and math.abs(player.position.y - self.node.y) <= self.y_Proximity + 0 then
            self.lastspawn = self.lastspawn + dt
            if self.lastspawn > 5 then
                self.lastspawn = 0
                self:createNode()
            end
        end
    elseif self.spawnType == 'smart' and player.velocity.x ~= 0 then
        if (math.abs(math.abs(player.position.x - self.node.x) / (player.velocity.x * dt))) <= self.fallFrames then
            -- Don't spawn enemies too fast
            self.lastspawn = self.lastspawn + dt
            if self.lastspawn > 5 then
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
    spawnedNode.state = self.initialState or 'default'
    level:addNode(spawnedNode)
    self.spawned = self.spawned + 1
    -- If the node has a spawn sound defined, then play it
    if spawnedNode.props and spawnedNode.props.spawn_sound then
        sound.playSfx( spawnedNode.props.spawn_sound )
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
            local message = {''..self.message..''}
            local callback = function(result)
                self.prompt = nil
                player.freeze = false
                player.invulnerable = false
                if node.keypressed then
                    node:keypressed( button, player )
                end
            end
            local options = {'Exit'}
            local direction = player.character.direction == 'left' and -1 or 1
            local x_offset = node.bbox_offset_x and node.bbox_offset_x[1] or 0
            print(x_offset)
            node.position = {
                x = player.position.x - player.character.bbox.x + player.character.bbox.width/2,
                y = player.position.y - player.character.bbox.y - 15
            }

            self.prompt = Prompt.new(message, callback, options, node)
            self.collider:remove(self.bb)
            -- Key has been handled, halt further processing
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
            -- Key has been handled, halt further processing
            return true
        end
    end
end

return Spawn
