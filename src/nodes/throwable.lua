local anim8 = require 'vendor/anim8'
local window = require 'window'
local sound = require 'vendor/TEsound'
local utils = require 'utils'

local Throwable = {}
Throwable.__index = Throwable


function Throwable.new(node, collider)
    local throw = {}
    setmetatable(throw, Throwable)
    
    local name= node.name

    throw.type = 'throwable'
    throw.name = name
    throw.props = utils.require('nodes/throwables/' .. name) 
   
    local dir= node.directory or ""
    throw.image = love.graphics.newImage('images/throwables/'..dir..name..'.png')

    throw.bb = collider:addRectangle(node.x, node.y, node.width, node.height)
    throw.bb.node = throw
    throw.collider = collider
    throw.width = throw.props.width or node.width
    throw.height = throw.props.height or node.height

    throw.holdXOffset = throw.props.holdXOffset or 0
    throw.holdYOffset = throw.props.holdYOffset or 0
    throw.collider:setPassive(throw.bb)

    if throw.props.explode then
        throw.explodeImage= love.graphics.newImage('images/throwables/'..dir..name..'_explode.png')
        local g = anim8.newGrid( throw.props.explode.frameWidth,
                                 throw.props.explode.frameHeight,
                                 throw.explodeImage:getWidth(),
                                 throw.explodeImage:getHeight() )
    local explodeAnimation= throw.props.explode.animation
            throw.explode = anim8.newAnimation(explodeAnimation[1],g(unpack(explodeAnimation[2])),explodeAnimation[3])
    end

    throw.position = { x = node.x, y = node.y }
    throw.velocity = { x = 0, y = 0 }

    throw.floor = 0
    throw.die = false
    throw.thrown = false
    throw.held = false

    return throw
end

function Throwable:draw()
    if self.die and self.explode then
        self.explode:draw(self.explodeImage, self.position.x, self.position.y)
    else
        love.graphics.draw(self.image, self.position.x, self.position.y)
    end
end

function Throwable:collide(node, dt, mtv_x, mtv_y)
    if node.isPlayer and not self.die then
        node:registerHoldable(self)
    end
end

function Throwable:collide_end(node, dt)
    if node.isPlayer then
        node:cancelHoldable(self)
    end
end


function Throwable:update(dt, player)
    if self.held then
        if player.character.direction == "right" then
            -- the offset of 4 is for aesthetic purposes.
            self.position.x = math.floor(player.position.x + player.offset_hand_right[1] )
            + player.character.bbox.width/2 - 4
        else
            self.position.x = math.floor(player.position.x + player.offset_hand_left[1] )
            + player.character.bbox.width/2 - self.holdXOffset
        end
        -- Needed due to side inversions. Prevents wider throwbles from floating out on the sides.
        if player.character.state == player.gaze_state then
            self.position.x = math.floor(player.position.x + player.offset_hand_left[1] )
            + player.character.bbox.width/2 - 2
        end

        self.position.y = math.floor(player.position.y + player.offset_hand_right[2] - self.height)
        + self.holdYOffset - player.character.bbox.y
        self:moveBoundingBox()
        return
    end

    if self.die and self.explode and self.explode.position ~= 5 then
        self.explode:update(dt)
        self.position.x = self.position.x + (self.velocity.x > 0 and 1 or -1) * 50 * dt
        return
    end

    if not (self.thrown or self.held) then
        return
    end

    self.velocity.y = self.velocity.y + 0.21875 * 10000 * dt

    if not self.held then
        self.position.x = self.position.x + self.velocity.x * dt
        self.position.y = self.position.y + self.velocity.y * dt
        self:moveBoundingBox()
    end

    local lwx, rwx = player.footprint:getWall_x()
    if self.position.x < lwx then
        self.velocity.x = -self.velocity.x
    end

    if self.position.x > rwx - self.width then
        self.velocity.x = -self.velocity.x
    end

    if self.thrown and self.position.y > self.floor then
        player:cancelHoldable( self )
        self.position.y = self.floor
        self.thrown = false
        if self.explode then
            self.die = true
            sound.playSfx('pot_break') 
        end
    end
end

function Throwable:moveBoundingBox()
    if not self.bb then return end
    self.bb:moveTo(self.position.x + self.width / 2, self.position.y + (self.height / 2) + 2)
end

function Throwable:pickup(player)
    self.held = true
    self.velocity.y = 0
    self.velocity.x = 0
end

function Throwable:throw(player)
    self.held = false
    self.thrown = true
    self.floor = player.footprint and player.footprint.y - self.height
    self.velocity.x = player.velocity.x + ((player.character.direction == "left") and -1 or 1) * 500
    self.velocity.y = player.velocity.y
    if(self.explode) then
      self.collider:remove(self.bb)
    end
    player:cancelHoldable(self)
end

function Throwable:throw_vertical(player)
    self.held = false
    self.thrown = true
    self.floor = player.footprint and player.footprint.y - self.height
    self.velocity.x = player.velocity.x
    self.velocity.y = player.velocity.y - 500
    self.collider:remove(self.bb)
    player:cancelHoldable(self)
end

function Throwable:drop(player)
    self.held = false
    self.thrown = false
    self.position.y = player.footprint and player.footprint.y - self.height
    self.velocity.x = 0
    self.velocity.y = 0
    self:moveBoundingBox()
    player:cancelHoldable(self)
end

return Throwable
