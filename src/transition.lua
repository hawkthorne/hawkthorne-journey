local Transition = {}
Transition.__index = Transition


function Transition.new(effect, duration)
  local trans = {}
  setmetatable(trans, Transition)
  trans.count = 0
  trans.sign = 1
  trans.effect = effect
  trans.duration = duration
  trans.callback = function() return nil end
  trans.effect = love.graphics.newPixelEffect [[
    extern number alpha;
    vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 pixel_coords)
    {
        vec4 pixel = Texel(texture, texture_coords);
	pixel.a = alpha;
        return pixel;
    }
  ]]

  return trans
end

function Transition:finished()
  return self.count > self.duration
end

function Transition:forward(callback)
  self.effect:send('alpha', 1.0)
  self.callback = callback
  self.sign = 1
  self.count = 0
end

function Transition:backward(callback)
  self.effect:send('alpha', 0)
  self.callback = callback
  self.sign = -1
  self.count = 0
end

function Transition:update(dt)
  self.count = self.count + dt 

  if self:finished() then
    self.callback()
    self.count = 0
    return
  end

  if self.sign > 0 then
    self.effect:send('alpha', 1.0 - math.min(self.count + (dt * 5), 1.0))
  else
    self.effect:send('alpha', math.min(self.count + (dt * 5), 1.0))
  end
end

function Transition:draw(x, y, width, height)
  love.graphics.setPixelEffect(self.effect)
  love.graphics.setColor(0, 0, 0)
  love.graphics.rectangle('fill', x, y, width, height)
  love.graphics.setColor(255, 255, 255)
  love.graphics.setPixelEffect()
end

return Transition
