local tween = require 'vendor/tween'
local camera = {}
local tween_id = nil

camera.x = 0
camera.y = 0
camera.min = {x=0, y=0}
camera.max = {x=math.huge, y=0}
camera.scaleX = 1
camera.scaleY = 1
camera.rotation = 0

function camera:set()
  love.graphics.push()
  love.graphics.rotate(-self.rotation)
  love.graphics.scale(1 / self.scaleX, 1 / self.scaleY)
  love.graphics.translate(-self.x, -self.y)
end

function camera:unset()
  love.graphics.pop()
end

function camera:move(dx, dy)
  self.x = self.x + (dx or 0)
  self.y = self.y + (dy or 0)
end

function camera:rotate(dr)
  self.rotation = self.rotation + dr
end

function camera:scale(sx, sy)
  sx = sx or 1
  self.scaleX = self.scaleX * sx
  self.scaleY = self.scaleY * (sy or sx)
end

function camera:bbox()
  return self.x, self.y, self:getWidth() + self.x, self:getHeight() + self.y
end

function camera:getWidth()
  return love.graphics.getWidth() * self.scaleX
end

function camera:getHeight()
  return love.graphics.getHeight() * self.scaleY
end

function camera:target(x, y)
  if x < self.min.x then
    x = self.min.x
  elseif x > self.max.x then
    x = self.max.x
  end

  return math.floor(x - self:getWidth() / 2), math.floor(y - self:getHeight() / 2)
end

function camera:setPosition(x, y)
  self.x = x or self.x
  self.y = y or self.y

  if self.x < self.min.x then
    self.x = self.min.x
  elseif self.x > self.max.x then
    self.x = self.max.x
  end

  self.x = math.floor(self.x)
  self.y = math.floor(self.y)
end

function camera:setScale(sx, sy)
  self.scaleX = sx or self.scaleX
  self.scaleY = sy or self.scaleY
end

return camera
