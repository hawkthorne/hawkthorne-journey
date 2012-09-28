local Image = {}

Image.__index = Image

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


function Image.new(node, collider)
    local sprite = {}
    local p = node.properties
    setmetatable(sprite, Image)

    assert(p.sheet, "'sheet' required for sprite node")
    sprite.sheet = load_sprite(p.sheet)
    sprite.foreground = p.foreground == 'true'
    sprite.x = node.x
    sprite.y = node.y
    
    return sprite
end

function Image:draw()
    love.graphics.draw(self.sheet, self.x, self.y)
end

return Image
