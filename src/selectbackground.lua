local window = require 'window'
local VerticalParticles = require "verticalparticles"
local CharacterStrip = require "characterstrip"

local selectBackground = {}

local slideTime = 0
local unknownFriend = nil
local strips = nil

function selectBackground.init()
end

function selectBackground.enter()
  VerticalParticles.init()

  unknownFriend = love.graphics.newImage('images/menu/insufficient_friend.png')

  selectBackground.speed = 1
  selectBackground.slideIn = false
  selectBackground.slideOut = false
  slideTime = 0;

  strips = {}

  strips[1] = CharacterStrip.new( 81,  73, 149) -- Jeff
  strips[2] = CharacterStrip.new(150, 220, 149) -- Britta
  strips[3] = CharacterStrip.new(200, 209, 149) -- Abed
  strips[4] = CharacterStrip.new(173, 135, 158) -- Annie
  strips[5] = CharacterStrip.new(149, 214, 200) -- Troy
  strips[6] = CharacterStrip.new(134,  60, 133) -- Shirley
  strips[7] = CharacterStrip.new(171,  98, 109) -- Pierce
  strips[8] = CharacterStrip.new( 80,  80,  80) -- Insufficient

  for i,s in pairs(strips) do
    s.flip = i > 4
    s.pos = (i-1) % 4
    s.ratio = -(s.pos * 2 + 1)
    s.x = window.width / 2 + ( ( 7 + (25+15) * s.pos ) * (s.flip and 1 or -1))
    s.y = 66 + (35+15) * s.pos
  end

  if not selectBackground.selected then
    selectBackground:setSelected(0,0)
  end
end

function selectBackground.leave()
  unknownFriend = nil
  strips = nil
  VerticalParticles.leave()
end

-- Renders the starry background and each strip
function selectBackground.draw()
  love.graphics.setBackgroundColor(0, 0, 0, 0)

  VerticalParticles.draw()

  for _,strip in ipairs(strips) do strip:draw() end

  love.graphics.setColor(255, 255, 255, 255)

  local x, y = strips[8]:getCharacterPos()
  love.graphics.draw(unknownFriend, x + 14, y + 10)
end

-- Updates the particle system and each strip
function selectBackground.update(dt)
  VerticalParticles.update(dt)

  sliding = selectBackground.slideIn or selectBackground.slideOut

  if not sliding then selectBackground.speed = 1 end

  if selectBackground.slideOut then
    slideTime = slideTime + (dt * selectBackground.speed)
  end

  for i,strip in ipairs(strips) do
    -- Tell the strips to slide out at the proper time
    strip.slideOut = (slideTime*4 > (i-1) % 4)
    strip:update(dt * selectBackground.speed, strips[8].ratio == 0)
  end

  -- Set 'slideIn' to false when the last strip is fully on-screen
  selectBackground.slideIn = (strips[8].ratio < 0)

  -- After a set delay, tell the caller it's safe to swap states
  return (slideTime > 1.25)
end

-- Returns the postion the strip's character should be drawing at
function selectBackground.getPosition(side, level)
  return strips[(side * 4) + (level+1)]:getCharacterPos()
end

function selectBackground.reset()
  slideTime = 0
  selectBackground.slideIn = false
  selectBackground.slideOut = false
end

function selectBackground.setSelected(side, level)
  for _,strip in pairs(strips) do strip.selected = false end
  strips[(level + 1) + (side == 1 and 4 or 0)].selected = true
  selectBackground.selected = (level + 1) + (side == 1 and 4 or 0)
end

return selectBackground
