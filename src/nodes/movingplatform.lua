-- The MovingPlatform node facilitates platforms that move back and fourth along a Bspline Curve
-- So setup a movingplatform, you will need to create 2 objects:
--      The 'control' object represents the size of the ledge and contains all of the properties required to make it work
--      The 'line' object is a polyline that represents the path that the platform will follow

-- 'control' object:
--      Must be setup in the 'nodes' object layer

--      Required:
--      'line' ( string ) - the name of the polyline that defines the path
--      'sprite' ( filepath ) - the path to the single image sprite

--      Optional properties:
--      'offset_x' ( integer ) - horizontal offset for the sprite to be drawn ( defaults to 0 )
--      'offset_y' ( integer ) - vertical offset for the sprite to be drawn ( defaults to 0 )
--      'direction' ( 1 or -1 ) - direction to start travel in, where 1 is away from the first line point ( defaults to 1 )
--      'speed' ( float ) - speed of the platform, 0.5 for half, 2 for double, etc ( defaults to 1 )
--      'start' ( 0 => 1 ) - point along the line that the platform should start at ( defaults to 0.5 )
--              Note: 0 is the beginning of the line, 1 is the end and 0.5 is right in the middle
--      'showline' ( true / false ) - draws the line that the platform will follow ( defaults to false )
--      'touchstart' ( true / false ) - doesn't start moving until the player collides ( defaults to false )
--      'singleuse' ( true / false ) - falls off the level when it reaches the end of the line ( defaults to false )
--      'chain' ( int >= 1 ) - defines the number of 'links' in the chain ( defaults to 1 )

-- 'line' object
--      Must be setup in the 'movement' object layer

--      Required:
--      'name' ( string ) - a unique name that is used to associate back to the control object

-- Planned features / ideas
--      [planned] Resetable positioning ( to allow for square or circular paths )
--      [planned] Non bspline curve support ( stick to the line, no rounding )
--      [idea] Flipping platforms ( at certain points, the platform will spin, possibly knocking the player off to their death )

local anim8 = require 'vendor/anim8'
local collision  = require 'hawk/collision'
local Bspline = require 'vendor/bspline'
local game = require 'game'
local gs = require 'vendor/gamestate'
local sound = require 'vendor/TEsound'
local options = require 'options'
local utils = require 'utils'

local MovingPlatform = {}
MovingPlatform.__index = MovingPlatform

function MovingPlatform.new(node, collider, level)
    local mp = {}
    setmetatable(mp, MovingPlatform)
    mp.node = node
    mp.collider = collider
    
    mp.x = node.x
    mp.y = node.y
    mp.width = node.width
    mp.height = node.height

    mp.line = node.properties.line
    assert(mp.line, 'Moving platforms must include a \'line\' property')

    mp.direction = node.properties.direction == '-1' and -1 or 1

    mp.sprite = love.graphics.newImage( node.properties.sprite )
    assert( mp.sprite, 'Moving platforms must specify a \'sprite\' property' )

    mp.offset_x = node.properties.offset_x and node.properties.offset_x or 0
    mp.offset_y = node.properties.offset_y and node.properties.offset_y or 0
    mp.speed = node.properties.speed and node.properties.speed or 1
    mp.pos = node.properties.start and tonumber(node.properties.start) or 0.5 -- middle
    mp.showline = node.properties.showline == 'true'
    mp.moving = node.properties.touchstart ~= 'true'
    mp.singleuse = node.properties.singleuse == 'true'
    mp.restart = node.properties.restart == 'true'
    mp.noise_radius = node.properties.noise_radius and node.properties.noise_radius or nil
    mp.sfx = node.properties.sfx and node.properties.sfx or nil
    mp.allowed_offscreen = node.properties.offscreen == 'true'
    mp.chain = tonumber(node.properties.chain) or 1
    
    if node.properties.animation then
        local p = node.properties
        mp.anim_speed = p.anim_speed and tonumber(p.anim_speed) or 0.20
        mp.mode = p.mode and p.mode or 'loop'

        local g = anim8.newGrid(tonumber(p.width), tonumber(p.height), 
                                mp.sprite:getWidth(), mp.sprite:getHeight())

        mp.animation = anim8.newAnimation( mp.mode, g( unpack( utils.split( p.animation, '|' ) ) ), mp.anim_speed )
    end

    mp.velocity = {x=0, y=0}
    
    mp.level = level
    mp.map = level.map
    table.insert(mp.map.moving_platforms, mp)

    return mp
