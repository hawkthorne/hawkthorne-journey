local gs = require 'vendor/gamestate'

local Splat = {}
Splat.__index = Splat

Splat.splatters = love.graphics.newImage('images/splatters.png')
Splat.splattersize = {width=300,height=250}
Splat.splattersAvail = Splat.splatters:getWidth() / Splat.splattersize.width

-- Probably shouldn't hardcode these in
-- Splats will only work in hallway
Splat.ceiling = {y = 0, height = 72}
Splat.wall = {y = 72, height = 216}
Splat.floor = {y = 288, height = 24}

function Splat.new(node)
  local splat = {}
  setmetatable(splat, Splat)
  splat.splats = {}
  splat.node = {x=0, width=0}
  return splat
end

function Splat:add(x,y,width,height)

  local index_x = math.random(6)
  local index_y = math.random(2)
  
  table.insert(self.splats, {
    position = {
      x = x,
      y = y
    },
    width = width,
    height = height,
    wallQuad = self:wallQuad(y, height, index_x, index_y),
    ceilingQuad = self:ceilingQuad(y, height, index_x, index_y),
    floorQuad = self:floorQuad(y, height, index_x, index_y),
  } )

end

function Splat:wallQuad(y, height, index_x, index_y)
  local y = (y + height / 2 ) - self.splattersize.height / 2
  if y + self.splattersize.height > self.ceiling.height then
    -- splat starts in ceiling
    if y < self.ceiling.height then
      return love.graphics.newQuad(
        (index_x-1)*self.splattersize.width, (index_y -1)*self.splattersize.height + self.ceiling.height - y,
        self.splattersize.width, self.splattersize.height - self.ceiling.height + y,
        self.splatters:getDimensions()
      )
    -- splat starts on wall
    elseif y < self.floor.y then
      return love.graphics.newQuad(
        (index_x-1)*self.splattersize.width, (index_y -1)*self.splattersize.height,
        self.splattersize.width, math.min(self.splattersize.height, self.floor.y - y),
        self.splatters:getDimensions()
      )
    end
  end
end

function Splat:ceilingQuad(y, height, index_x, index_y)
  local y = (y + height / 2 ) - self.splattersize.height / 2
  -- splat starts in ceiling
  if y < self.ceiling.height then
    return love.graphics.newQuad(
      (index_x-1)*self.splattersize.width, (index_y -1)*self.splattersize.height, 
      self.splattersize.width, math.min(self.splattersize.height, self.ceiling.height - y),
      self.splatters:getDimensions()
    )
  end
end

function Splat:floorQuad(y, height, index_x, index_y)
local y = (y + height / 2 ) - self.splattersize.height / 2
  if y + self.splattersize.height > self.floor.y then
    -- splatter starts on wall
    if y < self.floor.y then
      return love.graphics.newQuad(
        (index_x-1)*self.splattersize.width, (index_y -1)*self.splattersize.height + self.floor.y - y,
        self.splattersize.width, math.min(self.floor.height, self.splattersize.height + y - self.floor.y),
        self.splatters:getDimensions()
      )
    -- splatter starts on floor
    else
      return love.graphics.newQuad(
        (index_x-1)*self.splattersize.width, (index_y -1)*self.splattersize.height,
        self.splattersize.width, self.floor.height,
        self.splatters:getDimensions()
      )
    end
  end
end

function Splat:draw()

  love.graphics.setColor( 255, 255, 255, 255 )

  for _,s in pairs( self.splats ) do

    local x = (s.position.x + s.width / 2 ) - self.splattersize.width / 2
    local y = (s.position.y + s.height / 2 ) - self.splattersize.height / 2

    if s.wallQuad then
      if y < self.ceiling.height then
        love.graphics.draw(self.splatters, s.wallQuad, x, self.ceiling.height)
      else
        love.graphics.draw( self.splatters, s.wallQuad, x, y)
      end
    end

    love.graphics.setColor( 200, 200, 200, 255 )  -- Giving darker shade to splash on ceiling and floor

    if s.floorQuad then
      if y < self.floor.y then
        love.graphics.draw(self.splatters, s.floorQuad, x, self.floor.y)
      else
        love.graphics.draw( self.splatters, s.floorQuad, x, y)
      end
    end

    if s.ceilingQuad then
      love.graphics.draw( self.splatters, s.ceilingQuad, x, y)
    end
  end

  love.graphics.setColor( 255, 255, 255, 255 )
end

return Splat
