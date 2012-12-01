local anim8 = require 'vendor/anim8'
local Timer = require 'vendor/timer'

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

    assert(p.sheet, "'sheet' required for sprite node")

    sprite.sheet = load_sprite(p.sheet)
    
    sprite.animation = p.animation or false
    
    sprite.foreground = p.foreground == 'true'
    
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

        sprite.animation = anim8.newAnimation( sprite.mode, g( unpack( split( p.animation, '|' ) ) ), sprite.speed )

        if sprite.random then
            sprite.animation.status = 'stopped'
            --randomize the play interval
            local window = p.window and tonumber(p.window) or 5
            local interval = ( math.random( window * 100 ) / 100 ) + ( #sprite.animation.frames * sprite.speed )
            Timer.addPeriodic( interval, function()
                sprite.animation:gotoFrame(1)
                sprite.animation.status = 'playing'
            end)
        end
    
    end

    sprite.x = node.x
    sprite.y = node.y
    
    return sprite
end

function Sprite:update(dt)
    if self.dead then return end
    if self.animation then
        self.animation:update(dt)
    end
end

function Sprite:draw()
    if self.dead then return end
    if self.animation then
        self.animation:draw(self.sheet, self.x, self.y)
    else
        love.graphics.draw(self.sheet, self.x, self.y)
    end
end

return Sprite
