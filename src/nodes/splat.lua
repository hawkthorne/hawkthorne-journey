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

function Splat:enter()
  for k,v in pairs(self.splats) do self.splats[k]=nil end
end

function Splat:add(x,y,width,height)

  local index = math.random(3)
  local flipX = math.random(2) == 1
  local flipY = math.random(2) == 1

  table.insert(self.splats, {
    position = {
      x = x,
      y = y
    },
    width = width,
    height = height,
    wallQuad = self:wallQuad(y, height, index, flipY),
    ceilingQuad = self:ceilingQuad(y, height, index, flipY),
    floorQuad = self:floorQuad(y, height, index, flipY),
    flipX = flipX,
    flipY = flipY,
  } )

end

function Splat:wallQuad(y, height, index, flipY)
  local y = (y + height / 2 ) - self.splattersize.height / 2 + ( flipY and self.splattersize.height or 0 )
  if y + self.splattersize.height > self.ceiling.height then
    -- splat starts in ceiling
    if y < self.ceiling.height then
      return love.graphics.newQuad(
        (index-1)*self.splattersize.width, self.ceiling.height - y,
        self.splattersize.width, height - self.ceiling.height + y,
        self.splatters:getDimensions()
      )
    -- splat starts on wall
    elseif y < self.floor.y then
      return love.graphics.newQuad(
        (index-1)*self.splattersize.width, 0,
        self.splattersize.width, math.min(self.splattersize.height, self.floor.y - y),
        self.splatters:getDimensions()
      )
    end
  end
end

function Splat:ceilingQuad(y, height, index, flipY)
  local y = (y + height / 2 ) - self.splattersize.height / 2 + ( flipY and self.splattersize.height or 0 )
  -- splat starts in ceiling
  if y < self.ceiling.height then
    return love.graphics.newQuad(
      (index-1)*self.splattersize.width, 0, 
      self.splattersize.width, math.min(self.splattersize.height, self.ceiling.height - y),
      self.splatters:getDimensions()
    )
  end
end

function Splat:floorQuad(y, height, index, flipY)
local y = (y + height / 2 ) - self.splattersize.height / 2 + ( flipY and self.splattersize.height or 0 )
  if y + self.splattersize.height > self.floor.y then
    -- splatter starts on wall
    if y < self.floor.y then
      return love.graphics.newQuad(
        (index-1)*self.splattersize.width, self.floor.y - y,
        self.splattersize.width, math.min(self.floor.height, self.splattersize.height + y - self.floor.y),
        self.splatters:getDimensions()
      )
    -- splatter starts on floor
    else
      return love.graphics.newQuad(
        (index-1)*self.splattersize.width, 0,
        self.splattersize.width, self.floor.height,
        self.splatters:getDimensions()
      )
    end
  end
end

function Splat:draw()

  -- possibly do a check for existence?

  love.graphics.setColor( 255, 255, 255, 255 )

  for _,s in pairs( self.splats ) do

    local x = (s.position.x + s.width / 2 ) - self.splattersize.width / 2 + ( s.flipX and self.splattersize.width or 0 )
    local y = (s.position.y + s.height / 2 ) - self.splattersize.height / 2 + ( s.flipY and self.splattersize.height or 0 )
    local flipX = s.flipX and -1 or 1
    local flipY = s.flipY and -1 or 1

    if s.wallQuad then
      if y < self.ceiling.height then
        love.graphics.draw(self.splatters, s.wallQuad, x, self.ceiling.height, 0, flipX, flipY)
      else
        love.graphics.draw( self.splatters, s.wallQuad, x, y, 0, flipX, flipY)
      end
    end

    love.graphics.setColor( 200, 200, 200, 255 )  -- Giving darker shade to splash on ceiling and floor

    if s.floorQuad then
      if y < self.floor.y then
        love.graphics.draw(self.splatters, s.floorQuad, x, self.floor.y, 0, flipX, flipY, 
          -self.splattersize.width / 2 + ( flipY and 51 or 0 ), 0, -1, 0 )
      else
        love.graphics.draw( self.splatters, s.floorQuad, x, y, 0, flipX, flipY,
          -self.splattersize.width / 2 - ( s.flipX and 51 or 0 ), 0, -1, 0 )
      end
    end

    if s.ceilingQuad then
      love.graphics.draw( self.splatters, s.ceilingQuad, x, y, 0, flipX, flipY,
        self.splattersize.width / 2 + ( s.flipX and 51 or 0 ), 0, 1, 0 )
    end
  end

  love.graphics.setColor( 255, 255, 255, 255 )
end

return Splat
