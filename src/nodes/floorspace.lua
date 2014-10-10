local window = require 'window'
local Floorspaces = require 'floorspaces'
local game = require 'game'
local utils = require 'utils'

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

    footprint:setFromPlayer( player, 0 )

    return footprint
end

function Footprint:getWall_x()
    local vertices = utils.deepcopy(Floorspaces:getPrimary().vertices)
    table.insert( vertices, vertices[1] )
    table.insert( vertices, vertices[2] )
    local xpoints = {}

    for i=1,#vertices - 2, 2 do
        local ix, iy = utils.findIntersect( 0, self.y, window.width, self.y, vertices[i], vertices[i+1], vertices[i+2], vertices[i+3] )
        if ix and ix ~= 0 and ix ~= window.width + 1 then
            table.insert( xpoints, ix )
        end
    end
    
    table.sort(xpoints)
    
    return unpack(xpoints)
end

function Footprint:setFromPlayer( player, height )
    self.x = player.position.x + player.character.bbox.width / 2 - self.width / 2
    if not self.y or not player.jumping then
        self.y = player.position.y + player.character.bbox.height - self.height + height
    end
    self.offset = height
    self:moveBoundingBox()
end

function Footprint:within( floorspace )
    return floorspace.bb:contains( self.x, self.y ) and
           floorspace.bb:contains( self.x + self.width, self.y ) and
           floorspace.bb:contains( self.x, self.y + self.height ) and
           floorspace.bb:contains( self.x + self.width, self.y + self.height )
end

function Footprint:correctPlayer( player, height )
    player.position.x = self.x + self.width / 2 - player.character.bbox.width / 2
    if not player.jumping then
        player.position.y = self.y + self.height - player.character.bbox.height - height
    end
end

function Footprint:moveBoundingBox()
    self.bb:moveTo( self.x + self.width / 2, self.y )
end

function Footprint:draw()
    love.graphics.setColor( 0, 0, 0, 20 )
    love.graphics.line( self.x, self.y-1-self.offset, self.x + self.width, self.y-1-self.offset )
    love.graphics.line( self.x+1, self.y-self.offset, self.x + self.width+1, self.y-self.offset )
    love.graphics.line( self.x, self.y+1-self.offset, self.x + self.width, self.y+1-self.offset )
    love.graphics.setColor( 0, 0, 0, 80 )
    love.graphics.line( self.x, self.y-self.offset, self.x + self.width, self.y-self.offset )
    love.graphics.setColor( 255, 255, 255, 255 )
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
    floorspace.node = node
    floorspace.blocks = node.properties.blocks == 'true'
    if floorspace.blocks and floorspace.height == 0 then floorspace.height = 20 end

    level.collider:setPassive(floorspace.bb)
    return floorspace
end

function Floorspace:enter()
    local player = self.level.player
    if self.node.properties.primary == 'true' then
        Floorspaces:setPrimary( self )
        -- if the player is colliding, and we don't have a footprint, create one
        --      ( this should only happen once per level )
        if not player.footprint then
            player.footprint = Footprint.new( player, self.collider )
            player.velocity = {x=0,y=0}
        end
        local fp = player.footprint
        if not fp:within( self ) and not player.jumping then
            -- if the footprint isn't within the primary floorspace, then move the footprint straight down until it is. If the distance is far enough, make the player fall
            local dst = 0
            while not fp:within( self ) do
                fp.y = fp.y + 1
                dst = dst + 1
            end
            if dst > 10 then player.jumping = true end
            self.lastknown = {x=fp.x,y=fp.y}
        end
    else
        Floorspaces:addObject( self )
    end
    if player.footprint and self.lastknown then
        player.footprint.x = self.lastknown.x
        player.footprint.y = self.lastknown.y
    end
end

function Floorspace:leave()
    -- clean up any existing footprints
    if self.level.player.footprint then
        self.level.collider:remove( self.level.player.footprint.bb )
        self.level.player.footprint = nil
        Floorspaces:init()
    end
end

