local Platform = require 'nodes/platform'
local Bspline = require 'vendor/bspline'

local MovingPlatform = {}
MovingPlatform.__index = MovingPlatform

function MovingPlatform.new(node, collider)
    local mp = {}
    setmetatable(mp, MovingPlatform)
    mp.node = node
    mp.x = node.x
    mp.y = node.y
    mp.width = node.width
    mp.height = node.height

    mp.line = node.properties.line
    assert(mp.line, 'Moving platforms must include a \'line\' property')

    for _,x in pairs( node.layer.map.objectLayers.movement.objects ) do
        if x.name == mp.line then mp.line = x end
    end
    if type(mp.line) == 'string' then error( 'Moving platform could not find \'' .. mp.line .. '\' movement line' ) end

    assert( mp.line.polyline, 'Moving platform only knows how to follow polylines currently, sorry' )

    mp.bspline = Bspline.new( getPolylinePoints( mp.line ) )
    mp.direction = 1

    mp.sprite = love.graphics.newImage( node.properties.sprite )
    assert( mp.sprite, 'Moving platforms must specify a \'sprite\' property' )

    mp.offset_x = node.properties.offset_x and node.properties.offset_x or 0
    mp.offset_y = node.properties.offset_y and node.properties.offset_y or 0
    mp.speed = node.properties.speed and node.properties.speed or 1
    mp.pos = node.properties.start and node.properties.start or 0.5 -- middle
    mp.showline = node.properties.showline == 'true'

    mp.platform = Platform.new( node, collider )

    return mp
end

function MovingPlatform:update(dt,player)
    self.pos = self.pos + ( dt * ( .25 * self.speed ) * self.direction )
    if self.pos > 1 then self.pos = 1 end
    if self.pos < 0 then self.pos = 0 end
    if self.pos == 1 or self.pos == 0 then
        self.direction = -self.direction
    end

    local pre = { x = self.x, y = self.y }

    local p = self.bspline:eval( self.pos )
    self.x, self.y = p.x - (self.width / 2), p.y - (self.height / 2)

    -- move the player along with the bounding box
    if self.platform.player_touched then
        player.position.x = player.position.x + ( self.x - pre.x )
        player.position.y = player.position.y + ( self.y - pre.y )
        player:moveBoundingBox()
    end

    -- update the bounding box
    self.platform.bb:moveTo( self.x + self.width / 2,
                             self.y + (self.height / 2) + 2 )
end

function MovingPlatform:draw()
    if self.showline then love.graphics.line( unpack( self.bspline:polygon(4) ) ) end
    
    love.graphics.draw( self.sprite, self.x + self.offset_x, self.y + self.offset_y )
end

function getPolylinePoints( poly )
    -- returns sets of coordinates that make up each line
    local x,y = poly.x, poly.y
    local coords = {}
    for i = 1, #poly.polyline, 2 do
        table.insert( coords, x + poly.polyline[i] )
        table.insert( coords, y + poly.polyline[i+1] )
    end
    return coords
end

function lerp(a,b,t) return a+(b-a)*t end

return MovingPlatform


