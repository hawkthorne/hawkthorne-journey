local Timer = require 'vendor/timer'
local sound = require 'vendor/TEsound'
local splat = require 'nodes/splat'
local Enemy = require 'nodes/enemy'
local GS = require 'vendor/gamestate'

local Hippie = {}
Hippie.__index = Hippie

local open_ceiling = love.graphics.newImage('images/open_ceiling.png')
local broken_tiles = love.graphics.newImage('images/broken_tiles.png')

function Hippie.new(node, collider)
    local hippie = {}
    setmetatable(hippie, Hippie)
    hippie.node = node
    hippie.collider = collider
    hippie.node = node
    hippie.width = 48
    hippie.height = 48
    hippie.dropped = false
    hippie.floor = node.y + node.height - 48

    hippie.position = {x=node.x + 40, y=node.y}
    hippie.bb = collider:addRectangle(hippie.position.x, node.y, node.width, node.height)
    hippie.bb.node = hippie
    collider:setPassive(hippie.bb)
    return hippie
end


function Hippie:collide(player, dt, mtv_x, mtv_y)
    if not self.dropped then
        -- //change the bounding box
        sound.playSfx('hippy_enter')
		self.node.x = self.position.x
        self.collider:remove(self.bb)
        self.bb = self.collider:addRectangle(self.node.x, self.node.y,30,25)
        self.bb.node = self
        self.collider:setPassive(self.bb)
		self.node.properties.name = "hippy"
		self.node.properties.floor = self.floor
    	table.insert(GS.currentState().nodes, Enemy.new(self.node, self.collider))
    	self.collide = nil
    	self.dropped = true
        return
    end
end


function Hippie:draw()
    --if not self.dropped then
        --return
    --end
    love.graphics.draw( open_ceiling, self.position.x-40, self.node.y )
    love.graphics.draw( broken_tiles, self.node.x-24, self.node.y + self.node.height )
end

return Hippie