function Floorspace:update(dt, player)
    if not player.footprint then return end
    if not Floorspaces:getActive() then return end

    local controls = player.controls
    local fp = player.footprint
    local x1,y1,x2,y2 = self.bb:bbox()

    -- player handles left, right and jump. We have to handle up / down manually
    if self.isActive then
        local y_ratio = utils.clamp( 1.5, utils.map( fp.y, y1, y2, 1.5, 3 ), 3 )
        
        if controls:isDown( 'UP' ) and not player.controlState:is('ignoreMovement') then
            if player.jumping then
                fp.y = fp.y - ( game.accel * dt ) / ( y_ratio * 2 )
            elseif player.velocity.y > 0 then
                player.velocity.y = player.velocity.y - (game.deccel * dt) / y_ratio
            elseif player.velocity.y > -game.max_y / y_ratio then
                player.velocity.y = player.velocity.y - (game.accel * dt) / y_ratio
                if player.velocity.y < -game.max_y / y_ratio then
                    player.velocity.y = -game.max_y / y_ratio
                end
            end
        elseif controls:isDown( 'DOWN' ) and not player.controlState:is('ignoreMovement') then
            if player.jumping then
                fp.y = fp.y + ( game.accel * dt ) / ( y_ratio * 2 )
            elseif player.velocity.y < 0 then
                player.velocity.y = player.velocity.y + (game.deccel * dt) / y_ratio
            elseif player.velocity.y < game.max_y / y_ratio then
                player.velocity.y = player.velocity.y + (game.accel * dt) / y_ratio
                if player.velocity.y > game.max_y / y_ratio then
                    player.velocity.y = game.max_y / y_ratio
                end
            end
        else
            if player.velocity.y < 0 then
                player.velocity.y = math.min(player.velocity.y + ( game.friction * dt ) / y_ratio, 0)
            else
                player.velocity.y = math.max(player.velocity.y - ( game.friction * dt ) / y_ratio, 0)
            end
        end

        -- update the footprint based on the player position
        fp:setFromPlayer( player, self.height )
    end

    if self.isPrimary then
        -- bound the footprint
        if self.lastknown and
            not fp:within( self ) or
            fp.isBlocked then
                if not player.jumping then
                   player.velocity = {x=0,y=0}
                end
                if not self.lastknown then
                    self.lastknown = {
                        x = fp.x,
                        y = fp.y
                    }   
                end
                fp.x = self.lastknown.x
                fp.y = self.lastknown.y
                fp:correctPlayer( player, Floorspaces:getActive().height )
                fp:moveBoundingBox()
                fp.isBlocked = false
        end
    end

    if self.isActive then
        -- counteract gravity
        if fp.y - self.height < player.position.y + player.character.bbox.height then
            player.position.y = fp.y - self.height + fp.height - player.character.bbox.height
            if player.jumping and player.velocity.y > 0 then player.velocity.y = 0 end
            player:moveBoundingBox()
            player.jumping = false
            player.rebounding = false
            player:impactDamage()
            player:restore_solid_ground()
            fp:correctPlayer( player, self.height )
            fp:moveBoundingBox()
        end
    end
end

function Floorspace:collide(node, dt, mtv_x, mtv_y)
    -- only listen to footprints
    if not node.isFootprint then return end

    local active = Floorspaces:getActive()
    if not active then return end
    
    local fp = node
    local player = self.level.player
    
    if active.height < self.height - 10 and -- stairs
        ( not player.jumping or -- running into
          ( fp.y - ( player.position.y + player.character.bbox.height ) < self.height ) -- not jumping high enough
        ) then
        fp.isBlocked = true

        if Floorspaces:getPrimary().lastknown then
          Floorspaces:getPrimary().lastknown = {
              x = Floorspaces:getPrimary().lastknown.x + mtv_x * 1.01,
              y = Floorspaces:getPrimary().lastknown.y + mtv_y * 1.01
          }
        end
    end

    if not self.isPrimary and not fp.isBlocked and not self.blocks then
        if Floorspaces:getPrimary().isActive then
            Floorspaces:setActive( self )
            fp:correctPlayer( self.level.player, self.height )
        end
    else
        -- primary only
        if not fp.isBlocked and
           fp:within( self ) then
            -- keep track of where the player is
            self.lastknown = {
                x = fp.x,
                y = fp.y
            }        
        end
    end
end

function Floorspace:collide_end( node, dt )
    if not node.isFootprint then return end
    if not self.isPrimary then
        self.isActive = false
    end
    
    local onObject = false
    for k,v in pairs(Floorspaces.objects) do
        if v.isActive then onObject = true end
    end
    if not onObject then
        -- not on an object anymore
        local pri = Floorspaces:getPrimary()
        if not pri then return end
        local player = pri.level.player
        if node.y - ( player.position.y + player.character.bbox.height ) > 5 then player.jumping = true end
        Floorspaces:setActive( pri )
        node:correctPlayer( pri.level.player, pri.height )
    end
end

return Floorspace
