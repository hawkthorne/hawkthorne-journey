local luassert = require "vendor/luassert"

local test = require "hawk/test"
local middle = require "hawk/middleclass"

local window = require "window"

local OptionsTest = middle.class("OptionsTest", test.Test)

function OptionsTest:testChangeSoundEffectVolume()
  self:visit("/options")

  self:press("DOWN", 2)
  self:press("LEFT", 5)
  self:press("RIGHT", 5)
end

function OptionsTest:testChangeMusicVolume()
  self:visit("/options")

  self:press("DOWN")
  self:press("LEFT", 5)
  self:press("RIGHT", 5)
end

function OptionsTest:testShowFPS()
  self:visit("/options")

  self:press("DOWN", 3)
  self:press("JUMP")

  self:run(function()
    luassert.is_true(window.showfps)
  end)

  self:press("JUMP")
end


function OptionsTest:testToggleFullscreen()
  self:visit("/options")

  self:press("JUMP")

  self:run(function()
    local _, _, is_fullscreen, _ = love.graphics.getMode()
    luassert.is_true(is_fullscreen)
  end)

  self:press("JUMP")

  self:run(function()
    local _, _, is_fullscreen, _ = love.graphics.getMode()
    luassert.is_false(is_fullscreen)
  end)
end


function OptionsTest:testBackToTitle()
  self:visit("/options")

  self:press("START")

  self:run(function() 
    luassert.are.equal("/title", self.app.url)
  end)
end

return OptionsTest
