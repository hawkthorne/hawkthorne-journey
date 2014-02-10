local anim8 = require 'vendor/anim8'
local utils = require 'utils'

local Sprite = {}

Sprite.__index = Sprite

local sprite_cache = {}

local function load_sprite(name)
  if sprite_cache[name] then
    return sprite_cache[name]
  end

  local image = love.graphics.newImage(name)
  image:setFilter('nearest', 'nearest')
  sprite_cache[name] = image
  return image
end


function Sprite.new(node, collider, level)
    local sprite = {}
    local p = node.properties
    setmetatable(sprite, Sprite)

    assert(p.sheet, "'sheet' required for sprite node")

    sprite.sheet = load_sprite(p.sheet)

    sprite.animation = p.animation or false
    sprite.foreground = p.foreground == 'true'
    sprite.flip = p.flip == 'true'
    sprite.node = node

    if p.height and p.width then
        sprite.height = p.height
        sprite.width = p.width
    end

    if sprite.animation then
        sprite.random = p.random == 'true'
        sprite.speed = p.speed and tonumber(p.speed) or 0.20
        if sprite.random then
            sprite.mode = 'once'
        else
            sprite.mode = p.mode and p.mode or 'loop'
        end

        local g = anim8.newGrid(tonumber(p.width), tonumber(p.height), 
                                sprite.sheet:getWidth(), sprite.sheet:getHeight())

        sprite.animation = anim8.newAnimation( sprite.mode, g( unpack( utils.split( p.animation, '|' ) ) ), sprite.speed )

        if sprite.random then
            sprite.animation.status = 'stopped'
            --randomize the play interval
            local window = p.window and tonumber(p.window) or 5
            sprite.interval = (math.random(window * 100) / 100 ) + ( #sprite.animation.frames * sprite.speed)
        end
    
    end

    sprite.dt = math.random()
    sprite.x = node.x
    sprite.y = node.y
    
    sprite.moveable = p.moveable
    
    if sprite.moveable then 
      sprite.max_x = node.x + tonumber(p.max_x)
      sprite.min_x = node.x + tonumber(p.min_x)
      sprite.velocity = tonumber(p.velocity)
    end

    return sprite
end

function Sprite:update(dt)
  self.dt = self.dt + dt

  if self.random and self.dt > self.interval then
    self.dt = 0
    self.animation:gotoFrame(1)
    self.animation.status = 'playing'
  end

  if self.animation then
    self.animation:update(dt)
  end
  
  if self.moveable then
    self.x = self.x - (self.velocity * dt)
    if self.x > self.max_x or self.x < self.min_x then
      self.velocity = - self.velocity
    end
  end  
    
  
end

function Sprite:draw()
    if self.animation then
        self.animation:draw(self.sheet, self.x, self.y, 0, self.flip and -1 or 1, 1, self.flip and self.width or 0)
    else
        love.graphics.draw(self.sheet, self.x, self.y, 0, self.flip and -1 or 1, 1, self.flip and self.width or 0)
    end
end

return Sprite
