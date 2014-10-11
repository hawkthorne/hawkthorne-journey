-- Functions the same as a regular sprite, but will take into account the height of the node and tile the animation.

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
  assert(p.width, "'width' required for sprite node")
  assert(p.height, "'height' required for sprite node")
  assert(p.animation, "'animation' required for sprite node")

  sprite.sheet = load_sprite(p.sheet)

  sprite.random = p.random == 'true'

  sprite.speed = p.speed and tonumber(p.speed) or 0.20

  sprite.nheight = node.height
  sprite.height = p.height

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

  sprite.x = node.x
  sprite.y = node.y

  return sprite
end

function Sprite:update(dt)
  self.animation:update(dt)
end

function Sprite:draw()
  -- self.animation:draw(self.sheet, self.x, self.y)
  for i = 0, ( self.nheight / self.height ) - 1, 1 do
    self.animation:draw(self.sheet, self.x, self.y + ( i * self.height))
  end
end

function join(_tbl,_delim)
  _delim = _delim or ''
  local _str = ''
  for n,v in pairs(_tbl) do
    _str = _str .. v
    if n ~= #_tbl then
      _str = _str .. _delim
    end
  end
  return _str
end

function split(str, pat)
  local t = {}  -- NOTE: use {n = 0} in Lua-5.0
  local fpat = "(.-)" .. pat
  local last_end = 1
  local s, e, cap = str:find(fpat, 1)
  while s do
    if s ~= 1 or cap ~= "" then
      table.insert(t,cap)
    end
    last_end = e+1
    s, e, cap = str:find(fpat, last_end)
  end
  if last_end <= #str then
    cap = str:sub(last_end)
    table.insert(t, cap)
  end
  return t
end

return Sprite
