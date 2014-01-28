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
  self.images = {}
  self.masks = {}
  self.characterorder = {}

  self.current = character.current()

  -- Only include greendale seven
  for _, name in pairs({"abed", "annie", "jeff", "pierce", "troy", "britta", "shirley"}) do
    if name ~= self.current.name then
      table.insert(self.characterorder, name)
    end
  end

  self.characterorder = utils.shuffle(self.characterorder, 5)

  table.insert(self.characterorder, self.current.name)

  local time = 0

  for _, name in pairs(self.characterorder) do
    local costume_name = self.current.costume

    if name ~= self.current.name then
      costume_name = character.findRelatedCostume(name, self.current:getCategory())
    end

    Timer.add(time, function()
      table.insert(self.flying, {
        n = name,
        c = costume_name,
        x = window.width / 2,
        y = window.height / 2,
        t = math.random((math.pi * 2) * 10000) / 10000,
        r = name == self.current.name and 0 or (math.random(4) - 1) * (math.pi / 2),
        s = 0.1,
        show = true
      })
    end)
    time = time + 0.4
  end
end

function flyin:leave()
  self.current = nil
  self.flying = {}
  self.images = {}
  self.masks = {}
  self.characterorder = {}
  --TunnelParticles.leave()
end

function flyin:drawCharacter(flyer, x, y, r, sx, sy, ox, oy)
  local name = flyer.n
  local costume = flyer.c
  local key = name .. costume


  -- find costume
  -- load image
  -- load mask
  -- draw

  --local char = self:loadCharacter(name)
  --local key = name .. char.costume

  if not self.images[key] then
    self.images[key] = character.getCostumeImage(name, costume)
  end

  local image = self.images[key]

  if not self.masks[key] then
    self.masks[key] = love.graphics.newQuad(11 * 48, 4 * 48, 48, 48,
                                            image:getWidth(), image:getHeight())
  end

  local mask = self.masks[key]

  love.graphics.draw(image, mask, x, y, r, sx, sy, ox, oy)
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
  Gamestate.switch('splash')
end

function flyin:keypressed(button)
  Timer.clear()
  if button == "START" then
    Gamestate.switch("start")
  else
    self:startGame()
  end
end

function flyin:update(dt)
  TunnelParticles.update(dt)
  for k,v in pairs(flyin.flying) do
    if v.n ~= self.current.name then
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
