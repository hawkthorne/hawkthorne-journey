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
  return trans
end

function Transition:finished()
  return self.count > self.duration
end

function Transition:forward(callback)
  self.callback = callback
  self.sign = 1
  self.count = 0
  self.alpha = 1
end

function Transition:backward(callback)
  self.callback = callback
  self.sign = -1
  self.count = 0
  self.alpha = 0
end

function Transition:update(dt)
  self.count = self.count + dt 

  if self:finished() then
    self.callback()
    self.count = 0
    return
  end

  if self.sign > 0 then
    self.alpha = 1.0 - math.min(self.count + (dt * 5), 1.0)
  else
    self.alpha = math.min(self.count + (dt * 5), 1.0)
  end
end

function Transition:draw(x, y, width, height)
  love.graphics.setColor(0, 0, 0, self.alpha * 255)
  love.graphics.rectangle('fill', x, y, width, height)
  love.graphics.setColor(255, 255, 255, 255)
end

return Transition
