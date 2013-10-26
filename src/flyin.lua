local app = require 'app'
local Gamestate = require 'vendor/gamestate'
local window = require 'window'
local fonts = require 'fonts'
local TunnelParticles = require "tunnelparticles"
local sound = require 'vendor/TEsound'
local Timer = require 'vendor/timer'
local character = require 'character'
local utils = require 'utils'

local flyin = Gamestate.new()

function flyin:init( )
  TunnelParticles:init()
end

function flyin:enter( prev )
  self.flying = {}
  self.characterorder = {}

  local current = character.current()

  -- Only include greendale seven
  for _, name in pairs({"abed", "annie", "jeff", "pierce", "troy", "britta", "shirley"}) do
    if name ~= current.name then
      table.insert(self.characterorder, name)
    end
  end

  self.characterorder = utils.shuffle(self.characterorder, 5)

  table.insert(self.characterorder, current.name)

  local time = 0

  for _, name in pairs(self.characterorder) do
    Timer.add(time, function()
      table.insert(self.flying, {
        n = name,
        c = nil, --name == current.name and current.costume or character.findRelatedCostume(name),
        x = window.width / 2,
        y = window.height / 2,
        t = math.random((math.pi * 2) * 10000) / 10000,
        r = name == current.name and 0 or (math.random(4) - 1) * (math.pi / 2),
        s = 0.1,
        show = true
      })
    end)
    time = time + 0.4
  end
end

function flyin:drawCharacter(flyer, x, y, r, sx, sy, ox, oy)
  local name = flyer.n
  local costume = flyer.c

  -- find costume
  -- load image
  -- load mask
  -- draw

  --local char = self:loadCharacter(name)
  --local key = name .. char.costume

  --if not self.costumes[key] then
  --  self.costumes[key] = character.getCostumeImage(name, char.costume)
  --end

  --local image = self.costumes[key]

  --if not char.mask then
  --  char.mask = love.graphics.newQuad(0, char.offset, 48, 35,
  --                                    image:getWidth(), image:getHeight())
  --end

  --if offset then
  --  love.graphics.drawq(image, char.mask, x, y, 0, -1, 1)
  --else
  --  love.graphics.drawq(image, char.mask, x, y)
  --end
end


function flyin:draw()
  TunnelParticles.draw()

  love.graphics.circle('fill', window.width / 2, window.height / 2, 30)

  -- draw in reverse order, so the older ones get drawn on top of the newer ones
  for i = #flyin.flying, 1, -1 do
    local v = flyin.flying[i]
    if v.show then
      love.graphics.setColor(255, 255, 255, 255)

      self:drawCharacter(v, v.x, v.y, v.r - (v.r % (math.pi / 2)),
                         math.min(v.s, 5), math.min(v.s, 5), 22, 32)
      -- black mask while coming out of 'tunnel'
      if v.s <= 1 then
        love.graphics.setColor(0, 0, 0, 255 * (1 - v.s ))

        self:drawCharacter(v, v.x, v.y, v.r - (v.r % (math.pi / 2)),
                           math.min(v.s, 5), math.min(v.s, 5), 22, 32)
      end
    end
  end
end

function flyin:startGame(dt)
  local gamesave = app.gamesaves:active()
  local point = gamesave:get('savepoint', {level='studyroom', name='main'})
  Gamestate.switch(point.level, point.name)
end

function flyin:keypressed(button)
  Timer.clear()
  self:startGame()
end

function flyin:update(dt)
  TunnelParticles.update(dt)
  for k,v in pairs(flyin.flying) do
    if v.n ~= character.name then
      v.x = v.x + ( math.cos( v.t ) * dt * v.s * 90 )
      v.y = v.y + ( math.sin( v.t ) * dt * v.s * 90 )
    end
    v.s = v.s + dt * 4
    v.r = v.r + dt * 5
    if v.s >= 6 then
      v.show = false
    end
  end
  if not flyin.flying[#flyin.flying].show then
    Timer.clear()
    self:startGame()
  end
end

return flyin
