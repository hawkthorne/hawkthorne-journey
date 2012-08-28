-- General use 'liquid' node for things like quicksand and waterfalls
-- Set properties on the object to control

-- Required:
-- 'sprite' ( filepath ) - the path to the single image sprite for animation
-- 			Note: format for this sprite is 24x24 tiles, 2 rows, where the top
-- 			row is the top of the object and the bottom row is tiled across the remainder

-- Optional properties:
-- 'tile_height' ( integer ) - Height of the sprite tiles ( deafults to 24 )
-- 'tile_width' ( integer ) - Width of the sprite tiles ( deafults to 24 )
-- 'death' ( true / false ) - Player dies immediaetly on contact with liquid
-- 'injure' ( true / false ) - Player is injured for as long as they are touching the liquid
-- 'drown' ( true / false ) - Player dies when his head is submersed in the liquid
-- 'drag' ( true / false ) - Player is slowly dragged down by the liquid ( like quicksand )
-- 'speed' ( 0 => 1 ) - Speed at which the animation is played ( defaults to 0.2 )
-- 'mode' ( 'loop', 'once' or 'bounce' ) - Mode to play the animation at ( defaults to loop )
-- 'foreground' ( true / false ) - Render the sprites in front of the player ( defaults to true )

local anim8 = require 'vendor/anim8'
local Helper = require 'helper'
local window = require 'window'

local Liquid = {}
Liquid.__index = Liquid

function Liquid.new(node, collider)
    local np = node.properties

    local liquid = {}
    setmetatable(liquid, Liquid)

    liquid.collider = collider
    liquid.width = node.width
    liquid.height = node.height

    assert(np.sprite, 'Liquid Object (' .. node.name .. ') must specify \'sprite\' property ( path )' )
    liquid.image = love.graphics.newImage( np.sprite )
    liquid.tile_height = np.tile_height and np.tile_height or 24
    liquid.tile_width = np.tile_width and np.tile_width or 24

    liquid.g = anim8.newGrid( liquid.tile_height, liquid.tile_width, liquid.image:getWidth(), liquid.image:getHeight())
    liquid.animation_mode = np.mode and np.mode or 'loop'
    liquid.animation_speed = np.speed and np.speed or .2
    liquid.animation_top_frames = '1-' .. math.floor( liquid.image:getWidth() / liquid.tile_width ) .. ',1'
    liquid.animation_bottom_frames = '1-' .. math.floor( liquid.image:getWidth() / liquid.tile_width ) .. ',2'
    liquid.animation_top = anim8.newAnimation( liquid.animation_mode, liquid.g( liquid.animation_top_frames ), liquid.animation_speed )
    liquid.animation_bottom = anim8.newAnimation( liquid.animation_mode, liquid.g( liquid.animation_bottom_frames ), liquid.animation_speed )

    liquid.position = {x=node.x, y=node.y}

    liquid.death = np.death == 'true'
    liquid.injure = np.injure == 'true'
    liquid.drown = np.drown == 'true'
    liquid.drag = np.drag == 'true'
    liquid.foreground = np.foreground ~= 'false'

    liquid.bb = collider:addRectangle(node.x, node.y, node.width, node.height)
    liquid.bb.node = liquid
    collider:setPassive(liquid.bb)

    return liquid
end

function Liquid:collide(player, dt, mtv_x, mtv_y)
    if self.death then
        player.health = 0
        player.state = 'dead'
        self.died = true
    end

    if self.injure then
        player:die(1)
    end

    if self.drown and player.position.y >= self.position.y then
        player.health = 0
        player.state = 'dead'
    end

    if self.drag then
        player.rebounding = false
        player.liquid_drag = true

        if player.velocity.x > 20 then
            player.velocity.x = 20
        elseif player.velocity.x < -20 then
            player.velocity.x = -20
        end

        if player.velocity.y > 0 then
            player.jumping = false
            player.velocity.y = 20
        end
    end
end

function Liquid:collide_end(player, dt, mtv_x, mtv_y)
    if self.drag then
        player.liquid_drag = false
        if player.velocity.y < 0 then
            player.velocity.y = player.velocity.y - 200
        end
    end
end

function Liquid:update(dt, player)
    self.animation_top:update(dt)
    self.animation_bottom:update(dt)
    if self.died then
        player.position.y = player.position.y + 20 * dt
    end
end

function Liquid:draw()
    for i = 0, ( self.width / 24 ) - 1, 1 do
        love.graphics.drawq( self.image, self.animation_top.frames[ ( ( self.animation_top.position + i ) % #self.animation_top.frames ) + 1 ], self.position.x + ( i * 24 ), self.position.y )
        for j = 1, ( self.height / 24 ) - 1, 1 do
            love.graphics.drawq( self.image, self.animation_bottom.frames[ ( ( self.animation_bottom.position + i ) % #self.animation_top.frames) + 1 ], self.position.x + ( i * 24 ), self.position.y + ( j * 24 ) )
        end
    end
end

return Liquid
