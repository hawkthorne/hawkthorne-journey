local controls = require 'controls'
local window = require 'window'
local Floorspaces = require 'floorspaces'

local Footprint = {}
Footprint.__index = Footprint
Footprint.isFootprint = true

function Footprint.new( player, collider )
    local footprint = {}
    setmetatable(footprint, Footprint)

    footprint.collider = collider
    footprint.width = player.bbox_width
    footprint.height = 1
    footprint.bb = collider:addRectangle( 0, 0, footprint.width, footprint.height )
    footprint.bb.node = footprint

    footprint:setFromPlayer( player )

    return footprint
end

function Footprint:getWall_x()
    local vertices = deepcopy(Floorspaces:getPrimary().vertices)
    table.insert( vertices, vertices[1] )
    table.insert( vertices, vertices[2] )
    local xpoints = {}

    for i=1,#vertices - 2, 2 do
        local ix, iy = findIntersect( 0, self.y, window.width, self.y, vertices[i], vertices[i+1], vertices[i+2], vertices[i+3] )
        if ix and ix ~= 0 and ix ~= window.width + 1 then
            table.insert( xpoints, ix )
        end
    end

    return unpack(xpoints)
end

function Footprint:setFromPlayer( player )
    self.x = player.position.x + player.width / 2 - self.width / 2
    if not player.jumping then
        self.y = player.position.y + player.height - self.height
    end
    self.bb:moveTo( self.x + self.width / 2, self.y )
end

function Footprint:correctPlayer( player )
    player.position.x = self.x + self.width / 2 - player.width / 2
    if not player.jumping then
        player.position.y = self.y + self.height - player.height
    end
end

local Floorspace = {}
Floorspace.__index = Floorspace
Floorspace.isFloorspace = true

function Floorspace.new(node, level)
    local floorspace = {}
    setmetatable(floorspace, Floorspace)

    --If the node is a polyline, we need to draw a polygon rather than rectangle
    if node.polygon then
        local vertices = {}

        for i, point in ipairs(node.polygon) do
            table.insert(vertices, node.x + point.x)
            table.insert(vertices, node.y + point.y)
        end

        floorspace.bb = level.collider:addPolygon(unpack(vertices))
        floorspace.vertices = vertices
    else
        floorspace.bb = level.collider:addRectangle( node.x, node.y, node.width, node.height )
        floorspace.verticies = { node.x, node.y, node.x + node.width, node.y, node.x + node.width, node.y + node.height, node.x, node.y + node.height }
    end
    floorspace.bb.node = floorspace
    floorspace.level = level
    floorspace.collider = level.collider
    floorspace.height = node.properties.height and tonumber(node.properties.height) or 0

    if node.properties.primary == 'true' then
        Floorspaces:setPrimary( floorspace )
    else
        Floorspaces:addObject( floorspace )
    end
    
    level.collider:setPassive(floorspace.bb)
    return floorspace
end

function Floorspace:update(dt, player)
    if not player.footprint then return end

    local fp = player.footprint
    local x1,y1,x2,y2 = self.bb:bbox()

    local y_ratio = math.clamp( 2, map( fp.y, y2, y1, 2, 5 ), 5 )
    local x_ratio = map( fp.x + fp.width / 2, x1, x2, -9, 9 ) + 15 -- no idea why these numbers work, but they do
    -- player handles left, right and jump. We have to handle up / down manually
    if controls.isDown( 'UP' ) then
        player.position.x = player.position.x - x_ratio * dt
        player.position.y = player.position.y - ( (player:deccel() * dt) / y_ratio ) * dt
    elseif controls.isDown( 'DOWN' ) then
        player.position.x = player.position.x + x_ratio * dt
        player.position.y = player.position.y + ( (player:deccel() * dt) / y_ratio ) * dt
    end

    -- update the footprint based on the player position
    fp:setFromPlayer( player )
    
    -- bound the footprints
    if self.lastknown and (
       not self.bb:contains( fp.x, fp.y ) or
       not self.bb:contains( fp.x + fp.width, fp.y + fp.height ) ) then
           fp.x = self.lastknown.x
           fp.y = self.lastknown.y
           fp:correctPlayer( player )
    end
    
    -- counteract gravity
    if fp.y < player.position.y + player.height then
        player:floor_pushback(self, fp.y + fp.height - player.height)
    end
end

function Floorspace:collide(node, dt, mtv_x, mtv_y)

    if node.isPlayer then
        local player = node
        player:setSpriteStates('default')
        -- if the player is colliding, and we don't have a footprint, create one
        --      ( this should only happen once per level )
        if not player.footprint then
            player.footprint = Footprint.new( player, self.collider )
            return
        end
    end
    
    -- only listen to footprints
    if not node.isFootprint then return end
    
    local fp = node

    if self.isPrimary and
       self.bb:contains( fp.x, fp.y ) and
       self.bb:contains( fp.x + fp.width, fp.y + fp.height ) then
        -- keep track of where the player is
        self.lastknown = {
            x = fp.x,
            y = fp.y
        }
    end
end

function Floorspace:leave()
    -- clean up any existing footprints
    if self.level.player.footprint then
        self.level.collider:remove( self.level.player.footprint.bb )
        self.level.player.footprint = nil
    end
end

return Floorspace
