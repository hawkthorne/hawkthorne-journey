local anim8 = require 'vendor/anim8'

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


function Sprite.new(node, collider)
    local sprite = {}
    local p = node.properties
    setmetatable(sprite, Sprite)

    sprite.sheet = load_sprite(p.sheet)

    local g = anim8.newGrid(tonumber(p.width), tonumber(p.height), 
                            sprite.sheet:getWidth(), sprite.sheet:getHeight())

    sprite.animation = anim8.newAnimation('loop', g(p.animation), 0.20)

    sprite.x = node.x
    sprite.y = node.y
    
    return sprite
end

function Sprite:update(dt)
    self.animation:update(dt)
end

function Sprite:draw()
    self.animation:draw(self.sheet, self.x, self.y)
end

return Sprite