end

function MovingPlatform:enter()
    for _,x in pairs( self.map.objectgroups.movement.objects ) do
        if x.name == self.line then self.line = x end
    end
    if type(self.line) == 'string' then error( 'Moving platform could not find \'' .. self.line .. '\' movement line' ) end

    assert( self.line.polyline, 'Moving platform only knows how to follow polylines currently, sorry' )

    self.bspline = Bspline.new( getPolylinePoints( self.line ) )
    
    if self.noise_radius then
        self.engineNoise = sound.startSfx( self.sfx, nil, self.x, self.y, self.noise_radius )
    end
end

function MovingPlatform:leave()
    if self.engineNoise then
        sound.stopSfx( self.engineNoise )
    end
end

function MovingPlatform:collide(node)
    if not node.isPlayer then return end
    local player = node

    if not player.currentplatform then
        player.currentplatform = self
    end
    if not self.moving and self.pos <= 1 then
        self.moving = true
    end
end

function MovingPlatform:update(dt,player)
    local pre = { x = self.x, y = self.y }
    
    if self.moving then
        self.pos = self.pos + ( dt * ( .25 * self.speed ) * self.direction )
    end

    if self.chain > 1 and self.x - self.node.x > self.width and not self.next then
        self.next = MovingPlatform.new(self.node, self.collider, self.level )
        self.next:enter()
        self.next.chain = self.chain - 1
        self.next.moving = true
    end

    if self.moving and self.pos > 1 then
        if self.singleuse then
            self.moving = false
            self.velocity.x = 300
            self.velocity.y = -100
        elseif not self.noise_radius then
            self.pos = 1
        end
    end

    if self.pos < 0 then self.pos = 0 end
    if self.noise_radius then
        if self.pos > 1 + self.noise_radius / (self.map.width * self.map.tilewidth) then
            self.pos = -self.noise_radius / (self.map.width * self.map.tilewidth)
        end
    elseif self.moving and ( self.pos == 1 or self.pos == 0 ) and not self.noise_radius then
        self.direction = -self.direction
    end
    
    if self.noise_radius then
        if options.option_map['SFX VOLUME'].range[3] ~= 0 then
            self.engineNoise.x = self.x
        end
    end
    
    if self.singleuse and self.pos >= 1 then
        --throw it
        if self.velocity.x < 0 then
            self.velocity.x = math.min(self.velocity.x + game.friction * dt, 0)
        else
            self.velocity.x = math.max(self.velocity.x - game.friction * dt, 0)
        end
        
        self.velocity.y = self.velocity.y + ( game.gravity / 2 ) * dt

        if self.velocity.y > game.max_y then
            self.velocity.y = game.max_y
        end

        self.x = self.x + self.velocity.x * dt
        self.y = self.y + self.velocity.y * dt
    elseif self.allowed_offscreen and self.pos >= 1 then
        local p = self.bspline:eval( self.pos )
        -- determine x based on where it would have been going
        local x = self.x - ( dt * (0.25 * self.speed ) * self.map.width * self.map.tilewidth)
        self.x, self.y = x, p.y - (self.height / 2)
    else
        local p = self.bspline:eval( self.pos )
        self.x, self.y = p.x - (self.width / 2), p.y - (self.height / 2)
    end
    
    if self.animation then
        self.animation:update(dt)
    end
    
    -- move the player along with the bounding box
    if player.currentplatform == self then
        player:updatePosition(self.map, self.x - pre.x, self.y - pre.y)

        player:moveBoundingBox()
    end
                    
    if self.next then self.next:update(dt,player) end
end

function MovingPlatform:draw()
    if self.showline then love.graphics.line( unpack( self.bspline:polygon(4) ) ) end
    
    if self.animation then
        self.animation:draw( self.sprite, self.x + self.offset_x, self.y + self.offset_y)
    else
        love.graphics.draw( self.sprite, self.x + self.offset_x, self.y + self.offset_y )
    end
    
    if self.next then self.next:draw() end
end

function getPolylinePoints( poly )
    -- returns sets of coordinates that make up each line
    local x,y = poly.x, poly.y
    local coords = {}
    for _, point in ipairs(poly.polyline) do
        table.insert( coords, x + point.x )
        table.insert( coords, y + point.y )
    end
    return coords
end

return MovingPlatform


