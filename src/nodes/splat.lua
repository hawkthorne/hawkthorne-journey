local gs = require 'vendor/gamestate'

local Splat = {}
Splat.__index = Splat

local splatters = love.graphics.newImage('images/splatters.png')
local splatterSize = {width=300,height=250}
local splattersAvail = splatters:getWidth() / splatterSize.width
local quads = {
  love.graphics.newQuad(0, 0, splatterSize.width, splatterSize.height, splatters:getWidth(), splatters:getHeight()),
  love.graphics.newQuad(splatterSize.width, 0, splatterSize.width, splatterSize.height, splatters:getWidth(), splatters:getHeight()),
  love.graphics.newQuad(splatterSize.width * 2, 0, splatterSize.width, splatterSize.height, splatters:getWidth(), splatters:getHeight()),
}

function Splat.new(node)
  local splat = {}
  setmetatable(splat, Splat)
  splat.splats = {}
  splat.node = {x=0, width=0}
  return splat
end

function Splat:setup_stencils()
  -- get coords of the first ceiling and the first floor node
  -- note: this will probably have to be refactored if we use hippies anywhere besides the hallway
  self.ceiling = gs.currentState().map.objectgroups.ceiling.objects[1]
  self.floor = gs.currentState().map.objectgroups.block.objects[1]
  self.map_width = gs.currentState().map.width * gs.currentState().map.tilewidth

  self.stencils = {
    ceiling = {
      x = self.ceiling.x,
      y = self.ceiling.y,
      width = self.map_width,
      height = self.ceiling.height * 2
    },
    wall = {
      x = self.ceiling.x,
      y = self.ceiling.y + self.ceiling.height * 2,
      width = self.map_width,
      height = self.floor.y * 2 - ( self.ceiling.y + self.ceiling.height * 2 )
    },
    floor = {
      x = self.floor.x,
      y = self.floor.y * 2,
      width = self.map_width,
      height = self.floor.height * 2
    }
  }
end

function Splat:enter()
  for k,v in pairs(self.splats) do self.splats[k]=nil end
end

function Splat:add(x,y,width,height)
  table.insert(self.splats, {
    position = {
      x = x,
      y = y
    },
    width = width,
    height = height,
    index = math.random( splattersAvail ),
    flipX = math.random( 2 ) == 1,
    flipY = math.random( 2 ) == 1
  } )

  if not self.stencils then
    self:setup_stencils()
  end
end

function Splat:draw()
  if self.stencils then
    love.graphics.setColor( 255, 255, 255, 255 )

    love.graphics.setScissor( self.stencils.wall.x, self.stencils.wall.y, self.stencils.wall.width, self.stencils.wall.height)
    for _,s in pairs( self.splats ) do
      love.graphics.draw( splatters,
                 quads[s.index],
                 ( s.position.x + s.width / 2 ) - splatterSize.width / 2 + ( s.flipX and splatterSize.width or 0 ),
                 ( s.position.y + s.height / 2 ) - splatterSize.height / 2 + ( s.flipY and splatterSize.height or 0 ),
                 0,
                 s.flipX and -1 or 1,
                 s.flipY and -1 or 1 )
    end

    love.graphics.setColor( 200, 200, 200, 255 )  -- Giving darker shade to splash on ceiling and floor

    love.graphics.setScissor( self.stencils.floor.x, self.stencils.floor.y, self.stencils.floor.width, self.stencils.floor.height )
    for _,s in pairs( self.splats ) do
      love.graphics.draw( splatters,
                 quads[s.index],
                 ( s.position.x + s.width / 2 ) - splatterSize.width / 2 + ( s.flipX and splatterSize.width or 0 ),
                 ( s.position.y + s.height / 2 ) - splatterSize.height / 2 + ( s.flipY and splatterSize.height or 0 ),
                 0,
                 s.flipX and -1 or 1,
                 s.flipY and -1 or 1,
                 -splatterSize.width / 2 + ( s.flipY and 51 or 0 ), 0,
                 -1, 0 )
    end

    love.graphics.setScissor( self.stencils.ceiling.x, self.stencils.ceiling.y, self.stencils.ceiling.width, self.stencils.ceiling.height )
    for _,s in pairs( self.splats ) do
      love.graphics.draw( splatters,
                 quads[s.index],
                 ( s.position.x + s.width / 2 ) - splatterSize.width / 2 + ( s.flipX and splatterSize.width or 0 ),
                 ( s.position.y + s.height / 2 ) - splatterSize.height / 2 + ( s.flipY and splatterSize.height or 0 ),
                 0,
                 s.flipX and -1 or 1,
                 s.flipY and -1 or 1,
                 splatterSize.width / 2 - ( s.flipY and 51 or 0 ), 0,
                 1, 0 )
    end

    love.graphics.setColor( 255, 255, 255, 255 )
    love.graphics.setScissor()

  end
end

return Splat
